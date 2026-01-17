<script setup>
import { computed } from "vue";

const props = defineProps({
  servings: { type: Number, default: 1 },
  ingredients: { type: Array, default: () => [] },
});

const emit = defineEmits(["change-servings"]);

const calculateTotal = (fieldName) => {
  if (!props.ingredients.length) return 0;
  const oneServingTotal = props.ingredients.reduce((sum, item) => {
    const weight = (item.amount || 0) * (item.unit_weight || 1);
    const nutrientValue = (weight / 100) * (item[fieldName] || 0);
    return sum + nutrientValue;
  }, 0);
  return Math.round(oneServingTotal * props.servings);
};

const totalCalories = computed(() => calculateTotal("calories_per_100g"));
const totalProtein = computed(() => calculateTotal("protein_per_100g"));
const totalFat = computed(() => calculateTotal("fat_per_100g"));
const totalCarbs = computed(() => calculateTotal("carbs_per_100g"));

const updateServings = (delta) => {
  const next = props.servings + delta;
  if (next >= 1 && next <= 20) emit("change-servings", next);
};
</script>

<template>
  <div class="nutrition-card">
    <header class="card-header">
      <div class="zh-h3">營養小清單</div>
      <div class="en-h3">Nutrition List</div>
    </header>

    <div class="servings-control">
      <button type="button" @click="updateServings(-1)" :disabled="servings <= 1" class="control-btn"> − </button>

      <div class="servings-display p-p1">{{ servings }} 人份</div>

      <button type="button" @click="updateServings(1)" :disabled="servings >= 20" class="control-btn"> + </button>
    </div>

    <div class="total-calories-box">
      <i-material-symbols-mode-heat-outline-rounded />
      <span class="calories-value zh-h4">{{ totalCalories }}</span>
      <span class="unit zh-h4">kcal</span>
    </div>

    <div class="nutrients-content">
      <div class="nutrient-item">
        <p class="value p-p1">{{ totalProtein }}g</p>
        <p class="label p-p2">蛋白質</p>
      </div>
      <div class="nutrient-item">
        <p class="value p-p1">{{ totalFat }}g</p>
        <p class="label p-p2">脂質</p>
      </div>
      <div class="nutrient-item">
        <p class="value p-p1">{{ totalCarbs }}g</p>
        <p class="label p-p2">碳水化合物</p>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.nutrition-card {
  background-color: $neutral-color-100;
  border-radius: 15px;
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 20px;

  .en-h3 {
    letter-spacing: 3px;
  }
}

.card-header {
  display: flex;
  flex-direction: column;
  align-items: flex-start;

  .zh-h3 {
    margin-bottom: 10px;
  }
}

.servings-control {
  display: flex;
  align-items: center;
  background-color: $neutral-color-white;
  border: 1.5px solid $primary-color-700;
  border-radius: 10px;
  overflow: hidden;
  height: 48px;
  width: 100%;
  margin: 0 auto;

  .control-btn {
    width: 50px;
    height: 100%;
    background-color: $primary-color-700;
    color: $neutral-color-white;
    font-size: 24px;
    border: none;
    cursor: pointer;
    display: flex;
    justify-content: center;
    align-items: center;
    transition: all 0.2s ease; // 平滑過渡動畫

    &:hover:not(:disabled) {
      background-color: $primary-color-400;
      filter: brightness(1.1);
    }

    &:active:not(:disabled) {
      background-color: $primary-color-800;
    }

    &:disabled {
      background-color: $neutral-color-400;
      cursor: not-allowed;
      opacity: 0.7;
    }
  }

  .servings-display {
    flex: 1;
    text-align: center;
    user-select: none; // 防止連點時選取到文字
  }
}

.total-calories-box {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;

  :deep(svg) {
    font-size: 22px;
    display: block;
  }
}

.nutrients-content {
  display: flex;
  gap: 12px;
}

.nutrient-item {
  flex: 1;
  background-color: $neutral-color-white;
  height: 90px;
  border-radius: 12px;
  border: 1px solid $neutral-color-400;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}
</style>