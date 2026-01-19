<script setup>
import { ref, computed } from 'vue';
import DefaultPlanAccordion from './DefaultPlanAccordion.vue';
import DateTabs from './DateTabs.vue';
import NutritionChart from './NutritionChart.vue';

const props = defineProps({
  planData: { type: Object, required: true },
  mealPlanItems: { type: Array, default: () => [] }, // 關鍵：接收完整配餐清單
  allRecipes: { type: Array, default: () => [] }     // 關鍵：接收食譜資料庫
});

const emit = defineEmits(['close']);

// --- 1. 根據計畫日期產生日誌頁籤 ---
const dateTabsData = computed(() => {
  if (!props.planData.start_date) return [];
  const start = new Date(props.planData.start_date);
  const end = new Date(props.planData.end_date);
  const list = [];
  const weekDays = ['日', '一', '二', '三', '四', '五', '六'];

  let idCounter = 1;
  for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
    list.push({
      id: idCounter++,
      day: weekDays[d.getDay()],
      date: d.getDate().toString(),
      fullDate: d.toISOString().split('T')[0] // 隱藏屬性，用於後續過濾配餐
    });
  }
  return list;
});

// --- 2. 狀態：當前選中的頁籤 ID ---
const activeTabId = ref(1);

// --- 3. 核心邏輯：計算「當前選中日期」的營養總和 ---
const currentNutritionData = computed(() => {
  // A. 找出目前 activeTabId 對應的完整日期字串
  const activeTab = dateTabsData.value.find(tab => tab.id === activeTabId.value);
  if (!activeTab) return { calories: 0, protein: 0, carbs: 0, starch: 0, fat: 0 };

  // B. 從所有配餐清單中，篩選出符合該日期的項目
  const todaysItems = props.mealPlanItems.filter(item =>
    item.planned_date.includes(activeTab.fullDate)
  );

  // C. 累加營養素：遍歷今日項目，根據 recipe_id 到食譜庫查詢數值
  return todaysItems.reduce((acc, item) => {
    const recipe = props.allRecipes.find(r => r.recipe_id === item.recipe_id);
    if (recipe) {
      acc.calories += recipe.recipe_kcal_per_100g || 0;
      acc.protein += recipe.recipe_protein_per_100g || 0;
      acc.carbs += recipe.recipe_carbs_per_100g || 0;
      acc.fat += recipe.recipe_fat_per_100g || 0;
      acc.starch += (recipe.recipe_carbs_per_100g * 0.7) || 0; // 暫定澱粉佔碳水 70%
    }
    return acc;
  }, { calories: 0, protein: 0, carbs: 0, starch: 0, fat: 0 });
});

const closePanel = () => { emit('close'); };
</script>

<template>
  <div class="plan-panel">
    <div class="plan-panel__header">
      <div class="plan-panel__field p-p1">
        計畫名稱：
        <input type="text" :placeholder="planData.title || '載入中...'" class="plan-panel__input p-p1" />
      </div>
      <div class="plan-panel__close" @click="closePanel">
        <i-material-symbols-close />
      </div>
    </div>

    <div class="plan-panel__accordion p-p1">
      <DefaultPlanAccordion />
    </div>

    <div class="plan-panel__cover">
      <i-material-symbols-camping-outline />
      <span class="cover-hint">更換封面圖片</span>
    </div>

    <div class="plan-panel__tabs">
      <DateTabs v-model="activeTabId" :tabs="dateTabsData" />
    </div>

    <div class="plan-panel__chart">
      <NutritionChart :data="currentNutritionData" />
    </div>
  </div>
</template>

<style lang="scss" scoped>
.plan-panel {
  width: 510px;
  height: 100vh;
  position: fixed;
  top: 0;
  right: 0;
  background-color: $neutral-color-white;
  padding: 30px 20px 0;
  display: flex;
  flex-direction: column;
  gap: 20px;
  overflow-y: auto;
  z-index: 999;
  box-shadow: -5px 0 15px rgba($neutral-color-black, 0.1);

  &__header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-shrink: 0;
  }

  &__field {
    display: flex;
    align-items: center;
    gap: 8px;
    color: $primary-color-800;
    font-weight: bold;
  }

  &__input {
    border: 0;
    border-bottom: 1px solid transparent;
    outline: none;
    background-color: transparent;
    padding: 4px 0;
    color: inherit;
    transition: border-bottom 0.3s;

    &:focus {
      border-bottom: 1px solid $primary-color-800;
    }
  }

  &__close {
    cursor: pointer;
    font-size: 1.5rem;
    color: $neutral-color-400;
    transition: color 0.2s;

    &:hover {
      color: $primary-color-800;
    }
  }

  &__cover {
    background-color: $accent-color-100;
    width: 100%;
    height: 225px;
    border-radius: 12px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    color: $accent-color-800;
    cursor: pointer;
    flex-shrink: 0;
    transition: background-color 0.3s;

    svg {
      font-size: 80px;
    }

    .cover-hint {
      font-size: 0.8rem;
      margin-top: 10px;
      font-weight: bold;
    }

    &:hover {
      background-color: mix($accent-color-100, $neutral-color-white, 80%);
    }
  }

  &__tabs {
    margin-top: 10px;
  }

  &__chart {
    padding-bottom: 40px;
  }

  &::-webkit-scrollbar {
    width: 6px;
  }

  &::-webkit-scrollbar-thumb {
    background-color: $neutral-color-100;
    border-radius: 10px;
  }
}
</style>