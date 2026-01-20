<script setup>
import { ref, computed, onMounted } from 'vue';
import { publicApi } from '@/utils/publicApi'

import SearchBanner from '@/components/site/search/SearchBanner.vue'
import SearchResultCard from '@/components/site/search/SearchResultCard.vue'
import EmptyState from '@/components/site/RecipeOverview/NoResult.vue'
import PageBtn from '@/components/common/PageBtn.vue'

const recipes = ref([]);
const recipeTags = ref([]);
const tags = ref([]);
const searchQuery = ref('');

const currentPage = ref(1); 
const pageSize = 5;

onMounted(async () => {
    try{
        const [resRecipes, resRecipeTags, resTags ] = await Promise.all([
            publicApi.get('data/recipe/recipes.json'),
            publicApi.get('data/recipe/recipe_tag.json'),
            publicApi.get('data/recipe/tags.json')
        ]);
        recipes.value = resRecipes.data;
        recipeTags.value = resRecipeTags.data;
        tags.value = resTags.data;

    }catch(err){
        console.error("載入失敗", err);
    }
});

const getRecipeTags = (recipeId) => {
    const targetTagIds = recipeTags.value
        .filter(rt => rt.recipe_id === recipeId)
        .map(rt => rt.tag_id);
    return tags.value.filter(t => targetTagIds.includes(t.tag_id));
};

const filteredRecipes = computed(() => {
    const query = searchQuery.value.trim().toLowerCase();
    if(!query) return recipes.value;

    const matchTagIds = tags.value
    .filter(t => t.tag_name.toLowerCase()
    .includes(query))
    .map(t => t.tag_id);

    return recipes.value.filter(recipe => {
        const titleMatch = recipe.recipe_title.toLowerCase().includes(query);
        const tagMatch = recipeTags.value.some(rt => 
            rt.recipe_id === recipe.recipe_id && matchTagIds.includes(rt.tag_id)
        );
        return titleMatch || tagMatch;
    });
});

const totalPages = computed(() => {
    return Math.ceil(filteredRecipes.value.length/pageSize);
});

const paginateRecipes = computed(() => {
    const start = (currentPage.value - 1) * pageSize;
    const end = start + pageSize;
    return filteredRecipes.value.slice(start, end);
});

const handlePageChange = (newPage) => {
    currentPage.value = newPage;
    window.scrollTo({ top: 0, behavior: 'smooth' });
};

import { watch } from 'vue';
watch(searchQuery, () => {
    currentPage.value = 1;
});
</script>

<template>
    <div class="container">
        <div class="row">
            <div class="col-12">
                <SearchBanner v-model="searchQuery"/>
            </div>
        </div>
    </div>
    <div class="container">
        <div v-if="filteredRecipes.length > 0" class="row">
            <div class="col-12">
                <h3 class="zh-h3" v-if="searchQuery">「{{searchQuery}}」搜尋結果({{ filteredRecipes.length }})</h3>
                <h3 class="zh-h3" v-else>所有食譜({{ filteredRecipes.length }})</h3>
            </div>
            <div class="col-12" v-if="!isLoading">
                <SearchResultCard 
                v-for="item in paginateRecipes" 
                :key="item.recipe_id"
                :recipe="item" 
                :recipeTags="getRecipeTags(item.recipe_id)" />
            </div>
        </div>
        <div v-else class="row">
            <div class="no-result col-12">
                <EmptyState 
                title="找不到符合條件的食譜"
                description="推薦您前往「靈感廚房」用食材找食譜喔!"
                :buttons="[
                    { title: '查看所有食譜', variant: 'solid', emit: 'recipes' },
                    { title: '前往靈感廚房', variant: 'outline', emit: 'go-kitchen' }
                ]"
                @button-click="handleEmptyAction"
            />
            </div>
        </div>
    </div>
    <section class="container page-btn">
        <div class="row">
            <div class="col-12">
                <PageBtn :currentPage="currentPage" :totalPages="totalPages" @update:page="handlePageChange" />
            </div>
        </div>
    </section>
</template>

<style lang="scss" scoped>
    .page-btn{
        margin: 30px auto;
    }
</style>
