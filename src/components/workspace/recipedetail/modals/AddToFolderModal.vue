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

// 1. 資料夾資料結構
const folders = ref([
    { name: '台式', id: 1 },
    { name: '早餐', id: 2 },
    { name: '午餐', id: 3 },
    { name: '三明治', id: 4 }
]);

const selectedFolderId = ref(3); // 預設選中午餐
const newFolderName = ref('');

const handleClose = () => {
    emit('update:modelValue', false);
};

// 2. 新增分類邏輯
const handleAddFolder = () => {
    if (!newFolderName.value.trim()) return;
    folders.value.push({
        name: newFolderName.value,
        id: Date.now()
    });
    newFolderName.value = '';
};

const handleSubmit = () => {
    const selected = folders.value.find(f => f.id === selectedFolderId.value);
    emit('submit', {
        folderName: selected?.name,
        folderId: selectedFolderId.value
    });
    alert(`已加入資料夾：${selected?.name}`);
    handleClose();
};
</script>

<template>
    <Teleport to="body">
        <div v-if="modelValue" class="black-mask" @click.self="handleClose">
            <div class="modal-card">
                <button class="close-x" @click="handleClose" aria-label="關閉">×</button>

                <div class="modal-header">
                    <div class="modal-title zh-h4-bold">加入收藏資料夾</div>
                    <div class="green-divider"></div>
                </div>

                <div class="folder-content">
                    <div v-for="folder in folders" :key="folder.id" class="folder-item"
                        :class="{ active: selectedFolderId === folder.id }" @click="selectedFolderId = folder.id">
                        <div class="icon-box">
                            <i-material-symbols:folder-outline-sharp v-if="selectedFolderId !== folder.id" />
                            <i-material-symbols:folder-sharp v-else />
                        </div>
                        <span class="folder-name">{{ folder.name }}</span>
                    </div>
                </div>

                <div class="add-folder-section">
                    <div class="add-folder-row">
                        <input v-model="newFolderName" type="text" placeholder="輸入資料夾名稱" class="folder-input" />

                        <BaseTag text="新增分類" variant="action"
                            :class="['btn-ingredient-tag', { 'is-active': newFolderName.length > 0 }]"
                            @click.stop="handleAddFolder" />
                    </div>

                    <div class="btn-group">
                        <BaseBtn title="取消" variant="outline" height="40" @click="handleClose" />
                        <BaseBtn title="確認加入" height="40" @click="handleSubmit" />
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

.folder-content {
    display: flex;
    justify-content: space-around;
    padding: 10px 0 30px;
    flex-wrap: wrap;
    gap: 10px;

    .folder-item {
        display: flex;
        flex-direction: column;
        align-items: center;
        cursor: pointer;
        transition: all 0.2s;
        min-width: 80px;

        .icon-box {
            font-size: 48px;
            color: $primary-color-700;
            margin-bottom: 4px;
            padding: 4px;
            border: 2px solid transparent;
            border-radius: 8px;
            display: flex;
            align-items: center;
        }

        .folder-name {
            font-size: 16px;
            color: $neutral-color-700;
        }

        &.active {
            .icon-box {
                color: $accent-color-400;
            }

            .folder-name {
                color: $accent-color-400;
                font-weight: bold;
            }
        }
    }
}

.add-folder-section {
    height: auto;
    min-height: 140px;
    margin: 0 -30px -24px -30px;
    padding: 20px 30px 24px;
    border-radius: 0 0 12px 12px;
    border-top: 1px solid rgba(0, 0, 0, 0.05);

    .add-folder-row {
        display: flex;
        gap: 12px;
        margin-bottom: 20px;
        align-items: center;

        .folder-input {
            flex: 1;
            height: 40px;
            border-radius: 20px;
            border: 1px solid $primary-color-400;
            padding: 0 16px;
            outline: none;
            background: $neutral-color-white;

            &:focus {
                border-color: $primary-color-700;
            }
        }

        :deep(.btn-ingredient-tag) {
            cursor: pointer;
            white-space: nowrap;
            user-select: none;
        }
    }
}

.btn-group {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
    z-index: 300;

    :deep(.base-btn) {
        width: 110px !important;
        flex: none !important;
    }
}

// --- 手機版 RWD 修正 ---
@media (max-width: 480px) {
    .modal-card {
        padding: 20px 20px;
    }

    .add-folder-section {
        
        min-height: 200px;
        margin: 0 -20px -20px -20px;
        padding: 20px 20px;

        .add-folder-row {
            flex-direction: column;
            align-items: stretch;
            gap: 10px; // 增加輸入框與標籤之間的距離

            .folder-input {
                width: 100%;
                height: 40px; // 強制固定高度，防止變窄
                flex: none; // 防止被 flex 壓縮
            }

            :deep(.btn-ingredient-tag) {
                text-align: center;
                justify-content: center;
                height: 40px; // 讓標籤跟輸入框等高比較好看
            }
        }
    }

    .btn-group {
        :deep(.base-btn) {
            flex: 1 !important;
            width: auto !important;
        }
    }
}
</style>