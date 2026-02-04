<script setup>
import { computed } from "vue";

const props = defineProps({
  servings: { type: Number, default: 1 },
  ingredients: { type: Array, default: () => [] },
  // 🏆 關鍵：新增支援直接傳入算好的營養數據物件
  nutrition: { type: Object, default: null }
});

const emit = defineEmits(["change-servings"]);

// --- 在 NutritionCard.vue 裡 ---
const getDisplayTotal = (fieldName, nutritionKey) => {
  // 模式 A：如果父組件直接給了算好的 nutrition 物件
  if (props.nutrition) {
    const val = parseFloat(props.nutrition[nutritionKey] || props.nutrition[fieldName]) || 0;
    // 這裡原本有 * props.servings，請刪掉，因為父組件已經算好了
    return Math.round(val);
  }

  // 模式 B：如果只有食材陣列
  if (!props.ingredients || !props.ingredients.length) return 0;

  const oneServingTotal = props.ingredients.reduce((sum, item) => {
    const nutrientValue = parseFloat(item[fieldName]) || 0;
    return sum + nutrientValue;
  }, 0);

  // 🏆 重要修正：這裡原本有 * props.servings，請刪掉！
  // 因為父組件傳進來的 ingredients 已經是 nutritionWrapper 算好「當前份數」的結果了
  return Math.round(oneServingTotal);
};

// 保持與原本變數名稱一致，Template 完全不需要改動
const totalCalories = computed(() => getDisplayTotal("calories_per_100g", "calories"));
const totalProtein = computed(() => getDisplayTotal("protein_per_100g", "protein"));
const totalFat = computed(() => getDisplayTotal("fat_per_100g", "fat"));
const totalCarbs = computed(() => getDisplayTotal("carbs_per_100g", "carbs"));

// --- 2. 功能函式 ---
const updateServings = (delta) => {
  const next = props.servings + delta;
  if (next >= 1 && next <= 20) emit("change-servings", next);
};

const formatDisplayValue = (val) => {
  if (val > 999999) return (val / 1000).toFixed(0) + 'k';
  return val;
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

      <div class="servings-display p-p1">{{ servings }} 份</div>

      <button type="button" @click="updateServings(1)" :disabled="servings >= 20" class="control-btn"> + </button>
    </div>

    <div class="total-calories-box">
      <i-material-symbols-mode-heat-outline-rounded class="heat-icon" />
      <span :key="servings"  class="calories-value zh-h4 bump-animation">{{ formatDisplayValue(totalCalories) }}</span>
      <span class="unit zh-h4">kcal</span>
    </div>

    <div class="nutrients-content">
      <div class="nutrient-item">
        <p :key="servings"  class="value p-p1 bump-animation">{{ formatDisplayValue(totalProtein) }}g</p>
        <p class="label p-p2">蛋白質</p>
      </div>
      <div class="nutrient-item">
        <p :key="servings"  class="value p-p1 bump-animation">{{ formatDisplayValue(totalFat) }}g</p>
        <p class="label p-p2">脂質</p>
      </div>
      <div class="nutrient-item">
        <p :key="servings"  class="value p-p1 bump-animation">{{ formatDisplayValue(totalCarbs) }}g</p>
        <p class="label p-p2">碳水</p>
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
  max-width: 100%;
  box-sizing: border-box;

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
    flex-shrink: 0; 
    transition: all 0.2s ease;

    &:hover:not(:disabled) {
      background-color: $primary-color-400;
    }

    &:disabled {
      background-color: $neutral-color-400;
      cursor: not-allowed;
    }
  }

  .servings-display {
    flex: 1;
    text-align: center;
    user-select: none;
  }
}

.total-calories-box {
  display: flex;
  justify-content: center;
  align-items: baseline; // 讓數字與單位對齊基線
  gap: 8px;
  width: 100%;

  .heat-icon {
    font-size: 22px;
    color: $primary-color-700;
    transform: translateY(2px);
  }

  .calories-value {
    // ✨ 關鍵：強制長數字斷行
    word-break: break-all;
    text-align: center;
    line-height: 1.2;
  }

  .unit {
    margin-left: 4px;
    color: $neutral-color-700;
  }
}

.nutrients-content {
  display: flex;
  gap: 12px;
  width: 100%;
}

.nutrient-item {
  flex: 1;
  // ✨ 關鍵：flex 項目必須設 min-width 0 才能在內容過長時正常縮小/斷行
  min-width: 0;
  background-color: $neutral-color-white;
  height: 90px;
  border-radius: 12px;
  border: 1px solid $neutral-color-400;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding: 8px;

  .value {
    width: 100%;
    text-align: center;
    // ✨ 關鍵：長數字處理
    word-break: break-all;
    line-height: 1.1;
    margin-bottom: 4px;
    font-weight: 500;
  }

  .label {
    color: $neutral-color-700;
    white-space: nowrap; // 標籤不換行，維持整齊
  }
}

// 在 style 區塊最後面加入
.bump-animation {
  display: inline-block; // 確保 transform 有效
  animation: bump 0.3s ease-out;
}

@keyframes bump {
  0% {
    transform: scale(1);
  }

  50% {
    transform: scale(1.15); // 變大的幅度，可以自己調整
    color: $primary-color-700; // 變大時稍微變色，視覺感更強
  }

  100% {
    transform: scale(1);
  }
}
</style>