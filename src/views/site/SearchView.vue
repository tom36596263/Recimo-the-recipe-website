<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { publicApi } from '@/utils/publicApi';

import SearchBanner from '@/components/site/search/SearchBanner.vue';
import SearchResultCard from '@/components/site/search/SearchResultCard.vue';
import EmptyState from '@/components/site/RecipeOverview/NoResult.vue';
import PageBtn from '@/components/common/PageBtn.vue';

// 1. 定義響應式變數
const recipes = ref([]);
const products = ref([]);
const recipeTags = ref([]);
const tags = ref([]);
const searchQuery = ref('');
const currentPage = ref(1); 
const pageSize = 5;
const isLoading = ref(true);

// 2. 取得搜尋結果的函式 (整合後端)
const fetchSearchResults = async (keyword = '') => {
    isLoading.value = true;
    try {
        const [resRecipes,resProducts, resRecipeTags, resTags ] = await Promise.all([
            publicApi.get('data/recipe/recipes.json'),
            publicApi.get('data/mall/products.json'),
            publicApi.get('data/recipe/recipe_tag.json'),
            publicApi.get('data/recipe/tags.json')
        ]);
        recipes.value = resRecipes.data;
        products.value = resProducts.data;
        recipeTags.value = resRecipeTags.data;
        tags.value = resTags.data;
        console.log(products.value);
    } catch (err) {
        console.error("搜尋載入失敗:", err);
        recipes.value = [];
    } finally {
        isLoading.value = false;
    }
};

// 3. 生命週期
onMounted(() => {
    fetchSearchResults(); 
});

// 4. 監聽搜尋關鍵字：當使用者輸入時，重新向後端要資料
watch(searchQuery, (newVal) => {
    currentPage.value = 1;
    fetchSearchResults(newVal); 
});

// 5. 計算屬性
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
const displayCounts = computed(() => {
    const currentResults = filteredRecipes.value; // 取得目前過濾後的食譜
    
    return {
        recipes: currentResults.length,
        // 統一判斷邏輯：確保 linked_product_id 有值（非 null/undefined/0/空字串）
        products: currentResults.filter(recipe => !!recipe.linked_product_id).length
    };
});

const totalPages = computed(() => {
    return Math.ceil(filteredRecipes.value.length / pageSize) || 1;
});

const paginateRecipes = computed(() => {
    const start = (currentPage.value - 1) * pageSize;
    return filteredRecipes.value.slice(start, start + pageSize);
});

// 6. 互動函式
const handlePageChange = (newPage) => {
    currentPage.value = newPage;
    window.scrollTo({ top: 0, behavior: 'smooth' });
};

const handleEmptyAction = (action) => {
    if (action === 'recipes') {
        searchQuery.value = ''; // 這會觸發 watch 並執行 fetchSearchResults('')
    } else if (action === 'go-kitchen') {
        // 跳轉邏輯
    }
};
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
                    :product="item.linked_product_id ? item : null" 
                    :recipeTags="item.tag_names ? item.tag_names.split(',').map(n => ({tag_name: n})) : []" 
                />
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
