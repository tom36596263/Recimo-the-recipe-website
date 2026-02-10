<script setup>
import { ref } from 'vue';
import { useCookingStore } from '@/stores/useCookingStore';
import StepOrder from './StepOrder.vue';

const props = defineProps({
    stepId: Number,
    order: Number,
    initialNote: String,
    initialImage: String,
    description: String
});

const cookingStore = useCookingStore();
const localImage = ref(props.initialImage);
const showDescriptionModal = ref(false);

const handleFileChange = (event) => {
    const file = event.target.files[0];
    if (file) {
        const url = URL.createObjectURL(file);
        localImage.value = url;
        cookingStore.tempLogData.noteImages[props.stepId] = url;
    }
};

const handleNoteInput = (event) => {
    cookingStore.tempLogData.stepNotes[props.stepId] = event.target.value;
};

const openModal = () => {
    console.log('Open Modal Triggered!'); // 🟢 Debug: 確認點擊有觸發
    showDescriptionModal.value = true;
};

const closeModal = () => {
    showDescriptionModal.value = false;
};
</script>

<template>
    <div class="card">
        <div class="step-btn-wrapper" @click="openModal">
            <StepOrder :order="order" />
        </div>

        <div class="card__note-wrapper">
            <input type="text" class="card__note-text" :value="initialNote" @input="handleNoteInput"
                placeholder="點擊添加筆記...">

            <div class="card__note-pic-upload">
                <input type="file" :id="'file-' + order" accept="image/*" @change="handleFileChange"
                    style="display: none;">

                <label :for="'file-' + order" class="upload-label">
                    <img v-if="localImage" :src="localImage" class="preview-img">
                    <div v-else class="log__upload-text">
                        <i-material-symbols-image-outline />
                    </div>
                </label>
            </div>
        </div>

        <Teleport to="body">
            <div v-if="showDescriptionModal" class="modal-overlay" @click.self="closeModal">
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
        </Teleport>
    </div>
</template>

<style lang="scss" scoped>
.card {
    display: flex;
    gap: 5px;

    /* 🟢 為 wrapper 加入樣式，讓它看起來像可點擊的按鈕 */
    .step-btn-wrapper {
        cursor: pointer;
        transition: transform 0.1s;

        /* 避免被壓縮 */
        flex-shrink: 0;

        &:active {
            transform: scale(0.95);
        }

        /* 讓滑鼠移過去有提示 */
        &:hover {
            opacity: 0.9;
        }
    }

    &__note-wrapper {
        display: flex;
        height: 100px;
        width: 100%;
        background-color: $neutral-color-white;
        justify-content: center;
        padding: 5px 10px;
        border-radius: 10px;
        gap: 10px;
        border: 1px solid $primary-color-800;
    }

    &__note-text {
        display: block;
        flex: 1;
        border: none;

        &:focus {
            outline: none;
            box-shadow: none;
        }
    }

    &__note-pic-upload {
        width: 96px;
        height: 80px;
        border: 1px dashed $neutral-color-400;
        border-radius: 10px;
        flex-shrink: 0;
        overflow: hidden;

        .upload-label {
            width: 100%;
            height: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            cursor: pointer;
        }

        .preview-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }

        .log__upload-text {
            color: $neutral-color-400;
            font-size: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
    }
}

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
        color: $primary-color-800;
    }

    .close-btn {
        background: none;
        border: none;
        font-size: 1.5rem;
        cursor: pointer;
        color: $neutral-color-400;

        &:hover {
            color: $primary-color-800;
        }
    }
}

.modal-body {
    color: $neutral-color-800;
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