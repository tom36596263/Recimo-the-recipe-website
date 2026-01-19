<script setup>
import { computed } from 'vue';

const props = defineProps({
  // 接收 PlanPanel 傳入的 currentNutritionData
  data: { type: Object, required: true }
});

const categories = [
  { key: 'calories', label: '熱量', color: '#2E6F4A', unit: 'kcal' },
  { key: 'protein', label: '蛋白質', color: '#74D09C', unit: 'g' },
  { key: 'carbs', label: '碳水', color: '#FFA527', unit: 'g' },
  { key: 'starch', label: '澱粉', color: '#FFCB82', unit: 'g' },
  { key: 'fat', label: '油脂', color: '#868686', unit: 'g' }
];

const chartBars = computed(() => {
  return categories.map((cat) => {
    const val = props.data[cat.key] || 0;
    // 熱量上限設為 2500，其餘上限為 300，確保長條視覺高度平衡
    const limit = cat.key === 'calories' ? 2500 : 300;
    const heightPercentage = Math.min((val / limit) * 100, 100);

    return {
      ...cat,
      value: val.toFixed(0),
      height: heightPercentage + '%'
    };
  });
});
</script>

<template>
  <div class="nutrition-card">
    <h3 class="card-title">單日營養總計</h3>
    <div class="chart-container">
      <div class="grid-lines">
        <div v-for="tick in [0, 20, 40, 60, 80, 100]" :key="tick" class="line" :style="{ bottom: tick + '%' }"></div>
      </div>
      <div class="bars-wrapper">
        <div v-for="bar in chartBars" :key="bar.key" class="bar-column">
          <span class="bar-value">{{ bar.value }}{{ bar.unit }}</span>
          <div class="bar" :style="{ height: bar.height, backgroundColor: bar.color }"></div>
          <span class="bar-label">{{ bar.label }}</span>
        </div>
      </div>
    </div>

    <div class="legend">
      <div v-for="cat in categories" :key="cat.key" class="legend-item">
        <span class="dot" :style="{ backgroundColor: cat.color }"></span>
        <span class="label">{{ cat.label }}</span>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.nutrition-card {
  border: 1px solid $neutral-color-100;
  border-radius: 16px;
  padding: 24px;
  background-color: $neutral-color-white;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.card-title {
  font-size: 1rem;
  font-weight: bold;
  color: $primary-color-800;
  margin-bottom: 30px;
}

.chart-container {
  position: relative;
  height: 180px;
  margin-bottom: 40px;
}

.grid-lines {
  position: absolute;
  inset: 0;

  .line {
    position: absolute;
    width: 100%;
    border-top: 1px dashed $neutral-color-100;
  }
}

.bars-wrapper {
  position: absolute;
  inset: 0;
  display: flex;
  justify-content: space-around;
  align-items: flex-end;
}

.bar-column {
  width: 40px;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  align-items: center;
  position: relative;

  .bar-value {
    font-size: 10px;
    color: $neutral-color-700;
    margin-bottom: 4px;
    font-weight: bold;
  }

  .bar {
    width: 100%;
    border-radius: 4px 4px 0 0;
    transition: height 0.6s cubic-bezier(0.175, 0.885, 0.32, 1.275);

    &:hover {
      filter: brightness(1.1);
    }
  }

  .bar-label {
    position: absolute;
    bottom: -25px;
    font-size: 12px;
    color: $neutral-color-800;
    white-space: nowrap;
  }
}

.legend {
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 10px;

  .legend-item {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 11px;
    color: $neutral-color-700;

    .dot {
      width: 8px;
      height: 8px;
      border-radius: 50%;
    }
  }
}
</style>