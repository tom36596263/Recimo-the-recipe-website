<script setup>
import { ref } from 'vue';
// 1. 引入 BaseModal
import BaseModal from '@/components/BaseModal.vue';

const props = defineProps({ modelValue: Boolean });
const emit = defineEmits(['update:modelValue', 'create']);

const newPlan = ref({
    title: '',
    range: {
        start: new Date(),
        end: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000) // 預設三天
    }
});

// 控制錯誤彈窗的開關
const showErrorModal = ref(false);

const handleClose = () => emit('update:modelValue', false);

const handleConfirm = () => {
    // 2. 修改驗證邏輯：如果沒填標題，開啟錯誤彈窗
    if (!newPlan.value.title.trim()) {
        showErrorModal.value = true;
        return;
    }
    emit('create', { ...newPlan.value });
    handleClose();
};
</script>

<template>
    <Teleport to="body">
        <div v-if="modelValue" class="create-modal-overlay" @click.self="handleClose">
            <div class="create-modal-card">
                <h3 class="zh-h4-bold">開始新的備餐計畫</h3>

                <div class="field">
                    <label class="p-p1">計畫名稱</label>
                    <input v-model="newPlan.title" type="text" placeholder="例如：健康三日計畫" class="p-p1" />
                </div>

                <div class="field">
                    <label class="p-p1">選擇日期範圍</label>
                    <VDatePicker v-model.range="newPlan.range" color="green" />
                </div>

                <div class="actions">
                    <button class="cancel-btn p-p1" @click="handleClose">取消</button>
                    <button class="confirm-btn p-p1" @click="handleConfirm">建立計畫</button>
                </div>
            </div>
        </div>

        <BaseModal class="high-z-index" :is-open="showErrorModal" type="danger"
            icon-class="fa-solid fa-triangle-exclamation" title="請輸入計畫名稱" description="計畫名稱不能為空，請輸入後再試。"
            @close="showErrorModal = false">
            <template #actions>
                <button class="error-confirm-btn" @click="showErrorModal = false">
                    知道了
                </button>
            </template>
        </BaseModal>
    </Teleport>
</template>

<style scoped lang="scss">
.create-modal-overlay {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 2000;
}

.create-modal-card {
    background: #fff;
    padding: 30px;
    border-radius: 20px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    gap: 10px;

    h3 {
        color: $primary-color-700;
        margin: auto;
    }

    .field {

        label {
            display: block;
            // font-weight: bold;
        }
    }

    input {
        width: 100%;
        padding: 10px;
        border: 1px solid transparent;
        border-radius: 10px;
        background-color: $neutral-color-100;

        &:focus {
            outline: none;
            border-color: $primary-color-700;
            background-color: $neutral-color-white;
        }
    }

    .actions {
        display: flex;
        gap: 10px;

        button {
            flex: 1;
            padding: 12px;
            border-radius: 10px;
            cursor: pointer;
            border: none;
        }

        .confirm-btn {
            background: $primary-color-700;
            color: $neutral-color-white;

            &:hover {
                background-color: $accent-color-700;
            }
        }

        .cancel-btn {
            background: $neutral-color-100;

            &:hover {
                background-color: $neutral-color-400;
                color: $neutral-color-white;
            }
        }
    }
}

/* 4. 針對 BaseModal 的樣式調整 */
/* 強制提升 BaseModal 的層級，確保它蓋在 create-modal-overlay (z-index: 2000) 之上 */
:deep(.modal-overlay) {
    z-index: 2100 !important;
}

/* 錯誤彈窗裡的按鈕樣式 */
.error-confirm-btn {
    width: 100%;
    padding: 10px;
    background-color: $secondary-color-danger-700;
    /* 或使用 #dc3545 */
    color: white;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-weight: bold;

    &:hover {
        opacity: 0.9;
    }
}
</style>