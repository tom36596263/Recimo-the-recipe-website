<script setup>
import { ref, onMounted } from 'vue';
import { phpApi } from '@/utils/publicApi';
import { useAuthStore } from '@/stores/authStore';
import { parsePublicFile } from '@/utils/parseFile';

// 引入拆分後的子元件
import CookingFocusStat from '@/components/workspace/cookinglab/CookingFocusStat.vue';
import CookingRhythmChart from '@/components/workspace/cookinglab/CookingRhythmChart.vue';
import IngredientAnalysisCard from '@/components/workspace/cookinglab/IngredientAnalysisCard.vue';
import CookedRecipeGrid from '@/components/workspace/cookinglab/CookedRecipeGrid.vue';
import LogHistoryModal from '@/components/workspace/cookinglab/LogHistoryModal.vue';

const authStore = useAuthStore();

// ========== 狀態管理 ==========

const cookingStats = ref({
    totalHours: 0,
    totalLogs: 0,
    rhythmData: {},
    topIngredients: []
});

const cookedRecipes = ref([]);
const isRecipesLoading = ref(true);

const showLogModal = ref(false);
const selectedRecipeLogs = ref([]);
const selectedRecipeInfo = ref({});

// ========== API 請求邏輯 ==========

// 獲取使用者所有的烹飪統計資料
const fetchDashboardData = async () => {

    const userId = 2; // 強制寫死測試
    console.log('Fetching Dashboard for User:', userId);

    console.log('Fetching Dashboard for User:', userId);

    try {
        const res = await phpApi.get(`log/get_dashboard_stats.php?user_id=${userId}`);
        if (res.data.status === 'success') {
            const data = res.data;

            const totalMins = data.total_minutes ? Number(data.total_minutes) : 0;

            cookingStats.value = {
                totalHours: totalMins,
                totalLogs: data.total_logs || 0,
                rhythmData: {
                    weekly: data.rhythm_data.weekly || {},
                    monthly: data.rhythm_data.monthly || {}
                },
                topIngredients: data.top_ingredients.map(ing => ({
                    ...ing,
                    image: parsePublicFile(ing.image)
                }))
            };
            console.log('Stats Updated:', cookingStats.value); // Debug 用
        }
    } catch (error) {
        console.error('獲取統計數據失敗', error);
    }
};

// 獲取製作過的食譜列表
const fetchCookedRecipes = async () => {
    // 🟢 優化：同樣使用 store 的 userId
    const userId = authStore.userId || 2;

    isRecipesLoading.value = true;
    try {
        const res = await phpApi.get(`log/get_user_cooked_recipes.php?user_id=${userId}`);
        if (res.data.status === 'success') {
            cookedRecipes.value = res.data.recipes;
        }
    } catch (error) {
        console.error('獲取食譜列表失敗', error);
    } finally {
        isRecipesLoading.value = false;
    }
};

// 開啟日誌燈箱
const handleOpenHistory = async (recipe) => {
    selectedRecipeInfo.value = recipe;
    const userId = authStore.userId || 2; // 保持 ID 邏輯一致

    try {
        const res = await phpApi.get(`log/get_recipe_logs.php?recipe_id=${recipe.recipe_id}&user_id=${userId}`);
        if (res.data.status === 'success') {
            selectedRecipeLogs.value = res.data.logs;
            showLogModal.value = true;
        }
    } catch (error) {
        console.error('獲取日誌詳情失敗', error);
        alert('無法讀取日誌，請稍後再試');
    }
};

// ========== 生命週期 ==========
onMounted(() => {
    fetchDashboardData();
    fetchCookedRecipes();
});
</script>

<template>
    <div class="cooking-lab-page">
        <div class="container">
            <div class="row">
                <div class="col-12 header-area">
                    <h2 class="zh-h2 page-title">烹飪實驗室</h2>

                    <CookingFocusStat :total-minutes="Number(cookingStats.totalHours)" />
                </div>
            </div>

            <div class="row main-content">
                <div class="col-9 col-lg-12 left-section">
                    <CookingRhythmChart :rhythm-data="cookingStats.rhythmData" />
                </div>

                <div class="col-3 col-lg-12 right-section">
                    <IngredientAnalysisCard :top-ingredients="cookingStats.topIngredients" />
                </div>
            </div>

            <div class="row">
                <div class="col-12">
                    <CookedRecipeGrid :recipes="cookedRecipes" :loading="isRecipesLoading"
                        @open-log="handleOpenHistory" />
                </div>
            </div>
        </div>

        <LogHistoryModal v-if="showLogModal" @close="showLogModal = false" :recipe="selectedRecipeInfo"
            :logs="selectedRecipeLogs" />
    </div>
</template>

<style lang="scss" scoped>
.cooking-lab-page {
    padding: 32px 0 60px;
    min-height: calc(100vh - 80px);
}

.header-area {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 32px;
    flex-wrap: wrap;
    gap: 16px;
}

.page-title {
    color: $neutral-color-800;
    margin: 0;
}

.main-content {
    margin-bottom: 48px;
    row-gap: 24px;
}

.left-section,
.right-section {
    display: flex;
    flex-direction: column;
}

/* 響應式調整 */
@media screen and (max-width: 810px) {
    .cooking-lab-page {
        padding: 24px 0 60px;
    }

    .header-area {
        flex-direction: column;
        align-items: flex-start;
    }
}
</style>