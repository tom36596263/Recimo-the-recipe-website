<script setup>
import { computed } from 'vue';
import SmallRecipeCard from './SmallRecipeCard.vue';

const props = defineProps({
  currentDate: {
    type: Date,
    required: true
  },
  items: {
    type: Array,
    default: () => []
  }
});

const emit = defineEmits(['click']);

// --- 邏輯處理區 ---

const dayNumber = computed(() => props.currentDate.getDate());

const dayOfWeek = computed(() => {
  const days = ['日', '一', '二', '三', '四', '五', '六'];
  return days[props.currentDate.getDay()];
});

// 根據 meal_type 分類
const breakfastItems = computed(() => props.items.filter(item => item.meal_type === 0));
const lunchItems = computed(() => props.items.filter(item => item.meal_type === 1));
const dinnerItems = computed(() => props.items.filter(item => item.meal_type === 2));
</script>

<template>
  <div class="day-column" @click="emit('click', currentDate)">

    <div class="day-column__date">
      {{ dayNumber }} ( {{ dayOfWeek }} )
    </div>

    <div v-for="(mealGroup, idx) in [breakfastItems, lunchItems, dinnerItems]" :key="idx" class="day-column__slot"
      @wheel.stop>
      <template v-if="mealGroup.length > 0">
        <SmallRecipeCard v-for="item in mealGroup" :key="item.item_id" :title="item.detail?.recipe_title"
          :kcal="item.detail?.recipe_kcal_per_100g" />
      </template>

      <div v-else class="add-btn">
        <span class="plus">+</span>
        <span class="text">新增菜色</span>
      </div>
    </div>

  </div>
</template>

<style lang="scss" scoped>
.day-column {
  display: flex;
  flex-direction: column;
  width: 130px;
  text-align: center;
  gap: 4px;
  cursor: pointer;
  flex-shrink: 0;

  &__date,
  &__slot {
    display: flex;
    width: 100%;
    background-color: $neutral-color-100;
    border-radius: 10px;
    color: $primary-color-800;
    transition: all 0.3s ease;
  }

  &__date {
    height: 5.5555555556vh;
    justify-content: center;
    align-items: center;
    font-weight: bold;
    font-size: 0.9rem;
  }

  &__slot {
    height: 22.2222222222vh;
    <<<<<<< HEAD=======flex-direction: column;
    justify-content: flex-start;
    align-items: center;
    padding: 8px 4px;
    gap: 6px;
    overflow-y: auto;

    /* 隱藏捲動軸，保持視覺整潔 */
    scrollbar-width: none; // Firefox

    &::-webkit-scrollbar {
      display: none; // Chrome, Safari
    }

    :deep(.small-recipe-card) {
      flex-shrink: 0; // 強制不壓縮
      width: 100%; // 確保填滿寬度
    }

    .add-btn {
      flex-grow: 1; // 讓按鈕填滿空的插槽
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      color: $primary-color-400;
      font-size: 0.85rem;

      .plus {
        font-size: 1.2rem;
        margin-bottom: 2px;
      }
    }

    >>>>>>>meal_plan
  }

  // 滑鼠懸停效果
  &:hover {

    .day-column__date,
    .day-column__slot {
      background-color: $accent-color-100;
      color: $accent-color-700;
      border: 1px solid $accent-color-800;
    }

    .add-btn {
      color: $accent-color-700;
    }
  }
}
</style>