<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import { phpApi } from '@/utils/publicApi'
import { useRouter } from 'vue-router'
import { parsePublicFile } from '@/utils/parseFile';
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
const isLoading = ref(true);
//新增
const searchIngredientIds = ref([]);
const searchIngredientNames = ref([]);

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
                ingredients: searchIngredientIds.value.join(',')
            }
        });

        if (response.data && response.data.status === 'success') {
            const recipeData = response.data.data;

            // 2. 處理資料格式轉換
            allRecipe.value = recipeData.map(recipe => {
                // SQL 字串轉陣列處理
                // const recipeTagsNames = recipe.tag_names ? recipe.tag_names.split(',') : [];
                const finalTags = Array.isArray(recipe.tags) ? recipe.tags : [];
                const matchedIngredients = recipe.ingredient_ids
                    ? recipe.ingredient_ids.split(',').map(Number)
                    : [];

                // --- 圖片路徑處理優化 ---
                // 優先順序：recipe_image_url -> recipe_image -> image_url -> main_image
                const rawImgUrl = recipe.recipe_image_url || recipe.recipe_image || recipe.image_url || recipe.main_image;

                // 處理路徑：移除開頭的 '/' 避免雙重斜線，然後交給 parsePublicFile 組合完整網址
                // parsePublicFile 內部會判斷如果是 http 開頭就不動作，否則加上 VITE_FILE_URL
                const cleanImgUrl = rawImgUrl && rawImgUrl.startsWith('/') ? rawImgUrl.substring(1) : rawImgUrl;
                const finalImgUrl = parsePublicFile(cleanImgUrl);

                // --- 作者頭像處理優化 ---
                const rawAvatarUrl = recipe.author_image || recipe.author_avatar || recipe.user_avatar || recipe.avatar_url || recipe.user_image;
                const cleanAvatarUrl = rawAvatarUrl && rawAvatarUrl.startsWith('/') ? rawAvatarUrl.substring(1) : rawAvatarUrl;
                const finalAvatarUrl = parsePublicFile(cleanAvatarUrl);

                return {
                    id: recipe.recipe_id,
                    recipe_name: recipe.recipe_title,
                    difficulty: recipe.recipe_difficulty,
                    image_url: finalImgUrl, // 使用處理後的完整路徑 
                    tags: finalTags,
                    ingredient_ids: matchedIngredients,
                    nutritional_info: {
                        calories: `${Math.round(recipe.recipe_kcal_per_100g || 0)}kcal`,
                        serving_size: recipe.recipe_servings,
                        cooking_time: (() => {
                            // 處理時間格式 HH:MM:SS -> 分鐘數
                            if (!recipe.recipe_total_time) return '0分鐘';
                            const timeParts = recipe.recipe_total_time.split(':');
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
                    user_url: finalAvatarUrl // 使用處理後的完整頭像路徑
                };
            });

        } else {
            console.warn('API 回傳狀態非 success:', response.data);
            allRecipe.value = [];
        }

    } catch (error) {
        // 3. API 連線失敗或伺服器錯誤 (如 404, 500)
    } finally {
        isLoading.value = false;
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
        <div v-if="isLoading" class="row">
            <div class="col-12 loading-state">
                <div class="spinner-border text-primary" role="status"></div>
                <p class="zh-h5">正在載入食譜中...</p>
            </div>
        </div>
        <template v-else>
            <div v-if="recipes.length > 0" class="row">
                <div v-for="item in recipes" :key="item.id"
                    :to="{ name: 'workspace-recipe-detail', params: { id: item.id } }"
                    class="col-3 col-lg-6 recipe-cards">
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
        </template>

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
.loading-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    min-height: 300px; // 撐開一點空間，避免頁面跳動
    gap: 16px;
    color: $primary-color-700; // 假設你有這個變數

    p {
        animation: pulse 1.5s infinite; // 增加一個簡單的呼吸燈效果
    }
}

@keyframes pulse {
    0% {
        opacity: 0.5;
    }

    50% {
        opacity: 1;
    }

    100% {
        opacity: 0.5;
    }
}

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