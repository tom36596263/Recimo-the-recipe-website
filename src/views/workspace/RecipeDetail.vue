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

    if (isPreviewMode.value) {
        const preview = recipeStore.previewData;
        if (preview) {
            rawRecipe.value = preview;
            rawIngredients.value = preview.ingredients || [];
            rawSteps.value = preview.steps || [];
            rawGallery.value = preview.gallery || [];
            setTimeout(() => { isLoading.value = false; }, 300);
            return;
        }
        router.replace('/workspace/edit-recipe');
        return;
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
            console.warn(`找不到食譜 ID: ${recipeId}`);
            isLoading.value = false;
            return;
        }

        // 留言過濾：同時檢查大寫 RECIPE_ID 與小寫 recipe_id
        rawComments.value = (resC.data || []).filter(c =>
            Number(c.RECIPE_ID || c.recipe_id) === recipeId
        );

        rawGallery.value = (resG.data || []).filter(g =>
            Number(g.RECIPE_ID || g.recipe_id) === recipeId
        );

        const masterIng = resIngMaster.data || [];
        const recipeIng = resRecipeIng.data || [];
        const filteredLinks = recipeIng.filter(i => Number(i.recipe_id || i.RECIPE_ID) === recipeId);

        rawIngredients.value = filteredLinks.map(link => {
            const master = masterIng.find(m => Number(m.ingredient_id) === Number(link.ingredient_id));
            return {
                ...link,
                ingredient_name: master?.ingredient_name || `未知食材`,
                unit_name: link.unit_name || master?.unit_name || '份'
            };
        });

        const steps = resS.data || [];
        rawSteps.value = steps.filter(s => Number(s.recipe_id || s.RECIPE_ID) === recipeId)
            .sort((a, b) => (a.step_order || 0) - (b.step_order || 0));

        servings.value = 1;

    } catch (err) {
        console.error('資料讀取出錯:', err);
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
watch(() => [route.params.id, route.query.mode], () => { fetchData(); }, { deep: true });

// --- 4. 計算屬性 (防禦性強化) ---

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
                if (cleanPath.includes('img/recipes/')) {
                    finalImg = `${baseUrl}/${cleanPath}`.replace(/\/+/g, '/');
                } else {
                    finalImg = `${baseUrl}/img/recipes/${rId}/steps/${cleanPath}`.replace(/\/+/g, '/');
                }
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

const snapsData = computed(() => rawGallery.value.map(g => {
    let rawUrl = g.GALLERY_URL || g.url || g.gallery_url || '';
    let finalUrl = '';
    if (rawUrl.startsWith('http') || rawUrl.startsWith('data:') || rawUrl.startsWith('blob:')) {
        finalUrl = rawUrl;
    } else if (rawUrl) {
        const cleanPath = rawUrl.replace(/^\//, '');
        finalUrl = `${baseUrl}/${cleanPath}`.replace(/\/+/g, '/');
    }
    return {
        url: finalUrl,
        comment: g.GALLERY_TEXT || g.comment || g.gallery_text || ''
    };
}));

const formatTime = (timeVal) => {
    if (!timeVal || timeVal === '00:00' || timeVal === 0) return '0 分鐘';
    const timeStr = String(timeVal);
    if (timeStr.includes(':')) {
        const parts = timeStr.split(':');
        const hh = parseInt(parts[0], 10) || 0;
        const mm = parseInt(parts[1], 10) || 0;
        return hh === 0 ? `${mm} 分鐘` : `${hh} 小時 ${mm} 分鐘`;
    }
    return `${timeStr} 分鐘`;
};

const ingredientsData = computed(() => rawIngredients.value.map(item => ({
    INGREDIENT_NAME: item.ingredient_name || item.INGREDIENT_NAME || '未知食材',
    amount: item.amount || item.AMOUNT || 0,
    unit_name: item.unit_name || item.UNIT_NAME || '份',
    // 修正這裡：加入 item.remark
    note: item.remark || item.note || item.NOTE || '',
    calories_per_100g: item.calories_per_100g || 0,
    protein_per_100g: item.protein_per_100g || 0,
    fat_per_100g: item.fat_per_100g || 0,
    carbs_per_100g: item.carbs_per_100g || 0,
    unit_weight: 1
})));

const nutritionWrapper = computed(() => {
    if (!rawRecipe.value) return [];
    return [{
        calories_per_100g: rawRecipe.value.recipe_kcal_per_100g || rawRecipe.value.RECIPE_KCAL_PER_100G || 0,
        protein_per_100g: rawRecipe.value.recipe_protein_per_100g || rawRecipe.value.RECIPE_PROTEIN_PER_100G || 0,
        fat_per_100g: rawRecipe.value.recipe_fat_per_100g || rawRecipe.value.RECIPE_FAT_PER_100G || 0,
        carbs_per_100g: rawRecipe.value.recipe_carbs_per_100g || rawRecipe.value.RECIPE_CARBS_PER_100G || 0,
        amount: 100,
        unit_weight: 1
    }];
});

// 最終極防禦：留言列表對接
const commentList = computed(() => {
    if (!rawComments.value || rawComments.value.length === 0) return [];

    return rawComments.value.map(c => {
        const userId = Number(c.USER_ID || c.user_id);
        // 在 Users 中找人，同時防禦大小寫
        const user = rawUsers.value.find(u => Number(u.USER_ID || u.user_id) === userId);

        let avatar = 'https://i.pravatar.cc/150?u=' + userId;
        const rawAvatar = user?.USER_URL || user?.user_url;
        if (rawAvatar) {
            avatar = rawAvatar.startsWith('http') ? rawAvatar : `${baseUrl}/${rawAvatar.replace(/^\//, '')}`.replace(/\/+/g, '/');
        }

        return {
            userName: user?.USER_NAME || user?.user_name || 'Recimo 用戶',
            handle: `user_${userId}`,
            time: c.COMMENT_AT || c.comment_at || '剛剛',
            content: c.COMMENT_TEXT || c.comment_text || '',
            avatar: avatar,
            likes: c.LIKE_COUNT || c.likes || c.LIKES || 0
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
    const url = window.location.href;
    if (navigator.share) {
        try { await navigator.share({ title, text: `我在 Recimo 看到一個很棒的食譜：${title}`, url }); }
        catch (err) { console.log('分享取消'); }
    } else {
        await navigator.clipboard.writeText(url);
        alert('連結已複製到剪貼簿！');
    }
};

const handleServingsChange = (newVal) => { servings.value = newVal; };
const isReportModalOpen = ref(false);
const onReportSubmit = (data) => {
    console.log('收到檢舉內容:', data);
    isReportModalOpen.value = false;
};
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
        userName: rawRecipe?.author_name || '未知作者',
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