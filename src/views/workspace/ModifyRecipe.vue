<script setup>
import { ref } from 'vue';
// 根據你提供的路徑引用
import CalorieAdviceModal from '@/components/workspace/mealplan/modals/CalorieAdviceModal.vue';

// 1. 控制彈窗開關
const isModalOpen = ref(false);

// 2. 模擬從 API 拿到的營養數據
const mockNutrition = ref({
    calories: 450,
    protein: 25,
    fat: 15,
    carbs: 55
});

// 打開彈窗的函式
const openAdvice = () => {
    isModalOpen.value = true;
};
</script>

<template>
    <div class="test-container">
        <header class="mb-8">
            <h1 class="zh-h2">改編輯頁面測試</h1>
            <p class="p-p2 color-neutral-500">測試 CalorieAdviceModal 組件連動</p>
        </header>

        <main>
            <button class="test-btn" @click="openAdvice">
                點擊查看熱量建議
            </button>

            <div class="mt-6 p-4 bg-light-gray rounded">
                <p>當前模擬熱量：{{ mockNutrition.calories }} kcal</p>
            </div>
        </main>

        <CalorieAdviceModal v-model="isModalOpen" :nutritionData="mockNutrition" />
    </div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.test-container {
    padding: 40px;
    max-width: 800px;
    margin: 0 auto;
}

.test-btn {
    background-color: $primary-color-400;
    color: white;
    padding: 12px 24px;
    border: none;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.3s;

    &:hover {
        background-color: $primary-color-700;
    }
}

.bg-light-gray {
    background-color: $neutral-color-100;
    border-radius: 8px;
    margin-top: 20px;
}
</style>