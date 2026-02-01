<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { publicApi, phpApi } from '@/utils/publicApi';
import { parsePublicFile } from '@/utils/parseFile';
import { useRecipeStore } from '@/stores/recipeEditor';
import { useAuthStore } from '@/stores/authStore';

// 元件引用
import RecipeSteps from '../../components/workspace/recipedetail/RecipeSteps.vue';
import NutritionCard from '../../components/workspace/recipedetail/NutritionCard.vue';
import RecipeIngredients from '../../components/workspace/recipedetail/RecipeIngredients.vue';
import RecipeComments from '../../components/workspace/recipedetail/RecipeComments.vue';
import CookSnap from '../../components/workspace/recipedetail/CookSnap.vue';
import RecipeIntro from '../../components/workspace/recipedetail/RecipeIntro.vue';
import RecipeReportModal from '@/components/workspace/recipedetail/modals/RecipeReportModal.vue';
import RelatedRecipes from '@/components/workspace/recipedetail/RelatedRecipes.vue';

const route = useRoute();
const router = useRouter();
const recipeStore = useRecipeStore();
const authStore = useAuthStore();

// --- 1. 響應式資料狀態 ---
const rawRecipe = ref(null);
const rawIngredients = ref([]);
const rawSteps = ref([]);
const servings = ref(1);
const isLoading = ref(true);

const isLiked = ref(false);
const localLikesOffset = ref(0); // 本地模擬按讚增減

const isPreviewMode = computed(() => route.query.mode === 'preview');
const isReportModalOpen = ref(false);

const getSmartImageUrl = (url) => {
    if (!url) return '';
    const urlStr = String(url);
    if (urlStr.startsWith('data:') || urlStr.startsWith('blob:') || urlStr.startsWith('http')) return urlStr;
    return parsePublicFile(urlStr);
};

const snapsData = ref([]);
const commentList = ref([]);

// 核心抓取

const fetchData = async () => {
    isLoading.value = true;
    const recipeId = Number(route.params.id);

    // --- 1. 預覽模式處理 (全新創建且無 ID) ---
    if (isPreviewMode.value && !recipeId && recipeStore.previewData) {
        try {
            const preview = recipeStore.previewData;
            const resIngMaster = await publicApi.get('data/recipe/ingredients.json');
            const masterIng = resIngMaster.data || [];
            const previewServings = Math.max(1, Number(preview.recipe_servings || preview.servings || 1));

            rawRecipe.value = {
                recipe_id: 0,
                recipe_title: preview.title || preview.recipe_title || '未命名食譜',
                recipe_description: preview.description || preview.recipe_description || '',
                recipe_image_url: preview.coverImg || preview.recipe_cover_image,
                recipe_difficulty: preview.difficulty || 1,
                recipe_total_time: preview.totalTime || 30,
                recipe_servings: previewServings,
                recipe_likes: 0,
                author_name: authStore.user?.user_name || '您的預覽',
                tags: preview.recipe_tags || preview.tags || []
            };

            rawIngredients.value = (preview.ingredients || []).map(ing => {
                const name = ing.name || ing.ingredient_name || "";
                const master = masterIng.find(m => m.ingredient_name.trim() === name.trim());
                const unit = ing.unit || ing.unit_name || master?.unit_name || '份';
                const isWeightUnit = ['g', '克', 'ml', '毫升'].includes(unit.toLowerCase());

                return {
                    ...ing,
                    ingredient_name: name,
                    amount: Number(ing.amount || 0),
                    unit_name: unit,
                    gram_conversion: isWeightUnit ? 1 : Number(master?.gram_conversion || ing.gram_conversion || 1),
                    kcal_per_100g: Number(master?.kcal_per_100g || ing.kcal_per_100g || 0),
                    protein_per_100g: Number(master?.protein_per_100g || ing.protein_per_100g || 0),
                    fat_per_100g: Number(master?.fat_per_100g || ing.fat_per_100g || 0),
                    carbs_per_100g: Number(master?.carbs_per_100g || ing.carbs_per_100g || 0)
                };
            });

            rawSteps.value = (preview.steps || []).sort((a, b) => (a.step_order || 0) - (b.step_order || 0));
            servings.value = previewServings;
            isLoading.value = false;
            return;
        } catch (err) {
            console.error('預覽資料處理失敗:', err);
        }
    }

    // --- 2. 正式模式：呼叫 PHP API 與 輔助 JSON ---
    try {
        const [resDetail, resG, resU, resC] = await Promise.all([
            phpApi.get(`recipes/recipe_detail_get.php?recipe_id=${recipeId}`),
            publicApi.get('data/social/gallery.json'),
            publicApi.get('data/user/users.json'),
            recipeId ? phpApi.get(`social/comment.php?recipe_id=${recipeId}`) : Promise.resolve({ data: [] })
        ]);

        if (resDetail.data && resDetail.data.success) {
            const serverData = resDetail.data.data;

            // A. 食譜主資訊 (整合 PHP 的 main 與 tags)
            rawRecipe.value = {
                ...serverData.main,
                tags: serverData.tags || []
            };

            // B. 食材處理 (確保計算屬性需要的欄位存在)
            rawIngredients.value = (serverData.ingredients || []).map(ing => {
                const unit = ing.unit_name || '份';
                const isWeightUnit = ['g', '克', 'ml', '毫升'].includes(unit.toLowerCase());
                return {
                    ...ing,
                    ingredient_name: ing.ingredient_name,
                    unit_name: unit,
                    gram_conversion: isWeightUnit ? 1 : Number(ing.gram_conversion || 1),
                    kcal_per_100g: Number(ing.kcal_per_100g || 0),
                    protein_per_100g: Number(ing.protein_per_100g || 0),
                    fat_per_100g: Number(ing.fat_per_100g || 0),
                    carbs_per_100g: Number(ing.carbs_per_100g || 0)
                };
            });

            // C. 步驟處理
            rawSteps.value = (serverData.steps || []).sort((a, b) =>
                (Number(a.step_order) || 0) - (Number(b.step_order) || 0)
            );

            servings.value = Number(rawRecipe.value.recipe_servings || 1);
        } else {
            console.error('PHP 回傳失敗:', resDetail.data?.message);
        }

        // --- 3. Gallery (CookSnap) 處理 ---
        if (resG.data) {
            const API_BASE_URL = 'http://localhost:8888/recimo_api/';
            snapsData.value = resG.data
                .filter(item => Number(item.RECIPE_ID) === recipeId)
                .map(item => {
                    let finalImg = '';
                    const rawUrl = item.GALLERY_URL || '';
                    if (rawUrl.includes(':\\')) {
                        const parts = rawUrl.split('recimo_api\\');
                        const relativePath = parts[1] ? parts[1].replace(/\\/g, '/') : '';
                        finalImg = `${API_BASE_URL}${relativePath}`;
                    } else {
                        finalImg = getSmartImageUrl(rawUrl);
                    }
                    return {
                        id: item.GALLERY_ID,
                        url: finalImg,
                        comment: item.GALLERY_TEXT,
                        createdAt: item.UPLOAD_AT,
                        userId: item.USER_ID,
                        userName: resU.data?.find(u => u.user_id === item.USER_ID)?.user_name || '熱心用戶'
                    };
                });
        }

        // --- 4. 留言區處理 ---
        if (resC.data && Array.isArray(resC.data)) {
            commentList.value = resC.data.map(c => {
                const userData = resU.data?.find(u => u.user_id === c.user_id);
                return {
                    comment_id: c.comment_id,
                    userId: c.user_id,
                    userName: userData?.user_name || 'Recimo用戶',
                    handle: `user_${c.user_id}`,
                    userAvatar: getSmartImageUrl(userData?.user_image),
                    content: c.comment_text,
                    time: c.comment_at,
                    likes: Number(c.like_count || 0),
                };
            });
        }

    } catch (err) {
        console.error('抓取失敗:', err);
    } finally {
        isLoading.value = false;
    }
};

// --- 3. 計算屬性 ---
const displayRecipeLikes = computed(() => {
    const baseLikes = Number(rawRecipe.value?.recipe_likes || 0);
    return baseLikes + localLikesOffset.value;
});

const ingredientsData = computed(() => {
    if (!rawRecipe.value) return [];
    const originalServings = Math.max(1, Number(rawRecipe.value.recipe_servings || 1));
    const scale = servings.value / originalServings;

    return rawIngredients.value.map(item => ({
        INGREDIENT_NAME: item.ingredient_name,
        // 確保 amount 是數字，避免乘法失敗
        amount: (Number(item.amount || 0) * scale).toFixed(1),
        unit_name: item.unit_name,
        // 🏆 關鍵修正：確保這裡能抓到後端的 remark 欄位
        note: item.remark || item.note || ''
    }));
});

const nutritionWrapper = computed(() => {
    if (!rawRecipe.value || rawIngredients.value.length === 0) return [];
    const originalServings = Math.max(1, Number(rawRecipe.value.recipe_servings || 1));
    let totalKcal = 0, totalP = 0, totalF = 0, totalC = 0;

    rawIngredients.value.forEach(ing => {
        const amount = Number(ing.amount || 0);
        const unitWeight = Number(ing.gram_conversion || 1);
        const totalGram = amount * unitWeight;
        const ratio = totalGram / 100;

        totalKcal += (Number(ing.kcal_per_100g) || 0) * ratio;
        totalP += (Number(ing.protein_per_100g) || 0) * ratio;
        totalF += (Number(ing.fat_per_100g) || 0) * ratio;
        totalC += (Number(ing.carbs_per_100g) || 0) * ratio;
    });

    const scale = servings.value / originalServings;

    return [{
        calories_per_100g: Math.round(totalKcal * scale),
        protein_per_100g: Number((totalP * scale).toFixed(1)),
        fat_per_100g: Number((totalF * scale).toFixed(1)),
        carbs_per_100g: Number((totalC * scale).toFixed(1)),
        amount: 1,
        unit_weight: 1
    }];
});

const recipeIntroData = computed(() => {
    if (!rawRecipe.value) return null;
    const r = rawRecipe.value;
    return {
        id: r.recipe_id,
        title: r.recipe_title,
        image: getSmartImageUrl(r.recipe_image_url),
        time: formatTime(r.recipe_total_time),
        difficulty: r.recipe_difficulty || 1,
        description: r.recipe_descreption || r.recipe_description || '暫無簡介',
        tags: r.tags || []
    };
});

const stepsData = computed(() => {
    return rawSteps.value.map((s, index) => ({
        id: s.step_id || `s-${index}`,
        title: s.step_title || `步驟 ${index + 1}`,
        content: s.step_content || '',
        image: getSmartImageUrl(s.step_image_url),
        time: s.step_total_time || ''
    }));
});

// --- 4. 互動函式 ---
const onReportSubmit = (reportForm) => {
    console.log('收到檢舉內容:', reportForm);
    isReportModalOpen.value = false;
    alert('感謝您的回饋，我們已收到檢舉。');
};

const handleShare = () => {
    if (isPreviewMode.value) return;
    const shareData = {
        title: rawRecipe.value?.recipe_title,
        text: rawRecipe.value?.recipe_description,
        url: window.location.href,
    };

    if (navigator.share) {
        navigator.share(shareData).catch((err) => console.log('分享失敗', err));
    } else {
        navigator.clipboard.writeText(window.location.href);
        alert('網址已複製到剪貼簿！');
    }
};

const backToEdit = () => {
    // 1. 優先從 URL query 抓取，如果沒有則嘗試從 Store 抓
    const editId = route.query.editId || recipeStore.previewData?.recipe_id;
    const action = route.query.action; // 'adapt' 或 undefined (創建)

    // 2. 判斷跳轉路徑
    if (action === 'adapt' && editId) {
        // 🚀 改編模式：返回原本的改編編輯頁
        router.push({
            path: '/workspace/edit-recipe',
            query: { editId: editId, action: 'adapt' }
        });
    } else if (editId && editId !== '0') {
        // 📝 一般編輯模式：返回該食譜編輯頁
        router.push({
            path: '/workspace/edit-recipe',
            query: { editId: editId }
        });
    } else {
        // ✨ 全新創建模式：返回空白編輯頁
        router.push('/workspace/edit-recipe');
    }
};

const handleServingsChange = (newVal) => {
    servings.value = Math.max(1, newVal);
};

const formatTime = (timeVal) => {
    if (!timeVal || timeVal === 0) return '30 分鐘';
    const timeStr = String(timeVal);
    if (timeStr.includes(':')) {
        const [h, m] = timeStr.split(':').map(n => parseInt(n, 10) || 0);
        return h === 0 ? `${m} 分鐘` : `${h} 小時 ${m} 分鐘`;
    }
    return `${timeStr} 分鐘`;
};

const toggleRecipeLike = () => {
    if (isPreviewMode.value) return;
    isLiked.value = !isLiked.value;
    localLikesOffset.value = isLiked.value ? 1 : 0;
};

const handleGoToEdit = () => {
    const currentId = isPreviewMode.value ? (route.query.editId) : (rawRecipe.value?.recipe_id);
    router.push({
        path: '/workspace/edit-recipe',
        query: {
            editId: currentId,
            action: isPreviewMode.value ? route.query.action : 'adapt'
        }
    });
};

const toggleWorkspaceTopBar = (show) => {
    const topBar = document.querySelector('.workspace-top-bar');
    if (topBar) topBar.style.display = show ? '' : 'none';
};


const handlePostComment = async (content) => {
    // 檢查登入狀態與內容
    if (!authStore.user) return alert('請先登入');
    if (!content || !content.trim()) return;

    // 取得正確的 user_id (相容不同 store 結構)
    const userId = authStore.user.user_id || authStore.user.id;

    try {
        const payload = {
            action: 'post',
            recipe_id: Number(route.params.id),
            user_id: userId,
            content: content
        };

        console.log("前端送出的資料:", payload); // 除錯用

        const response = await phpApi.post('social/comment.php', payload);

        if (response.data.success) {
            fetchData(); // 成功後重新整理列表
        } else {
            alert('失敗：' + response.data.message);
        }
    } catch (err) {
        console.error('API 錯誤:', err.response?.data || err);
        alert('發佈失敗，請稍後再試');
    }
};

// 點讚留言 (配合 PHP action: 'like')
const handleLikeComment = async (commentId, type) => {
    if (!authStore.user) return alert('登入後即可點讚');

    try {
        // type 由子組件傳回 'like' 或 'dislike'
        await phpApi.post('social/comment.php', {
            action: 'like',
            comment_id: commentId,
            type: type
        });

        // 本地立即更新 UI 數字 (選用，或直接 fetchData)
        const target = commentList.value.find(c => c.comment_id === commentId);
        if (target) {
            target.likes = type === 'like' ? target.likes + 1 : Math.max(0, target.likes - 1);
        }
    } catch (err) {
        console.error('點讚失敗:', err);
    }
};

const handleDeleteComment = async (commentId) => {
    if (!authStore.user) return alert('請先登入');
    if (!confirm('確定要刪除這則留言嗎？')) return;

    // 確保抓到正確的 ID 欄位
    const userId = authStore.user.user_id || authStore.user.id;

    try {
        // 建議 URL 參數加上 timestamp 避免快取，並明確指定 comment_id
        const response = await phpApi.delete(`social/comment.php`, {
            params: {
                comment_id: commentId,
                user_id: userId
            }
        });

        if (response.data.success) {
            alert('留言已刪除');
            fetchData(); // 重新整理列表
        } else {
            alert('刪除失敗：' + (response.data.message || '未知錯誤'));
        }
    } catch (err) {
        console.error('刪除請求出錯:', err);
        // 檢查是否為 405 Method Not Allowed 或 403 Forbidden
        alert('刪除失敗，請檢查網路或權限');
    }
};

onMounted(() => {
    fetchData();
    if (isPreviewMode.value) toggleWorkspaceTopBar(false);
});
onUnmounted(() => toggleWorkspaceTopBar(true));

watch(() => [route.params.id, route.query.mode], () => fetchData());
</script>

<template>
    <div v-if="isPreviewMode" class="preview-sticky-bar">
        <div class="container">
            <div class="row">
                <div class="col-12">
                    <div class="bar-content">
                        <span class="p-p1">✨ 正在預覽食譜草稿（尚未儲存）</span>
                        <button class="exit-preview-btn p-p2" @click="backToEdit">返回編輯</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="recipe-container-root" v-if="!isLoading && rawRecipe" :class="{ 'preview-padding': isPreviewMode }">
        <main class="container">
            <div class="title-content fade-up" style="--delay: 1">
                <div class="zh-h2">
                    <i-material-symbols-restaurant-rounded class="main-icon" />
                    {{ recipeIntroData.title }}
                </div>
                <div class="icon-group" :class="{ 'is-preview': isPreviewMode }">
                    <div class="action-item" :class="{ 'active': isLiked }" @click="toggleRecipeLike">
                        <i-material-symbols-thumb-up-rounded v-if="isLiked" class="action-icon" />
                        <i-material-symbols-thumb-up-outline-rounded v-else class="action-icon" />
                        <span class="count-text">{{ displayRecipeLikes }}</span>
                    </div>

                    <div class="action-item" @click="handleShare">
                        <i-material-symbols-share-outline class="action-icon" />
                    </div>

                    <div class="action-item" @click="handleGoToEdit">
                        <i-material-symbols-edit class="action-icon" />
                    </div>

                    <div class="action-item" @click="isReportModalOpen = true">
                        <i-material-symbols-error-outline-rounded class="action-icon report-btn" />
                    </div>

                    <div v-if="!isPreviewMode" class="adapt-btn-wrapper">
                        <router-link :to="`/workspace/modify-recipe/${rawRecipe.recipe_id}`">
                            <BaseBtn title="改編一覽" variant="outline" height="40" class="w-auto" />
                        </router-link>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-7 col-lg-12">
                    <RecipeIntro :info="recipeIntroData" :is-preview="isPreviewMode" class="fade-up"
                    style="--delay: 2" />

                    <div class="d-lg-none">
                        <section class="mb-10 fade-up" style="--delay: 3">
                            <NutritionCard :servings="servings" :ingredients="nutritionWrapper"
                                @change-servings="handleServingsChange" />
                        </section>
                        <section class="mb-10 fade-up" style="--delay: 4">
                            <RecipeIngredients :servings="servings" :list="ingredientsData" />
                        </section>
                    </div>

                    <section class="mb-10 steps-section fade-up" style="--delay: 5">
                        <RecipeSteps :steps="stepsData" />
                    </section>
                </div>

                <div class="col-5 col-lg-12">
                    <div class="d-none-lg">
                        <section class="mb-10 fade-up" style="--delay: 3">
                            <NutritionCard :servings="servings" :ingredients="nutritionWrapper"
                                @change-servings="handleServingsChange" />
                        </section>
                        <section class="mb-10 fade-up" style="--delay: 4">
                            <RecipeIngredients :servings="servings" :list="ingredientsData" />
                        </section>
                    </div>
                    <section v-if="!isPreviewMode" class="mb-10 fade-up" style="--delay: 6">
                        <section v-if="!isPreviewMode" class="mb-10 fade-up" style="--delay: 6">
                            <RecipeComments :list="commentList" @post-comment="handlePostComment"
                                @like-comment="handleLikeComment" @delete-comment="handleDeleteComment" />
                        </section>
                    </section>
                </div>

                <div v-if="!isPreviewMode" class="col-12 cook-snap-full fade-up" style="--delay: 7">
                    <section class="mb-10 content-wrapper">
                        <CookSnap :list="snapsData" @post-snap="handlePostSnap" />
                    </section>
                </div>
            </div>
        </main>
    </div>

    <div v-else-if="isLoading" class="loading-state">
        <p>正在為您準備食譜資料...</p>
    </div>
    <div v-else class="error-state">
        <p>抱歉，找不到該食譜資料 (ID: {{ route.params.id }})。</p>
        <router-link to="/">返回首頁</router-link>
    </div>

    <RecipeReportModal v-model="isReportModalOpen" :targetData="{
        title: recipeIntroData?.title,
        content: recipeIntroData?.description,
        // 🏆 這裡確保傳入作者名稱
        userName: rawRecipe?.author_name || '未知作者',
        // 🏆 關鍵：新增傳入 author_id，這樣 Modal 才能判斷是否為官方
        author_id: rawRecipe?.author_id || rawRecipe?.AUTHOR_ID,
        image: recipeIntroData?.image
    }" @submit="onReportSubmit" />

    <div v-if="!isPreviewMode" class="col-12 fade-up" style="--delay: 8">
        <RelatedRecipes :currentId="route.params.id" />
    </div>
</template>

<style lang="scss" scoped>
/* 原有的樣式保持不變... */
@import '@/assets/scss/abstracts/_color.scss';

.fade-up {
    opacity: 0;
    animation: fadeUpIn 0.8s cubic-bezier(0.2, 0.6, 0.35, 1) forwards;
    animation-delay: calc(var(--delay) * 0.12s);
}

@keyframes fadeUpIn {
    from {
        opacity: 0;
        transform: translateY(25px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.preview-sticky-bar {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    z-index: 110;
    padding: 12px 0;
    pointer-events: none;
    transition: all 0.3s ease;

    @media screen and (min-width: 810px) {
        left: 260px;
        width: calc(100% - 260px);
        background: transparent;
    }

    @media screen and (max-width: 809px) {
        left: 0;
        width: 100%;
        background: rgba(255, 255, 255, 0.7);
        backdrop-filter: blur(8px);
        padding: 8px 0;
    }

    .container {
        max-width: 1000px;
        margin: 0 auto;
        padding: 0 16px;
    }

    .bar-content {
        display: flex;
        justify-content: space-between;
        align-items: center;
        background-color: $primary-color-400;
        color: $neutral-color-white;
        padding: 10px 20px;
        border-radius: 12px;
        pointer-events: auto;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);

        @media screen and (max-width: 480px) {
            padding: 8px 12px;

            span {
                font-size: 11px;
            }
        }

        span {
            font-weight: 500;
            font-size: 14px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .exit-preview-btn {
            flex-shrink: 0;
            background-color: $neutral-color-white;
            color: $primary-color-700;
            border: none;
            padding: 6px 16px;
            border-radius: 50px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            margin-left: 12px;
            white-space: nowrap;
            transition: transform 0.2s ease;

            &:hover {
                background-color: $primary-color-100;
                transform: scale(1.05);
            }
        }
    }
}

.recipe-container-root {
    background-color: $neutral-color-white;
    min-height: 100vh;
    padding: 0 0 100px 0;

    &.preview-padding {
        padding-top: 90px;

        @media screen and (max-width: 768px) {
            padding-top: 0px;
        }
    }
}

.title-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px 0;
    margin-bottom: 20px;
    border-bottom: 1px solid $neutral-color-100;

    @media screen and (max-width: 768px) {
        flex-direction: column;
        align-items: flex-start;
        gap: 16px;
        padding: 15px 0;
    }

    .zh-h2 {
        display: flex;
        align-items: center;
        gap: 12px;

        .main-icon {
            font-size: 24px;
            color: $neutral-color-black;
        }
    }

    .icon-group {
        display: flex;
        align-items: center;
        gap: 20px;
        color: $primary-color-700;

        @media screen and (max-width: 768px) {
            gap: 16px;
            width: 100%;
            justify-content: flex-start;
        }

        &.is-preview {
            opacity: 0.6;

            .action-item {
                cursor: not-allowed;
                pointer-events: none;
            }
        }

        .action-item {
            display: flex;
            align-items: center;
            gap: 6px;
            cursor: pointer;
            transition: color 0.2s ease;

            &.active {
                color: $primary-color-700;

                .action-icon {
                    fill: $primary-color-700;
                }
            }

            &:hover {
                color: $primary-color-400;
            }
        }

        .count-text {
            font-size: 16px;
            font-weight: 500;
        }

        .action-icon {
            font-size: 24px;
        }

        .adapt-btn-wrapper {
            @media screen and (max-width: 768px) {
                margin-left: auto;
            }

            :deep(.base-btn) {
                padding: 0 10px;
                font-size: 13px;
                border-radius: 6px;
            }
        }
    }
}

.cook-snap-full {
    display: flex;
    justify-content: center;
    width: 100%;
    margin-top: 40px;
    background-color: $neutral-color-100;
    padding: 40px 0;

    .content-wrapper {
        width: 100%;
        max-width: 800px;
    }
}

.steps-section {
    margin-top: 40px;
}

.loading-state,
.error-state {
    text-align: center;
    padding: 100px 0;
    color: $primary-color-700;
}

.d-lg-none {
    @media screen and (min-width: 1024px) {
        display: none !important;
    }
}

.d-none-lg {
    @media screen and (max-width: 1023.98px) {
        display: none !important;
    }
}
</style>