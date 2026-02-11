<script setup>
import { ref, onMounted, computed } from 'vue'; // 移除 watch，因為沒有要監聽日期
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
    topIngredients: [],
    favoriteStyle: ''
});

const cookedRecipes = ref([]);
const isRecipesLoading = ref(true);
const showLogModal = ref(false);
const selectedRecipeLogs = ref([]);
const selectedRecipeInfo = ref({});

const fetchDashboardData = async () => {
    const userId = authStore.userId || 2;

    try {
        // 您目前的 PHP 預設查本月，若要查全部，可能需要修改 PHP 或傳入更早的 start_date
        // 這裡暫時維持預設 (查本月)
        const res = await phpApi.get(`log/get_dashboard_stats.php?user_id=${userId}`);

        if (res.data.status === 'success') {
            const data = res.data;
            const totalMins = data.total_minutes ? Number(data.total_minutes) : 0;

            // 處理 rhythmData (確保是物件)
            // 如果後端回傳空陣列 []，要轉成 {}
            const rawRhythm = (Array.isArray(data.rhythm_data) && data.rhythm_data.length === 0)
                ? {}
                : (data.rhythm_data || {});

            console.log('Rhythm Data:', rawRhythm); // Debug: 看看後端到底回傳什麼

            // --- 計算最常烹飪的風格 (Favorite Style) ---
            let topStyle = '尚無數據';

            // 因為 PHP 現在回傳的是扁平結構 { "中式": 1, ... }
            // 所以直接用 rawRhythm 即可
            const entries = Object.entries(rawRhythm);

            // 過濾掉非數值的值 (防呆)
            const validEntries = entries.filter(([key, val]) => typeof val === 'number');

            if (validEntries.length > 0) {
                // 排序：次數由大到小
                validEntries.sort((a, b) => b[1] - a[1]);
                // 取第一名的 Key
                topStyle = validEntries[0][0];
            } else {
                console.warn('沒有有效的風格數據可供排序');
            }
            // ----------------------------------------

            cookingStats.value = {
                totalHours: totalMins,
                totalLogs: data.total_logs || 0,
                rhythmData: rawRhythm,
                topIngredients: (data.top_ingredients || []).map(ing => ({
                    ...ing,
                    image: parsePublicFile(ing.image)
                })),
                favoriteStyle: topStyle
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

                    <CookingFocusStat :total-minutes="Number(cookingStats.totalHours)"
                        :total-logs="cookingStats.totalLogs" :top-tag="cookingStats.favoriteStyle" />
                </div>
            </div>

            <div class="row main-content">
                <div class="col-9 col-lg-12 left-section">
                    <CookingRhythmChart :rhythm-data="cookingStats.rhythmData" :total-logs="cookingStats.totalLogs" />
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