<script setup>
import { ref, computed, watch } from 'vue';
import { useRoute } from 'vue-router';
import RecipeSteps from '../../components/workspace/recipedetail/RecipeSteps.vue';
import NutritionCard from '../../components/workspace/recipedetail/NutritionCard.vue';
import RecipeIngredients from '../../components/workspace/recipedetail/RecipeIngredients.vue';
import RecipeComments from '../../components/workspace/recipedetail/RecipeComments.vue';
import CookSnap from '../../components/workspace/recipedetail/CookSnap.vue';
import RecipeIntro from '../../components/workspace/recipedetail/RecipeIntro.vue';

const route = useRoute();

// --- 1. 響應式資料狀態 ---
const rawRecipe = ref(null);
const rawIngredients = ref([]);
const rawSteps = ref([]);
const servings = ref(1);
const isLoading = ref(true);

// 備用食材名稱映射表
const ingredientNameMap = {
    390: "高筋麵粉",
    496: "酵母粉",
    497: "溫水",
};

// --- 2. 資料獲取邏輯 ---
const fetchData = async () => {
    isLoading.value = true;
    const recipeId = Number(route.params.id) || 1;

    try {
        const [resR, resI, resS] = await Promise.all([
            fetch('/data/recipe/recipes.json').then(r => r.json()),
            fetch('/data/recipe/ingredients.json').then(r => r.json()),
            fetch('/data/recipe/steps.json').then(r => r.json())
        ]);

        rawRecipe.value = resR.find(r => Number(r.recipe_id) === recipeId) || null;
        rawIngredients.value = resI.filter(i => Number(i.recipe_id) === recipeId);
        rawSteps.value = resS.filter(s => Number(s.recipe_id) === recipeId)
            .sort((a, b) => a.step_order - b.step_order);

        if (rawRecipe.value) {
            servings.value = rawRecipe.value.recipe_servings;
        }
    } catch (error) {
        console.error("資料讀取失敗:", error);
    } finally {
        setTimeout(() => { isLoading.value = false; }, 100);
    }
};

watch(() => route.params.id, () => fetchData(), { immediate: true });

// --- 3. 資料轉換邏輯 ---

const formatTime = (timeStr) => {
    if (!timeStr) return '0 分鐘';
    const parts = timeStr.split(':');
    const hours = parseInt(parts[0]);
    const minutes = parseInt(parts[1]);
    return hours > 0 ? `${hours} 小時 ${minutes} 分鐘` : `${minutes} 分鐘`;
};

const recipeIntroData = computed(() => {
    if (!rawRecipe.value) return null;
    return {
        title: rawRecipe.value.recipe_title,
        image: rawRecipe.value.recipe_image_url,
        time: formatTime(rawRecipe.value.recipe_total_time),
        difficulty: rawRecipe.value.recipe_difficulty,
        description: rawRecipe.value.recipe_descreption
    };
});

// 食材表格資料
const ingredientsData = computed(() => {
    return rawIngredients.value.map(item => ({
        INGREDIENT_NAME: item.ingredient_name || ingredientNameMap[item.ingredient_id] || `食材 ID: ${item.ingredient_id}`,
        amount: item.amount,
        unit_name: item.unit_name,
        note: item.note || '',
        // 保留營養數值基礎
        calories_per_100g: item.calories_per_100g || 0,
        protein_per_100g: item.protein_per_100g || 0,
        fat_per_100g: item.fat_per_100g || 0,
        carbs_per_100g: item.carbs_per_100g || 0,
        unit_weight: 1
    }));
});

// 【核心修正】營養標籤資料：從食譜主表提取計算好的總值
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

const stepsData = computed(() => {
    return rawSteps.value.map(s => {
        let processedImage = s.step_image_url || '';
        if (processedImage.toLowerCase().endsWith('.jpg')) {
            processedImage = processedImage.replace(/\.jpg$/i, '.png');
        }
        return {
            title: s.step_title,
            content: s.step_content,
            image: processedImage
        };
    });
});

const handleServingsChange = (newVal) => {
    servings.value = newVal;
};

// 留言與 CookSnap 資料還原
const commentList = ref([
    { userName: 'Leo Harrison', handle: 'leo_h_bake', time: '2d ago', content: '質地非常完美！跟著步驟圖示觀察蛋白霜的尖角狀態真的很關鍵。口感輕盈像雲朵一樣。', avatar: 'https://i.pravatar.cc/150?u=leo', likes: 55 },
    { userName: 'Marcus Miller', handle: 'mar_cooks', time: '1w ago', content: '排版非常人性化。當我手上沾滿麵粉時，這種文字在圖片上方的排版超有幫助。', avatar: 'https://i.pravatar.cc/150?u=marcus', likes: 42 },
    { userName: 'Sophia Chen', handle: 'sophia_lab', time: '5h ago', content: '數據精確且具科學性。我非常喜歡你們提供的精確分量數據。', avatar: 'https://i.pravatar.cc/150?u=sophia', likes: 21 }
]);

const SnapsData = [
    { url: '/img/social/32/1.jpg', comment: '第一次做就上手！口感真的很綿密。' },
    { url: '/img/social/32/2.jpg', comment: '加了點蜂蜜後味道更提升了。' },
    { url: '/img/social/32/3.jpg', comment: '孩子們超愛，這是我的週末必備甜點。' },
    { url: '/img/social/32/4.jpg', comment: '照著做也能做出這種療癒的晃動感。' },
    { url: '/img/social/32/5.jpg', comment: '沒開玩笑，超級好吃!' }
];
</script>

<template>
    <div class="recipe-container-root" v-if="!isLoading && rawRecipe">
        <main class="container">
            <header class="page-header">
                <router-link :to="`/workspace/modify-recipe/${rawRecipe.recipe_id}`">
                    <BaseBtn title="改編集+" variant="outline" height="30" class="w-auto" />
                </router-link>
            </header>

            <div class="title-content">
                <div class="zh-h2">
                    <i-material-symbols-restaurant-rounded class="main-icon" />
                    {{ recipeIntroData.title }}
                </div>
                <div class="icon-group">
                    <i-material-symbols:edit-outline-rounded />
                    <i-material-symbols-thumb-up-outline />
                    <i-material-symbols-share-outline />
                </div>
            </div>

            <div class="row">
                <div class="col-7 col-lg-12">
                    <section class="mb-10">
                        <RecipeIntro :info="recipeIntroData" />
                    </section>

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
                    <section class="mb-10">
                        <RecipeComments :list="commentList" />
                    </section>
                </div>

                <div class="col-12 cook-snap-full">
                    <section class="mb-10 content-wrapper">
                        <CookSnap :list="SnapsData" />
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
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.loading-state,
.error-state {
    text-align: center;
    padding: 100px 0;
    color: $primary-color-700;
}

.recipe-container-root {
    background-color: $neutral-color-white;
    min-height: 100vh;
    padding: 0 0 100px 0;

    @media screen and (max-width: 810px) {
        padding-top: 10px !important;
    }
}

.page-header {
    display: flex;
    justify-content: flex-end;
    padding-top: 10px;
}

.title-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 12px;
    padding: 20px 0;
    margin-bottom: 20px;
    border-bottom: 1px solid $neutral-color-100;

    .zh-h2 {
        display: flex;
        align-items: center;
        gap: 12px;
        color: $neutral-color-black;
        margin: 0;

        .main-icon {
            font-size: 24px;
            flex-shrink: 0;
        }

        @media screen and (max-width: 1024px) {
            width: 100%;
        }
    }

    .icon-group {
        display: flex;
        align-items: center;
        gap: 20px;
        color: $primary-color-700;

        @media screen and (max-width: 1024px) {
            width: 100%;
            justify-content: flex-start;
            margin-top: 10px;
        }

        svg {
            font-size: 24px;
            cursor: pointer;
            transition: color 0.2s;

            &:hover {
                color: $primary-color-400;
            }
        }
    }
}

// 響應式控制
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

.cook-snap-full {
    display: flex !important;
    justify-content: center;
    width: 100%;
    margin-top: 40px;
    background-color: $neutral-color-100;
    padding-top: 40px;

    .content-wrapper {
        width: 100%;
        max-width: 800px;
    }
}

.steps-section {
    margin-top: 40px;

    @media screen and (max-width: 810px) {
        margin-top: 20px !important;
    }
}

// 捲軸修正
:global(.workspace-layout),
:global(.workspace-layout .page-content),
:global(html, body) {
    height: auto !important;
    overflow: visible !important;
    overflow-y: auto !important;
}
</style>