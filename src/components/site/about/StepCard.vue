<script setup>
defineProps({
    number: {
        type: [String, Number],
        default: 1
    },
    content: {
        type: String,
        default: '選取您想要吃的食材或是冰箱剩餘的食材'
    }
});
</script>
<template>
    <div class="step-card">
        <div class="step-badge">
            <p class="p-p3">step</p>
            <span class="en-h2-bold">{{ number }}</span>
        </div>
        <div class="p-p1 step-content">
            {{ content }}
        </div>
    </div>
</template>
<style lang="scss" scoped>
@use "sass:map";
@use "@/assets/scss/layouts/_grid.scss" as *;

.step-card {
    height: 205px;
    border: 1px solid $primary-color-800;
    background-color: $primary-color-100;
    border-radius: 10px;
    padding: 20px 25px;

    display: flex;
    flex-direction: column;
    align-items: center;

    &:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
        transition: transform 0.5s ease;
    }
}

@media screen and (max-width: map.get($breakpoints, "lg")) {
    .step-card {
        &:hover {
            transform: none; // 強制取消位移
        }
    }
}

.step-badge {
    display: felx;
    flex-direction: column;
    text-align: center;
    background-color: $neutral-color-white;
    width: 50px;
    height: 50px;
    border-radius: 10px;
    color: $primary-color-700;
    margin-bottom: 15px;
}
</style>
