<script setup>
import { ref, watch, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { publicApi } from '@/utils/publicApi';
import AdaptRecipeCard from '@/components/workspace/modifyrecipe/AdaptRecipeCard.vue';
import AdaptationDetailModal from '@/components/workspace/modifyrecipe/modals/AdaptationDetailModal.vue';
// 🏆 引入 Pinia Store
import { useNutritionStore } from '@/stores/nutritionStore.js';

const router = useRouter();
const route = useRoute();
const nutritionStore = useNutritionStore();

// --- 🏆 核心修正：抓取 MAMP 的檔案位址 ---
const fileUrl = import.meta.env.VITE_FILE_URL || 'http://localhost:8888/recimo_api/';

// --- 狀態定義 ---
const originalRecipe = ref({ id: null, title: '', coverImg: '', description: '', servings: 1 });
const variantItems = ref([]);

// --- 燈箱控制 ---
const isModalOpen = ref(false);
const selectedRecipe = ref(null);
const currentNutrition = ref(null);

async function openAdaptDetail(item) {
    // 🛑 唯讀邏輯：如果是來自 JSON 的資料（id 以 json- 開頭），直接中斷，不執行任何計算與彈窗
    if (String(item.id).startsWith('json-')) return;

    console.log('--- 🛡️ 熱量校正啟動 ---');

    // 1. 確保 Store 資料已加載
    if (!nutritionStore.isLoaded) {
        await nutritionStore.fetchMasterData();
    }

    const ingredients = item.ingredients || [];

    // 2. 份數抓取邏輯
    let finalServings = Number(
        item.recipe_servings ||
        item.servings ||
        originalRecipe.value.servings ||
        2
    );

    try {
        // 3. 計算總熱量
        const totalResult = nutritionStore.calculateRecipeNutrition(ingredients);

        // 🏆 異常高熱量修正
        if (totalResult.kcal > 1000 && finalServings === 1) {
            console.warn('偵測到異常高熱量且份數為 1，自動修正為 2 份計算');
            finalServings = 2;
        }

        // 4. 計算單份比例
        const scale = 1 / finalServings;

        currentNutrition.value = {
            kcal: Math.round(totalResult.kcal * scale),
            protein: (totalResult.protein * scale).toFixed(1),
            fat: (totalResult.fat * scale).toFixed(1),
            carbs: (totalResult.carbs * scale).toFixed(1),
            calories: totalResult.kcal * scale
        };

    } catch (err) {
        console.error('計算失敗:', err);
    }

    selectedRecipe.value = item;
    isModalOpen.value = true;
}

// 🏆 頁面掛載時預先載入食材庫
onMounted(async () => {
    await nutritionStore.fetchMasterData();
});

// 監聽路由變化載入資料
watch(
    () => [route.params.id, route.query.editId],
    async ([id, editId]) => {
        const targetId = id || editId;
        if (targetId) {
            await loadRecipeData(targetId);
        } else {
            initEmptyRecipe();
        }
    },
    { immediate: true }
);

async function loadRecipeData(recipeId) {
    try {
        const [resRecipes, resAdaptations, resIngredients] = await Promise.all([
            publicApi.get('data/recipe/recipes.json'),
            publicApi.get('data/recipe/recipe_adaptations.json'),
            publicApi.get('data/recipe/recipe_ingredient.json')
        ]);

        const allRecipes = resRecipes.data;
        const allAdaptations = resAdaptations.data;
        const targetParentId = Number(recipeId);

        // --- 🏆 核心修正：優化路徑對接邏輯 ---
        const fixPath = (url) => {
            if (!url) return 'https://placehold.co/800x600?text=No+Image';
            if (url.startsWith('http') || url.startsWith('data:') || url.startsWith('blob:')) return url;

            const base = fileUrl.endsWith('/') ? fileUrl : `${fileUrl}/`;
            const cleanPath = url.replace(/^\//, '');
            return `${base}${cleanPath}`;
        };

        // 1. 處理母食譜
        const found = allRecipes.find(r => Number(r.recipe_id || r.RECIPE_ID) === targetParentId);
        if (!found) return;

        const parentServings = Number(found.recipe_servings || found.RECIPE_SERVINGS || found.servings || 2);

        originalRecipe.value = {
            id: found.recipe_id || found.RECIPE_ID,
            title: found.recipe_title || found.title || found.RECIPE_TITLE,
            description: found.recipe_description || found.recipe_descreption || found.RECIPE_DESCRIPTION || '暫無簡介',
            coverImg: fixPath(found.recipe_image_url || found.recipe_cover_image || found.coverImg),
            servings: parentServings
        };

        // 2. 處理改編食譜
        const jsonAdaptations = allAdaptations
            .filter(a => Number(a.parent_recipe_id || a.PARENT_RECIPE_ID) === targetParentId)
            .map(adapt => {
                const childId = Number(adapt.child_recipe_id || adapt.CHILD_RECIPE_ID);
                const childInfo = allRecipes.find(r => Number(r.recipe_id || r.RECIPE_ID) === childId);
                if (!childInfo) return null;

                const childIngredients = resIngredients.data
                    .filter(i => Number(i.recipe_id || i.RECIPE_ID) === childId)
                    .map(ing => ({
                        ...ing,
                        id: ing.ingredient_id || ing.INGREDIENT_ID || ing.id
                    }));

                return {
                    id: `json-${childId}`,
                    title: adapt.adaptation_title || childInfo.recipe_title || childInfo.RECIPE_TITLE,
                    summary: adapt.adaptation_note || '暫無改編心得',
                    coverImg: fixPath(adapt.adaptation_image_url || childInfo.recipe_image_url),
                    is_mine: false,
                    recipe_descreption: childInfo.recipe_description || childInfo.RECIPE_DESCRIPTION || '暫無詳細內容',
                    recipe_servings: Number(childInfo.recipe_servings || childInfo.RECIPE_SERVINGS || parentServings),
                    ingredients: childIngredients
                };
            }).filter(Boolean);

        // 3. 處理本地改編
        const localRevisions = JSON.parse(localStorage.getItem('user_revisions') || '[]');
        const localAdaptations = localRevisions
            .filter(r => Number(r.parent_recipe_id) === targetParentId)
            .map(r => ({
                ...r,
                id: r.id || `local-${Date.now()}-${Math.random()}`,
                title: r.title || '未命名改編',
                summary: r.description || '暫無改編心得',
                coverImg: fixPath(r.coverImg || r.image), // 🏆 確保本地改編圖片路徑也經過處理
                is_mine: true,
                recipe_servings: Number(r.servings || r.recipe_servings || 1)
            }));

        variantItems.value = [...localAdaptations, ...jsonAdaptations];

    } catch (err) {
        console.error('載入失敗:', err);
    }
}

function deleteLocalRecipe(targetId) {
    if (!confirm('確定要刪除這個本地改編版本嗎？')) return;
    const localData = JSON.parse(localStorage.getItem('user_revisions') || '[]');
    const filtered = localData.filter(r => String(r.id) !== String(targetId));
    localStorage.setItem('user_revisions', JSON.stringify(filtered));
    loadRecipeData(route.params.id || route.query.editId);
}

function initEmptyRecipe() {
    originalRecipe.value = { id: null, title: '新食譜', coverImg: '', description: '', servings: 1 };
    variantItems.value = [];
}

function handleCreateNew() {
    if (!originalRecipe.value.id) return;
    router.push({
        path: '/workspace/edit-recipe',
        query: { editId: originalRecipe.value.id, action: 'adapt' }
    });
}

function goBack() {
    if (!originalRecipe.value.id) return;
    router.push(`/workspace/recipe-detail/${originalRecipe.value.id}`);
}
</script>

<template>
    <div class="variants-gallery container">
        <div class="row mb-40 desktop-only-btn fade-in-down">
            <div class="col-12 text-right">
                <BaseBtn title="返回原食譜" variant="outline" :width="120" @click="goBack" />
            </div>
        </div>

        <section class="original-recipe-hero mb-40">
            <div class="row align-center">
                <div class="col-7 col-md-12">
                    <div class="main-image-container">
                        <img :src="originalRecipe.coverImg" class="hero-img" />
                    </div>
                </div>
                <div class="col-5 col-md-12">
                    <div class="info-content">
                        <h1 class="zh-h2 mb-16">{{ originalRecipe.title }}</h1>
                        <p class="p-p1 color-p1 mb-24">{{ originalRecipe.description }}</p>
                        <div class="stat-tag p-p3 mb-24">
                            共有 {{ variantItems.length }} 個改編版本
                        </div>

                        <div class="mobile-only-btn">
                            <BaseBtn title="返回原食譜" variant="outline" class="w-100" @click="goBack" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="decorative-line"></div>
        </section>

        <div class="row align-stretch custom-grid">
            <div class="col-3 col-lg-4 col-md-6 mb-24 grid-item">
                <div class="add-card-placeholder full-height" @click="handleCreateNew">
                    <div class="add-content">
                        <span class="plus-icon">+</span>
                        <p class="zh-h4">創建食譜</p>
                        <p class="p-p3 uppercase">add recipe</p>
                    </div>
                </div>
            </div>

            <TransitionGroup name="staggered-list">
                <div v-for="(item, index) in variantItems" :key="item.id"
                    class="col-3 col-lg-4 col-md-6 mb-24 grid-item" :style="{
                        '--delay': index + 1,
                        'cursor': String(item.id).startsWith('json-') ? 'default' : 'pointer'
                    }" @click="openAdaptDetail(item)">

                    <div class="card-wrapper" style="position: relative; height: 100%;">
                        <AdaptRecipeCard class="demo-readonly-card" :recipe="{
                            title: item.title,
                            summary: item.summary,
                            coverImg: item.coverImg
                        }" :readonly="true" />

                        <button v-if="item.is_mine" class="local-delete-btn" title="刪除此改編版本"
                            @click.stop="deleteLocalRecipe(item.id)">
                            ✕
                        </button>
                    </div>
                </div>
            </TransitionGroup>
        </div>

        <AdaptationDetailModal v-model="isModalOpen" :recipe="selectedRecipe" :nutrition="currentNutrition" />
    </div>
</template>

<style lang="scss" scoped>
/* 🔴 以下 CSS 與你提供的完全一致，未做任何刪減或改動 */
@import '@/assets/scss/abstracts/_color.scss';

.mobile-only-btn {
    display: none !important;
}

.desktop-only-btn {
    display: block;
}

.fade-in-down {
    animation: fadeInDown 0.6s ease-out;
}

.original-recipe-hero {
    animation: fadeInUp 0.8s ease-out;

    .main-image-container {
        overflow: hidden;

        img {
            animation: imageScale 1.2s ease-out;
        }
    }
}

.staggered-list-enter-active {
    transition: all 0.6s cubic-bezier(0.34, 1.56, 0.64, 1);
    transition-delay: calc(var(--delay) * 0.1s);
}

.staggered-list-enter-from {
    opacity: 0;
    transform: translateY(40px) scale(0.9);
}

.decorative-line {
    height: 10px;
    background-color: $primary-color-100;
    border-radius: 4px;
    margin-top: 40px;
    transform-origin: left;
    animation: lineExtend 1s cubic-bezier(0.65, 0, 0.35, 1) forwards;
}

@keyframes fadeInDown {
    from {
        opacity: 0;
        transform: translateY(-20px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}

@keyframes fadeInUp {
    from {
        opacity: 0;
        transform: translateY(30px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}

@keyframes lineExtend {
    from {
        transform: scaleX(0);
    }

    to {
        transform: scaleX(1);
    }
}

@keyframes imageScale {
    from {
        transform: scale(1.1);
    }

    to {
        transform: scale(1);
    }
}

.custom-grid {
    display: flex;
    flex-wrap: wrap;

    &>span {
        display: contents;
    }
}

.variants-gallery {
    padding: 20px 0 60px;
}

.text-right {
    text-align: right;
}

.w-100 {
    width: 100% !important;
}

.original-recipe-hero {
    .main-image-container {
        width: 100%;
        height: 320px;
        border-radius: 16px;
        background-color: $neutral-color-100;

        .hero-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
    }

    .info-content {
        padding-left: 32px;
    }

    .color-p1 {
        color: $neutral-color-700;
        line-height: 2;
    }

    .stat-tag {
        display: inline-block;
        background: $primary-color-100;
        color: $primary-color-800;
        padding: 6px 16px;
        border-radius: 20px;
    }
}

.add-card-placeholder {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    border: 2px dashed $primary-color-400;
    border-radius: 12px;
    cursor: pointer;
    transition: all 0.3s ease;
    padding: 40px 20px;

    &:hover {
        background-color: $primary-color-100;
        transform: translateY(-8px);
        border-style: solid;
    }

    .add-content {
        text-align: center;
        color: $primary-color-700;

        .plus-icon {
            font-size: 56px;
            display: block;
        }

        .uppercase {
            color: $neutral-color-400;
            font-size: 12px;
            margin-top: 8px;
        }
    }
}

.demo-readonly-card {
    cursor: pointer;
    transition: all 0.4s cubic-bezier(0.165, 0.84, 0.44, 1);

    &:hover {
        transform: scale(1.05);
        box-shadow: 0 15px 35px rgba(0, 0, 0, 0.12);
    }

    :deep(.key-change-badge),
    :deep(.key-change-wrapper),
    :deep(.change-hint-overlay),
    :deep(.hover-overlay),
    :deep(.mask),
    :deep(.result-overlay),
    :deep(.adaptation-hover-info),
    :deep(.adaptation-result),
    :deep(.adapt-result-text),
    :deep(.overlay),
    :deep(.overlay-content) {
        display: none !important;
        opacity: 0 !important;
        visibility: hidden !important;
        pointer-events: none !important;
    }
}

@media screen and (max-width: 810px) {
    .desktop-only-btn {
        display: none !important;
    }

    .mobile-only-btn {
        display: block !important;
        margin-top: 16px;
    }

    .original-recipe-hero {
        .info-content {
            padding-left: 0;
            margin-top: 16px;
        }

        .main-image-container {
            height: 240px;
        }
    }

    .custom-grid {
        .grid-item {
            flex: 0 0 50% !important;
            max-width: 50% !important;
            padding: 0 8px !important;
        }
    }
}

.card-wrapper {
    &:hover {
        .local-delete-btn {
            opacity: 1;
        }
    }
}

.local-delete-btn {
    position: absolute;
    top: -10px;
    right: -10px;
    width: 28px;
    height: 28px;
    background-color: #ff4d4f;
    color: white;
    border: 2px solid white;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    cursor: pointer;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    z-index: 20;
    opacity: 0;
    transition: all 0.3s ease;

    &:hover {
        background-color: #ff7875;
        transform: scale(1.1);
    }
}

.full-height {
    height: 100%;
}

.mb-16 {
    margin-bottom: 16px;
}

.mb-24 {
    margin-bottom: 24px;
}

.mb-40 {
    margin-bottom: 40px;
}
</style>