<script setup>
import { computed } from 'vue';
import { useCookingStore } from '@/stores/useCookingStore';

const cookingStore = useCookingStore();

// 1. 從 Store 獲取數據
const actualTime = computed(() => cookingStore.tempLogData.totalTime || 0);
const estimateTime = computed(() => cookingStore.tempLogData.estimatedTime || 1); // 避免除以 0

// 2. 判斷是否超時
const isOverTime = computed(() => actualTime.value > estimateTime.value);

// 3. 計算差異百分比
const diffPercentage = computed(() => {
    const diff = actualTime.value - estimateTime.value;
    const percent = 100 + (diff / estimateTime.value) * 100;
    if (percent > 0) {
        return `+${percent.toFixed(1)}%`;
    } else {
        return `${Math.abs(percent).toFixed(1)}%`; // Math.abs 取絕對值去掉負號
    }
});

// 4. 計算進度條寬度
// 我們以 120px (CSS中底條的寬度) 作為 100% 的基準
// 為了不蓋住右邊的文字，我們設定最大寬度約為 125px
const barWidth = computed(() => {
    const baseWidth = 120;
    const ratio = actualTime.value / estimateTime.value;
    // 計算像素寬度，但設定上限以免蓋住文字
    return Math.min(ratio * baseWidth, 125) + 'px';
});

// 5. 決定顏色 (使用您專案的顏色變數邏輯)
const statusColor = computed(() => {
    // 紅色 (超過) : 綠色 (未超過)
    return isOverTime.value ? '#D32F2F' : '#51A448';
});

</script>

<template>
    <div class="time">
        <div class="time__title p-p1">
            <i-material-symbols-alarm />
            製作時間
        </div>

        <div class="time__total-time zh-h3-bold">
            {{ actualTime }}分鐘
        </div>

        <div class="time__bar">
            <div class="estimate-time"></div>

            <div class="used-time" :style="{ width: barWidth, backgroundColor: statusColor }">
            </div>

            <span class="estimate-time__text" :style="{ color: statusColor }">
                {{ diffPercentage }}
            </span>
        </div>

        <div class="estimate-time-desc p-p2">預估時間：{{ estimateTime }}分鐘</div>
    </div>
</template>

<style lang="scss" scoped>
.time {
    flex-shrink: 0;
    flex: 1;
    min-width: 150px;
    height: 150px;
    background-color: $neutral-color-white;
    border-radius: 10px;
    padding: 30px 20px;
    // margin-left: -10px;
    border: 1px solid $primary-color-800;

    @media screen and (max-width: 1024px) {
        width: 100%;
    }

    &__title {
        display: flex;
        align-items: center;
        color: $primary-color-800;
        gap: 4px;
    }

    &__total-time {
        color: $neutral-color-black;
    }

    /* 核心修改區域：使用相對定位容器，讓內部元素絕對定位 */
    &__bar {
        position: relative;
        display: flex;
        align-items: center;
        height: 20px;
        margin-bottom: 10px;

        .estimate-time {
            height: 15px;
            width: 120px;
            border-radius: 10px;
            background-color: $primary-color-100;
            position: absolute;
            left: 0;
            top: 2px;
            z-index: 1;
        }

        .used-time {
            height: 15px;
            border-radius: 99999px;
            position: absolute;
            left: 0;
            top: 2px;
            z-index: 2;
            transition: width 0.5s ease, background-color 0.3s;
        }

        /* 文字 */
        .estimate-time__text {
            position: absolute;
            left: 130px;
            font-size: 0.9rem;
            font-weight: bold;
            white-space: nowrap;
            z-index: 3;
        }
    }

    .estimate-time-desc {
        color: $neutral-color-400;
    }
}
</style>