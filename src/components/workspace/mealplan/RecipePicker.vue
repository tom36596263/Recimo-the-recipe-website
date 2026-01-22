<script setup>
import { ref, onMounted, computed } from 'vue';
import { publicApi } from '@/utils/publicApi';
import PlanRecipeCard from '@/components/workspace/mealplan/PlanRecipeCard.vue';

/**
 * RecipePicker.vue 
 * 目的：單日詳細編輯介面。提供已選餐點概覽、總熱量統計，以及食譜搜尋庫。
 * 串接：接收 EditMealPlan 傳入的日期物件與該日已選明細，點擊食譜後 emit 新增事件回父組件。
 */

// 定義 Props，接收來自父組件 EditMealPlan 的資料
const props = defineProps({
    // 當前正在編輯的日期物件 (Date 物件)
    date: { type: Date, required: true },
    // 該日期目前已有的配餐明細 (包含食譜 detail)
    currentItems: { type: Array, default: () => [] },
    // 全域食譜庫資料，用於搜尋瀏覽
    allRecipes: { type: Array, default: () => [] }
});

// 定義 Emit 事件，用於通知父組件行為
const emit = defineEmits(['back', 'add', 'remove']);

// --- 響應式狀態管理 ---
const recipes = ref([]);          // 存放顯示在瀏覽器中的食譜清單
const searchQuery = ref('');      // 搜尋框的雙向綁定字串
const selectedMealType = ref(1);  // 目前選擇要操作的餐期 (0:早餐, 1:午餐, 2:晚餐)

// --- 計算屬性 (Computed) ---

// 1. 加總當前日期的總熱量：遍歷 currentItems 並加總所有食譜的熱量數值
const currentTotalKcal = computed(() => {
    return Math.round(
        props.currentItems.reduce((sum, item) => {
            return sum + (item.detail?.recipe_kcal_per_100g || 0);
        }, 0)
    );
});

// 2. 格式化日期標題：將傳入的 Date 物件轉換為如 "1/19 星期一" 的顯示格式
const displayDate = computed(() => {
    const weekDays = ['日', '一', '二', '三', '四', '五', '六'];
    return `${props.date.getMonth() + 1}/${props.date.getDate()} 星期${weekDays[props.date.getDay()]}`;
});

// 3. 搜尋過濾邏輯：根據使用者輸入的關鍵字即時過濾食譜標題
const filteredRecipes = computed(() => {
    if (!searchQuery.value.trim()) return recipes.value;
    return recipes.value.filter(recipe =>
        recipe.recipe_title.toLowerCase().includes(searchQuery.value.toLowerCase())
    );
});

// --- 方法 (Methods) ---

// 根據 meal_type (0,1,2) 過濾出顯示在上方格子內的項目
const getItemsByType = (type) => props.currentItems.filter(item => item.meal_type === type);

// 當使用者點擊下方搜尋結果的卡片時，封裝資料並 emit 給父組件進行資料庫(陣列)更新
const selectRecipe = (recipe) => {
    emit('add', {
        date: props.date.toISOString().split('T')[0], // 傳回 YYYY-MM-DD 格式
        recipe_id: recipe.recipe_id,
        meal_type: selectedMealType.value        // 根據目前選中的顏色標籤決定餐期
    });
};

// 從slot刪除食譜
const removeRecipe = (item_id) => {
    emit('remove', item_id)
}

// 元件掛載時初始化食譜資料
onMounted(async () => {
    // 優先使用父組件傳入的 allRecipes 減少 API 請求次數
    if (props.allRecipes && props.allRecipes.length > 0) {
        recipes.value = props.allRecipes;
    } else {
        // 備援方案：若無資料則自行請求 API
        const res = await publicApi.get('data/recipe/recipes.json');
        recipes.value = res.data;
    }
});
</script>

<template>
    <div class="recipe-picker container">
        <header class="recipe-picker__header row">
            <div class="header-left col-6">
                <button class="back-btn" @click="emit('back')" title="返回週計畫視圖">
                    <i-material-symbols-arrow-back-ios-new />
                    返回週計畫
                </button>
                <h2 class="date-title">{{ displayDate }}</h2>
            </div>

            <div class="header-right">
                <div class="kcal-status-box">
                    <div class="kcal-item">
                        目前總熱量：<span class="value">{{ currentTotalKcal }}</span> kcal
                    </div>
                    <div class="kcal-item target">
                        目標熱量：<input type="number" class="kcal-input p-p1" /> kcal
                    </div>
                </div>
            </div>
        </header>

        <section class="recipe-picker__overview row">
            <div v-for="(label, type) in { 0: '早餐', 1: '午餐', 2: '晚餐' }" :key="type" class="meal-slot col-4"
                :class="{ 'is-active': selectedMealType === Number(type) }" @click="selectedMealType = Number(type)">

                <div class="meal-slot__header">
                    <span class="label">{{ label }}</span>
                    <span class="count">{{ getItemsByType(Number(type)).length }} 道菜</span>
                </div>

                <div class="meal-slot__content">
                    <div v-if="getItemsByType(Number(type)).length > 0" class="mini-list">
                        <div v-for="item in getItemsByType(Number(type))" :key="item.item_id" class="mini-item"
                            :title="item.detail?.recipe_title">
                            <span class="item-title">{{ item.detail?.recipe_title }}</span>
                            <button class="delete-btn" @click.stop="removeRecipe(item.item_id)" title="移除此食譜">
                                <i-material-symbols-delete-outline-rounded />
                            </button>
                        </div>
                    </div>
                    <div v-else class="empty-hint">點選下方卡片加入{{ label }}</div>
                </div>
            </div>
        </section>

        <section class="recipe-picker__browser-header row">
            <div class="search-bar col-10">
                <i-material-symbols-search />
                <input v-model="searchQuery" type="text" placeholder="搜尋食譜名稱..." />
            </div>
            <button class="filter-btn">
                篩選條件 <i-material-symbols-keyboard-arrow-down />
            </button>
        </section>

        <section class="recipe-picker__browser-scroll-area row">
            <div class="col-3" v-for="recipe in filteredRecipes" :key="recipe.recipe_id" @click="selectRecipe(recipe)">
                <PlanRecipeCard :recipe="recipe" />
            </div>


            <div v-if="filteredRecipes.length === 0" class="no-results col-12 col-lg-6 col-md-12">
                沒有找到符合「{{ searchQuery }}」的食譜。
            </div>

        </section>
    </div>
</template>

<style lang="scss" scoped>
.recipe-picker {
    display: flex;
    flex-direction: column;
    height: calc(100vh - 120px);
    gap: 16px;
    animation: fadeIn 0.3s ease;

    /* 頂部標題列 */
    &__header {
        flex-shrink: 0;
        display: flex;
        justify-content: space-between;
        align-items: center;

        .header-left {
            display: flex;
            align-items: center;
            gap: 20px;

            .back-btn {
                display: flex;
                align-items: center;
                gap: 6px;
                background: $neutral-color-white;
                border: 1px solid $neutral-color-100;
                padding: 8px 16px;
                border-radius: 8px;
                color: $primary-color-800;
                cursor: pointer;
                font-weight: bold;
                transition: 0.3s;

                &:hover {
                    background: $primary-color-100;
                }
            }

            .date-title {
                font-size: 1.4rem;
                color: $primary-color-800;
                margin: 0;
            }
        }

        .kcal-status-box {
            display: flex;
            gap: 24px;
            align-items: center;

            .kcal-item {
                font-size: 1rem;
                color: $neutral-color-800;

                .value {
                    color: $primary-color-800;
                    font-weight: bold;
                    font-size: 1.2rem;
                }

                &.target {
                    color: $neutral-color-700;
                }
            }

            .kcal-input {
                border: none;
                width: 50px;
                text-align: center;
                outline: none;
                color: $primary-color-800;
                font-weight: bold;
                background: transparent;

                /* 隱藏 Chrome, Safari, Edge 的數字調節箭頭 */
                &::-webkit-outer-spin-button,
                &::-webkit-inner-spin-button {
                    -webkit-appearance: none;
                    margin: 0;
                }
            }
        }
    }

    /* --- 三餐插槽概覽 --- */
    &__overview {
        flex-shrink: 0;
        display: flex;
        gap: 12px;

        .meal-slot {
            flex: 1;
            background: $neutral-color-100;
            border-radius: 12px;
            padding: 12px;
            cursor: pointer;
            border: 2px solid transparent;
            transition: all 0.3s ease;

            &.is-active {
                background: $primary-color-100;
                border-color: $primary-color-400;
                box-shadow: 0 4px 12px rgba($primary-color-800, 0.05);
            }

            &__header {
                display: flex;
                justify-content: space-between;
                margin-bottom: 8px;

                .label {
                    font-weight: bold;
                    color: $primary-color-800;
                }

                .count {
                    font-size: 0.75rem;
                    color: $neutral-color-700;
                }
            }

            &__content {
                height: 64px;
                border: 1px dashed $neutral-color-400;
                border-radius: 8px;
                display: flex;
                align-items: flex-start;
                justify-content: flex-start;
                overflow-y: auto;
                scrollbar-width: none;
                height: 100px;

                &::-webkit-scrollbar {
                    display: none;
                }

                .mini-list {
                    width: 100%;
                    padding: 8px 6px;

                    .mini-item {
                        font-size: 16px;
                        font-weight: bold;
                        color: $primary-color-800;
                        background: $neutral-color-white;
                        padding: 4px 10px;
                        margin-bottom: 4px;
                        border-radius: 4px;
                        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        position: relative;
                        transition: all 0.2s ease;
                        white-space: nowrap;
                        overflow: hidden;
                        text-overflow: ellipsis;
                        width: 100%;
                    }

                    .mini-item:last-child {
                        margin-bottom: 0;
                    }

                    item-title {
                        white-space: nowrap;
                        overflow: hidden;
                        text-overflow: ellipsis;
                        flex: 1;
                    }
                }

                .delete-btn {
                    display: none; // 預設隱藏
                    background: none;
                    border: none;
                    color: $neutral-color-400;
                    cursor: pointer;
                    padding: 0;
                    margin-left: 8px;
                    display: flex;
                    align-items: center;
                    opacity: 0; // 預設透明
                    transition: color 0.2s, opacity 0.2s;

                    &:hover {
                        color: #ff4d4f; // 垃圾桶 hover 變紅色
                    }

                    svg {
                        width: 18px;
                        height: 18px;
                    }
                }

                // 當 mini-item 被 hover 時，顯示垃圾桶
                &:hover {
                    background: $neutral-color-100; // 稍微變色增加回饋感

                    .delete-btn {
                        display: flex;
                        opacity: 1;
                    }
                }

                .empty-hint {
                    width: 100%;
                    height: 100%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 0.75rem;
                    color: $neutral-color-400;
                }
            }
        }
    }

    /* --- 食譜搜尋欄和篩選器 --- */
    &__browser-header {
        display: flex;
        background: $neutral-color-white;
        gap: 20px;

        .search-bar {
            flex: 1;
            display: flex;
            align-items: center;
            gap: 12px;
            background: $neutral-color-100;
            padding: 10px 20px;
            border-radius: 30px;

            input {
                border: none;
                background: transparent;
                outline: none;
                width: 100%;
                font-size: 1rem;
            }
        }

        .filter-btn {
            background: $neutral-color-white;
            border: 1px solid $neutral-color-100;
            padding: 0 20px;
            border-radius: 10px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            color: $neutral-color-800;
            transition: 0.3s;

            &:hover {
                border-color: $primary-color-400;
                color: $primary-color-700;
            }
        }
    }

    // /* 食譜清單捲動容器 */
    &__browser-scroll-area {
        display: flex;
        flex-wrap: wrap;
        flex: 1;
        overflow-y: auto;

        &::-webkit-scrollbar {
            width: 6px;
        }

        &::-webkit-scrollbar-thumb {
            background: $neutral-color-100;
            border-radius: 10px;
        }

        .no-results {
            text-align: center;
            padding: 80px 0;
            color: $neutral-color-400;
            font-size: 1.1rem;
        }
    }


}

/* 入場淡入動畫 */
@keyframes fadeIn {
    from {
        opacity: 0;
        transform: translateY(10px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}
</style>