<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import { phpApi } from '@/utils/publicApi'
import { useRouter } from 'vue-router'

import RecipeCardSm from '@/components/common/RecipeCardSm.vue'
import FilterSection from '@/components/site/RecipeOverview/FilterSection.vue'
import EmptyState from '@/components/site/RecipeOverview/NoResult.vue'
import PageBtn from '@/components/common/PageBtn.vue'
import Cook from '@/components/common/Cook.vue'

// const isShow = ref(false);
const router = useRouter();
const allRecipe = ref([])
const currentPage = ref(1)
const pageSize = 8
//新增
const searchIngredientIds = ref([]);

const activeFilters = ref({
    time: "全部",
    difficulty: "全部",
    mealPortions: "全部",
    kcal: "全部"
});

// 監聽篩選條件
watch(activeFilters, () => {
    currentPage.value = 1;
    fetchRecipes(); // 💡 條件變了，重新去抓過濾後的資料
}, { deep: true });

// 監聽食材搜尋
watch(searchIngredientIds, () => {
    currentPage.value = 1;
    fetchRecipes(); // 💡 食材變了，重新抓資料
});
const handlePageChange = (page) => {
    currentPage.value = page;
};

const fetchRecipes = async () => {
    try {
        // 1. 使用 phpApi 抓取資料
        const response = await phpApi.get('recipes/recipe_filter_get.php', {
            params: {
                time: activeFilters.value.time,
                difficulty: activeFilters.value.difficulty,
                mealPortions: activeFilters.value.mealPortions,
                kcal: activeFilters.value.kcal,
                ingredients: searchIngredientIds.value.join(',') // 把陣列 [1,2] 轉成字串 "1,2"
            }
        });
        
        // 偵錯用：確認 API 回傳的原始資料
        console.log('API 原始回應：', response.data);

    if (response.data && response.data.status === 'success') {
        const recipeData = response.data.data;
        const apiBase = phpApi.defaults.baseURL;
        // const imgBase = apiBase.replace('/api/', '/');

        // 2. 處理資料格式轉換
        allRecipe.value = recipeData.map(recipe => {
            // SQL 字串轉陣列處理
            const recipeTagsNames = recipe.tag_names ? recipe.tag_names.split(',') : [];
            const matchedIngredients = recipe.ingredient_ids 
            ? recipe.ingredient_ids.split(',').map(Number) 
            : [];

            // 圖片路徑校正
            let finalImgUrl = recipe.recipe_image_url;
                
                if (finalImgUrl && !finalImgUrl.startsWith('http')) {
                    // 1. 確保 base 結尾有斜線
                    const safeBase = apiBase.endsWith('/') ? apiBase : `${apiBase}/`;
                    // 2. 確保 path 開頭沒有斜線
                    const safePath = finalImgUrl.startsWith('/') ? finalImgUrl.substring(1) : finalImgUrl;
                    
                    // 3. 組合：這會產生 http://localhost:8888/recimo_api/img/recipes/...
                    finalImgUrl = `${safeBase}${safePath}`;
                }
            return {
                id: recipe.recipe_id,
                recipe_name: recipe.recipe_title,
                difficulty: recipe.recipe_difficulty,
                image_url: finalImgUrl,
                tags: recipeTagsNames,
                ingredient_ids: matchedIngredients,
                nutritional_info: {
                    calories: `${Math.round(recipe.recipe_kcal_per_100g || 0)}kcal`,
                    serving_size: recipe.recipe_servings,
                    cooking_time: (() => {
                            const timeParts = recipe.recipe_total_time.split(':'); // [HH, mm, ss]
                            const hours = parseInt(timeParts[0]) || 0;
                            const minutes = parseInt(timeParts[1]) || 0;
                            const totalMinutes = hours * 60 + minutes;
                            return `${totalMinutes}分鐘`;
                        })()
                },
                author: {
                    name: 'Recimo',
                    likes: recipe.recipe_like_count
                }
            };
        });
        
        console.log('成功轉換並存入 allRecipe！', allRecipe.value);

        } else {
        // 處理 PHP 回傳 status: "error" 的情況
        console.error('PHP 邏輯錯誤:', response.data.message);
        }

    } catch (error) {
        // 3. API 連線失敗或伺服器錯誤 (如 404, 500)
        console.error('API 連線失敗:', error);
        if (error.response) {
        console.log('錯誤狀態碼:', error.response.status);
        console.log('錯誤內容:', error.response.data);
        }
    }
};

// 在生命週期中呼叫它
onMounted(() => {
    fetchRecipes();
});


// const filteredRecipes = computed(() => {
//     return allRecipe.value.filter(recipe => {
//         const timeValue = parseInt(recipe.nutritional_info.cooking_time);
//         const timeMatch = activeFilters.value.time === "全部" || (
//             (activeFilters.value.time === "15分鐘內" && timeValue <= 15) ||
//             (activeFilters.value.time === "15-30分鐘" && timeValue > 15 && timeValue <= 30) ||
//             (activeFilters.value.time === "30-60分鐘" && timeValue > 30 && timeValue <= 60) ||
//             (activeFilters.value.time === "1小時以上" && timeValue > 60 && timeValue <= 180) ||
//             (activeFilters.value.time === "慢火長燉" && timeValue > 180)
//         );

//         const selectedDiff = activeFilters.value.difficulty;
//         const d = recipe.difficulty;

//         let difficultyMatch = false;
//         if (selectedDiff === "全部") {
//             difficultyMatch = true;
//         } else if (selectedDiff === "廚藝新手") {
//             difficultyMatch = (d >= 1 && d < 2);
//         } else if (selectedDiff === "基礎實作") {
//             difficultyMatch = (d >= 2 && d < 3);
//         } else if (selectedDiff === "進階挑戰") {
//             difficultyMatch = (d >= 3 && d < 4);
//         } else if (selectedDiff === "職人等級") {
//             difficultyMatch = (d >= 4 && d <= 5);
//         }

//         const portionMatch = activeFilters.value.mealPortions == "全部" || (
//             (activeFilters.value.mealPortions === "1人獨享" && recipe.nutritional_info.serving_size === 1) ||
//             (activeFilters.value.mealPortions === "2人世界" && recipe.nutritional_info.serving_size === 2) ||
//             (activeFilters.value.mealPortions === "3-4人家庭" && recipe.nutritional_info.serving_size >= 3 && recipe.nutritional_info.serving_size <= 4) ||
//             (activeFilters.value.mealPortions === "6人以上聚會" && recipe.nutritional_info.serving_size >= 6)
//         );

//         const kcalValue = parseInt(recipe.nutritional_info.calories);
//         const kcalMatch = activeFilters.value.kcal === "全部" || (
//             (activeFilters.value.kcal === "100kcal(輕食)" && kcalValue < 100) ||
//             (activeFilters.value.kcal === "150-300kcal(均衡)" && kcalValue > 150 && kcalValue <= 300) ||
//             (activeFilters.value.kcal === "300kcal以上(豐盛)" && kcalValue > 300)
//         );

//         //新增
//         let ingredientMatch = true;
//         if (searchIngredientIds.value.length > 0) {
//             // 使用 Array.prototype.some()：只要有一個符合就回傳 true
//             ingredientMatch = searchIngredientIds.value.some(searchId =>
//                 recipe.ingredient_ids.includes(searchId)
//             );
//         }

//         return timeMatch && difficultyMatch && portionMatch && kcalMatch && ingredientMatch;
//     });
// });

// 計算總頁數

const totalPages = computed(() => {
    return Math.ceil(allRecipe.value.length / pageSize);
});

// 根據當前頁碼計算應顯示的食譜
const recipes = computed(() => {
    const start = (currentPage.value - 1) * pageSize;
    return allRecipe.value.slice(start, start + pageSize);
});

const handleEmptyAction = (action) => {
    if (action === 'recipes') {
        activeFilters.value = { time: "全部", difficulty: "全部", mealPortions: "全部", kcal: "全部" };
        searchIngredientIds.value = [];
    } else if (action === 'go-kitchen') {
        // router.push('/inspiration-kitchen');
        openKitchen(); // 改成呼叫開燈箱函式
    }
};

//靈感廚房燈箱
const showCook = ref(false);
const handleCookFinish = (ingredients) => {
    if (ingredients && ingredients.length > 0) {
        searchIngredientIds.value = ingredients.map(item => item.ingredient_id);
    } else {
        searchIngredientIds.value = [];
    }
    showCook.value = false;
};
const openKitchen = () => {
    console.log("父層收到訊號了！準備打開燈箱..."); // 加入這行
    showCook.value = true;
}

</script>

<template>
    <section class="container filter-content">
        <div class="row">
            <FilterSection v-model="activeFilters" @open-kitchen="openKitchen" />
        </div>
        <Cook v-if="showCook" @close="showCook = false" @cook-finish="handleCookFinish" />
    </section>
    <section class="container recipe-cards-section">
        <div v-if="recipes.length > 0" class="row">
            <div v-for="item in recipes" :key="item.id"
                :to="{ name: 'workspace-recipe-detail', params: { id: item.id } }" class="col-3 col-lg-6 recipe-cards">
                <RecipeCardSm :recipe="item" class="recipe-card" />
            </div>
        </div>
        <div v-else class="row">
            <div class="no-result col-12">
                <EmptyState title="找不到符合條件的食譜" description="推薦您前往「靈感廚房」用食材找食譜喔!" :buttons="[
                    { title: '查看所有食譜', variant: 'outline', emit: 'recipes' },
                    // { title: '前往靈感廚房', variant: 'outline', emit: 'go-kitchen' }
                ]" @button-click="handleEmptyAction" />
            </div>
        </div>
    </section>

    <section class="container page-btn">
        <div class="row">
            <div class="col-12">
                <PageBtn :currentPage="currentPage" :totalPages="totalPages" @update:page="handlePageChange" />
            </div>
        </div>
    </section>
</template>

<style lang="scss" scoped>
.filter-content {
    margin-top: 40px;
}

.recipe-cards-section {
    margin: 60px auto 6px;
}

.recipe-cards {
    text-decoration: none;
    color: $neutral-color-800;

}

.page-btn {
    margin-top: 0px;
    margin-bottom: 80px;
}

.recipe-card {
    margin-bottom: 20px;
}

.cta-group-bg {
    width: 100%;
    height: 200px;

    img {
        width: 100%;
    }
}

@media screen and (max-width: 1024px) {
    .recipe-card {
        margin-bottom: 20px;

    }
}
</style>