<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { phpApi } from '@/utils/publicApi';
import { useRoute, useRouter } from 'vue-router';

import SearchBanner from '@/components/site/search/SearchBanner.vue';
import SearchResultCard from '@/components/site/search/SearchResultCard.vue';
import EmptyState from '@/components/site/RecipeOverview/NoResult.vue';
import PageBtn from '@/components/common/PageBtn.vue';


const route = useRoute();
const router = useRouter();

// 1. 定義響應式變數
const recipes = ref([]);
const recipeTags = ref([]);
const tags = ref([]);
const allResults = ref([]); // 儲存從後端取得的所有搜尋結果
const searchQuery = ref('');
const currentPage = ref(1); 
const pageSize = 5;
const isLoading = ref(true);

const fetchSearchResults = async (keyword = '') => {
    isLoading.value = true;
    try {
        // 呼叫你的 PHP 接口，傳遞 keyword 參數
        const response = await phpApi.get('recipes/search_get.php', {
            params: { keyword: keyword }
        });
        if (response.data.status === 'success') {
            allResults.value = response.data.data;
        }
    } catch (err) {
        console.error("API 載入失敗:", err);
        allResults.value = [];
    } finally {
        isLoading.value = false;
    }
};
watch(
  () => route.query.q,
  (newVal) => {
    // 1. 同步輸入框內容 (這會透過 v-model 傳給 SearchBanner -> SearchBar)
    searchQuery.value = newVal || '';
    
    // 2. 重新抓取 API 資料
    fetchSearchResults(newVal || '');
    
    // 3. 回到分頁第一頁
    currentPage.value = 1;
  }
);
onMounted(() => {
    // 關鍵：從網址抓取 q 參數
    const keywordFromUrl = route.query.q || '';
    
    // 這裡一定要賦值，SearchBanner 的 v-model 才會抓到這個值並顯示在輸入框
    searchQuery.value = keywordFromUrl; 
    
    // 執行 API 請求
    fetchSearchResults(keywordFromUrl); 
});

watch(searchQuery, (newVal) => {
    currentPage.value = 1;
    fetchSearchResults(newVal); // 這裡會根據新標籤重新抓 API
    
    // 同步更新網址 (選用，但建議加上，這樣重新整理才不會跳掉)
    router.replace({ query: { q: newVal || undefined } });
});

const displayCounts = computed(() => {
    const total = allResults.value.length;
    // 有 product_id 的才算料理包筆數
    const hasProductCount = allResults.value.filter(i => !!i.product_id).length;
    return {
        recipes: total,
        products: hasProductCount
    };
});

const totalPages = computed(() => {
    return Math.ceil(allResults.value.length / pageSize) || 1;
});

const paginateRecipes = computed(() => {
    const start = (currentPage.value - 1) * pageSize;
    return allResults.value.slice(start, start + pageSize);
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
        <div v-if="isLoading" class="row">
            <div class="col-12 loading-state">
                <div class="spinner-border text-primary" role="status"></div>
                <p class="zh-h5">正在載入好料理中...</p>
            </div>
        </div>
        <div v-if="allResults.length > 0" class="row">
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
                    :key="'recipe-'+ item.recipe_id"
                    :recipe="item" 
                    :is-product="item.source_type === 'product'"
                    :recipeTags="item.tags.map(t => ({tag_name: t}))" 
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
        0% { opacity: 0.5; }
        50% { opacity: 1; }
        100% { opacity: 0.5; }
    }
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
