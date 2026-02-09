<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { phpApi } from '@/utils/publicApi'
import { useRouter } from 'vue-router'
import { useAuthGuard } from '@/composables/useAuthGuard'
import BaseBtn from '@/components/common/BaseBtn.vue';
import { useFavoritesStore } from '@/stores/favoritesStore';
import { useAuthStore } from '@/stores/authStore';

import RecipeCardLg from '@/components/common/RecipeCardLg.vue'
import FilterSection from '@/components/site/RecipeOverview/FilterSection.vue'
import EmptyState from '@/components/site/RecipeOverview/NoResult.vue'
import PageBtn from '@/components/common/PageBtn.vue'
import RecipesCtaGroup from '@/components/site/RecipeOverview/RecipesCtaGroup.vue'
import Cook from '@/components/common/Cook.vue'

const isShow = ref(false);
const router = useRouter()
const { runWithAuth } = useAuthGuard()
const favoritesStore = useFavoritesStore();
const authStore = useAuthStore();
const allRecipe = ref([])
const currentPage = ref(1)
const pageSize = 6
//新增
const searchIngredientIds = ref([]);
const searchIngredientNames = ref([]);

const activeFilters = ref({
    time: "全部",
    difficulty: "全部",
    mealPortions: "全部",
    kcal: "全部"
});

watch(activeFilters, () => {
    currentPage.value = 1;
}, { deep: true });

//新增
watch(searchIngredientIds, () => {
    currentPage.value = 1;
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
                ingredients: searchIngredientIds.value.join(',') // 轉為 "1,2,3"
            }
        });
        
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
            let finalImgUrl = recipe.recipe_image_url || recipe.recipe_image || recipe.image_url || recipe.main_image;
                
                if (finalImgUrl && !finalImgUrl.startsWith('http')) {
                    // 1. 確保 base 結尾有斜線
                    const safeBase = apiBase.endsWith('/') ? apiBase : `${apiBase}/`;
                    // 2. 確保 path 開頭沒有斜線
                    const safePath = finalImgUrl.startsWith('/') ? finalImgUrl.substring(1) : finalImgUrl;
                    
                    // 3. 組合：這會產生 http://localhost:8888/recimo_api/img/recipes/...
                    finalImgUrl = `${safeBase}${safePath}`;
                }

            // 處理作者頭像路徑
            let finalAvatarUrl = recipe.author_image || recipe.author_avatar || recipe.user_avatar || recipe.avatar_url || recipe.user_image || '';
            if (finalAvatarUrl && !finalAvatarUrl.startsWith('http')) {
                const safeBase = apiBase.endsWith('/') ? apiBase : `${apiBase}/`;
                const safePath = finalAvatarUrl.startsWith('/') ? finalAvatarUrl.substring(1) : finalAvatarUrl;
                finalAvatarUrl = `${safeBase}${safePath}`;
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
                    name: recipe.author_name || recipe.user_name || 'Recimo',
                    likes: recipe.recipe_like_count,
                    id: recipe.author_id || recipe.user_id || 0,
                    handle: recipe.author_email || recipe.user_email || `user_${recipe.author_id || 0}`
                },
                author_name: recipe.author_name || recipe.user_name || 'Recimo',
                user_url: finalAvatarUrl
            };
        });
        
        } else {
        // 處理 PHP 回傳 status: "error" 的情況
        }

    } catch (error) {
        // 3. API 連線失敗或伺服器錯誤 (如 404, 500)
    }
};

// 在生命週期中呼叫它
onMounted(() => {
    // 統一載入收藏狀態
    const userId = authStore.user?.id || authStore.user?.user_id;
    if (userId) {
        favoritesStore.fetchFavorites(userId);
    }

    fetchRecipes();
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
        // 設定篩選 ID
        searchIngredientIds.value = ingredients.map(item => item.ingredient_id);

        // 存著名稱，方便 UI 顯示 "您選了：雞肉、洋蔥..."
        searchIngredientNames.value = ingredients.map(item => item.ingredient_name || '未知食材');

        //重置其他篩選器，避免條件衝突導致無結果
        activeFilters.value = {
            time: "全部",
            difficulty: "全部",
            mealPortions: "全部",
            kcal: "全部"
        };

        //關閉燈箱
        showCook.value = false;

        //滾動到食譜列表頂部 
        window.scrollTo({
            top: document.querySelector('.recipe-cards-section')?.offsetTop - 100 || 0,
            behavior: 'smooth'
        });

    } else {
        // 如果沒選食材就送出，視為取消
        clearIngredientFilter();
        showCook.value = false;
    }
};

//新增：清除食材篩選 
const clearIngredientFilter = () => {
    searchIngredientIds.value = [];
    searchIngredientNames.value = [];

};
const openKitchen = () => {
    showCook.value = true;
}

const handleCardClick = (id) => {
    runWithAuth(() => {
        router.push({
            name: 'workspace-recipe-detail',
            params: { id: id }
        })
    })
}
</script>

<template>
    <section class="container filter-content">
        <div class="row">
            <FilterSection v-model="activeFilters" @open-kitchen="openKitchen" />
        </div>

        <div v-if="searchIngredientIds.length > 0" class="row ingredient-filter-tag">
            <div class="col-12">
                <div class="alert-box p-p2">
                    <span>
                        <i class="fa-solid fa-utensils"></i>
                        正在搜尋包含以下食材的食譜：
                        <span class="highlight">{{ searchIngredientNames.join('、') }}</span>
                    </span>
                    <BaseBtn title="清除篩選" class="clear-btn" width="100px " variant="outline" height="30"
                        @click="clearIngredientFilter">
                    </BaseBtn>
                </div>
            </div>
        </div>
        <Cook v-if="showCook" @close="showCook = false" @cook-finish="handleCookFinish" />
    </section>

    <section class="container recipe-cards-section">
    </section>
    <section class="container recipe-cards-section">
        <div v-if="recipes.length > 0" class="row">
            <div v-for="item in recipes" :key="item.id" @click.prevent="handleCardClick(item.id)"
                class="col-4 col-md-12 recipe-cards">
                <RecipeCardLg :recipe="item" class="recipe-card" />
            </div>
        </div>
        <div v-else class="row">
            <div class="no-result col-12">
                <EmptyState title="找不到符合條件的食譜" description="推薦您前往「靈感廚房」用食材找食譜喔!" :buttons="[
                    { title: '查看所有食譜', variant: 'outline', emit: 'recipes' }

                ]" @button-click="handleEmptyAction" />
            </div>
        </div>

    </section>

    <section v-if="recipes.length > 0" class="container page-btn">
        <div class="row">
            <div class="col-12">
                <PageBtn :currentPage="currentPage" :totalPages="totalPages" @update:page="handlePageChange" />
            </div>
        </div>
    </section>
    <section class="container recipes-cta-group">
        <div class="row">
            <div class="col-12">
                <RecipesCtaGroup @open-kitchen="openKitchen" />
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
    cursor: pointer;
}

.page-btn {
    margin-bottom: 40px;
}

.recipe-card {
    margin-bottom: 20px;
}

@media screen and (max-width: 1024px) {
    .recipe-card {
        margin-bottom: 20px;

    }

    .page-btn {
        margin-bottom: 30px;
    }
}

@media screen and (max-width: 810px) {
    .page-btn {
        margin-bottom: 20px;
    }

    .recipes-cta-group {
        display: none;
    }
}

.alert-box {
    margin-top: 30px;
    margin-bottom: -10px;
    // display: flex;
    align-items: center;

    @media screen and (max-width: 810px) {
        flex-direction: column;
        align-items: flex-start;
    }
}

.clear-btn {
    margin-left: 24px;

    @media screen and (max-width: 810px) {
        margin-top: 10px;
        margin-bottom: -15px;
    }
}
</style>