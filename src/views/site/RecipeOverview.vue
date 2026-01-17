<script setup>
import { publicApi } from '@/utils/publicApi';

import RecipeCardLg from '@/components/common/RecipeCardLg.vue'
import FilterSection from '@/components/site/RecipeOverview/FilterSection.vue'
import PageBtn from '@/components/common/PageBtn.vue'
import { ref, onMounted, computed } from 'vue';

const allRecipe = ref([])
const currentPage = ref(1)
const pageSize = 6

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

        allRecipe.value = resRecipes.map(recipe => {

            const matchedTagIds = recipeTagsData
                .filter(rt => rt.recipe_id === recipe.recipe_id)
                .map(rt => rt.tag_id);

            // 透過 tagMap 轉換成 tag_name 陣列
            const recipeTagsNames = matchedTagIds.map(id => tagMap[id]).filter(Boolean);

            return {
                recipe_name: recipe.recipe_title,
                image_url: recipe.recipe_image_url,
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
                <RecipeCardLg :recipe="item" class="recipe-card"/>
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
    .filter-content{
        margin-top: 40px;
    }
    .recipe-cards-section{
        margin: 60px auto 30px ;
    }
    .page-btn{
        margin-bottom: 30px;
    }
    .recipe-card{
        margin-bottom:20px;
    }
    @media screen and (max-width: 1024px){
        .recipe-card{
            margin-bottom: 20px;

        }
    }
</style>