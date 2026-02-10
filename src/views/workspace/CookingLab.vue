<script setup>
import { ref, onMounted, watch, computed } from 'vue';
import { phpApi } from '@/utils/publicApi';
import { useAuthStore } from '@/stores/authStore';
import { parsePublicFile } from '@/utils/parseFile';

import CookingFocusStat from '@/components/workspace/cookinglab/CookingFocusStat.vue';
import CookingRhythmChart from '@/components/workspace/cookinglab/CookingRhythmChart.vue';
import IngredientAnalysisCard from '@/components/workspace/cookinglab/IngredientAnalysisCard.vue';
import CookedRecipeGrid from '@/components/workspace/cookinglab/CookedRecipeGrid.vue';
import LogHistoryModal from '@/components/workspace/cookinglab/LogHistoryModal.vue';

const authStore = useAuthStore();

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

const currentYear = new Date().getFullYear();
const currentMonth = new Date().getMonth() + 1;

const selectedYear = ref(currentYear);
const selectedMonth = ref(currentMonth);

const yearOptions = [currentYear, currentYear - 1];
const monthOptions = Array.from({ length: 12 }, (_, i) => i + 1);

// 計算日期範圍：永遠是該月份的第一天到最後一天
const dateRange = computed(() => {
    const y = selectedYear.value;
    const m = selectedMonth.value;

    const fmt = (d) => {
        const year = d.getFullYear();
        const month = String(d.getMonth() + 1).padStart(2, '0');
        const day = String(d.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    };

    const firstDay = new Date(y, m - 1, 1);
    const lastDay = new Date(y, m, 0); // 下個月第0天 = 本月最後一天

    return {
        start: fmt(firstDay),
        end: fmt(lastDay)
    };
});

const fetchDashboardData = async () => {
    const userId = authStore.userId || 2;
    const { start, end } = dateRange.value;

    try {
        const res = await phpApi.get(`log/get_dashboard_stats.php?user_id=${userId}&start_date=${start}&end_date=${end}`);
        if (res.data.status === 'success') {
            const data = res.data;
            const totalMins = data.total_minutes ? Number(data.total_minutes) : 0;

            cookingStats.value = {
                totalHours: totalMins,
                totalLogs: data.total_logs || 0,
                rhythmData: data.rhythm_data || {},
                topIngredients: (data.top_ingredients || []).map(ing => ({
                    ...ing,
                    image: parsePublicFile(ing.image)
                }))
            };
        }
    } catch (error) {
        console.error('獲取統計數據失敗', error);
    }
};

const fetchCookedRecipes = async () => {
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

const handleOpenHistory = async (recipe) => {
    selectedRecipeInfo.value = recipe;
    const userId = authStore.userId || 2;

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

// 只要年或月改變，就重新抓資料
watch([selectedYear, selectedMonth], () => {
    fetchDashboardData();
});

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
                    <CookingRhythmChart :rhythm-data="cookingStats.rhythmData" v-model:year="selectedYear"
                        v-model:month="selectedMonth" :year-options="yearOptions" :month-options="monthOptions" />
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