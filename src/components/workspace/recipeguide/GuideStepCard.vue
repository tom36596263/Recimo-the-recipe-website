<script setup>
import { computed } from 'vue';
import StepOrder from './StepOrder.vue';

const props = defineProps({
    step: Object,
    isTiming: Boolean,
    isFinished: Boolean,
    activeTime: String
});

const formatToMinSec = (timeStr) => {
    if (!timeStr) return '00:00';
    const parts = timeStr.split(':').map(Number);
    if (parts.length === 3) {
        const [hrs, mins, secs] = parts;
        const totalMins = (hrs * 60) + mins;
        return `${totalMins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    }
    return timeStr;
};

const displayTime = computed(() => {
    return props.activeTime || formatToMinSec(props.step.step_total_time);
});
</script>

<template>
    <div class="step-card" :class="{ 'is-finished': isFinished }">
        <StepOrder :order="step.step_order" />
        <div class="step-card__text">
            <span class="p-p1">{{ step.step_title }}</span>
            <span class="step-card__time p-p1" :class="{ 'is-timing': isTiming, 'is-time-up': isFinished }">
                <i-material-symbols-alarm v-if="!isTiming && !isFinished" />
                <i-material-symbols-timer-outline v-else /> {{ displayTime }}
            </span>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.step-card {
    width: 100%;
    height: 78px;
    min-height: 0;
    background-color: $neutral-color-white;
    border-radius: 10px;
    display: flex;
    flex-shrink: 0;
    align-items: center;
    padding: 10px 16px;
    gap: 10px;
    margin-bottom: 15px;
    cursor: pointer;
    border: 1px solid transparent;
    transition: all 0.3s ease;

    // 當計時結束時觸發
    &.is-finished {
        background-color: $secondary-color-danger-200; // 淺紅色背景
        border-color: $secondary-color-danger-700; // 深紅色邊框
        animation: shake 0.5s cubic-bezier(.36, .07, .19, .97) infinite; // 持續晃動
        transform: translate3d(0, 0, 0);
        backface-visibility: hidden;
        perspective: 1000px;

        // 穿透修改序號顏色
        :deep(.step-order) {
            background-color: $secondary-color-danger-700;
            color: $neutral-color-white;
        }
    }

    &__text {
        display: flex;
        flex-direction: column;
        min-width: 0;

        span {
            white-space: nowrap;
            text-overflow: ellipsis;
            overflow: hidden;
        }
    }

    &__time {
        display: flex;
        align-items: center;

        &.is-timing {
            color: $secondary-color-danger-700;
            font-weight: bold;
            animation: blink 1s infinite;
        }

        &.is-time-up {
            color: $secondary-color-danger-700;
            font-weight: bold;
        }
    }

    &.is-active {
        border-color: $secondary-color-info-700;
        background-color: $secondary-color-info-200;

        :deep(.step-order) {
            background-color: $neutral-color-white;
            color: $secondary-color-info-700;

            span {
                color: $secondary-color-info-700;
            }
        }
    }
}

// 左右晃動動畫
@keyframes shake {

    10%,
    90% {
        transform: translate3d(-1px, 0, 0);
    }

    20%,
    80% {
        transform: translate3d(2px, 0, 0);
    }

    30%,
    50%,
    70% {
        transform: translate3d(-4px, 0, 0);
    }

    40%,
    60% {
        transform: translate3d(4px, 0, 0);
    }
}

@keyframes blink {
    50% {
        opacity: 0.7;
    }
}
</style>