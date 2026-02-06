<script setup>

import { ref, computed } from 'vue';
import { phpApi } from '@/utils/phpApi';
import { useAuthStore } from '@/stores/authStore';
import { useRoute } from 'vue-router';

const route = useRoute();
const props = defineProps({
    modelValue: Boolean,
    commentData: {
        type: Object,
        default: () => ({
            content: '載入中...',
            userName: '未知用戶',
            time: ''
        })
    },
    recipeId: {
        type: [Number, String],
        default: null
    }
});

const recipeId = computed(() => {
    // 優先使用 props.recipeId，否則 fallback route
    return props.recipeId ? Number(props.recipeId) : Number(route.params.recipe_id || route.params.id);
});

const emit = defineEmits(['update:modelValue', 'submit']);

// 1. 資料夾資料結構



const folders = ref([]);
const selectedFolderId = ref(null);
const newFolderName = ref('');
const loading = ref(false);

// 編輯資料夾狀態
const isEditFolders = ref(false);
const editFolderName = ref('');
const editingFolderId = ref(null);
// 編輯資料夾名稱
const startEditFolder = (folder) => {
    editingFolderId.value = folder.id;
    editFolderName.value = folder.name;
};

const cancelEditFolder = () => {
    editingFolderId.value = null;
    editFolderName.value = '';
};

const saveEditFolder = async () => {
    if (!editFolderName.value.trim() || !editingFolderId.value) return;
    loading.value = true;
    try {
        const payload = new URLSearchParams();
        payload.append('favorites_folder_id', editingFolderId.value);
        payload.append('folder_name', editFolderName.value.trim());
        const { data } = await phpApi.patch('/personal/fav_folders.php', payload);
        if (data.success) {
            await fetchFolders();
            cancelEditFolder();
        } else {
            alert(data.message || '修改失敗');
        }
    } catch (e) {
        alert('修改資料夾失敗');
    } finally {
        loading.value = false;
    }
};

// 刪除資料夾
const deleteFolder = async (folder) => {
    // ...existing code...
    if (!folder || !folder.id) {
        alert('資料夾ID不存在');
        return;
    }
    if (!confirm(`確定要刪除「${folder.name}」資料夾？`)) return;
    loading.value = true;
    try {
        const payload = new URLSearchParams();
        payload.append('favorites_folder_id', folder.id);
        // ...existing code...
        const { data } = await phpApi.delete('/personal/fav_folders.php', {
            data: payload.toString(),
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        });
        // ...existing code...
        if (data.success) {
            await fetchFolders();
            if (selectedFolderId.value === folder.id) selectedFolderId.value = null;
        } else {
            alert(data.message || '刪除失敗');
        }
    } catch (e) {
        console.error('刪除錯誤：', e);
        alert('刪除資料夾失敗');
    } finally {
        loading.value = false;
    }
};

// 取得目前登入者 userId
const authStore = useAuthStore();
const userId = computed(() => authStore.user?.user_id || authStore.user?.id || null);

// 取得資料夾列表
const fetchFolders = async () => {
    if (!userId.value) return;
    loading.value = true;
    try {
        // 同時獲取資料夾列表和收藏列表
        const [foldersRes, favoritesRes] = await Promise.all([
            phpApi.get(`/personal/fav_folders.php`, { params: { creator_id: userId.value } }),
            phpApi.get('/social/favorites.php', { params: { user_id: userId.value } })
        ]);

        // ...existing code...

        if (foldersRes.data.success) {
            // 統計每個資料夾的食譜數量
            const favorites = favoritesRes.data.favorites || [];
            const folderCounts = {};

            favorites.forEach(fav => {
                const folderId = fav.folder_id ? Number(fav.folder_id) : null;
                if (folderId) {
                    folderCounts[folderId] = (folderCounts[folderId] || 0) + 1;
                }
            });

            // ...existing code...

            folders.value = foldersRes.data.folders.map(f => {
                const folderId = Number(f.favorites_folder_id);
                const folderData = {
                    name: f.folder_name,
                    id: folderId,
                    count: folderCounts[folderId] || 0
                };
                // ...existing code...
                return folderData;
            });
            // ...existing code...
            // 不自動選中任何資料夾，除非已收藏
            if (!favoriteInfo.value) {
                selectedFolderId.value = null;
            }
        }
    } catch (e) {
        console.error('取得資料夾失敗:', e);
    } finally {
        loading.value = false;
    }
};

// 監聽 modal 開啟狀態，只在打開時才載入資料
import { watch } from 'vue';
watch(() => props.modelValue, (isOpen) => {
    if (isOpen && userId.value) {
        // 同時載入資料夾列表和收藏資訊
        Promise.all([
            fetchFolders(),
            fetchFavoriteInfo()
        ]);
    }
});

const handleClose = () => {
    emit('update:modelValue', false);
};


// 2. 新增分類邏輯（呼叫 API）
const MAX_FOLDERS = 12;
const handleAddFolder = async () => {
    if (folders.value.length >= MAX_FOLDERS) {
        alert('最多只能建立12個資料夾');
        return;
    }
    if (!newFolderName.value.trim() || !userId.value) return;
    loading.value = true;
    try {
        const form = new FormData();
        form.append('creator_id', userId.value);
        form.append('folder_name', newFolderName.value.trim());
        const { data } = await phpApi.post('/personal/fav_folders.php', form);
        if (data.success) {
            await fetchFolders();
            // 自動選中新增的資料夾
            if (data.favorites_folder_id) {
                selectedFolderId.value = Number(data.favorites_folder_id);
            }
            newFolderName.value = '';
        } else {
            alert(data.message || '新增失敗');
        }
    } catch (e) {
        alert('新增資料夾失敗');
    } finally {
        loading.value = false;
    }
};


// 加入收藏時，指定資料夾（未選則為未分類）

// 加入收藏到指定資料夾

// 判斷是否已加入收藏（取得該食譜的收藏資料，若有則可移動資料夾）
const favoriteInfo = ref(null); // { favorite_id, folder_id, ... }


const fetchFavoriteInfo = async () => {
    if (!userId.value || !recipeId.value) return;
    try {
        const { data } = await phpApi.get('/social/favorites.php', {
            params: { user_id: userId.value }
        });
        if (data.success) {
            const found = data.favorites.find(f => Number(f.recipe_id) === recipeId.value);
            favoriteInfo.value = found || null;
            // 預設選到該食譜目前所在的資料夾
            if (found) {
                selectedFolderId.value = found.folder_id ? Number(found.folder_id) : null;
            } else {
                selectedFolderId.value = null;
            }
        } else {
            favoriteInfo.value = null;
        }
    } catch (e) {
        favoriteInfo.value = null;
    }
};

const handleSubmit = async () => {
    if (!userId.value || !recipeId.value) {
        alert('缺少 userId 或 recipeId');
        return;
    }
    const folderId = selectedFolderId.value || null;
    // 什麼都沒選且已收藏，則刪除收藏
    if (!folderId && favoriteInfo.value) {
        try {
            const form = new FormData();
            form.append('user_id', userId.value);
            form.append('recipe_id', recipeId.value);
            form.append('action', 'remove');
            const { data } = await phpApi.post('/social/favorites.php', form);
            if (data.success) {
                alert('已取消收藏');
                await fetchFavoriteInfo(); // 強制刷新
                await fetchFolders(); // 更新資料夾數量
                emit('submit', { updated: true });
                handleClose();
            } else {
                alert(data.message || '取消收藏失敗');
            }
        } catch (e) {
            alert('取消收藏失敗');
        }
        return;
    }
    if (!favoriteInfo.value) {
        // 尚未加入，執行加入收藏
        const form = new FormData();
        form.append('user_id', userId.value);
        form.append('recipe_id', recipeId.value);
        if (folderId) {
            form.append('folder_id', folderId);
        }
        try {
            const { data } = await phpApi.post('/social/favorites.php', form);
            if (data.success) {
                alert('已加入收藏');
                await fetchFavoriteInfo(); // 強制刷新
                await fetchFolders(); // 更新資料夾數量
                emit('submit', { updated: true });
                handleClose();
            } else {
                alert(data.message || '加入收藏失敗');
            }
        } catch (e) {
            alert('加入收藏失敗');
        }
    } else {
        // 已加入，執行移動資料夾
        try {
            const payload = new URLSearchParams();
            payload.append('favorite_id', favoriteInfo.value.favorite_id);
            if (folderId) {
                payload.append('folder_id', folderId);
            } else {
                payload.append('folder_id', 'null');
            }
            const { data } = await phpApi.patch('/social/favorites.php', payload);
            if (data.success) {
                alert('已更換收藏資料夾');
                await fetchFavoriteInfo(); // 強制刷新
                await fetchFolders(); // 更新資料夾數量
                emit('submit', { updated: true });
                handleClose();
            } else {
                alert(data.message || '更換失敗');
            }
        } catch (e) {
            alert('更換收藏失敗');
        }
    }
};

// 移動收藏到其他資料夾
const moveFavoriteToFolder = async (favoriteId, targetFolderId) => {
    try {
        const payload = new URLSearchParams();
        payload.append('favorite_id', favoriteId);
        if (targetFolderId) {
            payload.append('folder_id', targetFolderId);
        } else {
            payload.append('folder_id', 'null'); // PHP 端會判斷 null 為未分類
        }
        const { data } = await phpApi.patch('/social/favorites.php', payload);
        if (data.success) {
            alert('已移動收藏到新資料夾');
            // 可在此刷新收藏清單
        } else {
            alert(data.message || '移動失敗');
        }
    } catch (e) {
        alert('移動收藏失敗');
    }
};

// 動態按鈕文字
const submitButtonText = computed(() => {
    if (!favoriteInfo.value) {
        return '加入收藏'; // 尚未收藏
    }
    if (!selectedFolderId.value) {
        return '取消收藏'; // 已收藏但未選資料夾
    }
    return '確認更換'; // 已收藏且要換資料夾
});
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



                <div class="edit-folder-bar">
                    <BaseBtn title="編輯資料夾" variant="outline" height="32" @click="isEditFolders = !isEditFolders" />
                </div>

                <div class="folder-content">
                    <div v-for="folder in folders" :key="folder.id" class="folder-item"
                        :class="{ active: selectedFolderId === folder.id }" v-if="!isEditFolders"
                        @click="selectedFolderId === folder.id ? selectedFolderId = null : selectedFolderId = folder.id">
                        <div class="icon-box">
                            <i-material-symbols:folder-outline-sharp v-if="selectedFolderId !== folder.id" />
                            <i-material-symbols:folder-sharp v-else />
                        </div>
                        <span class="folder-name" :title="folder.name">{{ folder.name }}</span>
                        <span class="folder-count">({{ folder.count }})</span>
                    </div>
                    <!-- 編輯狀態下顯示編輯/刪除 -->
                    <div v-for="folder in folders" :key="folder.id" class="folder-item edit-mode" v-if="isEditFolders">
                        <div class="icon-box">
                            <i-material-symbols:folder-sharp />
                        </div>
                        <template v-if="editingFolderId === folder.id">
                            <input v-model="editFolderName" class="folder-input" style="width:80px;" />
                            <BaseBtn title="儲存" height="28" @click="saveEditFolder" />
                            <BaseBtn title="取消" variant="outline" height="28" @click="cancelEditFolder" />
                        </template>
                        <template v-else>
                            <span class="folder-name">{{ folder.name }}</span>
                            <span class="folder-count">({{ folder.count }})</span>
                            <BaseBtn title="改名" height="28" @click="startEditFolder(folder)" />
                            <BaseBtn title="刪除" variant="outline" height="28" @click="deleteFolder(folder)" />
                        </template>
                    </div>
                </div>

                <div class="add-folder-section">
                    <div class="add-folder-row">
                        <input v-model="newFolderName" type="text" placeholder="輸入資料夾名稱" class="folder-input" />

                        <BaseTag text="創建資料夾" variant="action"
                            :class="['btn-ingredient-tag', { 'is-active': newFolderName.length > 0 }]"
                            @click.stop="handleAddFolder" />
                    </div>

                    <div class="btn-group">
                        <BaseBtn title="取消" variant="outline" height="40" @click="handleClose" />
                        <BaseBtn :title="submitButtonText" height="40" @click="handleSubmit" />
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
    flex-wrap: wrap;
    gap: 12px 8px;
    justify-content: center;
    align-items: center;
    padding: 10px 0 30px;
    max-height: 340px;
    overflow-y: auto;

    .folder-item {
        display: flex;
        flex-direction: column;
        align-items: center;
        cursor: pointer;
        transition: all 0.2s;
        min-width: 90px;
        background: transparent;
        border-radius: 8px;
        padding: 8px 4px 10px 4px;
        position: relative;
        box-shadow: none;
        margin-bottom: 2px;

        .icon-box {
            font-size: 40px;
            color: $primary-color-700;
            margin-bottom: 4px;
            padding: 4px;
            border: 2px solid transparent;
            border-radius: 8px;
            display: flex;
            align-items: center;
            background: #f8faf7;
        }

        .folder-name {
            font-size: 16px;
            color: $neutral-color-700;
            margin-bottom: 2px;
            max-width: 90px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            display: inline-block;
            vertical-align: middle;
        }

        .folder-count {
            font-size: 12px;
            color: $neutral-color-700;
            display: block;
            text-align: center;
            margin-top: 2px;
            font-weight: 600;
            background: $neutral-color-100;
            padding: 2px 6px;
            border-radius: 8px;
        }

        &.active {
            background: $primary-color-100;

            .icon-box {
                color: $accent-color-400;
                background: $primary-color-100;
            }

            .folder-name {
                color: $accent-color-400;
                font-weight: bold;
            }
        }

        &.edit-mode {
            background: $neutral-color-100;
            border: 1.5px dashed $primary-color-400;
            min-width: 220px;
            max-width: 100%;
            flex-direction: row;
            align-items: center;
            justify-content: center;
            gap: 8px;
            margin-bottom: 8px;
            padding: 8px 12px;
            flex-wrap: wrap;
            word-break: break-all;
            text-align: center;

            .icon-box {
                margin-bottom: 0;
                font-size: 32px;
                background: none;
            }

            .folder-input {
                height: 32px;
                border-radius: 6px;
                border: 1px solid $primary-color-400;
                padding: 0 10px;
                font-size: 15px;
                margin-right: 6px;
                min-width: 70px;
                max-width: 90px;
                text-align: center;
            }

            .folder-name {
                max-width: 90px;
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
                display: inline-block;
                vertical-align: middle;
            }

            .folder-count {
                font-size: 11px;
                color: $neutral-color-800;
                margin-left: 4px;
                background: $neutral-color-white;
                padding: 2px 6px;
                border-radius: 6px;
                font-weight: 600;
            }

            .base-btn {
                margin-left: 2px;
                font-size: 13px;
                padding: 0 10px;
                height: 28px;
                white-space: nowrap;
            }
        }
    }

    .edit-folder-bar {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 8px;

        .edit-tip {
            color: $neutral-color-400;
            font-size: 13px;
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
        // gap: 0;
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