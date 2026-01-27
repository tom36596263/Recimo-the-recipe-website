<script setup>
import StepOrder from './StepOrder.vue';

defineProps({
    step: Object,
    ingredients: Array
});
</script>

<template>
    <div class="card">
        <div class="card__detail">

            <img v-if="step.step_image_url" :src="$parsePublicFile(step.step_image_url)" :alt="step.step_title"
                class="card__img">

            <div class="card__text">
                <div class="card__header">
                    <StepOrder :order="step.step_order" />
                    <h3 class="zh-h3">{{ step.step_title }}</h3>
                </div>
                <div class="card__step-desc p-p1">{{ step.step_content }}</div>
            </div>
        </div>

        <div class="card__ingredient">
            <div class="p-p1">當前步驟食材</div>
            <div class="ingredients-list">
                <span v-for="ing in ingredients" :key="ing.ingredient_id" class="p-p2 ingredients">
                    {{ ing.ingredient_name }} {{ ing.step_ingredient_amount }}{{ ing.unit_name }}
                </span>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.card {
    width: 100%;
    height: 360px;
    border: 1px solid $neutral-color-700;
    border-radius: 10px;
    display: flex;
    flex-direction: column;
    overflow: hidden;

    &__detail {
        display: flex;
        justify-content: start;
        align-items: center;
        padding: 20px;
        gap: 20px;
    }

    &__img {
        width: 220px;
        height: 220px;
        background-color: $neutral-color-700;
        border-radius: 10px;
    }

    &__text {
        width: auto;
        display: flex;
        flex-direction: column;
        justify-content: start;
        height: 220px;
        width: auto;
        gap: 20px;
    }

    &__header {
        height: 50px;
        width: 100%;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    &__step-desc {
        width: 100%;

    }

    &__ingredient {
        width: 100%;
        height: 96px;
        background-color: $primary-color-100;
        margin-bottom: 0%;
        margin-top: auto;
        padding: 20px;
        display: flex;
        flex-direction: column;
    }

    .ingredients-list {
        display: flex;
        gap: 10px;
    }
}
</style>