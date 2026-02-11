<script setup>
import { ref, computed, watch } from 'vue';
import { Bar } from 'vue-chartjs';
import {
    Chart as ChartJS,
    CategoryScale,
    LinearScale,
    BarElement,
    Title,
    Tooltip,
    Legend
} from 'chart.js';

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend);

const props = defineProps({
    rhythmData: {
        type: Object,
        default: () => ({})
    },
    totalLogs: {
        type: Number,
        default: 0
    }
});

const animatedCount = ref(0);

const currentData = computed(() => {
    return props.rhythmData || {};
});

const chartData = computed(() => ({
    labels: Object.keys(currentData.value),
    datasets: [
        {
            data: Object.values(currentData.value),
            backgroundColor: 'rgba(62, 141, 96, 0.6)',
            borderColor: 'rgba(62, 141, 96, 1)',
            borderWidth: 1,
            borderRadius: 6,
            hoverBackgroundColor: 'rgba(62, 141, 96, 0.8)'
        }
    ]
}));

const chartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    animation: {
        duration: 1000,
        easing: 'easeOutQuart'
    },
    animations: {
        x: {
            duration: 0
        },
        width: {
            duration: 0
        },
        colors: {
            duration: 0
        },
        y: {
            duration: 1000,
            easing: 'easeOutQuart',
            from: (ctx) => {
                if (ctx.type === 'data') {
                    const scale = ctx.chart.scales.y;
                    if (scale) {
                        return scale.getPixelForValue(0);
                    }
                }
            }
        }
    },
    plugins: {
        legend: { display: false },
        tooltip: {
            backgroundColor: 'rgba(0, 0, 0, 0.8)',
            padding: 10,
            cornerRadius: 6,
            titleFont: { size: 14 },
            bodyFont: { size: 13 }
        }
    },
    scales: {
        y: {
            beginAtZero: true,
            ticks: { stepSize: 1, font: { size: 12 } },
            grid: { color: 'rgba(0, 0, 0, 0.05)' }
        },
        x: {
            grid: { display: false },
            ticks: { font: { size: 13 } }
        }
    }
};

const animateNumber = (targetRef, endValue) => {
    const startValue = Number(targetRef.value) || 0;
    const finalValue = Number(endValue) || 0;

    if (startValue === finalValue) return;

    const duration = 800;
    const startTime = performance.now();

    const animate = (currentTime) => {
        const elapsed = currentTime - startTime;
        const progress = Math.min(elapsed / duration, 1);
        const easeProgress = 1 - Math.pow(1 - progress, 4);

        targetRef.value = Math.round(startValue + (finalValue - startValue) * easeProgress);

        if (progress < 1) {
            requestAnimationFrame(animate);
        } else {
            targetRef.value = finalValue;
        }
    };
    requestAnimationFrame(animate);
};

watch(
    () => props.totalLogs,
    (newVal) => {
        animateNumber(animatedCount, newVal);
    },
    { immediate: true }
);
</script>

<template>
    <section class="rhythm-section">
        <div class="section-header">
            <h4 class="zh-h4 section-title">我的烹飪數據總覽</h4>
            <div class="time-range-toggle">
                <button class="toggle-btn active">歷史總計</button>
            </div>
        </div>

        <div class="rhythm-content">
            <div class="chart-wrapper">
                <Bar :data="chartData" :options="chartOptions" />
            </div>
        </div>

        <div class="stat-cards-wrapper">
            <div class="stat-card">
                <h5 class="stat-title">歷史總計</h5>
                <div class="stat-label">完成料理數</div>
                <div class="stat-number">{{ animatedCount }}</div>
            </div>
        </div>
    </section>
</template>

<style lang="scss" scoped>
.rhythm-section {
    background: $neutral-color-white;
    border-radius: 12px;
    padding: 24px;
    display: flex;
    flex-direction: column;
    height: 100%;

    .section-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 24px;
    }

    .section-title {
        color: $neutral-color-800;
        margin: 0;
        font-size: 18px;
    }

    .time-range-toggle {
        display: flex;
        background: $neutral-color-100;
        border-radius: 20px;
        padding: 4px;
        gap: 4px;

        .toggle-btn {
            padding: 6px 16px;
            border: none;
            background: transparent;
            color: $neutral-color-700;
            border-radius: 16px;
            cursor: default;
            font-size: 14px;
            transition: all 0.3s ease;

            &.active {
                background: $primary-color-700;
                color: $neutral-color-white;
            }
        }
    }

    .chart-wrapper {
        width: 100%;
        height: 280px;
        padding: 10px;
        background: $neutral-color-white;
    }

    .stat-cards-wrapper {
        display: flex;
        gap: 16px;
        margin-top: 24px;
    }

    .stat-card {
        background: $primary-color-100;
        border: 1px solid $primary-color-100;
        border-radius: 16px;
        padding: 20px;
        text-align: center;
        flex: 1;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
        transition: transform 0.2s;

        .stat-title {
            font-size: 14px;
            color: $neutral-color-700;
            margin-bottom: 4px;
        }

        .stat-label {
            font-size: 13px;
            color: $neutral-color-800;
            margin-bottom: 8px;
        }

        .stat-number {
            font-size: 36px;
            font-weight: 800;
            color: $primary-color-700;
            line-height: 1;
        }
    }
}

@media screen and (max-width: 810px) {
    .rhythm-section {
        .section-header {
            flex-direction: column;
            align-items: flex-start;
            gap: 12px;
        }

        .chart-wrapper {
            height: 220px;
        }
    }
}
</style>