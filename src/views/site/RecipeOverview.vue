<script setup>
import RecipeCardLg from '@/components/common/RecipeCardLg.vue'
import FilterSection from '@/components/site/RecipeOverview/FilterSection.vue'
import PageBtn from '@/components/common/PageBtn.vue'
import { ref, onMounted, computed } from 'vue';

const allRecipe = ref([])
const currentPage = ref(1)
const pageSize = 6

// 從 JSON 加載食譜資料
onMounted(async () => {
    try {
        const response = await fetch('/data/recipe/recipes.json');
        const recipesData = await response.json();

        // 將 JSON 資料轉換為 RecipeCardLg 所需的格式
        allRecipe.value = recipesData.map(recipe => ({
            recipe_name: recipe.recipe_title,
            image_url: recipe.recipe_image_url,
            tags: [], // 稍後可以根據 recipe_tag.json 填充
            nutritional_info: {
                calories: `${Math.round(recipe.recipe_kcal_per_100g)}kcal`,
                serving_size: recipe.recipe_servings,
                cooking_time: `${recipe.recipe_totle_time.split(':')[1]}分鐘`
            },
            author: {
                name: 'Recimo',
                likes: recipe.recipe_like_count
            }
        }));
    } catch (error) {
        console.error('載入食譜資料失敗:', error);
    }
});

// 計算總頁數
const totalPages = computed(() => {
    return Math.ceil(allRecipe.value.length / pageSize);
});

// 根據當前頁碼計算應顯示的食譜
const recipes = computed(() => {
    const start = (currentPage.value - 1) * pageSize;
    const end = start + pageSize;
    return allRecipe.value.slice(start, end);
});

// 頁碼變更處理
const handlePageChange = (page) => {
    currentPage.value = page;
};
</script>

<template>
    <section class="container filter-content">
        <div class="row">
            <FilterSection />
        </div>
    </section>
    <section class="container recipe-cards-section">
        <div class="row">
            <div v-for="item in recipes" :key="item.recipe_name" class="col-4 col-lg-12">
                <RecipeCardLg :recipe="item" class="recipe-card" />
            </div>
        </div>
    </section>

    <section class="container">
        <PageBtn :currentPage="currentPage" :totalPages="totalPages" @update:page="handlePageChange" />
    </section>

</template>

<style lang="scss" scoped>
.filter-content {
    margin-top: 40px;
}

.recipe-cards-section {
    margin: 60px auto;
}

@media screen and (max-width: 1024px) {
    .recipe-card {
        margin-bottom: 20px;

    }
}
</style>