<script setup>
import { computed } from 'vue';
import { Doughnut } from 'vue-chartjs';
import { Chart as ChartJS, Title, Tooltip, Legend, ArcElement, CategoryScale } from 'chart.js';

ChartJS.register(Title, Tooltip, Legend, ArcElement, CategoryScale);

const props = defineProps({
  data: { type: Object, required: true },
  target: { type: Number, default: 0 } // 接收目標熱量
});

// --- 1. 計算三大營養素比例 (內圈甜甜圈) ---
const chartData = computed(() => {
  const p = props.data.protein || 0;
  const c = props.data.carbs || 0;
  const f = props.data.fat || 0;

  // 如果完全沒有數據，給一個預設灰色圈圈，避免圖表消失
  if (p === 0 && c === 0 && f === 0) {
    return {
      labels: ['無數據'],
      datasets: [{ backgroundColor: ['#E5E5E5'], data: [1], borderWidth: 0, hoverOffset: 0 }]
    };
  }

  return {
    labels: ['蛋白質', '碳水', '油脂'],
    datasets: [
      {
        backgroundColor: ['#51A448', '#C6ED3A', '#A5EABD'],
        hoverOffset: 4,
        borderWidth: 0,
        data: [p * 4, c * 4, f * 9], // 轉換為熱量權重
      },
    ],
  };
});

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  cutout: '75%', // 中間洞挖大一點，放文字
  plugins: {
    legend: { display: false },
    tooltip: { enabled: true }
  }
};

// --- 2. 自定義中心文字插件 ---
const centerTextPlugin = {
  id: 'centerText',
  beforeDraw: (chart) => {
    const { ctx, chartArea: { left, top, width, height } } = chart;
    ctx.save();

    const currentKcal = props.data.calories || 0;
    const targetKcal = props.target || 0;
    const centerX = left + width / 2;
    const centerY = top + height / 2;

    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    if (targetKcal > 0) {
      // --- 有設定目標時的顯示方式 ---

      // 1. 繪製 "目前數值" (大字)
      ctx.font = 'bold 24px sans-serif'; // 字體稍微調小一點避免擠
      ctx.fillStyle = '#2E6F4A'; // 預設綠色

      // 如果超過目標，變紅色
      if (currentKcal > targetKcal) {
        ctx.fillStyle = '#FF4D4F';
      }
      ctx.fillText(currentKcal.toFixed(0), centerX, centerY - 10);

      // 2. 繪製分隔線 / 目標 (小字)
      ctx.font = '12px sans-serif';
      ctx.fillStyle = '#868686';
      ctx.fillText(`/ ${targetKcal} kcal`, centerX, centerY + 15);

    } else {
      // --- 沒有設定目標時 (維持原樣) ---
      ctx.font = 'bold 24px sans-serif';
      ctx.fillStyle = '#2E6F4A';
      ctx.fillText(currentKcal.toFixed(0), centerX, centerY - 5);

      ctx.font = '12px sans-serif';
      ctx.fillStyle = '#868686';
      ctx.fillText('kcal', centerX, centerY + 15);
    }

    ctx.restore();
  }
};

// --- 3. 計算外圈進度條樣式 ---
const progressStyle = computed(() => {
  const current = props.data.calories || 0;
  const target = props.target || 1; // 避免除以 0

  let percent = (current / target) * 100;

  // 顏色邏輯：超過變紅，否則綠
  const color = percent > 100 ? '#FF4D4F' : '#2E6F4A';

  // 限制背景繪製不超過 100% (視覺上滿圈)，或者你可以讓他繼續轉
  // 這裡範例是超過就滿圈
  const drawPercent = percent > 100 ? 100 : percent;

  return {
    background: `conic-gradient(${color} 0% ${drawPercent}%, #f0f0f0 ${drawPercent}% 100%)`
  };
});
</script>

<template>
  <div class="nutrition-card">
    <div class="chart-box">
      <div class="canvas-wrapper" :style="progressStyle">
        <div class="canvas-container">
          <Doughnut :data="chartData" :options="chartOptions" :plugins="[centerTextPlugin]" />
        </div>
      </div>

      <div class="legend-list">
        <div class="legend-item">
          <span class="dot p"></span> 蛋白質
          <span class="val">{{ data.protein.toFixed(1) }}g</span>
        </div>
        <div class="legend-item">
          <span class="dot c"></span> 碳水
          <span class="val">{{ data.carbs.toFixed(1) }}g</span>
        </div>
        <div class="legend-item">
          <span class="dot f"></span> 油脂
          <span class="val">{{ data.fat.toFixed(1) }}g</span>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.nutrition-card {
  background: $neutral-color-white;
  border-radius: 20px;
  padding: 24px;
  border: 1px solid $neutral-color-100;
}

.chart-box {
  display: flex;
  align-items: center;
  gap: 24px;
}

/* 外圈進度條容器 */
.canvas-wrapper {
  position: relative;
  width: 160px;
  /* 比內部 canvas 稍大 */
  height: 160px;
  border-radius: 50%;
  display: flex;
  justify-content: center;
  align-items: center;
  /* background 由 computed style 控制 */
  transition: background 0.3s ease;
  /* 讓顏色變化平滑 */
}

.canvas-container {
  position: relative;
  width: 140px;
  /* 內部縮小，露出外圈 */
  height: 140px;
  background: $neutral-color-white;
  /* 重要：白色背景蓋住中間，只露出邊緣 */
  border-radius: 50%;
  z-index: 2;
  padding: 5px;
  /* 讓甜甜圈圖跟外圈有點距離 */
}

/* ... Legend 樣式保持不變 ... */
.legend-list {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 10px;

  .legend-item {
    display: flex;
    align-items: center;
    font-size: 14px;
    color: $neutral-color-black;

    .dot {
      width: 10px;
      height: 10px;
      border-radius: 50%;
      margin-right: 8px;

      &.p {
        background: #51A448;
      }

      &.c {
        background: #C6ED3A;
      }

      &.f {
        background: #A5EABD;
      }
    }

    .val {
      margin-left: auto;
      font-weight: bold;
    }
  }
}
</style>