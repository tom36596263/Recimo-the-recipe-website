<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import { publicApi } from '@/utils/publicApi'
import { useRouter } from 'vue-router'

import RecipeCardLg from '@/components/common/RecipeCardLg.vue'
import FilterSection from '@/components/site/RecipeOverview/FilterSection.vue'
import EmptyState from '@/components/site/RecipeOverview/NoResult.vue'
import PageBtn from '@/components/common/PageBtn.vue'
import RecipesCtaGroup from '@/components/site/RecipeOverview/RecipesCtaGroup.vue'
import Cook from '@/components/common/Cook.vue'


const router = useRouter();
const allRecipe = ref([])
const currentPage = ref(1)
const pageSize = 6

const activeFilters = ref({
    time: "全部",
    difficulty: "全部",
    mealPortions: "全部",
    kcal: "全部"
});

watch(activeFilters, () => {
    currentPage.value = 1;
}, { deep: true });

const handlePageChange = (page) => {
    currentPage.value = page;
};

onMounted(async () => {
    try {
        const [resRecipes, resRecipeTags, resTags] = await Promise.all([
            publicApi.get('data/recipe/recipes.json'),
            publicApi.get('data/recipe/recipe_tag.json'),
            publicApi.get('data/recipe/tags.json')
        ]);

        const recipeData = resRecipes.data;
        const recipeTagsData = resRecipeTags.data;
        const tagsData = resTags.data;

        const tagMap = {};
        tagsData.forEach(tag => {
            tagMap[tag.tag_id] = tag.tag_name;
        });

        const base = import.meta.env.BASE_URL;
        allRecipe.value = recipeData.map(recipe => {

            const matchedTagIds = recipeTagsData
                .filter(rt => rt.recipe_id === recipe.recipe_id)
                .map(rt => rt.tag_id);

            // 透過 tagMap 轉換成 tag_name 陣列
            const recipeTagsNames = matchedTagIds.map(id => tagMap[id]).filter(Boolean);

            return {
                id: recipe.recipe_id,
                recipe_name: recipe.recipe_title,
                difficulty: recipe.recipe_difficulty,
                image_url: recipe.recipe_image_url.startsWith('http')
                    ? recipe.recipe_image_url
                    : `${base}${recipe.recipe_image_url}`.replace(/\/+/g, '/'),
                tags: recipeTagsNames,
                nutritional_info: {
                    calories: `${Math.round(recipe.recipe_kcal_per_100g)}kcal`,
                    serving_size: recipe.recipe_servings,
                    cooking_time: `${recipe.recipe_total_time.split(':')[1]}分鐘`
                },
                author: {
                    name: 'Recimo',
                    likes: recipe.recipe_like_count
                }
            };
        });
    } catch (error) {
        console.error('載入資料失敗:', error);
    }
});


const filteredRecipes = computed(() => {
    return allRecipe.value.filter(recipe => {
        const timeValue = parseInt(recipe.nutritional_info.cooking_time);
        const timeMatch = activeFilters.value.time === "全部" || (
            (activeFilters.value.time === "15分鐘內" && timeValue <= 5) ||
            (activeFilters.value.time === "15-30分鐘" && timeValue > 15 && timeValue <= 30) ||
            (activeFilters.value.time === "30-60分鐘" && timeValue > 30 && timeValue <= 60) ||
            (activeFilters.value.time === "1小時以上" && timeValue > 60 && timeValue <= 180) ||
            (activeFilters.value.time === "慢火長燉" && timeValue > 180)
        );

        const selectedDiff = activeFilters.value.difficulty;
        const d = recipe.difficulty;

        let difficultyMatch = false;
        if (selectedDiff === "全部") {
            difficultyMatch = true;
        } else if (selectedDiff === "廚藝新手") {
            difficultyMatch = (d >= 1 && d < 2);
        } else if (selectedDiff === "基礎實作") {
            difficultyMatch = (d >= 2 && d < 3);
        } else if (selectedDiff === "進階挑戰") {
            difficultyMatch = (d >= 3 && d < 4);
        } else if (selectedDiff === "職人等級") {
            difficultyMatch = (d >= 4 && d <= 5);
        }

        const portionMatch = activeFilters.value.mealPortions == "全部" || (
            (activeFilters.value.mealPortions === "1人獨享" && recipe.nutritional_info.serving_size === 1) ||
            (activeFilters.value.mealPortions === "2人世界" && recipe.nutritional_info.serving_size === 2) ||
            (activeFilters.value.mealPortions === "3-4人家庭" && recipe.nutritional_info.serving_size >= 3 && recipe.nutritional_info.serving_size <= 4) ||
            (activeFilters.value.mealPortions === "6人以上聚會" && recipe.nutritional_info.serving_size >= 6)
        );

        const kcalValue = parseInt(recipe.nutritional_info.calories);
        const kcalMatch = activeFilters.value.kcal === "全部" || (
            (activeFilters.value.kcal === "100kcal(輕食)" && kcalValue < 100) ||
            (activeFilters.value.kcal === "150-300kcal(均衡)" && kcalValue > 150 && kcalValue <= 300) ||
            (activeFilters.value.kcal === "300kcal以上(豐盛)" && kcalValue > 300)
        );

        return timeMatch && difficultyMatch && portionMatch && kcalMatch;
    });
});

// 計算總頁數
const totalPages = computed(() => {
    return Math.ceil(filteredRecipes.value.length / pageSize);
});

// 根據當前頁碼計算應顯示的食譜
const recipes = computed(() => {
    const start = (currentPage.value - 1) * pageSize;
    return filteredRecipes.value.slice(start, start + pageSize);
});

const handleEmptyAction = (action) => {
    if (action === 'recipes') {
        activeFilters.value = { time: "全部", difficulty: "全部", mealPortions: "全部", kcal: "全部" };
    } else if (action === 'go-kitchen') {
        // router.push('/inspiration-kitchen');
        openKitchen(); // 改成呼叫開燈箱函式
    }
};

//靈感廚房燈箱
const showCook = ref(false);
const handleCookFinish = (ingredients) => {
    console.log('收到食材，可以進行搜尋或是跳轉：', ingredients);
    showCook.value = false;
};
const openKitchen = () => {
    console.log("🔥 父層收到訊號了！準備打開燈箱..."); // 加入這行
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
            <router-link v-for="item in recipes" :key="item.id"
                :to="{ name: 'workspace-recipe-detail', params: { id: item.id } }" class="col-4 col-md-12 recipe-cards">
                <RecipeCardLg :recipe="item" class="recipe-card" />
            </router-link>
        </div>
        <div v-else class="row">
            <div class="no-result col-12">
                <EmptyState title="找不到符合條件的食譜" description="推薦您前往「靈感廚房」用食材找食譜喔!" :buttons="[
                    { title: '查看所有食譜', variant: 'outline', emit: 'recipes' }

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
    <section class="container">
        <div class="row">
            <div class="col-12">
                <RecipesCtaGroup />
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
}
</style>