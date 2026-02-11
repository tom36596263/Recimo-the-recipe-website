<script setup>
import { defineProps, defineEmits } from 'vue';

const props = defineProps({
    isOpen: {
        type: Boolean,
        default: false
    },
    order: {
        type: Number,
        required: true
    },
    description: {
        type: String,
        default: ''
    }
});

const emit = defineEmits(['close']);

const closeModal = () => {
    emit('close');
};
</script>

<template>
    <div v-if="isOpen" class="modal-overlay" @click.self="closeModal">
        <div class="modal-content">
            <div class="modal-header">
                <span class="modal-title zh-h3-bold">步驟 {{ order }} 說明</span>
                <button class="close-btn" @click="closeModal">
                    <i-material-symbols-close />
                </button>
            </div>
            <div class="modal-body p-p1">
                {{ description || '此步驟沒有詳細說明。' }}
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background-color: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 9999;
}

.modal-content {
    background-color: white;
    width: 90%;
    max-width: 400px;
    border-radius: 12px;
    padding: 20px;
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
    position: relative;
    animation: fadeIn 0.3s ease;
}

.modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
    border-bottom: 1px solid #eee;
    padding-bottom: 10px;

    .modal-title {
        color: #2E6F4A;
        /* 請依您的設計系統調整顏色 */
    }

    .close-btn {
        background: none;
        border: none;
        font-size: 1.5rem;
        cursor: pointer;
        color: #999;

        &:hover {
            color: #2E6F4A;
        }
    }
}

.modal-body {
    color: #333;
    line-height: 1.6;
    white-space: pre-wrap;
}

@keyframes fadeIn {
    from {
        opacity: 0;
        transform: translateY(10px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}
</style>