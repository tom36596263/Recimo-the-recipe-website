<script setup>
import { ref } from 'vue';

const props = defineProps({
    modelValue: Boolean,
    commentData: {
        type: Object,
        default: () => ({
            content: '載入中...',
            userName: '未知用戶',
            time: ''
        })
    }
});

const emit = defineEmits(['update:modelValue', 'submit']);

// --- 狀態變數 ---
const fileInput = ref(null);
const previewImage = ref(null); // 用於前端預覽的 blob 網址
const selectedFile = ref(null); // 用於傳送給後端的原始檔案實體
const reportNote = ref('');

// --- 圖片選擇邏輯 ---
const triggerFileSelect = () => {
    fileInput.value.click();
};

const onFileChange = (e) => {
    const file = e.target.files[0];
    if (file) {
        console.log("選取的檔案實體:", file); // 🏆 這裡應該印出 File { name: "...", size: ... }
        selectedFile.value = file;
        previewImage.value = URL.createObjectURL(file);
    }
};

// --- 關閉與重置邏輯 ---
const handleClose = () => {
    // 1. 先重置所有內部狀態，避免下次開啟時殘留舊資料
    previewImage.value = null;
    selectedFile.value = null;
    reportNote.value = '';

    // 2. 清除 input file 的值，確保選取同一張圖時仍能觸發 change 事件
    if (fileInput.value) {
        fileInput.value.value = '';
    }

    // 3. 通知父組件關閉 Modal
    emit('update:modelValue', false);
};

// --- 提交邏輯 ---
const handleSubmit = () => {
    // 1. 偵錯檢查：看看當下變數到底是什麼
    console.log("Submit 觸發，selectedFile 內容:", selectedFile.value);

    // 2. 驗證是否已選取圖片
    if (!selectedFile.value) {
        alert("請先上傳成品照片喔！");
        return;
    }

    // 3. 再次確認檔案類型 (如果是字串，代表邏輯在某處被覆蓋了)
    if (typeof selectedFile.value === 'string') {
        console.error("錯誤：selectedFile 變成了字串！內容是：", selectedFile.value);
        alert("圖片讀取異常，請重新選取圖片");
        return;
    }

    // 🏆 重要：傳送真正的檔案實體
    // 這裡我們確保傳出去的是 selectedFile.value 這個 File 物件
    emit('submit', {
        image: selectedFile.value,
        note: reportNote.value
    });

    alert("成品照上傳中，請稍候...");
    handleClose();
};

</script>

<template>
    <Teleport to="body">
        <div v-if="modelValue" class="black-mask" @click.self="handleClose">
            <div class="modal-card">
                <button class="close-x" @click="handleClose" aria-label="關閉">
                    ×
                </button>

                <div class="modal-header">
                    <div class="modal-title zh-h4-bold ">分享你的料理成果</div>
                    <div class="green-divider"></div>
                </div>

                <div class="report-content">
                    <div class="upload-box" @click="triggerFileSelect">
                        <input type="file" ref="fileInput" accept="image/*" hidden @change="onFileChange" />

                        <template v-if="!previewImage">
                            <div class="upload-placeholder">
                                <i-material-symbols-add-rounded class="add-icon" />
                                <div class="placeholder-text">
                                    <span class="zh-h5-bold">成品展示</span>
                                    <span class="p-p3">add photo</span>
                                </div>
                            </div>
                        </template>

                        <img v-else :src="previewImage" class="preview-img" alt="成果預覽" />
                    </div>

                    <div class="input-section">
                        <p class="section-title zh-h5-bold">料理心得(選填):</p>
                        <textarea v-model="reportNote" placeholder="分享你的烹飪小撇步或是這道菜的故事..." class="p-p3"></textarea>
                    </div>

                    <div class="btn-group">
                        <BaseBtn title="取消" variant="outline" height="40" width="100%" @click="handleClose" />
                        <BaseBtn title="確認上傳" width="100%" height="40" @click="handleSubmit" />
                    </div>
                </div>
            </div>
        </div>
    </Teleport>
</template>

<style scoped lang="scss">
.black-mask {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 100;
    padding: 20px;
}

.modal-card {
    display: flex;
    flex-direction: column;
    height: auto;
    background: $neutral-color-white;
    width: 450px;
    max-width: calc(100% - 40px);
    border-radius: 12px;
    padding: 24px 30px;
    position: relative;
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
    max-height: 90vh;
    overflow: hidden;
    text-align: left;

    .close-x {
        position: absolute;
        top: 20px;
        right: 20px;
        background: none;
        border: none;
        font-size: 26px;
        color: $neutral-color-700;
        cursor: pointer;
        line-height: 1;
        padding: 5px;
        transition: color 0.2s;
        z-index: 2;

        &:hover {
            color: $neutral-color-black;
        }
    }
}

.modal-header {
    flex-shrink: 0;
    margin-bottom: 16px;

    .modal-title {
        color: $primary-color-700;
        margin: 0 0 10px 0;
    }

    .green-divider {
        height: 1px;
        background: $primary-color-400;
        width: 100%;
    }
}

.report-content {
    flex: 1;
    overflow-y: auto;
    width: 100%;
    box-sizing: border-box;

    &::-webkit-scrollbar {
        width: 4px;
    }

    &::-webkit-scrollbar-thumb {
        background: $neutral-color-100;
        border-radius: 4px;
    }
}

.upload-box {
    border: 2px dashed $neutral-color-400;
    background: $neutral-color-100;
    border-radius: 10px;
    margin-bottom: 20px;
    height: 220px;
    display: flex;
    justify-content: center;
    align-items: center;
    cursor: pointer;
    overflow: hidden;
    transition: background 0.3s;

    &:hover {
        background: darken($neutral-color-100, 5%);
    }

    .upload-placeholder {
        text-align: center;
        color: $neutral-color-700;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 8px;

        .add-icon {
            font-size: 32px;
        }

        .placeholder-text {
            display: flex;
            flex-direction: column;
            line-height: 1.2;
        }
    }

    .preview-img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
}

.btn-group {
    margin: 0;
    background-color: transparent;
    width: 100%;
    height: 40px;
    flex-shrink: 0;
    display: flex;
    justify-content: space-between;
    gap: 16px;
    margin-top: 16px;

    :deep(.base-btn) {
        flex: 1 !important;
        max-width: none !important;
        width: 100% !important;

        button,
        a {
            width: 100% !important;
        }
    }
}

.input-section {
    margin-bottom: 16px;

    .section-title {
        margin-bottom: 8px;
    }
}

textarea {
    width: 100%;
    min-height: 120px;
    border-radius: 10px;
    border: 1px solid $primary-color-400;
    padding: 10px 12px;
    resize: none;
    box-sizing: border-box;
    white-space: pre-wrap;
    word-wrap: break-word;
    overflow-x: hidden;
    overflow-y: auto;
    scrollbar-width: thin;
    scrollbar-color: $primary-color-100 transparent;

    &::-webkit-scrollbar {
        width: 6px;
    }

    &::-webkit-scrollbar-track {
        background: transparent;
    }

    &::-webkit-scrollbar-thumb {
        background-color: $primary-color-100;
        border-radius: 10px;

        &:hover {
            background-color: $primary-color-400;
        }
    }

    &:focus {
        border-color: $primary-color-700;
        outline: none;
    }
}
</style>