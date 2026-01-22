<script setup>
import StepOrder from './StepOrder.vue';
defineProps({
    step: Object
});
</script>

<template>
    <div class="step-card">
        <StepOrder :order="step.step_order" />
        <div class="step-card__text">
            <span class="p-p1">{{ step.step_title }}</span>
            <span class="step-card__time p-p1"><i-material-symbols-alarm />{{ step.step_total_time }}</span>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.step-card {
    width: 100%;
    height: 78px;
    background-color: $neutral-color-white;
    border-radius: 10px;
    display: flex;
    align-items: center;
    padding: 10px 16px;
    gap: 10px;
    margin-bottom: 15px;
    cursor: pointer;
    border: 1px solid transparent;
    transition: all 0.3s ease;

    &__text {
        display: flex;
        flex-direction: column;
    }

    &__time {
        display: flex;
        align-items: center;
    }

    &.is-active {
        border-color: $secondary-color-info-700;
        background-color: $secondary-color-info-200;

        // 利用 :deep 穿透修改內層 StepOrder.vue 的樣式
        :deep(.step-order) {
            background-color: $neutral-color-white;
            color: $secondary-color-info-700;

            span {
                color: $secondary-color-info-700;
            }
        }
    }
}
</style>