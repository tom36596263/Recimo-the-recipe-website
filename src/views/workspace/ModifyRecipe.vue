<script setup>
import { ref } from 'vue';
import CookSnapUploadModal from '@/components/workspace/recipedetail/modals/CookSnapUploadModal.vue';

const isModalOpen = ref(false);

const openModal = () => {
    isModalOpen.value = true;
};

// 處理燈箱傳出的 submit 事件
const handleConfirm = (data) => {
    console.log('接收到上傳資料：', data);
    isModalOpen.value = false;
};
</script>

<template>
    <div class="test-container">
        <h1>燈箱功能測試頁面</h1>
        <hr>

        <button @click="openModal" class="test-btn">
            開啟「分享料理成果」燈箱
        </button>

        <CookSnapUploadModal v-model="isModalOpen" @submit="handleConfirm" />
    </div>
</template>

<style scoped>
.test-container
{
    padding: 50px;
    text-align: center;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 20px;
}

.test-btn
{
    padding: 12px 24px;
    background-color: #42b983;
    color: white;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-size: 16px;
    transition: background 0.3s;
}

.test-btn:hover
{
    background-color: #35495e;
}
</style>