<script setup>
import { ref, computed, onMounted } from 'vue';
import { phpApi } from '@/utils/publicApi'

import SearchBanner from '@/components/site/search/SearchBanner.vue'
import SearchResultCard from '@/components/site/search/SearchResultCard.vue'
import EmptyState from '@/components/site/RecipeOverview/NoResult.vue'
import PageBtn from '@/components/common/PageBtn.vue'

const recipes = ref([]);
const products = ref([]);
const recipeTags = ref([]);
const tags = ref([]);
const searchQuery = ref('');

const currentPage = ref(1); 
const pageSize = 5;
const isLoading = ref(true);

onMounted(async () => {
    try{
        const response = await phpApi.get('recipes/search_get.php');

        if (response.data.status === 'success') {
            const { data } = response.data;
            recipes.value = data.recipes;
            products.value = data.products;
            recipeTags.value = data.recipe_tag;
            tags.value = data.tags;
        }

    }catch(err){
        console.error("載入失敗", err);
    }finally {
        isLoading.value = false;
    }
});

const getProductForRecipe = (recipe) => {
    if(!recipe.linked_product_id) return null;
    return products.value.find(p => p.product_id === recipe.linked_product_id);
}

const getRecipeTags = (recipeId) => {
    const targetTagIds = recipeTags.value
        .filter(rt => rt.recipe_id === recipeId)
        .map(rt => rt.tag_id);
    return tags.value.filter(t => targetTagIds.includes(t.tag_id));
};

//篩選
const filteredRecipes = computed(() => {
    const query = searchQuery.value.trim().toLowerCase();
    if(!query) return recipes.value;

    const matchTagIds = tags.value
    .filter(t => t.tag_name.toLowerCase()
    .includes(query))
    .map(t => t.tag_id);

    return recipes.value.filter(recipe => {
        const titleMatch = recipe.recipe_title.toLowerCase().includes(query);

        const product = getProductForRecipe(recipe);
        const productMatch = product? product.product_name.toLowerCase().includes(query):false;
        const productCategoryMatch = product? product.product_category.toLowerCase().includes(query):false;
        const tagMatch = recipeTags.value.some(rt => 
            rt.recipe_id === recipe.recipe_id && matchTagIds.includes(rt.tag_id)
        );
        return titleMatch || productMatch || productCategoryMatch || tagMatch;
    });
});
//計算食譜、料理包總數
const displayCounts = computed(() => {
    const query = searchQuery.value.trim().toLowerCase();
    if(!query){
        return{
            recipes: recipes.value.length,
            products: products.value.length
        };
    }
    const currentResults = filteredRecipes.value;
    const recipeCount = currentResults.length;
    const productCount = currentResults.filter(recipe => recipe.linked_product_id !== null).length;
    return{
        recipes: recipeCount,
        products: productCount
    }
})

//計算頁數
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
    <div class="container fade-in-init">
        <div class="row">
            <div class="col-12">
                <SearchBanner v-model="searchQuery"/>
            </div>
        </div>
    </div>
    <div class="container">
        <div v-if="filteredRecipes.length > 0" class="row">
            <div class="col-12 result-title">
                <h3 class="zh-h3" v-if="searchQuery">「{{searchQuery}}」搜尋結果</h3>
                <h3 class="zh-h3" v-else>所有好料理</h3>
                <div class="count-badge-group p-p2">
                    <span>{{ displayCounts.recipes }}筆食譜</span>
                    <span> | </span>
                    <span>{{ displayCounts.products }}筆料理包</span>
                </div>

            </div>
            <div class="col-12" v-if="!isLoading">
                <SearchResultCard 
                v-for="item in paginateRecipes" 
                :key="item.recipe_id"
                :recipe="item"
                :product="getProductForRecipe(item)" 
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
    .result-title{
        display: flex;
        align-items: end;
        gap: 12px;
    }
    .fade-in-init {
        animation: fadeInScale 0.8s ease-out forwards;
    }

    @keyframes fadeInScale {
        from {
            opacity: 0;
            transform: scale(0.98);
        }

        to {
            opacity: 1;
            transform: scale(1);
        }
    }
</style>
