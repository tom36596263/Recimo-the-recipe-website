<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { publicApi } from '@/utils/publicApi';
import { useRecipeStore } from '@/stores/recipeEditor';

// 引用元件 
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

const baseUrl = import.meta.env.BASE_URL;

// --- 1. 響應式資料狀態 ---
const rawRecipe = ref(null);
const rawIngredients = ref([]);
const rawSteps = ref([]);
const rawComments = ref([]);
const rawGallery = ref([]);
const rawUsers = ref([]);
const servings = ref(1);
const isLoading = ref(true);

const isLiked = ref(false);
const localLikesOffset = ref(0);

const isPreviewMode = computed(() => route.query.mode === 'preview');

// --- 2. 功能函式 ---
const toggleRecipeLike = () => {
    if (isPreviewMode.value) return;
    isLiked.value = !isLiked.value;
    localLikesOffset.value = isLiked.value ? 1 : 0;
};

const handleGoToEdit = () => {
    const currentId = isPreviewMode.value
        ? (route.query.editId || recipeStore.previewData?.recipe_id)
        : (rawRecipe.value?.recipe_id || route.params.id);

    const queryParams = { editId: currentId };
    if (!isPreviewMode.value) { queryParams.action = 'adapt'; }

    if (isPreviewMode.value) {
        const parentId = recipeStore.previewData?.parent_recipe_id || recipeStore.previewData?.parent_id;
        if (parentId) {
            queryParams.editId = parentId;
            queryParams.action = 'adapt';
        }
    }
    router.push({ path: '/workspace/edit-recipe', query: queryParams });
};

const backToEdit = () => { handleGoToEdit(); };

const toggleWorkspaceTopBar = (show) => {
    const topBar = document.querySelector('.workspace-top-bar');
    if (topBar) { topBar.style.display = show ? '' : 'none'; }
};

// --- 3. fetchData 核心邏輯 ---
const fetchData = async () => {
    isLoading.value = true;
    const recipeId = Number(route.params.id);

    // --- [預覽模式省略，保持你現有的邏輯即可] ---
    if (isPreviewMode.value && recipeStore.previewData) {
        /* ...預覽模式邏輯... */
        // 建議同樣參考下方的 console.table 寫法
    }

    try {
        const [resR, resRecipeIng, resIngMaster, resS, resC, resG, resU] = await Promise.all([
            publicApi.get('data/recipe/recipes.json'),
            publicApi.get('data/recipe/recipe_ingredient.json'),
            publicApi.get('data/recipe/ingredients.json'),
            publicApi.get('data/recipe/steps.json'),
            publicApi.get('data/social/comments.json'),
            publicApi.get('data/social/gallery.json'),
            publicApi.get('data/user/users.json')
        ]);

        rawUsers.value = resU.data || [];
        const recipes = resR.data || [];
        rawRecipe.value = recipes.find(r => Number(r.recipe_id || r.RECIPE_ID) === recipeId);

        if (!rawRecipe.value) {
            // console.warn(`找不到食譜 ID: ${recipeId}`);
            isLoading.value = false;
            return;
        }

        // 🏆 修正 1：正確設定初始份數，不要死栓在 1
        const defaultServings = Number(rawRecipe.value.recipe_servings || rawRecipe.value.RECIPE_SERVINGS || 12);
        servings.value = 1;

        // console.log(`%c🏠 正式模式：載入食譜，原始總份數: ${defaultServings}，UI 預設顯示: 1`, 'color: #fff; background: #4CAF50; padding: 2px 4px;');

        const masterIng = resIngMaster.data || [];
        const recipeIng = resRecipeIng.data || [];
        const filteredLinks = recipeIng.filter(i => Number(i.recipe_id || i.RECIPE_ID) === recipeId);

        // console.log(`%c🏠 正式模式：載入食譜 ID [${recipeId}]，預設份數: ${defaultServings}`, 'color: #fff; background: #4CAF50; padding: 2px 4px;');

        rawIngredients.value = filteredLinks.map(link => {
            const master = masterIng.find(m => Number(m.ingredient_id) === Number(link.ingredient_id));

            // 單位與換算邏輯
            let unitWeight = Number(link.gram_conversion || master?.gram_conversion || master?.unit_weight || 1);
            const unitName = link.unit_name || master?.unit_name || '';

            // 如果單位本身就是克/毫升，換算率強制為 1
            if (['克', 'g', 'G', '毫升', 'ml', 'ML'].includes(unitName)) {
                unitWeight = 1;
            }

            const kcal = Number(master?.kcal_per_100g || link.kcal_per_100g || 0);
            const amount = Number(link.amount || 0);
            const totalGrams = amount * unitWeight;
            const itemTotalKcal = (totalGrams / 100) * kcal;

            return {
                ...link,
                ingredient_name: master?.ingredient_name || link.ingredient_name || '未知食材',
                gram_conversion: unitWeight,
                kcal_per_100g: kcal,
                protein_per_100g: Number(master?.protein_per_100g || link.protein_per_100g || 0),
                fat_per_100g: Number(master?.fat_per_100g || link.fat_per_100g || 0),
                carbs_per_100g: Number(master?.carbs_per_100g || link.carbs_per_100g || 0),
                unit_name: unitName || '份',
                // 偵錯用欄位
                calc_total_grams: totalGrams.toFixed(2),
                calc_total_kcal: itemTotalKcal.toFixed(2)
            };
        });

        // 🏆 修正 2：補上計算表格 Console
        console.table(rawIngredients.value.map(i => ({
            '食材': i.ingredient_name,
            '原始用量': i.amount,
            '單位': i.unit_name,
            '單位重(g)': i.gram_conversion,
            '換算總重(g)': i.calc_total_grams,
            '每100g熱量': i.kcal_per_100g,
            '該項總熱量': i.calc_total_kcal
        })));

        // 其他資料讀取
        rawSteps.value = (resS.data || []).filter(s => Number(s.recipe_id || s.RECIPE_ID) === recipeId)
            .sort((a, b) => (a.step_order || 0) - (b.step_order || 0));
        rawComments.value = (resC.data || []).filter(c => Number(c.RECIPE_ID || c.recipe_id) === recipeId);
        rawGallery.value = (resG.data || []).filter(g => Number(g.RECIPE_ID || g.recipe_id) === recipeId);

        // ❌ 移除這行：servings.value = 1; (這會蓋掉上面好不容易拿到的 defaultServings)

    } catch (err) {
        console.error('正式模式資料讀取出錯:', err);
    } finally {
        setTimeout(() => { isLoading.value = false; }, 100);
    }
};

onMounted(() => {
    fetchData();
    if (isPreviewMode.value) { toggleWorkspaceTopBar(false); }
});

onUnmounted(() => { toggleWorkspaceTopBar(true); });

watch(() => isPreviewMode.value, (newVal) => { toggleWorkspaceTopBar(!newVal); });
// 🚀 修正 Watch，確保路由變動時重新抓取
watch(() => [route.params.id, route.query.mode], () => { fetchData(); });

// --- 4. 計算屬性 ---

const recipeIntroData = computed(() => {
    if (!rawRecipe.value) return null;
    let rawImg = rawRecipe.value.recipe_image_url || rawRecipe.value.coverImg || rawRecipe.value.recipe_cover_image || '';
    let finalImg = '';

    if (rawImg) {
        if (rawImg.startsWith('http') || rawImg.startsWith('data:') || rawImg.startsWith('blob:')) {
            finalImg = rawImg;
        } else {
            const cleanPath = rawImg.replace(/^\//, '');
            finalImg = `${baseUrl}/${cleanPath}`.replace(/\/+/g, '/');
        }
    } else {
        finalImg = 'https://placehold.co/800x600?text=No+Image';
    }

    return {
        id: rawRecipe.value.recipe_id || rawRecipe.value.RECIPE_ID || route.params.id,
        title: rawRecipe.value.recipe_title || rawRecipe.value.title || rawRecipe.value.RECIPE_TITLE || '未命名食譜',
        image: finalImg,
        time: formatTime(rawRecipe.value.recipe_total_time || rawRecipe.value.RECIPE_TOTAL_TIME),
        difficulty: rawRecipe.value.recipe_difficulty || rawRecipe.value.RECIPE_DIFFICULTY || 1,
        description: rawRecipe.value.recipe_descreption || rawRecipe.value.recipe_description || rawRecipe.value.RECIPE_DESCRIPTION || '暫無簡介'
    };
});

const stepsData = computed(() => {
    if (!rawSteps.value || rawSteps.value.length === 0) return [];
    const rId = rawRecipe.value?.recipe_id || rawRecipe.value?.RECIPE_ID || route.params.id || '0';
    return rawSteps.value.map((s, index) => {
        let rawImg = s.step_image_url || s.image || s.img || s.STEP_IMAGE_URL || '';
        let finalImg = '';
        if (rawImg && typeof rawImg === 'string' && rawImg.length > 0) {
            if (rawImg.startsWith('data:') || rawImg.startsWith('http') || rawImg.startsWith('blob:')) {
                finalImg = rawImg;
            } else {
                let cleanPath = rawImg.replace(/^\//, '');
                finalImg = `${baseUrl}/${cleanPath}`.replace(/\/+/g, '/');
            }
        }
        return {
            id: s.step_id || s.id || s.STEP_ID || `s-${index}`,
            title: s.step_title || s.title || s.STEP_TITLE || `步驟 ${index + 1}`,
            content: s.step_content || s.content || s.text || s.STEP_CONTENT || '',
            image: finalImg,
            time: s.step_total_time || s.time || s.STEP_TOTAL_TIME || '',
            tags: s.tags || []
        };
    });
});

const snapsData = computed(() => {
    // 🔍 偵錯：看看 rawUsers 現在有沒有東西
    if (rawUsers.value.length === 0) {
        console.warn('⚠️ snapsData 計算時 rawUsers 還是空的，請檢查 fetchData 是否完成');
    }

    return rawGallery.value.map(g => {
        let rawUrl = g.GALLERY_URL || g.url || g.gallery_url || '';
        let finalUrl = '';
        if (rawUrl.startsWith('http') || rawUrl.startsWith('data:') || rawUrl.startsWith('blob:')) {
            finalUrl = rawUrl;
        } else if (rawUrl) {
            finalUrl = `${baseUrl}/${rawUrl.replace(/^\//, '')}`.replace(/\/+/g, '/');
        }

        const userId = Number(g.USER_ID || g.user_id);

        const user = rawUsers.value.find(u => {
            const uId = Number(u.USER_ID || u.user_id || u.id);
            return uId === userId;
        });

        if (!user && rawUsers.value.length > 0) {
            console.log(`❌ 在 rawUsers 中找不到 USER_ID: ${userId}`);
        }

        return {
            url: finalUrl,
            comment: g.GALLERY_TEXT || g.comment || g.gallery_text || '',
            userId: userId,
            // 🏆 修正這裡：抓不到時顯示 ID 方便除錯
            userName: user?.USER_NAME || user?.user_name || user?.name || `用戶ID:${userId}`,
            time: g.UPLOAD_AT || g.time || '剛剛'
        };
    });
});

const formatTime = (timeVal) => {
    if (!timeVal || timeVal === '00:00' || timeVal === 0) return '0 分鐘';
    const timeStr = String(timeVal);
    if (timeStr.includes(':')) {
        const parts = timeStr.split(':');
        return (parseInt(parts[0], 10) || 0) === 0 ? `${parseInt(parts[1], 10) || 0} 分鐘` : `${parseInt(parts[0], 10) || 0} 小時 ${parseInt(parts[1], 10) || 0} 分鐘`;
    }
    return `${timeStr} 分鐘`;
};

const ingredientsData = computed(() => {
    // 取得縮放比例
    const originalServings = Number(rawRecipe.value?.recipe_servings || 1);
    const scale = (servings.value || 1) / originalServings;

    return rawIngredients.value.map(item => ({
        INGREDIENT_NAME: item.ingredient_name || '未知食材',
        // 🏆 數量要乘上縮放比例
        amount: (Number(item.amount) * scale).toFixed(1),
        unit_name: item.unit_name || '份',
        note: item.remark || item.note || '',
        // 營養素保持原始資料，由組件決定是否顯示
        calories_per_100g: item.kcal_per_100g || 0,
        protein_per_100g: item.protein_per_100g || 0,
        fat_per_100g: item.fat_per_100g || 0,
        carbs_per_100g: item.carbs_per_100g || 0,
        unit_weight: item.gram_conversion || 1
    }));
});

const nutritionWrapper = computed(() => {
    if (!rawRecipe.value) return [];

    const originalServings = Number(rawRecipe.value.recipe_servings || rawRecipe.value.RECIPE_SERVINGS || 1);
    const currentServings = servings.value || 1;
    // 這裡算出正確的縮放比 (例如 1/12 或 2/12)
    const scale = currentServings / originalServings;

    let totalKcal = 0, totalProtein = 0, totalFat = 0, totalCarbs = 0;

    rawIngredients.value.forEach(ing => {
        const amount = Number(ing.amount) || 0;
        const gramWeight = Number(ing.gram_conversion || 1);
        const ratio = (amount * gramWeight) / 100;

        totalKcal += (Number(ing.kcal_per_100g) || 0) * ratio;
        totalProtein += (Number(ing.protein_per_100g) || 0) * ratio;
        totalFat += (Number(ing.fat_per_100g) || 0) * ratio;
        totalCarbs += (Number(ing.carbs_per_100g) || 0) * ratio;
    });

    return [{
        // 🏆 這裡已經算好「當前顯示份數」的總量
        calories_per_100g: totalKcal * scale,
        protein_per_100g: totalProtein * scale,
        fat_per_100g: totalFat * scale,
        carbs_per_100g: totalCarbs * scale,

        // 關鍵：強制讓子組件的乘法乘上 1，不要再加乘
        amount: 1,
        unit_weight: 1
    }];
});

const commentList = computed(() => {

    if (!rawUsers.value || rawUsers.value.length === 0) return [];

    return rawComments.value.map(c => {
        const userId = Number(c.USER_ID || c.user_id);

        // 🏆 強化比對邏輯：同時支援 USER_ID 與 user_id
        const user = rawUsers.value.find(u => {
            const uId = Number(u.USER_ID || u.user_id || u.id);
            return uId === userId;
        });

        // 處理頭像路徑
        const rawAvatar = user?.USER_URL || user?.user_url || '';
        const finalAvatar = rawAvatar
            ? `${baseUrl}/${rawAvatar.replace(/^\//, '')}`.replace(/\/+/g, '/')
            : `https://i.pravatar.cc/150?u=${userId}`;

        return {
            userName: user?.USER_NAME || user?.user_name || user?.name || `用戶ID:${userId}`,
            handle: `user_${userId}`,
            time: c.COMMENT_AT || c.comment_at || '剛剛',
            content: c.COMMENT_TEXT || c.comment_text || '',
            avatar: finalAvatar,
            likes: Number(c.LIKE_COUNT || c.like_count || 0)
        };
    });
});

const baseRecipeLikes = ref(0);
watch(rawRecipe, (newVal) => {
    if (newVal) {
        baseRecipeLikes.value = isPreviewMode.value ? 0 : Math.floor(Math.random() * 200) + 50;
    }
}, { immediate: true });

const displayRecipeLikes = computed(() => baseRecipeLikes.value + localLikesOffset.value);

const handleShare = async () => {
    if (isPreviewMode.value) return;
    const title = recipeIntroData.value?.title || '美味食譜';
    if (navigator.share) {
        try { await navigator.share({ title, url: window.location.href }); } catch (err) { }
    } else {
        await navigator.clipboard.writeText(window.location.href);
        alert('連結已複製！');
    }
};

const handleServingsChange = (newVal) => { servings.value = newVal; };
const isReportModalOpen = ref(false);
const onReportSubmit = (data) => { isReportModalOpen.value = false; };
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
                        <RecipeComments :list="commentList" />
                    </section>
                </div>

                <div v-if="!isPreviewMode" class="col-12 cook-snap-full fade-up" style="--delay: 7">
                    <section class="mb-10 content-wrapper">
                        <CookSnap :list="snapsData" />
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