<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import { publicApi } from '@/utils/publicApi';
import PlanRecipeCard from '@/components/workspace/mealplan/PlanRecipeCard.vue';
import CalorieAdviceModal from './modals/CalorieAdviceModal.vue';

const props = defineProps({
    date: { type: Date, required: true },
    currentItems: { type: Array, default: () => [] },
    allRecipes: { type: Array, default: () => [] },
    targetCalories: { type: Number, default: 0 },
    startDate: { type: String, default: '' },
    endDate: { type: String, default: '' }
});

const emit = defineEmits(['back', 'add', 'remove', 'update-target', 'change-date', 'apply-all-target']);

const currentDateStr = computed(() => {
    const d = props.date;
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
});

const isFirstDay = computed(() => currentDateStr.value === props.startDate);
const isLastDay = computed(() => currentDateStr.value === props.endDate);

const changeDate = (value) => {
    if ((value === -1 && isFirstDay.value) || (value === 1 && isLastDay.value)) return;

    const newDate = new Date(props.date);
    newDate.setDate(newDate.getDate() + value);
    emit('change-date', newDate);
};

const recipes = ref([]);
const searchQuery = ref('');
const selectedMealType = ref(1);

const currentTotalKcal = computed(() => {
    return Math.round(
        props.currentItems.reduce((sum, item) => {
            const recipe = item.detail || {};

            // 取得食譜總熱量 (若無則為 0)
            const totalKcal = Number(recipe.recipe_kcal_per_100g) || 0;

            // 取得食譜份數 (若無或 <= 0 則預設為 1，避免除以零)
            let servings = Number(recipe.recipe_servings);
            if (!servings || servings <= 0) servings = 1;

            // 累加：總熱量 / 份數 = 單人份熱量
            return sum + (totalKcal / servings);
        }, 0)
    );
});

const displayDate = computed(() => {
    const weekDays = ['日', '一', '二', '三', '四', '五', '六'];
    return `${props.date.getMonth() + 1}/${props.date.getDate()} 星期${weekDays[props.date.getDay()]}`;
});

const filteredRecipes = computed(() => {
    if (!searchQuery.value.trim()) return recipes.value;
    return recipes.value.filter(recipe =>
        recipe.recipe_title.toLowerCase().includes(searchQuery.value.toLowerCase())
    );
});

const getItemsByType = (type) => props.currentItems.filter(item => item.meal_type === type);

const selectRecipe = (recipe) => {
    emit('add', {
        date: props.date.toISOString().split('T')[0],
        recipe_id: recipe.recipe_id,
        meal_type: selectedMealType.value
    });
};

const removeRecipe = (item_id) => {
    emit('remove', item_id)
}

onMounted(async () => {
    if (props.allRecipes && props.allRecipes.length > 0) {
        recipes.value = props.allRecipes;
    } else {
        const res = await publicApi.get('data/recipe/recipes.json');
        recipes.value = res.data;
    }
});

const showModal = ref(false);
const openModal = () => { showModal.value = true; };
const localTarget = ref(props.targetCalories);

watch(localTarget, (newVal) => {
    if (newVal < 0) {
        localTarget.value = 0;
        return;
    }
    emit('update-target', Number(newVal));
});

watch(() => props.targetCalories, (newVal) => {
    if (newVal !== localTarget.value) {
        localTarget.value = newVal;
    }
});

const handleApplyAdvice = (kcal) => {
    localTarget.value = kcal;
    emit('apply-all-target', kcal);
};

</script>

<template>
    <div class="recipe-picker container">
        <header class="recipe-picker__header row">
            <div class="header-left">
                <button class="back-btn" @click="emit('back')" title="返回週計畫視圖">
                    <i-material-symbols-arrow-back-ios-new />
                    <span class="back-text">返回週計畫</span>
                </button>
                <div class="date-selector">
                    <div class="previous-date" :class="{ 'is-disabled': isFirstDay }" @click="changeDate(-1)">
                        <i-material-symbols-arrow-left />
                    </div>
                    <h2 class="date-title">
                        {{ displayDate }}
                    </h2>
                    <div class="next-date" :class="{ 'is-disabled': isLastDay }" @click="changeDate(1)">
                        <i-material-symbols-arrow-right />
                    </div>
                </div>
            </div>

            <div class="header-right">
                <div class="kcal-status-box">
                    <div class="kcal-item">
                        當日總熱量：<span class="value p-p1">{{ currentTotalKcal }}</span> kcal
                    </div>
                    <div class="kcal-item target">
                        目標熱量：
                        <input type="number" v-model="localTarget" class="kcal-input p-p1" /> kcal
                    </div>
                    <div class="kcal-advice-modal-btn" @click="openModal">
                        <i-material-symbols-calculate />
                    </div>
                </div>
            </div>
        </header>

        <section class="recipe-picker__overview row">
            <div v-for="(label, type) in { 0: '早餐', 1: '午餐', 2: '晚餐' }" :key="type" class="meal-slot-col"
                :class="{ 'is-active': selectedMealType === Number(type) }" @click="selectedMealType = Number(type)">

                <div class="meal-slot">
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
                        <div v-else class="empty-hint">點選卡片加入{{ label }}</div>
                    </div>
                </div>
            </div>
        </section>

        <section class="recipe-picker__browser-header row">
            <div class="search-bar">
                <i-material-symbols-search />
                <input v-model="searchQuery" type="text" placeholder="搜尋食譜名稱..." />
            </div>
            <button class="filter-btn">
                <span>篩選條件</span>
                <i-material-symbols-keyboard-arrow-down />
            </button>
        </section>

        <section class="recipe-picker__browser-scroll-area row">
            <div class="recipe-card-wrapper" v-for="recipe in filteredRecipes" :key="recipe.recipe_id"
                @click="selectRecipe(recipe)">
                <PlanRecipeCard :recipe="recipe" />
            </div>

            <div v-if="filteredRecipes.length === 0" class="no-results col-12">
                沒有找到符合「{{ searchQuery }}」的食譜。
            </div>
        </section>
    </div>

    <CalorieAdviceModal v-model="showModal" @apply="handleApplyAdvice" />
</template>

<style lang="scss" scoped>
.recipe-picker {
    display: flex;
    flex-direction: column;
    height: calc(100vh - 120px);
    gap: 16px;
    animation: fadeIn 0.3s ease;

    @media (max-width: 810px) {
        height: auto;
        min-height: calc(100vh - 120px);
        padding-bottom: 30px;
    }

    &__header {
        flex-shrink: 0;
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin: 0;

        @media (max-width: 810px) {
            flex-direction: column;
            gap: 15px;
            align-items: flex-start;
        }

        .header-left {
            display: flex;
            align-items: center;
            gap: 20px;

            @media (max-width: 390px) {
                gap: 10px;
                width: 100%;
                justify-content: space-between;
            }

            .back-btn {
                display: flex;
                align-items: center;
                gap: 6px;
                background: $neutral-color-100;
                padding: 8px 16px;
                border-radius: 10px;
                color: $primary-color-800;
                cursor: pointer;
                border: 1px solid transparent;

                &:hover {
                    background: $accent-color-100;
                    color: $accent-color-800;
                    border: 1px solid $accent-color-800;
                }

                @media (max-width: 390px) {
                    padding: 8px 10px;

                    .back-text {
                        display: none;
                    }
                }
            }

            .date-selector {
                display: flex;
                align-items: center;
                gap: 5px;
            }

            .date-title {
                font-size: 1.4rem;
                color: $primary-color-800;
                margin: 0; // 移除桌機版負邊距，避免 RWD 跑版
                white-space: nowrap;

                @media (max-width: 1024px) {
                    font-size: 1.2rem;
                }
            }

            .previous-date,
            .next-date {
                width: 30px;
                height: 30px;
                display: flex;
                justify-content: center;
                align-items: center;
                font-size: 1.4rem;
                color: $primary-color-800;
                cursor: pointer;

                &:hover {
                    color: $accent-color-700;
                }

                &.is-disabled {
                    color: $neutral-color-400;
                    cursor: default;
                }
            }
        }

        .header-right {
            @media (max-width: 810px) {
                width: 100%;
            }

            .kcal-status-box {
                display: flex;
                gap: 24px;
                align-items: center;

                @media (max-width: 810px) {
                    background: $primary-color-100;
                    padding: 10px 15px;
                    border-radius: 10px;
                    justify-content: space-between;
                    gap: 10px;
                }

                @media (max-width: 390px) {
                    flex-wrap: wrap;
                    justify-content: center;
                }

                .kcal-item {
                    font-size: 1rem;
                    color: $neutral-color-800;

                    @media (max-width: 1024px) {
                        font-size: 0.9rem;
                    }

                    .value {
                        color: $primary-color-800;
                        font-weight: bold;
                        font-size: 1.2rem;
                    }
                }

                .kcal-input {
                    border: none;
                    width: 55px;
                    text-align: center;
                    outline: none;
                    color: $primary-color-800;
                    font-weight: bold;
                    background: transparent;
                    font-size: 1.2rem;
                    border-bottom: 1px solid $primary-color-400;

                    &::-webkit-outer-spin-button,
                    &::-webkit-inner-spin-button {
                        -webkit-appearance: none;
                        margin: 0;
                    }
                }

                .kcal-advice-modal-btn {
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    width: 40px;
                    height: 40px;
                    border-radius: 50%;
                    background-color: $primary-color-100;
                    color: $primary-color-800;
                    cursor: pointer;
                    border: 1px solid transparent;

                    &:hover {
                        background-color: $accent-color-100;
                        color: $accent-color-700;
                        border-color: $accent-color-800;
                    }

                    @media (max-width: 810px) {
                        background-color: $neutral-color-white;
                    }
                }
            }
        }
    }

    /* --- 三餐插槽概覽 --- */
    &__overview {
        flex-shrink: 0;
        display: flex;
        gap: 12px;
        margin: 0;

        @media (max-width: 810px) {
            flex-direction: column;
        }

        .meal-slot-col {
            flex: 1;

            @media (max-width: 810px) {
                width: 100%;
            }
        }

        .meal-slot {
            background: $neutral-color-100;
            border-radius: 12px;
            padding: 12px;
            cursor: pointer;
            border: 1px solid transparent;
            height: 100%;

            .meal-slot-col.is-active & {
                background: $primary-color-100;
                box-shadow: 0 4px 12px rgba($neutral-color-black, 0.1);

                .meal-slot__header .label {
                    color: $primary-color-800;
                }

                .meal-slot__header .count {
                    color: $primary-color-400;
                }

                .meal-slot__content .mini-item {
                    color: $primary-color-800;
                }
            }

            &:hover {
                background: $accent-color-100;
                border-color: $accent-color-800;

                .meal-slot__header .label {
                    color: $accent-color-700;
                }

                .meal-slot__header .count {
                    color: $accent-color-400;
                }

                .meal-slot__content {
                    border-color: $accent-color-400;
                }

                .empty-hint {
                    color: $accent-color-400;
                }
            }

            &__header {
                display: flex;
                justify-content: space-between;
                margin-bottom: 8px;

                .label {
                    font-weight: bold;
                    color: $neutral-color-700;
                }

                .count {
                    font-size: 0.75rem;
                    color: $neutral-color-400;
                }
            }

            &__content {
                height: 100px;
                border: 1px dashed $neutral-color-400;
                border-radius: 8px;
                display: flex;
                flex-direction: column;
                overflow-y: auto;
                scrollbar-width: none;

                &::-webkit-scrollbar {
                    display: none;
                }

                .mini-list {
                    width: 100%;
                    padding: 8px 6px;

                    .mini-item {
                        font-size: 1rem;
                        font-weight: bold;
                        color: $neutral-color-700;
                        background: $neutral-color-white;
                        padding: 6px 10px;
                        margin-bottom: 4px;
                        border-radius: 4px;
                        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
                        display: flex;
                        align-items: center;
                        justify-content: space-between;

                        .item-title {
                            white-space: nowrap;
                            overflow: hidden;
                            text-overflow: ellipsis;
                            flex: 1;
                        }

                        .delete-btn {
                            display: none;
                            background: none;
                            border: none;
                            color: $neutral-color-400;
                            cursor: pointer;
                            margin-left: 8px;
                            opacity: 0;

                            &:hover {
                                color: $secondary-color-danger-700;
                            }
                        }

                        &:hover .delete-btn {
                            display: flex;
                            opacity: 1;
                        }

                        @media (max-width: 810px) {
                            .delete-btn {
                                display: flex;
                                opacity: 1;
                            }
                        }
                    }
                }

                .empty-hint {
                    flex-grow: 1;
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
        margin: 0;

        @media (max-width: 810px) {
            flex-direction: column;
            gap: 10px;
        }

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
            background: $primary-color-100;
            border: 1px solid transparent;
            padding: 0 20px;
            border-radius: 10px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            color: $primary-color-800;
            height: 45px;

            &:hover {
                border-color: $accent-color-700;
                color: $accent-color-700;
                background-color: $accent-color-100;
            }

            @media (max-width: 810px) {
                width: 100%;
            }
        }
    }

    &__browser-scroll-area {
        display: flex;
        flex-wrap: wrap;
        flex: 1;
        overflow-y: auto;
        margin: 0 -10px; // 補償 card-wrapper 的 padding

        &::-webkit-scrollbar {
            width: 6px;
        }

        &::-webkit-scrollbar-thumb {
            background: $neutral-color-100;
            border-radius: 10px;
        }

        .recipe-card-wrapper {
            width: 25%; // 桌機 4 欄
            padding: 10px;

            @media (max-width: 1320px) {
                width: 33.33%;
            }

            // xl: 3 欄
            @media (max-width: 1024px) {
                width: 50%;
            }

            // lg: 2 欄
            @media (max-width: 390px) {
                width: 100%;
            }

            // sm: 1 欄
        }

        .no-results {
            text-align: center;
            padding: 80px 0;
            color: $neutral-color-400;
            font-size: 1.1rem;
        }
    }
}

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