<script setup>
import { computed } from 'vue';

const props = defineProps({
    totalMinutes: {
        type: Number,
        default: 0
    }
});

// 將分鐘轉換為 "X 小時 Y 分鐘"
const formattedTime = computed(() => {
    if (props.totalMinutes <= 0) return { hours: 0, mins: 0 };
    const hours = Math.floor(props.totalMinutes / 60);
    const mins = props.totalMinutes % 60;
    return { hours, mins };
});
</script>

<template>
    <div class="focus-stat-card">
        <div class="icon-wrapper">
            <i-material-symbols-timer-outline class="timer-icon" />
        </div>
        <div class="content">
            <h5 class="title">專注時刻</h5>
            <div class="time-display">
                <span class="number">{{ formattedTime.hours }}</span>
                <span class="unit">小時</span>
                <span class="number">{{ formattedTime.mins }}</span>
                <span class="unit">分鐘</span>
            </div>
            <p class="subtitle">累積烹飪投入時間</p>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.focus-stat-card {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, $primary-color-800 0%, $primary-color-700 100%);
    color: white;
    padding: 16px 24px;
    border-radius: 12px;
    gap: 16px;
    // min-width: 280px;
    width: 100%;

    .icon-wrapper {
        background: rgba(255, 255, 255, 0.2);
        width: 48px;
        height: 48px;
        border-radius: 50%;
        display: flex;
        justify-content: center;
        align-items: center;

        .timer-icon {
            font-size: 24px;
            color: white;
        }
    }

    .content {
        .title {
            font-size: 14px;
            opacity: 0.9;
            margin-bottom: 4px;
            font-weight: 500;
        }

        .time-display {
            display: flex;
            align-items: baseline;
            gap: 4px;
            margin-bottom: 2px;

            .number {
                font-size: 28px;
                font-weight: 700;
                line-height: 1;
            }

            .unit {
                font-size: 13px;
                margin-right: 6px;
                opacity: 0.8;
            }
        }

        .subtitle {
            font-size: 12px;
            opacity: 0.7;
            margin: 0;
        }
    }
}

// 響應式微調
@media screen and (max-width: 600px) {
    .focus-stat-card {
        width: 100%;
        padding: 12px 16px;

        .content .time-display .number {
            font-size: 24px;
        }
    }
}
</style>