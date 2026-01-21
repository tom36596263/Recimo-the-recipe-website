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

// --- 1. 響應式資料狀態 ---
const rawRecipe = ref(null);
const rawIngredients = ref([]);
const rawSteps = ref([]);
const rawComments = ref([]);
const rawGallery = ref([]);
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
    const currentId = rawRecipe.value?.recipe_id || route.params.id;
    router.push({
        path: '/workspace/edit-recipe',
        query: { editId: currentId }
    });
};

const backToEdit = () => {
    handleGoToEdit();
};

const toggleWorkspaceTopBar = (show) => {
    const topBar = document.querySelector('.workspace-top-bar');
    if (topBar) {
        topBar.style.display = show ? '' : 'none';
    }
};

// --- 3. fetchData 核心邏輯 ---
const fetchData = async () => {
    isLoading.value = true;
    rawRecipe.value = null;
    rawIngredients.value = [];
    rawSteps.value = [];

    const recipeId = Number(route.params.id);

    if (isPreviewMode.value) {
        const preview = recipeStore.previewData;
        if (preview) {
            rawRecipe.value = preview;
            rawIngredients.value = preview.ingredients || [];
            rawSteps.value = preview.steps || [];
            rawComments.value = [];
            rawGallery.value = [];
            setTimeout(() => { isLoading.value = false; }, 300);
            return;
        } else {
            router.replace('/workspace/edit-recipe');
            return;
        }
    }

    recipeStore.previewData = null;

    try {
        const [resR, resRecipeIng, resIngMaster, resS, resC, resG] = await Promise.all([
            publicApi.get('data/recipe/recipes.json'),
            publicApi.get('data/recipe/recipe_ingredient.json'),
            publicApi.get('data/recipe/ingredients.json'),
            publicApi.get('data/recipe/steps.json'),
            publicApi.get('data/social/comments.json'),
            publicApi.get('data/social/gallery.json')
        ]);

        const found = resR.data.find(r => Number(r.recipe_id) === recipeId);
        if (!found) {
            rawRecipe.value = null;
            return;
        }
        rawRecipe.value = found;

        const filteredLinks = resRecipeIng.data.filter(i => Number(i.recipe_id) === recipeId);
        rawIngredients.value = filteredLinks.map(link => {
            const masterInfo = resIngMaster.data.find(m => Number(m.ingredient_id) === Number(link.ingredient_id));
            return {
                ...link,
                ingredient_name: masterInfo?.ingredient_name || `食材 ID: ${link.ingredient_id}`,
                calories_per_100g: masterInfo?.kcal_per_100g || 0,
                protein_per_100g: masterInfo?.protein_per_100g || 0,
                fat_per_100g: masterInfo?.fat_per_100g || 0,
                carbs_per_100g: masterInfo?.carbs_per_100g || 0,
                unit_name: link.unit_name || masterInfo?.unit_name || '份',
                note: link.remark || ''
            };
        });

        rawSteps.value = resS.data.filter(s => Number(s.recipe_id) === recipeId)
            .sort((a, b) => (a.step_order || 0) - (b.step_order || 0));

        rawComments.value = resC.data.filter(c => Number(c.RECIPE_ID) === recipeId);
        const galleryRaw = resG.data.data || resG.data;
        rawGallery.value = galleryRaw.filter(g => Number(g.RECIPE_ID) === recipeId);
        servings.value = 1;

    } catch (err) {
        console.error('API 讀取失敗：', err);
    } finally {
        setTimeout(() => { isLoading.value = false; }, 100);
    }
};

onMounted(() => {
    fetchData();
    if (isPreviewMode.value) {
        toggleWorkspaceTopBar(false);
    }
});

onUnmounted(() => {
    toggleWorkspaceTopBar(true);
});

watch(() => isPreviewMode.value, (newVal) => {
    toggleWorkspaceTopBar(!newVal);
});

watch(() => [route.params.id, route.query.mode], () => {
    fetchData();
}, { deep: true });

// --- 4. 計算屬性 ---
const recipeIntroData = computed(() => {
    if (!rawRecipe.value) return null;

    let rawImg = rawRecipe.value.recipe_image_url ||
        rawRecipe.value.coverImg ||
        rawRecipe.value.recipe_cover_image || '';

    let finalImg = '';

    if (rawImg) {
        if (rawImg.startsWith('http') || rawImg.startsWith('data:') || rawImg.startsWith('/')) {
            finalImg = rawImg;
        } else {
            finalImg = `/${rawImg}`;
        }
    } else {
        finalImg = 'https://placehold.co/800x600?text=No+Image';
    }

    return {
        title: rawRecipe.value.recipe_title || rawRecipe.value.title || '未命名食譜',
        image: finalImg,
        time: formatTime(rawRecipe.value.recipe_total_time),
        difficulty: rawRecipe.value.recipe_difficulty || rawRecipe.value.difficulty || 1,
        description: rawRecipe.value.recipe_descreption || rawRecipe.value.recipe_description || rawRecipe.value.description || '暫無簡介'
    };
});

const stepsData = computed(() => {
    if (!rawSteps.value || rawSteps.value.length === 0) return [];
    const rId = rawRecipe.value?.recipe_id || route.params.id || '0';
    return rawSteps.value.map((s, index) => {
        let rawImg = s.step_image_url || s.image || s.img || '';
        let finalImg = '';
        if (rawImg && typeof rawImg === 'string' && rawImg.length > 0) {
            if (rawImg.startsWith('data:') || rawImg.startsWith('http')) {
                finalImg = rawImg;
            } else {
                let cleanPath = rawImg.replace(/^\//, '');
                if (cleanPath.includes('img/recipes/')) {
                    finalImg = `/${cleanPath}`;
                } else {
                    finalImg = `/img/recipes/${rId}/steps/${cleanPath}`;
                }
            }
        }
        return {
            id: s.step_id || s.id || `s-${index}`,
            title: s.step_title || s.title || `步驟 ${index + 1}`,
            content: s.step_content || s.content || s.text || '',
            image: finalImg,
            time: s.step_total_time || s.time || '',
            tags: s.tags || []
        };
    });
});

const commentList = computed(() => {
    return rawComments.value.map(c => ({
        userName: c.USER_NAME,
        handle: `user_${c.USER_ID}`,
        time: c.COMMENT_AT,
        content: c.COMMENT_TEXT,
        avatar: c.USER_URL || 'https://i.pravatar.cc/150',
        likes: Math.floor(Math.random() * 50)
    }));
});

const baseRecipeLikes = ref(0);
watch(rawRecipe, (newVal) => {
    if (newVal) {
        baseRecipeLikes.value = isPreviewMode.value ? 0 : Math.floor(Math.random() * 200) + 50;
    }
}, { immediate: true });

const displayRecipeLikes = computed(() => baseRecipeLikes.value + localLikesOffset.value);

const snapsData = computed(() => rawGallery.value.map(g => ({
    url: g.GALLERY_URL.startsWith('/') ? g.GALLERY_URL : `/${g.GALLERY_URL}`,
    comment: g.GALLERY_TEXT
})));

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

const formatTime = (timeVal) => {
    if (!timeVal || timeVal === '00:00' || timeVal === 0) return '0 分鐘';
    const timeStr = String(timeVal);
    if (timeStr.includes(':')) {
        const parts = timeStr.split(':');
        const hh = parseInt(parts[0], 10) || 0;
        const mm = parseInt(parts[1], 10) || 0;
        if (hh === 0) return `${mm} 分鐘`;
        return `${hh} 小時 ${mm} 分鐘`;
    }
    return `${timeStr} 分鐘`;
};

const ingredientsData = computed(() => rawIngredients.value.map(item => ({
    INGREDIENT_NAME: item.ingredient_name,
    amount: item.amount,
    unit_name: item.unit_name,
    note: item.note || '',
    calories_per_100g: item.calories_per_100g || 0,
    protein_per_100g: item.protein_per_100g || 0,
    fat_per_100g: item.fat_per_100g || 0,
    carbs_per_100g: item.carbs_per_100g || 0,
    unit_weight: 1
})));

const nutritionWrapper = computed(() => {
    if (!rawRecipe.value) return [];
    return [{
        calories_per_100g: rawRecipe.value.recipe_kcal_per_100g || 0,
        protein_per_100g: rawRecipe.value.recipe_protein_per_100g || 0,
        fat_per_100g: rawRecipe.value.recipe_fat_per_100g || 0,
        carbs_per_100g: rawRecipe.value.recipe_carbs_per_100g || 0,
        amount: 100,
        unit_weight: 1
    }];
});

const handleServingsChange = (newVal) => { servings.value = newVal; };

// --- 5. 檢舉食譜燈箱 ---
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
            <div class="title-content">
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
                            <BaseBtn title="改編集+" variant="outline" height="40" class="w-auto" />
                        </router-link>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-7 col-lg-12">
                    <RecipeIntro :info="recipeIntroData" :is-preview="isPreviewMode" />
                    <div class="d-lg-none">
                        <section class="mb-10">
                            <NutritionCard :servings="servings" :ingredients="nutritionWrapper"
                                @change-servings="handleServingsChange" />
                        </section>
                        <section class="mb-10">
                            <RecipeIngredients :servings="servings" :list="ingredientsData" />
                        </section>
                    </div>
                    <section class="mb-10 steps-section">
                        <RecipeSteps :steps="stepsData" />
                    </section>
                </div>

                <div class="col-5 col-lg-12">
                    <div class="d-none-lg">
                        <section class="mb-10">
                            <NutritionCard :servings="servings" :ingredients="nutritionWrapper"
                                @change-servings="handleServingsChange" />
                        </section>
                        <section class="mb-10">
                            <RecipeIngredients :servings="servings" :list="ingredientsData" />
                        </section>
                    </div>
                    <section v-if="!isPreviewMode" class="mb-10">
                        <RecipeComments :list="commentList" />
                    </section>
                </div>

                <div v-if="!isPreviewMode" class="col-12 cook-snap-full">
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

    <div v-if="!isPreviewMode" class="col-12">
        <RelatedRecipes :currentId="route.params.id" />
    </div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.preview-sticky-bar {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    z-index: 9999;
    padding-top: 12px;
    pointer-events: none;
    transition: all 0.3s ease;

    @media screen and (min-width: 1025px) {
        left: 260px;
        width: calc(100% - 260px);
    }

    .container {
        max-width: 1000px;
        margin: 0 auto;
        padding: 0 12px;
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
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);

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
            margin-left: 8px;

            &:hover {
                background-color: $primary-color-100;
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
            /* 保持圖示靠左 */
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

        /* ✨ 讓改編集按鈕在手機版推到最右邊 */
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
    @media screen and (max-width: 1024px) {
        display: none !important;
    }
}
</style>