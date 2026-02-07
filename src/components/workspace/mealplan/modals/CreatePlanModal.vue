<script setup>
import { ref } from 'vue';

const props = defineProps({ modelValue: Boolean });
const emit = defineEmits(['update:modelValue', 'create']);

const newPlan = ref({
    title: '',
    range: {
        start: new Date(),
        end: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000) // 預設三天
    }
});

const handleClose = () => emit('update:modelValue', false);

const handleConfirm = () => {
    if (!newPlan.value.title.trim()) return alert('請輸入計畫名稱');
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
                    <label>計畫名稱</label>
                    <input v-model="newPlan.title" type="text" placeholder="例如：健康均衡三日計畫" />
                </div>

                <div class="field">
                    <label>選擇日期範圍</label>
                    <VDatePicker v-model.range="newPlan.range" color="green" />
                </div>

                <div class="actions">
                    <button class="cancel-btn" @click="handleClose">取消</button>
                    <button class="confirm-btn" @click="handleConfirm">建立計畫</button>
                </div>
            </div>
        </div>
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
    width: 400px;

    h3 {
        color: $primary-color-700;
        margin-bottom: 20px;
    }

    .field {
        margin-bottom: 20px;

        label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
        }
    }

    input {
        width: 100%;
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 8px;
    }

    .actions {
        display: flex;
        gap: 10px;
        margin-top: 20px;

        button {
            flex: 1;
            padding: 12px;
            border-radius: 10px;
            cursor: pointer;
            border: none;
        }

        .confirm-btn {
            background: $primary-color-700;
            color: #fff;
        }

        .cancel-btn {
            background: #eee;
        }
    }
}
</style>