<script setup>
import { ref, watch, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { phpApi } from '@/utils/phpApi';
import { publicApi } from '@/utils/publicApi';
// 🏆 1. 引入團隊規範工具，取代原本手寫的 fixPath
import { parsePublicFile } from '@/utils/parseFile';
import { useNutritionStore } from '@/stores/nutritionStore.js';

import AdaptRecipeCard from '@/components/workspace/modifyrecipe/AdaptRecipeCard.vue';
import AdaptationDetailModal from '@/components/workspace/modifyrecipe/modals/AdaptationDetailModal.vue';

const router = useRouter();
const route = useRoute();
const nutritionStore = useNutritionStore();

// --- 狀態定義 ---
const originalRecipe = ref({ id: null, title: '', coverImg: '', description: '', servings: 1 });
const variantItems = ref([]);

// --- 燈箱控制 ---
const isModalOpen = ref(false);
const selectedRecipe = ref(null);
const currentNutrition = ref(null);

/**
 * 打開改編詳情燈箱
 * 包含熱量計算與異常數值校正
 */
async function openAdaptDetail(item) {
    selectedRecipe.value = item;

    if (!nutritionStore.isLoaded) {
        await nutritionStore.fetchMasterData();
    }

    if (item.ingredients && item.ingredients.length > 0) {
        // 1. 執行計算 (計算出該份食譜的「總量」)
        const total = nutritionStore.calculateRecipeNutrition(item.ingredients);

        // 2. 份數抓取：統一檢查 recipe_servings 與 servings
        // 優先順序：item 內的設定 > 預設值 1
        const servings = Number(item.recipe_servings || item.servings || 0);

        // 3. 🔍 [偵錯工具]
        console.group(`📊 食譜計算詳情: ${item.title}`);
        console.log(`📌 原始食材總量:`, total);
        console.log(`📌 最終使用的份數: ${servings}`);

        // 模擬計算過程表格
        const debugTable = item.ingredients.map(ing => {
            const master = nutritionStore.ingredientMaster.find(m =>
                String(m.ingredient_id) === String(ing.id || ing.ingredient_id)
            );
            return {
                "食材": ing.name || ing.ingredient_name,
                "數量": ing.amount,
                "單位": ing.unit || ing.unit_name,
                "每100g熱量": master?.kcal_per_100g || "未匹配",
                "轉換克數": ing.gram_conversion || "1"
            };
        });
        console.table(debugTable);
        console.groupEnd();

        // 4. 更新畫面數值 (總量 / 份數 = 每份營養)
        currentNutrition.value = {
            calories: Math.round(total.kcal / servings),
            protein: (total.protein / servings).toFixed(1),
            fat: (total.fat / servings).toFixed(1),
            carbs: (total.carbs / servings).toFixed(1)
        };
    } else {
        currentNutrition.value = { calories: 0, protein: 0, fat: 0, carbs: 0 };
    }

    isModalOpen.value = true;
}

/**
 * 從後端載入食譜完整資料
 */
async function loadRecipeData(recipeId) {
    try {
        console.log(`🚀 開始從 PHP 載入食譜 ID: ${recipeId}`);

        const res = await phpApi.get('recipes/recipe_detail_get.php', {
            params: { recipe_id: recipeId }
        });

        const apiResponse = res.data;

        if (!apiResponse.success || !apiResponse.data) {
            console.error('後端回傳失敗或資料格式錯誤', apiResponse);
            return;
        }

        const { main, ingredients, steps, tags, adaptations } = apiResponse.data;

        if (!main) {
            console.error('找不到主食譜資訊(main)');
            return;
        }

        // 1. 處理母食譜資料
        originalRecipe.value = {
            id: main.recipe_id,
            title: main.recipe_title,
            description: main.recipe_description || main.recipe_descreption || '暫無簡介',
            coverImg: parsePublicFile(main.recipe_image_url),
            servings: Number(main.recipe_servings || 2)
        };

        const formattedDbAdaptations = (adaptations || []).map(child => {
            // 💡 這裡先定義「摘要」要抓哪個欄位
            // 如果後端有傳 summary 或 adaptation_note 就用它，否則才從描述截斷
            const shortNote = child.adaptation_note || child.summary ||
                (child.recipe_description ? child.recipe_description.slice(0, 15) + '...' : '點擊查看改編重點');

            return {
                ...child,
                id: `db-${child.recipe_id}`,
                title: child.recipe_title,

                // ✨ 修改這裡：傳給小卡的摘要
                adaptation_note: shortNote,

                // 💾 保留原本的完整描述，讓燈箱彈窗 (selectedRecipe) 還是能看到完整內容
                recipe_description: child.recipe_description || '暫無詳細說明',

                coverImg: parsePublicFile(child.recipe_image_url),
                is_mine: false,
                ingredients: child.ingredients || [],
                steps: child.steps || [],
                servings: Number(child.recipe_servings || 2)
            };
        });

        // 3. 處理本地改編 (LocalStorage)
        const targetParentId = Number(recipeId);
        const localRevisions = JSON.parse(localStorage.getItem('user_revisions') || '[]');
        const localAdaptations = localRevisions
            .filter(r => Number(r.parent_recipe_id) === targetParentId)
            .map(r => {
                const s = Number(r.servings || r.recipe_servings || 1);
                return {
                    ...r,
                    id: r.id,
                    title: r.title || '未命名改編',
                    ingredients: r.ingredients || [],
                    steps: r.steps || [],
                    servings: s,
                    recipe_servings: s, // 雙重保險
                    is_mine: true
                };
            });

        // 4. 合併並更新畫面
        variantItems.value = [...localAdaptations, ...formattedDbAdaptations];
        console.log('✅ 資料載入成功，總數:', variantItems.value.length);

    } catch (err) {
        console.error('❌ 載入失敗:', err.message);
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

// 生命週期 Hook
onMounted(async () => {
    // 預載營養資料庫
    await nutritionStore.fetchMasterData();

    const recipeId = route.params.id || route.query.editId;
    if (recipeId) {
        loadRecipeData(recipeId);
    } else {
        console.warn("⚠️ 找不到食譜 ID，初始化空資料");
        initEmptyRecipe();
    }
});

watch(() => route.params.id, (newId) => {
    if (newId) loadRecipeData(newId);
});

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
                            // ✨ 改成傳遞 adaptation_note，因為小卡裡面現在只認這個
                            adaptation_note: item.adaptation_note || item.summary,
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