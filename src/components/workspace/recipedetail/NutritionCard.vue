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
      <button 
        type="button"
        @click="updateServings(-1)" 
        :disabled="servings <= 1" 
        class="control-btn"
      > − </button>
      
      <div class="servings-display p-p1">{{ servings }} 人份</div>
      
      <button 
        type="button"
        @click="updateServings(1)" 
        :disabled="servings >= 20" 
        class="control-btn"
      > + </button>
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

    <div class="tags-row" v-if="totalProtein > 10">
      <span class="tag">豐富蛋白質</span>
      <span class="tag">低脂肪含量</span>
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

/* 修正後的 CSS */
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
    // 這裡強制設定背景色，避免被預設樣式覆蓋
    background-color: $primary-color-700 ; 
    color: $neutral-color-white;
    font-size: 24px;
    border: none;
    cursor: pointer;
    display: flex;
    justify-content: center;
    align-items: center;

    &:disabled {
      background-color: $neutral-color-400;
      cursor: not-allowed;
    }
  }

  .servings-display {
    flex: 1;
    text-align: center;
  }
}

.total-calories-box {
  display: flex;
  justify-content: center;
  align-items: center; 
  gap: 8px;           


  :deep(svg) {
    font-size: 22px; 
    // color: $primary-color-700;
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

.tags-row {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  .tag { background-color: $neutral-color-100; color: $primary-color-400; padding: 4px 12px; border-radius: 6px; font-size: 12px; }
}
</style>