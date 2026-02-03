<script setup>
import { phpApi } from '@/utils/phpApi';
import { useAuthStore } from '@/stores/authStore';

const props = defineProps({
    recipeId: [String, Number],
    // 判斷是否為資料庫資料 (或是傳入 boolean)
    isDbData: {
        type: Boolean,
        default: true
    }
});

const emit = defineEmits(['success']);
const authStore = useAuthStore();

const handleDelete = async () => {
    if (!confirm('確定要刪除您的改編版本嗎？此操作將無法復原。')) return;

    // 清理 ID (移除 db- 前綴)
    const cleanId = String(props.recipeId).replace(/[^\d]/g, '');

    if (props.isDbData) {
        try {
            const res = await phpApi.post('recipes/recipe_adaptation_delete.php', {
                recipe_id: cleanId,
                user_id: authStore.user?.id || authStore.user?.user_id
            });

            if (res.data.success) {
                alert('刪除成功！');
                emit('success', cleanId);
            } else {
                alert('刪除失敗：' + (res.data.message || '未知錯誤'));
            }
        } catch (err) {
            console.error('刪除 API 請求出錯:', err);
            alert('連線伺服器失敗，請檢查網路狀態');
        }
    } else {
        // 純 LocalStorage 資料
        emit('success', cleanId);
    }
};
</script>

<template>
    <button class="btn-delete-adaptation" @click="handleDelete">
        <i-material-symbols-delete-outline-rounded class="mr-4" />
        刪除
    </button>
</template>

<style lang="scss" scoped>
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