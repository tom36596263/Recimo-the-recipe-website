<script setup>
defineProps({
    order: [Number, String]
});
</script>

<template>
    <div class="step-order">
        <span class="p-p3">step</span>
        <span class="en-h2-bold">{{ order }}</span>
    </div>
</template>

<style lang="scss" scoped>
.step-order {
    width: 50px;
    height: 50px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    background-color: $neutral-color-white;
    color: $primary-color-800;
    border: 1px solid $primary-color-800;
    border-radius: 10px;
    flex-shrink: 0;
}
</style>