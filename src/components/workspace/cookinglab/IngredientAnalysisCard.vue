<script setup>
import { computed } from 'vue';
import { Doughnut } from 'vue-chartjs';
import {
    Chart as ChartJS,
    ArcElement,
    Tooltip,
    Legend
} from 'chart.js';

// 註冊 Chart.js 模組
ChartJS.register(ArcElement, Tooltip, Legend);

const props = defineProps({
    topIngredients: {
        type: Array,
        default: () => []
    }
});

// 靈魂伴侶計算 (簡單取前兩名)
const soulIngredients = computed(() => {
    if (props.topIngredients.length >= 2) {
        return `${props.topIngredients[0].name} 與 ${props.topIngredients[1].name}`;
    } else if (props.topIngredients.length === 1) {
        return props.topIngredients[0].name;
    }
    return '尚未累積足夠數據';
});

// 甜甜圈圖數據
const doughnutData = computed(() => ({
    labels: props.topIngredients.map(item => item.name),
    datasets: [{
        data: props.topIngredients.map(item => item.count),
        backgroundColor: [
            '#3E8D60', // 主綠色
            '#74D09C', // 淺綠色
            '#FFA527', // 橙色
            '#FFCB82', // 淺橙色
            '#F1F6EF'  // 極淺綠
        ],
        borderWidth: 2,
        borderColor: '#fff'
    }]
}));

// 甜甜圈圖選項
const doughnutOptions = {
    responsive: true,
    maintainAspectRatio: false,
    cutout: '60%',
    plugins: {
        legend: {
            display: true,
            position: 'bottom',
            labels: {
                padding: 15,
                usePointStyle: true,
                pointStyle: 'circle',
                font: { size: 12 }
            }
        },
        tooltip: {
            backgroundColor: 'rgba(0, 0, 0, 0.8)',
            callbacks: {
                label: function (context) {
                    const label = context.label || '';
                    const value = context.parsed || 0;
                    return ` ${label}: ${value} 次`;
                }
            }
        }
    }
};
</script>

<template>
    <div class="ingredient-lab-card">

        <div class="soul-mate" v-if="topIngredients.length">
            <p class="soul-label">本月你的靈魂伴侶</p>
            <p class="soul-value">{{ soulIngredients }}</p>
        </div>

        <h4 class="zh-h4 card-title">常用食材 Top5</h4>

        <div class="top-ingredients" v-if="topIngredients.length">
            <div v-for="(ingredient, index) in topIngredients" :key="ingredient.id" class="ingredient-item">
                <div class="ingredient-image-wrapper">
                    <img :src="ingredient.image" :alt="ingredient.name" class="ingredient-image">
                    <span class="rank-badge">{{ index + 1 }}</span>
                </div>
            </div>
        </div>
        <div v-else class="no-data">尚無數據</div>

        <div class="doughnut-wrapper" v-if="topIngredients.length">
            <Doughnut :data="doughnutData" :options="doughnutOptions" />
        </div>
    </div>
</template>

<style lang="scss" scoped>
.ingredient-lab-card {
    background: $primary-color-100;
    border-radius: 12px;
    padding: 24px;
    // box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
    text-align: center;
    display: flex;
    flex-direction: column;
    height: 100%;

    .card-title {
        color: $neutral-color-800;
        margin: 20px 0;
        font-size: 18px;
    }

    .top-ingredients {
        display: flex;
        justify-content: center;
        gap: 12px;
        // margin-bottom: 24px;
        flex-wrap: wrap;
    }

    .ingredient-image-wrapper {
        position: relative;
        width: 60px;
        height: 60px;
        border-radius: 12px;
        background: $neutral-color-white;
        padding: 8px;
        // box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
        transition: transform 0.2s;

        &:hover {
            transform: translateY(-4px);
        }

        .ingredient-image {
            width: 100%;
            height: 100%;
            object-fit: contain;
        }

        .rank-badge {
            position: absolute;
            top: -6px;
            right: -6px;
            width: 24px;
            height: 24px;
            background: $accent-color-700;
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 700;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }
    }

    .doughnut-wrapper {
        flex: 1;
        min-height: 240px;
        margin-bottom: 20px;
        padding: 0 10px;
    }

    .soul-mate {
        padding-bottom: 20px;
        border-bottom: 1px solid rgba($neutral-color-400, 0.2);

        .soul-label {
            font-size: 13px;
            color: $neutral-color-700;
            margin-bottom: 6px;
        }

        .soul-value {
            font-size: 16px;
            font-weight: 600;
            color: $primary-color-700;
        }
    }

    .no-data {
        color: $neutral-color-400;
        padding: 40px 0;
    }
}
</style>