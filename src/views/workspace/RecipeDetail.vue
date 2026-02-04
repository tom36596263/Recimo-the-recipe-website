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
import AuthorInfo from '@/components/workspace/modifyrecipe/AuthorInfo.vue';
import DeleteAdaptationBtn from '@/components/workspace/modifyrecipe/DeleteAdaptationBtn.vue'; 


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

const isHubOpen = ref(false); // 用來控制選單展開/收合

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

// --- 核心抓取邏輯 ---
const fetchData = async () => {
    isLoading.value = true;
    console.log('🔍 [路由偵錯] route.params:', route.params);
    const recipeId = Number(route.params.id);
    console.log('🔍 [路由偵錯] 轉換後的 recipeId:', recipeId);



    // --- 1. 預覽模式優先處理 ---
    if (isPreviewMode.value) {
        console.log('🚀 [偵錯] 進入預覽模式，嘗試從 Store 讀取資料');
        const preview = recipeStore.previewData;

        if (preview) {
            try {
                // 同步抓取食材母表以校正營養係數
                const resIngMaster = await publicApi.get('data/recipe/ingredients.json');
                const masterIng = resIngMaster.data || [];

                // 【份數捕獲】確保預覽模式能拿到正確的原始份數
                const previewServings = Math.max(1, Number(
                    preview.recipe_servings ||
                    preview.servings ||
                    preview.recipe_serving || 1
                ));

                console.log('📊 [預覽偵錯] 解析出的份數:', previewServings);

                // 映射為前端統一格式 (rawRecipe)
                rawRecipe.value = {
                    recipe_id: 0,
                    recipe_title: preview.title || preview.recipe_title || '未命名食譜',
                    recipe_description: preview.description || preview.recipe_description || '',
                    recipe_image_url: preview.coverImg || preview.recipe_cover_image,
                    recipe_difficulty: Number(preview.difficulty || preview.recipe_difficulty || 1),
                    recipe_total_time: preview.totalTime || preview.recipe_total_time || '0:30',
                    recipe_servings: previewServings,
                    recipe_likes: 0,
                    author_name: authStore.user?.user_name || '您的預覽',
                    tags: preview.recipe_tags || preview.tags || []
                };

                servings.value = previewServings;

                // 處理食材 (rawIngredients) - 確保欄位與正式模式一致以利 computed 計算
                rawIngredients.value = (preview.ingredients || []).map(ing => {
                    const name = (ing.ingredient_name || ing.name || "").trim();
                    const master = masterIng.find(m => String(m.ingredient_name).trim() === name);
                    const unit = ing.unit || ing.unit_name || master?.unit_name || '份';
                    const isWeightUnit = ['g', '克', 'ml', '毫升'].includes(unit.toLowerCase());

                    return {
                        ...ing,
                        ingredient_name: name,
                        amount: Number(ing.amount || 0),
                        unit_name: unit,
                        // 關鍵：確保計算營養所需的係數都存在
                        gram_conversion: isWeightUnit ? 1 : Number(master?.gram_conversion || ing.gram_conversion || 1),
                        kcal_per_100g: Number(master?.kcal_per_100g || ing.kcal_per_100g || 0),
                        protein_per_100g: Number(master?.protein_per_100g || ing.protein_per_100g || 0),
                        fat_per_100g: Number(master?.fat_per_100g || ing.fat_per_100g || 0),
                        carbs_per_100g: Number(master?.carbs_per_100g || ing.carbs_per_100g || 0)
                    };
                });

                // 處理步驟 (rawSteps)
                rawSteps.value = (preview.steps || []).map((s, idx) => ({
                    ...s,
                    step_order: s.step_order || (idx + 1)
                })).sort((a, b) => Number(a.step_order) - Number(b.step_order));

                console.log('✅ [預覽成功] 資料已從 Store 渲染至畫面');
                isLoading.value = false;
                return;
            } catch (err) {
                console.error('預覽資料解析失敗:', err);
            }
        } else {
            console.warn('⚠️ 網址為預覽模式但 Store 內無資料，切換回正式模式嘗試');
        }
    }

    // --- 2. 正式模式：從伺服器抓取資料 ---
    console.log('🏠 [偵錯] 進入正式模式，請求 API 中...');
    try {
        const [resDetail, resG, resU, resC] = await Promise.all([
            phpApi.get(`recipes/recipe_detail_get.php?recipe_id=${recipeId}`),
            phpApi.get(`social/gallery.php?recipe_id=${recipeId}`), // 改成你的 PHP 路徑
            publicApi.get('data/user/users.json'),
            recipeId ? phpApi.get(`social/comment.php?recipe_id=${recipeId}`) : Promise.resolve({ data: [] })
        ]);

        console.log('📥 [API 偵錯] PHP 回傳原始內容:', resDetail.data);

        if (resDetail.data && resDetail.data.success) {
            const serverData = resDetail.data.data;
            const mainData = serverData.main;

            rawRecipe.value = {
                ...serverData.main,
                // 🏆 關鍵修正：確保作者名稱有被存入 rawRecipe
                // 根據一般 API 慣例，嘗試從 main 裡面抓取可能的名字欄位
                author_name: mainData.author_name || 'Recimo 用戶',
                author_id: mainData.author_id,

                recipe_description: serverData.main.recipe_descreption || serverData.main.recipe_description || '',
                tags: serverData.tags || []
            };

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

            rawSteps.value = (serverData.steps || []).sort((a, b) =>
                (Number(a.step_order) || 0) - (Number(b.step_order) || 0)
            );

            servings.value = Number(rawRecipe.value.recipe_servings || 1);
        }

        // --- 3. 處理成品照 ---
        if (resG.data && resG.data.success) {
            // 🏆 直接引用 axios 實例的 baseURL，確保開發與生產環境一致
            const API_BASE_URL = phpApi.defaults.baseURL.endsWith('/')
                ? phpApi.defaults.baseURL
                : `${phpApi.defaults.baseURL}/`;

            snapsData.value = resG.data.data
                .filter(item => Number(item.recipe_id) === recipeId)
                .map(item => {
                    let finalImg = '';
                    const rawUrl = item.gallery_url || '';

                    if (rawUrl.startsWith('http')) {
                        finalImg = rawUrl;
                    } else if (rawUrl.includes(':\\')) {
                        // 處理 Windows 實體路徑備案
                        const parts = rawUrl.split('recimo_api\\');
                        const relativePath = parts[1] ? parts[1].replace(/\\/g, '/') : '';
                        finalImg = `${API_BASE_URL}${relativePath}`;
                    } else {
                        // 🏆 核心修正：移除路徑開頭的斜線，確保拼接正確
                        const cleanPath = rawUrl.replace(/^\/+/, '');
                        finalImg = `${API_BASE_URL}${cleanPath}`;
                    }

                    // 🔍 診錯日誌：如果還是破圖，請在瀏覽器控制台看這個輸出的網址
                    console.log(`🖼️ 成品照 ID ${item.gallery_id} 最終路徑:`, finalImg);

                    return {
                        id: item.gallery_id,
                        url: finalImg,
                        comment: item.gallery_text,
                        createdAt: item.upload_at,
                        userId: item.user_id,
                        userName: item.user_name || '熱心用戶'
                    };
                });

            console.log('✅ 成功抓取成品照:', snapsData.value);
        }

        // --- 4. 處理留言 ---
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
        console.log('✅ [正式模式] 資料加載完成');
    } catch (err) {
        console.error('正式資料抓取失敗:', err);
    } finally {
        isLoading.value = false;
    }
};

const isFromWorkspace = computed(() => {
    return route.path.includes('/workspace/recipe-detail');
});

const isAdaptation = computed(() => {
    // 根據你提供的 JSON，關鍵在於 parent_recipe_id 是否有值
    return !!(rawRecipe.value?.parent_recipe_id);
});

// --- 權限判斷 ---
const isMyRecipe = computed(() => {
    // 1. 確保 rawRecipe 有資料
    // 2. 比較 authStore 裡的 user_id 與食譜的 author_id
    const currentUserId = authStore.user?.user_id || authStore.user?.id;
    const authorId = rawRecipe.value?.author_id || rawRecipe.value?.user_id;

    return currentUserId && authorId && Number(currentUserId) === Number(authorId);
});

// --- 3. 計算屬性 ---
const displayRecipeLikes = computed(() => {
    const baseLikes = Number(rawRecipe.value?.recipe_likes || 0);
    return baseLikes + localLikesOffset.value;
});

const ingredientsData = computed(() => {
    if (!rawRecipe.value || !rawIngredients.value.length) return [];
    const originalServings = Math.max(1, Number(rawRecipe.value.recipe_servings || 1));
    const currentServings = Math.max(1, Number(servings.value || 1));
    const scale = currentServings / originalServings;

    return rawIngredients.value.map(item => ({
        INGREDIENT_NAME: item.ingredient_name,
        amount: (Number(item.amount || 0) * scale).toFixed(1),
        unit_name: item.unit_name,
        note: item.remark || item.note || ''
    }));
});

const nutritionWrapper = computed(() => {
    if (!rawRecipe.value || rawIngredients.value.length === 0) return [];

    // 這裡的 scale 計算是基於「當前選擇份數」相對於「食譜原始份數」
    const original = Math.max(1, Number(rawRecipe.value.recipe_servings || 1));
    const current = Math.max(1, Number(servings.value || 1));
    const scale = current / original;

    let totalKcal = 0, totalP = 0, totalF = 0, totalC = 0;

    rawIngredients.value.forEach(ing => {
        const amt = Number(ing.amount) || 0;
        const conv = Number(ing.gram_conversion) || 1;
        const weight = amt * conv;
        totalKcal += (Number(ing.kcal_per_100g) || 0) * (weight / 100);
        totalP += (Number(ing.protein_per_100g) || 0) * (weight / 100);
        totalF += (Number(ing.fat_per_100g) || 0) * (weight / 100);
        totalC += (Number(ing.carbs_per_100g) || 0) * (weight / 100);
    });

    // 返回陣列格式以符合 NutritionCard 的 Props
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
        description: r.recipe_description || '暫無簡介',
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
    const editId = route.query.editId || recipeStore.previewData?.recipe_id;
    const action = route.query.action;
    if (action === 'adapt' && editId) {
        router.push({ path: '/workspace/edit-recipe', query: { editId: editId, action: 'adapt' } });
    } else if (editId && editId !== '0') {
        router.push({ path: '/workspace/edit-recipe', query: { editId: editId } });
    } else {
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

// 處理刪除成功後的跳轉
const onDeleteSuccess = (deletedId) => {
    console.log(`食譜 ${deletedId} 已刪除`);
    // 這裡導向你的工作區食譜列表頁面
    router.push('/workspace/my-recipes');
};

const toggleWorkspaceTopBar = (show) => {
    const topBar = document.querySelector('.workspace-top-bar');
    if (topBar) topBar.style.display = show ? '' : 'none';
};

const handlePostComment = async (content) => {
    if (!authStore.user) return alert('請先登入');
    if (!content || !content.trim()) return;
    const userId = authStore.user.user_id || authStore.user.id;
    try {
        const payload = { action: 'post', recipe_id: Number(route.params.id), user_id: userId, content: content };
        const response = await phpApi.post('social/comment.php', payload);
        if (response.data.success) fetchData();
        else alert('失敗：' + response.data.message);
    } catch (err) {
        alert('發佈失敗，請稍後再試');
    }
};

const handleLikeComment = async (commentId, type) => {
    if (!authStore.user) return alert('登入後即可點讚');
    try {
        await phpApi.post('social/comment.php', { action: 'like', comment_id: commentId, type: type });
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
    const userId = authStore.user.user_id || authStore.user.id;
    try {
        const response = await phpApi.delete(`social/comment.php`, {
            params: { comment_id: commentId, user_id: userId }
        });
        if (response.data.success) {
            alert('留言已刪除');
            fetchData();
        } else {
            alert('刪除失敗：' + (response.data.message || '未知錯誤'));
        }
    } catch (err) {
        alert('刪除失敗，請檢查網路或權限');
    }
};

const handlePostSnap = async (payload) => {
    // 🏆 核心偵錯：看看到底是 File 還是 String
    console.log("--- 上傳流程開始 ---");
    console.log("1. 原始 Payload:", payload);
    console.log("2. 圖片類型:", typeof payload.image);
    console.log("3. 是否為 File 物件:", payload.image instanceof File);

    if (!authStore.user) return alert('請先登入');

    const userId = authStore.user.user_id || authStore.user.id;
    const recipeId = route.params.id;

    // 驗證 ID
    if (!userId || !recipeId) {
        console.error("缺少 ID:", { userId, recipeId });
        return alert('無法讀取用戶或食譜資訊');
    }

    const formData = new FormData();
    formData.append('recipe_id', recipeId);
    formData.append('user_id', userId);
    formData.append('gallery_text', payload.note || '');

    // 🏆 關鍵修正：確保只有 File 物件才能附加到 'image'
    if (payload.image instanceof File) {
        formData.append('image', payload.image);
        console.log("4. FormData 已成功附加 File 物件");
    } else {
        // 如果進到這裡，代表 Modal 傳出來的就是那個 blob 網址字串
        console.error("致命錯誤：Payload 提供的不是檔案實體，而是網址：", payload.image);
        alert("圖片讀取異常，請重新選取圖片後再試一次");
        return;
    }

    try {
        const response = await phpApi.post('social/gallery.php', formData, {
            headers: {
                'Content-Type': 'multipart/form-data'
            }
        });

        console.log("5. 後端回傳:", response.data);

        if (response.data.success) {
            alert('成品照發布成功！');
            if (typeof fetchData === 'function') fetchData();
        } else {
            alert('上傳失敗：' + response.data.message);
        }
    } catch (err) {
        console.error('API 出錯:', err);
        alert('上傳出錯，請檢查伺服器連線');
    }
};

const handleDeleteSnap = async (galleryId) => {
    const userId = authStore.user?.user_id || authStore.user?.id;

    try {
        // 🏆 注意：這裡改用 .delete() 或是傳參數給 gallery.php
        const response = await phpApi.delete('social/gallery.php', {
            data: {
                gallery_id: galleryId,
                user_id: userId
            }
        });

        if (response.data.success) {
            alert(response.data.message);
            fetchData(); // 重新整理列表
        }
    } catch (err) {
        console.error('刪除請求失敗', err);
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
                <div class="title-group">
                    <h2 class="zh-h2">
                        <i-material-symbols-restaurant-rounded class="main-icon" />
                        {{ recipeIntroData?.title }}
                    </h2>
                    <span v-if="isAdaptation" class="badge-adaptation">改編版本</span>
                </div>

                <div class="meta-wrapper">
                    <AuthorInfo :name="rawRecipe.author_name" :handle="`user_${rawRecipe.author_id}`"
                        :time="rawRecipe.created_at" />

                        <DeleteAdaptationBtn v-if="isMyRecipe && !isPreviewMode" :recipe-id="rawRecipe.recipe_id"
                        :is-db-data="true" @success="onDeleteSuccess" />

                    <div v-if="!isPreviewMode" class="adapt-btn-wrapper">
                        <router-link v-if="isAdaptation" :to="`/workspace/recipe-detail/${rawRecipe.parent_recipe_id}`">
                            <BaseBtn title="查看原食譜" variant="outline" class="w-auto" />
                        </router-link>
                        <router-link v-else :to="`/workspace/modify-recipe/${rawRecipe.recipe_id}`">
                            <BaseBtn title="改編一覽" variant="outline" class="w-auto" />
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
                            <RecipeIngredients :servings="servings" :list="ingredientsData" />
                        </section>

                        <section class="mb-10 fade-up" style="--delay: 4">
                            <NutritionCard :servings="servings" :ingredients="nutritionWrapper"
                                @change-servings="handleServingsChange" />
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
                        <section v-if="!isPreviewMode && !isAdaptation" class="mb-10 fade-up" style="--delay: 6">
                            <RecipeComments :list="commentList" @post-comment="handlePostComment"
                                @like-comment="handleLikeComment" @delete-comment="handleDeleteComment" />
                        </section>
                    </section>
                </div>

                <div v-if="!isPreviewMode && !isAdaptation" class="col-12 cook-snap-full fade-up" style="--delay: 7">
                    <section class="mb-10 content-wrapper">
                        <CookSnap :list="snapsData" @post-snap="handlePostSnap" @delete-snap="handleDeleteSnap" />
                    </section>
                </div>
            </div>
        </main>
    </div>



    

    <div v-if="isHubOpen" class="hub-overlay" @click="isHubOpen = false"></div>

    <div v-if="!isLoading && rawRecipe" class="recipe-action-hub"
        :class="{ 'active': isHubOpen, 'is-preview': isPreviewMode }">

        <button class="main-hub-btn" @click="isLiked = !isLiked; localLikesOffset = isLiked ? 1 : 0">
            <i-material-symbols-thumb-up-rounded v-if="isLiked" />
            <i-material-symbols-thumb-up-outline-rounded v-else />
            <span v-if="displayRecipeLikes > 0" class="badge">{{ displayRecipeLikes }}</span>

            <div class="indicator" :class="{ 'rotate': isHubOpen }" @click.stop="isHubOpen = !isHubOpen">
                <i-material-symbols-add-rounded />
            </div>
        </button>

        <div class="sub-actions">
            <button class="sub-btn" @click="handleGoToEdit" title="編輯/改編">
                <i-material-symbols-edit />
            </button>
            <button class="sub-btn" @click="handleShare" title="分享">
                <i-material-symbols-share-outline />
            </button>
            <button class="sub-btn report" @click="isReportModalOpen = true" title="檢舉">
                <i-material-symbols-error-outline-rounded />
            </button>
        </div>
    </div>


    <div v-else-if="isLoading" class="loading-state">
        <p>正在為您準備食譜資料...</p>
    </div>
    <div v-else class="error-state">
        <p>抱歉，找不到該食譜資料 (ID: {{ route.params.id }})。</p>
        <router-link to="/">返回首頁</router-link>
    </div>

    <RecipeReportModal v-model="isReportModalOpen" :targetData="{
        recipe_id: rawRecipe?.recipe_id,
        title: recipeIntroData?.title,
        content: recipeIntroData?.description,

        // 🏆 多重保險：嘗試抓取所有可能的作者欄位名稱
        userName: rawRecipe?.author_name || rawRecipe?.user_name || '未知作者',

        // 🏆 這裡也一樣，相容大小寫與不同命名
        author_id: rawRecipe?.author_id || rawRecipe?.AUTHOR_ID || rawRecipe?.user_id,

        image: recipeIntroData?.image
    }" @submit="onReportSubmit" />


    <div v-if="!isPreviewMode && !isAdaptation" class="col-12 fade-up" style="--delay: 8">
        <RelatedRecipes :currentId="route.params.id" :excludeAdapted="true" />
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
    align-items: center;
    justify-content: flex-start;
    padding: 20px 0;
    border-bottom: 1px solid $neutral-color-100;
    margin-bottom: 20px;

    .zh-h2 {
        flex-shrink: 0;
        display: flex;
        align-items: center;

        .main-icon {
            margin-right: 15px;
            font-size: 24px;
            color: $neutral-color-black;
            transform: translateY(4px);

            @media screen and (min-width: 769px) {
                transform: translateY(3px) !important;
            }
        }
    }


    .meta-wrapper {
        margin-left: auto;
        display: flex;
        align-items: center;
        gap: 16px;

        @media screen and (max-width: 768px) {
            margin-left: 0;
            width: 100%;
            justify-content: space-between;
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

/* --- [區塊 A] 詳情頁彈窗專用 --- */
.fixed-floating-bar {
    position: fixed;
    bottom: 30px;
    right: 40px;
    display: flex;
    flex-direction: row;
    gap: 12px;
    z-index: 1000;
    background: rgba(255, 255, 255, 0.4);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    padding: 10px;
    border-radius: 50px;
    border: 1px solid rgba(255, 255, 255, 0.3);
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
    transition: all 0.3s ease;

    @media (max-width: 768px) {
        bottom: 20px;
        right: 20px;
        gap: 8px;
        padding: 8px;
    }

    &.is-preview {
        opacity: 0.5;
        pointer-events: none;
    }

    .action-circle-btn {
        width: 46px;
        height: 46px;
        border-radius: 50%;
        background: white;
        border: none;
        display: flex;
        align-items: center;
        justify-content: center;
        color: $primary-color-700 !important;
        font-size: 22px;
        cursor: pointer;
        transition: all 0.2s ease;
        position: relative;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);

        svg,
        :deep(svg) {
            fill: currentColor;
        }

        &:hover {
            transform: translateY(-3px);
            background: $primary-color-100;
        }

        &.active {
            background: $primary-color-700 !important;
            color: white !important;

            svg,
            :deep(svg) {
                fill: white;
            }
        }

        &.report {
            color: #ff7875 !important;

            &:hover {
                background: #fff1f0;
            }

            svg,
            :deep(svg) {
                fill: #ff7875;
            }
        }

        .badge {
            position: absolute;
            top: -5px;
            right: -5px;
            background: #ff4d4f;
            color: white;
            font-size: 10px;
            padding: 2px 6px;
            border-radius: 10px;
            border: 2px solid white;
        }
    }
}

/* --- [區塊 B] 頁面通用食譜按鈕 Hub (修正後的順序與樣式) --- */
.recipe-action-hub {
    position: fixed;
    z-index: 1000;
    display: flex;
    align-items: center;
    transition: all 0.3s ease;

    /* 桌機版：讚 -> 編輯 -> 分享 -> 檢舉 (橫向) */
    @media (min-width: 992px) {
        bottom: 30px;
        right: 30px;
        flex-direction: row; // 確保按讚在最左，檢舉在最右
        gap: 12px;
        background: rgba(255, 255, 255, 0.6);
        backdrop-filter: blur(12px);
        padding: 10px 16px;
        border-radius: 50px;
        border: 1px solid rgba(255, 255, 255, 0.3);
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);

        .sub-actions {
            display: flex !important;
            flex-direction: row;
            gap: 12px;
            opacity: 1 !important;
            pointer-events: auto !important;
            transform: none !important;
        }

        .indicator {
            display: none !important;
        }
    }

    /* 手機版：展開後 編輯/分享/檢舉 在 讚 的上方 */
    @media (max-width: 991px) {
        bottom: 100px;
        right: 24px;
        flex-direction: column;
        gap: 12px;

        .sub-actions {
            display: flex;
            flex-direction: column;
            gap: 12px;
            opacity: 0;
            transform: translateY(20px);
            pointer-events: none;
            transition: 0.3s cubic-bezier(0.18, 0.89, 0.32, 1.28);
            order: -1; // 讓子按鈕群組在 column 模式下出現在主按鈕上方
        }

        &.active .sub-actions {
            opacity: 1;
            transform: translateY(0);
            pointer-events: auto;
        }
    }

    /* 按鈕顏色邏輯 */
    .main-hub-btn {
        background: $neutral-color-white;
        color: $primary-color-700 !important;
        width: 44px;
        height: 44px;
        border-radius: 50%;
        border: none;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 22px;
        cursor: pointer;
        position: relative;

        svg,
        :deep(svg) {
            fill: $neutral-color-white;
        }
    }

    .sub-btn {
        width: 44px;
        height: 44px;
        border-radius: 50%;
        border: none;
        background: $neutral-color-white;
        color: $primary-color-700 !important;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 22px;
        cursor: pointer;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);

        svg,
        :deep(svg) {
            fill: currentColor;
        }

        &:hover {
            background: $primary-color-100;
        }

        &.report {
            color: $accent-color-700 !important;

            svg,
            :deep(svg) {
                fill: $accent-color-700;
            }

            &:hover {
                background: $neutral-color-100;
            }
        }
    }

    .badge {
        position: absolute;
        top: -5px;
        right: -5px;
        background: $primary-color-400;
        color: white;
        font-size: 10px;
        padding: 2px 6px;
        border-radius: 10px;
        border: 2px solid white;
    }

    .indicator {
        position: absolute;
        bottom: -4px;
        right: -4px;
        background: $primary-color-700;
        color: $neutral-color-white;
        width: 20px;
        height: 20px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;

        &.rotate {
            transform: rotate(45deg);
        }
    }
}

.hub-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background: rgba(0, 0, 0, 0.2);
    z-index: 999;

    @media (min-width: 992px) {
        display: none;
    }
}

.title-content .icon-group .adapt-btn-wrapper {
    margin-left: 0;
}

.title-group {
    display: flex;
    align-items: center;
    gap: 16px;
    flex-wrap: wrap;
}

.badge-adaptation {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    height: 26px;
    background: $primary-color-100;
    color: $primary-color-700;
    padding: 0 14px;
    border-radius: 99px;
    font-weight: 600;
    font-size: 14px;
    white-space: nowrap;
    line-height: 1;
}

@media screen and (max-width: 768px) {
    .title-content {
        flex-direction: column !important;
        align-items: flex-start !important;
        gap: 16px;
        padding: 15px 0;

        .title-group {
            width: 100%;
            flex-wrap: wrap;

            .zh-h2 {
                font-size: 1.5rem;
                line-height: 1.4;
            }
        }

        .meta-wrapper {
            margin-left: 0 !important;
            width: 100% !important;
            display: flex !important;
            align-items: center !important;
            justify-content: space-between !important;

            :deep(.author-info-container) {
                flex-shrink: 0;
            }

            .adapt-btn-wrapper,
            .delete-btn-wrapper,
            :deep(.delete-adaptation-btn) {
                margin-left: auto !important;
                display: flex !important;
                justify-content: flex-end;
                gap: 8px;
            }

            :deep(button) {
                white-space: nowrap;
            }
        }
    }
}
</style>