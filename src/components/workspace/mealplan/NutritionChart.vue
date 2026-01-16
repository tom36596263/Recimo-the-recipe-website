<script setup>
import { computed } from 'vue';

const props = defineProps({
  // 接收單日的營養數據物件
  data: {
    type: Object,
    required: true
  }
});

// 設定圖表 Y 軸的最大值 (用來計算百分比)
const MAX_VALUE = 300;

// 定義靜態設定：包含每個類別的 key、顯示名稱、顏色
const categories = [
  { key: 'calories', label: '熱量', color: '#1f7a36' }, // 深綠
  { key: 'protein', label: '蛋白質', color: '#4caf50' }, // 草綠
  { key: 'carbs', label: '碳水', color: '#cddc39' }, // 黃綠
  { key: 'starch', label: '澱粉', color: '#a5f3bc' }, // 淺綠
  { key: 'fat', label: '油脂', color: '#1aa37a' } // 青綠
];

// 計算屬性：將原始數據轉換為「UI 需要的格式 (高度、顏色)」
const chartBars = computed(() => {
  return categories.map((cat) => {
    // 從 props.data 取出對應數值，若無則預設 0
    const val = props.data[cat.key] || 0;

    // 計算高度百分比： (數值 / 最大值) * 100
    // Math.min 確保不會超過 100% 導致破版
    const heightPercentage = Math.min((val / MAX_VALUE) * 100, 100);

    return {
      ...cat, // 保留原本的 label, color
      value: val, // 數值
      height: heightPercentage + '%' // CSS 用的高度字串
    };
  });
});
</script>

<template>
  <div class="nutrition-card">
    <h3 class="card-title">營養總計</h3>

    <div class="chart-container">
      <div class="grid-lines">
        <div class="line" style="bottom: 0%"><span>0g</span></div>
        <div class="line" style="bottom: 20%"><span>50g</span></div>
        <div class="line" style="bottom: 40%"><span>100g</span></div>
        <div class="line" style="bottom: 60%"><span>150g</span></div>
        <div class="line" style="bottom: 80%"><span>200g</span></div>
        <div class="line" style="bottom: 100%"><span>250g</span></div>
      </div>

      <div class="bars-wrapper">
        <div v-for="bar in chartBars" :key="bar.key" class="bar-column">
          <div
            class="bar"
            :style="{ height: bar.height, backgroundColor: bar.color }"
            :title="`${bar.label}: ${bar.value}`"
          ></div>
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
  border-radius: 12px;
  padding: 20px;
  background-color: $neutral-color-white;
}

.card-title {
  font-size: 1.1rem;
  font-weight: bold;
  color: $neutral-color-black;
  margin-bottom: 20px;
}

// 圖表主要容器
.chart-container {
  position: relative; // 讓內部絕對定位的元素以這裡為基準
  height: 200px; // 設定圖表固定高度
  margin-bottom: 20px;
  padding-left: 30px; // 左邊留白給 Y 軸文字
}

// 背景網格線
.grid-lines {
  // 佔滿整個容器
  position: absolute;
  top: 0;
  left: 30px;
  right: 0;
  bottom: 0;

  .line {
    position: absolute;
    left: 0;
    right: 0;
    border-top: 1px solid $neutral-color-100; // 淺灰色的橫線

    // 座標文字
    span {
      position: absolute;
      left: -35px; // 往左推到 padding 區域
      top: -8px; // 讓文字置中於線
      font-size: 10px;
      color: $neutral-color-700;
      width: 30px;
      text-align: right;
    }
  }
}

// 長條圖容器
.bars-wrapper {
  // 佔滿整個容器，疊在 grid-lines 上
  position: absolute;
  top: 0;
  left: 30px;
  right: 0;
  bottom: 0;
  display: flex;
  justify-content: space-between;
  padding: 0 10px;
}

.bar-column {
  width: 14%;
  height: 100%;
  display: flex;
  align-items: flex-end; // 讓Bar對齊底部

  .bar {
    width: 100%;
    border-radius: 4px 4px 0 0;
    transition: height 0.5s ease-out;

    &:hover {
      opacity: 0.9;
    }
  }
}

.legend {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
  font-size: 12px;
  color: #666;

  &-item {
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
  }
}
</style>
