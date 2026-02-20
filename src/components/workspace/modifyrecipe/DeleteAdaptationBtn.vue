<script setup>
// 這裡變得很乾淨，只負責定義 props 和 emits
const props = defineProps({
    recipeId: [String, Number],
    isDbData: { type: Boolean, default: true }
});

const emit = defineEmits(['click']); // 改為 emit click

const handleClick = () => {
    emit('click'); // 點了之後，讓外面的父組件去決定要不要開燈箱
};
</script>

<template>
    <button class="btn-delete-adaptation" @click="handleClick">
        <i-material-symbols-delete-outline-rounded class="mr-4" />
        刪除
    </button>
</template>

<style lang="scss" scoped>
/* 樣式維持不變 */
.btn-delete-adaptation {
    display: flex;
    align-items: center;
    background-color: #fff1f0;
    color: #ff4d4f;
    border: 1px solid #ffccc7;
    padding: 8px 16px;
    border-radius: 8px;
    font-weight: 600;
    font-size: 14px;
    transition: all 0.2s ease;
    cursor: pointer;

    &:hover {
        background-color: #ff4d4f;
        color: white;
        border-color: #ff4d4f;
    }
}

.mr-4 {
    margin-right: 4px;
}
</style>