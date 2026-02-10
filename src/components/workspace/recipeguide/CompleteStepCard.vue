<script setup>
// 這裡不需要引入 store 或 router 了，讓元件保持純粹
const emit = defineEmits(['finish']);

const handleComplete = () => {
    // 只要通知父層 (RecipeGuide.vue) 說：「我點擊完成了」
    // 剩下的計算時間、存入 Store、跳轉頁面，都交給父層處理
    emit('finish');
};
</script>

<template>
    <div @click="handleComplete" class="complete-card">
        <div class="complete-card__icon">
            <i-material-symbols-check-circle-outline />
        </div>
        <div class="complete-card__text">
            <span class="p-p2">製作完成</span>
            <span class="p-p2">填寫本次烹飪評估</span>
        </div>
        <i-material-symbols-arrow-forward-ios-rounded class="complete-card__arrow" />
    </div>
</template>

<style lang="scss" scoped>
.complete-card {
    width: 100%;
    height: 78px;
    background-color: $neutral-color-white;
    border-radius: 10px;
    display: flex;
    align-items: center;
    padding: 10px 16px;
    gap: 12px;
    margin-bottom: 15px;
    cursor: pointer;
    text-decoration: none;
    transition: transform 0.2s ease, background-color 0.2s ease;
    flex-shrink: 0;

    &:hover {
        background-color: $primary-color-400;
        transform: translateY(-3px);
    }

    &__icon {
        width: 40px;
        height: 40px;
        background-color: $primary-color-100;
        border-radius: 50%;
        display: flex;
        justify-content: center;
        align-items: center;
        color: $primary-color-800;
        font-size: 1.5rem;
    }

    &__text {
        display: flex;
        flex-direction: column;
        flex: 1;

        span:first-child {
            color: $neutral-color-700;
            font-weight: bold;
        }

        span:last-child {
            color: rgba($neutral-color-700, 0.8);
            font-size: 0.85rem;
        }
    }

    &__arrow {
        color: $neutral-color-700;
        font-size: 1.2rem;
        opacity: 0.7;
    }
}
</style>