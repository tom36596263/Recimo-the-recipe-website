<script setup>
import { ref, computed } from 'vue';
import DefaultPlanAccordion from './DefaultPlanAccordion.vue';
import DateTabs from './DateTabs.vue';
import NutritionChart from './NutritionChart.vue';

// 定義 Props
const props = defineProps({
  // 接收父層 (EditMealPlan) 傳來的計畫資料 (包含開始與結束日期)
  planData: {
    type: Object,
    required: true
  }
});

// 定義 Emits
const emit = defineEmits(['close']);

// 關閉面板函式
const closePanel = () => {
  emit('close');
};

// 邏輯：根據 planData 自動生成 DateTabs 需要的陣列
const dateTabsData = computed(() => {
  const start = new Date(props.planData.startDate);
  const end = new Date(props.planData.endDate);
  const list = [];
  const weekDays = ['日', '一', '二', '三', '四', '五', '六'];

  let idCounter = 1;
  // 迴圈：從開始日加到結束日
  for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
    list.push({
      id: idCounter++, // 自增 ID，用來做為 Tab 的唯一值
      day: weekDays[d.getDay()], // 轉換星期幾 (0-6 轉中文)
      date: d.getDate().toString() // 日期數字
    });
  }
  return list;
});

// 4. 狀態：目前選中的 Tab ID (預設選第 1 天)
const activeTabId = ref(1);

// 5. 假資料：模擬每一天的營養攝取量
// Key 對應上面的 idCounter
const fakeNutritionData = {
  1: { calories: 140, protein: 290, carbs: 140, starch: 190, fat: 180 }, // 第一天
  2: { calories: 200, protein: 150, carbs: 100, starch: 220, fat: 120 }, // 第二天
  3: { calories: 180, protein: 200, carbs: 180, starch: 150, fat: 160 }, // 第三天
  4: { calories: 220, protein: 170, carbs: 240, starch: 210, fat: 140 }, // 第四天
  5: { calories: 160, protein: 250, carbs: 120, starch: 130, fat: 190 }, // 第五天
  6: { calories: 280, protein: 140, carbs: 260, starch: 280, fat: 220 }, // 第六天
  7: { calories: 150, protein: 180, carbs: 150, starch: 140, fat: 110 }, // 第七天
  8: { calories: 190, protein: 210, carbs: 180, starch: 170, fat: 160 }, // 第八天
  9: { calories: 240, protein: 160, carbs: 210, starch: 230, fat: 150 } // 第九天
  // 沒資料的天數會吃到預設值 0
};

// 6. 計算屬性：根據 activeTabId 撈出當天的資料傳給圖表
const currentNutritionData = computed(() => {
  return (
    fakeNutritionData[activeTabId.value] || {
      //若沒有資料則為0
      calories: 0,
      protein: 0,
      carbs: 0,
      starch: 0,
      fat: 0
    }
  );
});
</script>

<template>
  <div class="plan-panel">
    <div class="plan-panel__header">
      <div class="plan-panel__field p-p1">
        計畫名稱：
        <input
          type="text"
          :placeholder="planData.title"
          class="plan-panel__input p-p1"
        />
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
  top: 0%;
  right: 0%;
  background-color: $neutral-color-white;
  padding: 30px 20px 0px;
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
    align-items: start;
    gap: 8px;
    color: $primary-color-800;
    font-weight: bold;
  }

  &__input {
    border: 0px;
    outline: none;
    background-color: transparent;
    padding: 4px 0;
    color: inherit;

    &:focus {
      border-bottom: 1px solid $primary-color-800;
    }
  }

  &__close {
    cursor: pointer;
    font-size: 1.2rem;
    &:hover {
      color: $primary-color-800;
    }
  }

  &__cover {
    background-color: $accent-color-100;
    width: 100%;
    height: 225px; // 固定高度
    border-radius: 10px;
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 100px;
    color: $accent-color-800;
    cursor: pointer;
    flex-shrink: 0; // 防止被壓縮
  }

  // 調整元件間距
  &__tabs {
    margin-top: 10px;
  }

  &__chart {
    padding-bottom: 40px; // 底部留白，避免貼底
  }
}
</style>
