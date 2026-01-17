<script setup>
import { ref } from 'vue';
// 修改引用路徑，指向你準備要開發的新燈箱
import AddToFolderModal from '@/components/workspace/recipedetail/modals/AddToFolderModal.vue';

const isModalOpen = ref(false);

const openModal = () => {
    isModalOpen.value = true;
};

// 處理收藏功能傳出的資料
const handleConfirm = (data) => {
    console.log('接收到收藏設定資料：', data);
    isModalOpen.value = false;
};
</script>

<template>
    <div class="test-container">
        <h1>燈箱功能測試頁面</h1>
        <p class="p-p3" style="color: #666;">目前測試對象：AddToFolderModal.vue</p>
        <hr>

        <button @click="openModal" class="test-btn">
            開啟「加入收藏分類」燈箱
        </button>

        <AddToFolderModal v-model="isModalOpen" @submit="handleConfirm" />
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
    /* 這是你目前的測試綠，之後可以改成 $primary-color-700 */
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