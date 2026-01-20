/**
* 烹飪實驗室頁面
* 功能：
* 1. 烹飪節奏感 - 柱狀圖顯示不同菜系使用頻率
* 2. 食材實驗室 - Top5常用食材、使用比例圓環圖
* 3. 食譜烹飪日誌 - 最近烹飪的食譜記錄
* 4. 製作過的食譜 - 網格展示所有烹飪過的食譜
*/
<script setup>
import { ref, computed, onMounted, watch } from 'vue';

/**
 * Chart.js 相關引入
 * Bar: vue-chartjs 提供的 Vue 包裝組件，用於渲染柱狀圖
 * Doughnut: vue-chartjs 提供的甜甜圈圖組件，用於顯示食材使用比例
 */
import { Bar, Doughnut } from 'vue-chartjs';

/**
 * Chart.js 核心模組引入
 * Chart as ChartJS: Chart.js 的主類別，重命名為 ChartJS 避免與其他命名衝突
 * CategoryScale: 類別座標軸（X 軸），用於顯示文字標籤（如「甘點」「義式」等）
 * LinearScale: 線性座標軸（Y 軸），用於顯示數字刻度
 * BarElement: 柱狀圖的柱子元素，定義柱子的渲染方式
 * ArcElement: 圓弧元素，用於甜甜圈圖和圓餅圖的扇形繪製
 * Title: 圖表標題插件（本專案未使用）
 * Tooltip: 滑鼠滑過時的提示框插件
 * Legend: 圖例插件（本專案設為不顯示）
 */
import {
    Chart as ChartJS,
    CategoryScale,
    LinearScale,
    BarElement,
    ArcElement,
    Title,
    Tooltip,
    Legend
} from 'chart.js';
import RecipeCardSm from '@/components/common/RecipeCardSm.vue';
import BaseBtn from '@/components/common/BaseBtn.vue';
import PageBtn from '@/components/common/PageBtn.vue';
import recipesData from '/public/data/recipe/recipes.json';
import tagsData from '/public/data/recipe/tags.json';
import recipeTagData from '/public/data/recipe/recipe_tag.json';

/**
 * 註冊 Chart.js 模組
 * 必須在使用 Chart.js 之前註冊所需的所有組件
 * 這是 Chart.js v3+ 的新要求，採用 Tree-shaking 機制減少打包大小
 * 只會引入實際使用的模組，不會將整個 Chart.js 庫全部打包進來
 * ArcElement: 新增註冊用於甜甜圈圖的圓弧元素
 */
ChartJS.register(CategoryScale, LinearScale, BarElement, ArcElement, Title, Tooltip, Legend);

// ========== 狀態管理 ==========
// 時間範圍切換（每週/每月）
const timeRange = ref('monthly');

// 烹飪節奏數據（模擬）
const cookingRhythmData = ref({
    weekly: {
        甜點: 3,
        義式: 8,
        中式: 20,
        西式: 4,
        美式: 2,
        泰式: 6
    },
    monthly: {
        甜點: 12,
        義式: 10,
        中式: 18,
        西式: 15,
        美式: 8,
        泰式: 22
    }
});

// 常用食材 Top5（包含使用次數）
const topIngredients = ref([
    { id: 1, name: '大蒜', image: '/img/ingredients/pantry-spices-nuts/garlic.png', rank: 1, count: 28 },
    { id: 2, name: '酪梨', image: '/img/ingredients/fresh-produce/avocado.png', rank: 2, count: 23 },
    { id: 3, name: '馬鈴薯', image: '/img/ingredients/fresh-produce/potato.png', rank: 3, count: 18 },
    { id: 4, name: '番茄', image: '/img/ingredients/fresh-produce/tomato.png', rank: 4, count: 15 },
    { id: 5, name: '洋蔥', image: '/img/ingredients/fresh-produce/onion.png', rank: 5, count: 12 }
]);

// 食材使用比例
const ingredientUsagePercent = ref(55);

// 本月靈魂伴侶食材
const soulIngredients = ref('大蒜與酪梨');

// 製作過的所有食譜
const cookedRecipes = ref([]);

// 分頁相關
const currentPage = ref(1);
const pageSize = 8;

// 動畫數字
const animatedWeekly = ref(0);
const animatedMonthly = ref(0);

// ========== 計算屬性 ==========
/**
 * 當前顯示的烹飪節奏數據
 * 根據 timeRange 的值 (weekly/monthly) 動態返回對應的數據
 * 當 timeRange 變化時，此計算屬性會自動重新計算，觸發圖表更新
 */
const currentRhythmData = computed(() => {
    return cookingRhythmData.value[timeRange.value];
});

/**
 * Chart.js 柱狀圖數據配置
 * 這是傳遞給 Bar 組件的數據結構
 * 
 * 結構說明：
 * - labels: X 軸標籤陣列，從 currentRhythmData 的 key 取得（甘點、義式等）
 * - datasets: 數據集陣列，柱狀圖可以有多個數據集，但這裡只用一個
 *   - data: Y 軸數據，從 currentRhythmData 的 value 取得（各菜系的次數）
 */
const chartData = computed(() => ({
    labels: Object.keys(currentRhythmData.value),
    datasets: [
        {
            data: Object.values(currentRhythmData.value),
            backgroundColor: [
                'rgba(62, 141, 96, 0.6)',
            ],
            borderColor: [
                'rgba(62, 141, 96, 1)',
            ],
            borderWidth: 1,
            borderRadius: 10
        }
    ]
}));

/**
 * Chart.js 柱狀圖選項配置
 * 這是傳遞給 Bar 組件的配置物件，控制圖表的顯示行為
 * 
 * 主要配置項：
 * 1. responsive: true - 圖表會自動適應容器寬度，響應式設計
 * 2. maintainAspectRatio: false - 不保持預設的寬高比，允許自由設定高度
 * 
 * plugins 插件配置：
 * - legend.display: false - 隱藏圖例，因為只有一個數據集不需要圖例
 * - tooltip: 滑鼠滑過時的提示框樣式
 *   - backgroundColor: 提示框背景色（半透明黑色）
 *   - padding: 內邊距 12px
 *   - cornerRadius: 圓角 8px
 *   - titleFont/bodyFont: 字體大小設定
 * 
 * scales 座標軸配置：
 * - y 軸 (Y 軸 - 垂直軸)：
 *   - beginAtZero: true - 從 0 開始顯示，不會自動裁切
 *   - ticks.stepSize: 5 - 刻度間隔 5
 *   - grid.color: 網格線顏色（淺灰）
 * - x 軸 (X 軸 - 水平軸)：
 *   - grid.display: false - 不顯示 X 軸的網格線，讓圖表更簡潔
 */
const chartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
        legend: {
            display: false
        },
        tooltip: {
            backgroundColor: 'rgba(0, 0, 0, 0.8)',
            padding: 12,
            cornerRadius: 8,
            titleFont: {
                size: 14
            },
            bodyFont: {
                size: 13
            }
        }
    },
    scales: {
        y: {
            beginAtZero: true,
            ticks: {
                stepSize: 5,
                font: {
                    size: 12
                }
            },
            grid: {
                color: 'rgba(0, 0, 0, 0.05)'
            }
        },
        x: {
            ticks: {
                font: {
                    size: 13
                }
            },
            grid: {
                display: false
            }
        }
    }
};

// 使用次數統計
const totalCookingTimes = computed(() => {
    return Object.values(currentRhythmData.value).reduce((sum, val) => sum + val, 0);
});

// 每週使用次數統計
const weeklyTotal = computed(() => {
    return Object.values(cookingRhythmData.value.weekly).reduce((sum, val) => sum + val, 0);
});

// 每月使用次數統計
const monthlyTotal = computed(() => {
    return Object.values(cookingRhythmData.value.monthly).reduce((sum, val) => sum + val, 0);
});

// 使用食材種類統計
const totalIngredientTypes = ref(43);

/**
 * 分頁相關計算屬性
 */
// 總頁數
const totalPages = computed(() => {
    return Math.ceil(cookedRecipes.value.length / pageSize);
});

// 當前頁顯示的食譜
const paginatedRecipes = computed(() => {
    const start = (currentPage.value - 1) * pageSize;
    const end = start + pageSize;
    return cookedRecipes.value.slice(start, end);
});

/**
 * 甜甜圈圖數據配置
 * 用於顯示 Top5 常用食材的使用比例
 * 
 * 結構說明：
 * - labels: 食材名稱陣列
 * - datasets: 甜甜圈圖數據集
 *   - data: 各食材的使用次數
 *   - backgroundColor: 每個扇形的填充顏色，使用不同色調區分
 *   - borderWidth: 扇形之間的間隔寬度
 *   - borderColor: 間隔顏色（白色）
 */
const doughnutData = computed(() => ({
    labels: topIngredients.value.map(item => item.name),
    datasets: [
        {
            data: topIngredients.value.map(item => item.count),
            backgroundColor: [
                '#3E8D60',  // 主綠色 - 大蒜
                '#74D09C',  // 淺綠色 - 酪梨
                '#FFA527',  // 橙色 - 馬鈴薯
                '#FFCB82',  // 淺橙色 - 番茄
                '#F1F6EF'   // 極淺綠 - 洋蔥
            ],
            borderWidth: 3,
            borderColor: '#fff'
        }
    ]
}));

/**
 * 甜甜圈圖選項配置
 * 
 * cutout: 中心空洞大小（百分比），70% 表示甜甜圈較細
 * plugins.legend: 顯示圖例，位置在右側
 * plugins.tooltip: 滑鼠滑過時顯示食材名稱和使用次數
 */
const doughnutOptions = {
    responsive: true,
    maintainAspectRatio: false,
    cutout: '50%',
    plugins: {
        legend: {
            display: true,
            position: 'bottom',
            labels: {
                padding: 15,
                font: {
                    size: 13
                },
                usePointStyle: true,
                pointStyle: 'circle'
            }
        },
        tooltip: {
            backgroundColor: 'rgba(0, 0, 0, 0.8)',
            padding: 12,
            cornerRadius: 8,
            callbacks: {
                label: function (context) {
                    const label = context.label || '';
                    const value = context.parsed || 0;
                    const total = context.dataset.data.reduce((a, b) => a + b, 0);
                    const percentage = ((value / total) * 100).toFixed(1);
                    return `${label}: ${value} 次 (${percentage}%)`;
                }
            }
        }
    }
};

// ========== 工具函數 ==========
/**
 * 數字滾動動畫
 * @param {Ref} target - 目標 ref
 * @param {number} endValue - 結束值
 * @param {number} duration - 持續時間（毫秒）
 */
const animateNumber = (target, endValue, duration = 1000) => {
    const startValue = target.value;
    const startTime = performance.now();

    const animate = (currentTime) => {
        const elapsed = currentTime - startTime;
        const progress = Math.min(elapsed / duration, 1);

        // easeOutQuart 緩動函數，讓動畫先快後慢
        const easeProgress = 1 - Math.pow(1 - progress, 4);

        target.value = Math.round(startValue + (endValue - startValue) * easeProgress);

        if (progress < 1) {
            requestAnimationFrame(animate);
        } else {
            target.value = endValue;
        }
    };

    requestAnimationFrame(animate);
};

/**
 * 獲取食譜的標籤列表
 */
const getRecipeTags = (recipeId) => {
    const recipeTags = recipeTagData
        .filter(rt => rt.recipe_id === recipeId)
        .map(rt => {
            const tag = tagsData.find(t => t.tag_id === rt.tag_id);
            return tag ? tag.tag_name : null;
        })
        .filter(Boolean);
    return recipeTags.length > 0 ? recipeTags : ['未分類'];
};

// ========== 事件處理 ==========
/**
 * 切換時間範圍
 */
const switchTimeRange = (range) => {
    timeRange.value = range;
};

/**
 * 切換頁碼
 */
const goToPage = (page) => {
    if (page >= 1 && page <= totalPages.value) {
        currentPage.value = page;
    }
};

// ========== 生命週期 ==========
onMounted(() => {
    // 載入製作過的食譜（12 筆）
    cookedRecipes.value = recipesData.slice(0, 12).map(recipe => ({
        id: recipe.recipe_id,
        recipe_name: recipe.recipe_title,
        image_url: recipe.recipe_image_url,
        tags: getRecipeTags(recipe.recipe_id),
        author: {
            name: 'Recimo',
            likes: recipe.recipe_like_count || 100
        }
    }));

    // 初始化動畫數字
    animateNumber(animatedWeekly, weeklyTotal.value);
    animateNumber(animatedMonthly, monthlyTotal.value);
});

// ========== 監聽器 ==========
// 監聽週數據變化
watch(weeklyTotal, (newVal) => {
    animateNumber(animatedWeekly, newVal);
});

// 監聽月數據變化
watch(monthlyTotal, (newVal) => {
    animateNumber(animatedMonthly, newVal);
});
</script>

<template>
    <div class="cooking-lab-page">
        <div class="container">
            <!-- 標題 -->
            <div class="row">
                <div class="col-12">
                    <h2 class="zh-h2 page-title">烹飪實驗室</h2>
                </div>
            </div>

            <!-- 主要內容區 -->
            <div class="row main-content">
                <!-- 左側：烹飪節奏感 + 食譜烹飪日誌 -->
                <div class="col-9 col-lg-12 left-section">
                    <!-- 烹飪節奏感 -->
                    <section class="rhythm-section">
                        <div class="section-header">
                            <h4 class="zh-h4 section-title">我的數據統計表</h4>
                            <div class="time-range-toggle">
                                <button :class="['toggle-btn', { active: timeRange === 'weekly' }]"
                                    @click="switchTimeRange('weekly')">
                                    每週
                                </button>
                                <button :class="['toggle-btn', { active: timeRange === 'monthly' }]"
                                    @click="switchTimeRange('monthly')">
                                    每月
                                </button>
                            </div>
                        </div>

                        <div class="rhythm-content">
                            <!-- 柱狀圖 -->
                            <div class="chart-wrapper">
                                <Bar :data="chartData" :options="chartOptions" />
                            </div>
                        </div>

                        <!-- 統計卡片 -->
                        <div class="stat-cards-wrapper">
                            <div class="stat-card">
                                <h5 class="stat-title">每週</h5>
                                <div class="stat-label">使用食譜數</div>
                                <div class="stat-number">{{ animatedWeekly }}</div>
                            </div>
                            <div class="stat-card">
                                <h5 class="stat-title">每月</h5>
                                <div class="stat-label">使用食譜數</div>
                                <div class="stat-number">{{ animatedMonthly }}</div>
                            </div>
                        </div>
                    </section>
                </div>

                <!-- 右側：食材實驗室卡片 -->
                <div class="col-3 col-lg-12 right-section">
                    <div class="ingredient-lab-card">
                        <h4 class="zh-h4 card-title">常用食材 Top5</h4>

                        <!-- Top5 食材圖片 -->
                        <div class="top-ingredients">
                            <div v-for="ingredient in topIngredients" :key="ingredient.id" class="ingredient-item">
                                <div class="ingredient-image-wrapper">
                                    <img :src="ingredient.image" :alt="ingredient.name" class="ingredient-image">
                                    <span class="rank-badge">{{ ingredient.rank }}</span>
                                </div>
                            </div>
                        </div>

                        <!-- 甜甜圈圖 -->
                        <div class="doughnut-wrapper">
                            <Doughnut :data="doughnutData" :options="doughnutOptions" />
                        </div>

                        <!-- 靈魂伴侶 -->
                        <div class="soul-mate">
                            <p class="soul-label">本月你的靈魂伴侶</p>
                            <p class="soul-value">{{ soulIngredients }}</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 製作過的食譜 -->
            <section class="cooked-recipes-section">
                <h4 class="zh-h4 section-title">製作過的食譜</h4>
                <div class="row recipe-grid">
                    <div v-for="recipe in paginatedRecipes" :key="recipe.id" class="col-3 col-lg-6 col-md-12">
                        <RecipeCardSm :recipe="recipe" />
                    </div>
                </div>

                <!-- 分頁控件 -->
                <PageBtn v-if="totalPages > 1" :currentPage="currentPage" :totalPages="totalPages"
                    @update:page="goToPage" />
            </section>
        </div>
    </div>
</template>

<style lang="scss" scoped>
/* ==================== 頁面容器 ==================== */
.cooking-lab-page {
    padding: 32px 0 60px;
    min-height: calc(100vh - 80px);

    .row:not(.main-content) {
        row-gap: 24px;
    }
}

.page-title {
    margin-bottom: 32px;
    color: $neutral-color-800;
}

/* ==================== 主要內容區 ==================== */
.main-content {
    margin-bottom: 48px;
    row-gap: 24px;
}

.left-section,
.right-section {
    display: flex;
    flex-direction: column;
    gap: 24px;
}

/* ==================== 通用區塊樣式 ==================== */
section {
    background: $neutral-color-white;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.section-title {
    color: $neutral-color-800;
    margin-bottom: 20px;
    font-size: 20px;
}

/* ==================== 烹飪節奏感區塊 ==================== */
.rhythm-section {
    display: flex;
    flex-direction: column;
    flex: 1;

    .section-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 24px;
    }

    .time-range-toggle {
        display: flex;
        background: $neutral-color-100;
        border-radius: 20px;
        padding: 4px;
        gap: 4px;

        .toggle-btn {
            padding: 6px 16px;
            border: none;
            background: transparent;
            color: $neutral-color-700;
            border-radius: 16px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.3s ease;

            &.active {
                background: $primary-color-700;
                color: $neutral-color-white;
            }

            &:hover:not(.active) {
                color: $primary-color-700;
            }
        }
    }

    .rhythm-content {
        display: flex;
        gap: 24px;
        align-items: center;
    }

    .chart-wrapper {
        width: 100%;
        height: 280px;
        padding: 16px;
        background: $neutral-color-white;
        border-radius: 8px;
    }

    .stat-cards-wrapper {
        display: flex;
        gap: 16px;
        margin-top: 24px;
    }

    .stat-card {
        background: linear-gradient(135deg, $neutral-color-white 0%, $primary-color-100 100%);
        border: 1px solid $primary-color-100;
        border-radius: 16px;
        padding: 24px 20px;
        text-align: center;
        display: flex;
        flex-direction: column;
        gap: 8px;
        align-items: center;
        flex: 1;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
        transition: all 0.3s ease;
        cursor: default;

        &:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 20px rgba(62, 141, 96, 0.15);
            border-color: $primary-color-400;
        }

        .stat-title {
            font-size: 14px;
            font-weight: 600;
            color: $neutral-color-700;
            margin-bottom: 4px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .stat-label {
            font-size: 13px;
            color: $neutral-color-800;
            margin-bottom: 12px;
            font-weight: 500;
        }

        .stat-number {
            font-size: 40px;
            font-weight: 800;
            color: $primary-color-700;
            line-height: 1;
            background: linear-gradient(135deg, $primary-color-700 0%, $primary-color-400 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
    }
}

/* ==================== 食材實驗室卡片 ==================== */
.ingredient-lab-card {
    background: linear-gradient(135deg, $primary-color-100 0%, $neutral-color-white 100%);
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
    text-align: center;
    display: flex;
    flex-direction: column;
    flex: 1;

    .card-title {
        color: $neutral-color-800;
        margin-bottom: 20px;
        font-size: 18px;
    }

    .top-ingredients {
        display: flex;
        justify-content: center;
        gap: 12px;
        margin-bottom: 24px;
        flex-wrap: wrap;
    }

    .ingredient-item {
        position: relative;
    }

    .ingredient-image-wrapper {
        position: relative;
        width: 60px;
        height: 60px;
        border-radius: 12px;
        background: $neutral-color-white;
        padding: 8px;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
        transition: all 0.3s ease;

        &:hover {
            transform: translateY(-4px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
        }

        .ingredient-image {
            width: 100%;
            height: 100%;
            object-fit: contain;
        }

        .rank-badge {
            position: absolute;
            top: -6px;
            right: -6px;
            width: 24px;
            height: 24px;
            background: $accent-color-700;
            color: $neutral-color-white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 700;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }
    }

    .doughnut-wrapper {
        height: 280px;
        margin-bottom: 24px;
        padding: 0 20px;
    }

    .soul-mate {
        padding-top: 20px;
        border-top: 1px solid $neutral-color-100;

        .soul-label {
            font-size: 14px;
            color: $neutral-color-700;
            margin-bottom: 8px;
        }

        .soul-value {
            font-size: 18px;
            font-weight: 600;
            color: $primary-color-700;
        }
    }
}

/* ==================== 製作過的食譜 ==================== */
.cooked-recipes-section {
    .recipe-grid {
        row-gap: 24px;
        margin-bottom: 32px;
    }
}

/* ==================== 響應式設計 ==================== */
// 平板橫向（1024px 以下）
@media screen and (max-width: 1024px) {}

// 平板直向（810px 以下）
@media screen and (max-width: 810px) {
    .cooking-lab-page {
        padding: 24px 0 40px;
    }

    .page-title {
        font-size: 22px;
        margin-bottom: 24px;
    }

    // 通用區塊
    section {
        padding: 20px 16px;
    }

    .section-title {
        font-size: 18px;
        margin-bottom: 16px;
    }

    // 烹飪節奏感
    .rhythm-section {
        .section-header {
            flex-direction: column;
            align-items: flex-start;
            gap: 12px;

            .section-title {
                margin-bottom: 0;
            }

            .time-range-toggle {
                width: 100%;
                justify-content: center;
            }
        }

        .chart-wrapper {
            height: 220px;
            padding: 12px;
        }

        .stat-cards-wrapper {
            margin-top: 20px;
            gap: 12px;
        }

        .stat-card {
            padding: 16px 12px;

            .stat-title {
                font-size: 15px;
            }

            .stat-number {
                font-size: 26px;
            }

            .stat-label {
                font-size: 13px;
            }
        }
    }

    // 食材實驗室卡片
    .ingredient-lab-card {
        padding: 20px 16px;

        .card-title {
            font-size: 17px;
        }

        .top-ingredients {
            gap: 10px;
            margin-bottom: 20px;
        }

        .ingredient-image-wrapper {
            width: 55px;
            height: 55px;
        }

        .doughnut-wrapper {
            height: 260px;
            padding: 0 10px;
        }

        .soul-mate {
            padding-top: 16px;

            .soul-label {
                font-size: 13px;
            }

            .soul-value {
                font-size: 17px;
            }
        }
    }

    // 製作過的食譜
    .cooked-recipes-section {
        padding: 20px 16px;

        .recipe-grid {
            row-gap: 20px;
        }
    }
}

// 手機（600px 以下）
@media screen and (max-width: 600px) {
    .cooking-lab-page {
        padding: 20px 0 32px;
    }

    .page-title {
        font-size: 20px;
        margin-bottom: 20px;
    }

    section {
        padding: 16px 12px;
        border-radius: 8px;
    }

    .section-title {
        font-size: 17px;
        margin-bottom: 14px;
    }

    // 烹飪節奏感
    .rhythm-section {
        .time-range-toggle {
            .toggle-btn {
                padding: 5px 14px;
                font-size: 13px;
            }
        }

        .chart-wrapper {
            height: 200px;
            padding: 10px;
        }

        .stat-cards-wrapper {
            margin-top: 16px;
            flex-direction: column;
            gap: 12px;
        }

        .stat-card {
            padding: 14px 10px;

            .stat-title {
                font-size: 14px;
            }

            .stat-number {
                font-size: 24px;
            }

            .stat-label {
                font-size: 12px;
                margin-bottom: 6px;
            }
        }
    }

    // 食材實驗室卡片
    .ingredient-lab-card {
        padding: 16px 12px;

        .card-title {
            font-size: 16px;
            margin-bottom: 16px;
        }

        .top-ingredients {
            gap: 8px;
            margin-bottom: 16px;
        }

        .ingredient-image-wrapper {
            width: 48px;
            height: 48px;
            padding: 6px;

            .rank-badge {
                width: 20px;
                height: 20px;
                font-size: 11px;
                top: -4px;
                right: -4px;
            }
        }

        .doughnut-wrapper {
            height: 240px;
            padding: 0 8px;
            margin-bottom: 20px;
        }

        .soul-mate {
            padding-top: 14px;

            .soul-label {
                font-size: 12px;
                margin-bottom: 6px;
            }

            .soul-value {
                font-size: 16px;
            }
        }
    }

    // 製作過的食譜
    .cooked-recipes-section {
        padding: 16px 12px;

        .section-title {
            margin-bottom: 16px;
        }

        .recipe-grid {
            row-gap: 16px;
            margin-bottom: 24px;
        }
    }
}

// 小手機（420px 以下）
@media screen and (max-width: 420px) {
    .cooking-lab-page {
        padding: 16px 0 24px;
    }

    .page-title {
        font-size: 18px;
        margin-bottom: 16px;
    }

    .rhythm-section {
        .section-header {
            gap: 10px;
        }

        .time-range-toggle .toggle-btn {
            padding: 4px 12px;
            font-size: 12px;
        }

        .chart-wrapper {
            height: 180px;
        }

        .stat-card {
            .stat-title {
                font-size: 13px;
            }

            .stat-number {
                font-size: 22px;
            }
        }
    }

    .ingredient-lab-card {
        .top-ingredients {
            gap: 6px;
        }

        .ingredient-image-wrapper {
            width: 44px;
            height: 44px;
        }

        .doughnut-wrapper {
            height: 220px;
        }
    }
}
</style>