<script setup>
// 關閉手機版預覽模態框
function closeModal() {
    isModalOpen.value = false;
    modalRecipe.value = null;
}
// 點擊卡片切換預覽
function selectRecipe(recipe) {
    if (window.innerWidth <= 1024) {
        modalRecipe.value = recipe;
        isModalOpen.value = true;
    } else {
        selectedRecipe.value = recipe;
    }
}
import { ref, onMounted, computed, watch, onUnmounted } from 'vue';
import { phpApi, publicApi } from '@/utils/publicApi';
import { parsePublicFile } from '@/utils/parseFile'
import RecipeCardSm from '@/components/common/RecipeCardSm.vue';
import RecipePreviewCard from '@/components/common/RecipePreviewCard.vue';
import BaseTag from '@/components/common/BaseTag.vue';
import PageBtn from '@/components/common/PageBtn.vue';
import BaseBtn from '@/components/common/BaseBtn.vue';
import { useFavoritesStore } from '@/stores/favoritesStore';

// ========== 狀態管理 ==========
const favoritesStore = useFavoritesStore();
import { useAuthStore } from '@/stores/authStore';
const authStore = useAuthStore();

// 所有收藏食譜列表（完整數據）
const allRecipes = ref([]);
const userId = ref(null);

// 當前選中的食譜（用於右側預覽卡片）
const selectedRecipe = ref(null);

// 彈窗狀態（用於手機版）
const isModalOpen = ref(false);

// 彈窗中顯示的食譜
const modalRecipe = ref(null);

// 螢幕寬度
const windowWidth = ref(window.innerWidth);

// ========== 資料夾篩選 ==========
const folders = ref([]);
const selectedFolderId = ref(null); // null 代表「全部」
const newFolderName = ref('');
const loading = ref(false);
const MAX_FOLDERS = 12;

// 編輯資料夾狀態
const isEditMode = ref(false);
const editFolderName = ref('');
const editingFolderId = ref(null);

// ========== 分頁設置 ==========
// 當前頁碼
const currentPage = ref(1);
// 每頁顯示食譜數量
const pageSize = 6;

// ========== 計算屬性 ==========
/**
 * 計算總頁數
 * 根據篩選後的食譜數量計算總頁數
 */
const totalPages = computed(() => {
    return Math.ceil(filteredRecipes.value.length / pageSize);
});

/**
 * 根據選中的資料夾篩選食譜
 * 若未選擇資料夾，則返回所有食譜
 */
const filteredRecipes = computed(() => {
    if (selectedFolderId.value === null) {
        return allRecipes.value;
    }
    // 篩選該資料夾的收藏（folder_id 為 null 代表未分類）
    return allRecipes.value.filter(recipe => {
        const recipeFolderId = recipe.folder_id ? Number(recipe.folder_id) : null;
        return recipeFolderId === selectedFolderId.value;
    });
});

/**
 * 計算當前頁面要顯示的食譜
 * 根據當前頁碼進行數據切片
 */
const currentPageRecipes = computed(() => {
    const start = (currentPage.value - 1) * pageSize;
    const end = start + pageSize;
    return filteredRecipes.value.slice(start, end);
});

// ========== 資料夾管理 ==========
// 取得資料夾列表
const fetchFolders = async () => {
    if (!userId.value) return;
    try {
        // 同時獲取資料夾列表和收藏列表
        const [foldersRes, favoritesRes] = await Promise.all([
            phpApi.get('/personal/fav_folders.php', { params: { creator_id: userId.value } }),
            phpApi.get('social/favorites.php', { params: { user_id: userId.value } })
        ]);

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

            folders.value = foldersRes.data.folders.map(f => {
                const folderId = Number(f.favorites_folder_id);
                return {
                    id: folderId,
                    name: f.folder_name,
                    count: folderCounts[folderId] || 0
                };
            });
        }
    } catch (e) {
        console.error('取得資料夾失敗:', e);
    }
};

// 新增資料夾
const handleAddFolder = async () => {
    if (folders.value.length >= MAX_FOLDERS) {
        alert('最多只能建立12個資料夾');
        return;
    }
    if (!newFolderName.value.trim() || !userId.value) {
        console.log('新增資料夾驗證失敗:', { newFolderName: newFolderName.value, userId: userId.value });
        return;
    }
    loading.value = true;
    try {
        const form = new FormData();
        form.append('creator_id', userId.value);
        form.append('folder_name', newFolderName.value.trim());

        console.log('準備新增資料夾:', {
            creator_id: userId.value,
            folder_name: newFolderName.value.trim()
        });

        const { data } = await phpApi.post('/personal/fav_folders.php', form, {
            headers: {
                'Content-Type': 'multipart/form-data'
            }
        });
        console.log('新增資料夾回應:', data);

        if (data.success) {
            await fetchFolders();
            newFolderName.value = '';
            alert('資料夾新增成功！');
        } else {
            alert(data.message || '新增失敗');
        }
    } catch (e) {
        console.error('新增資料夾錯誤:', e);
        alert('新增資料夾失敗: ' + (e.response?.data?.message || e.message));
    } finally {
        loading.value = false;
    }
};

// 選擇資料夾
const selectFolder = (folderId) => {
    selectedFolderId.value = folderId;
    currentPage.value = 1; // 切換資料夾時重置頁碼
};

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
    if (!folder || !folder.id) {
        alert('資料夾ID不存在');
        return;
    }
    if (!confirm(`確定要刪除「${folder.name}」資料夾？資料夾內的收藏也會一併刪除。`)) return;
    loading.value = true;
    try {
        const payload = new URLSearchParams();
        payload.append('favorites_folder_id', folder.id);
        const { data } = await phpApi.delete('/personal/fav_folders.php', {
            data: payload.toString(),
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        });
        if (data.success) {
            await fetchFolders();
            // 如果刪除的是當前選中的資料夾，切換回「全部」
            if (selectedFolderId.value === folder.id) {
                selectedFolderId.value = null;
            }
            // 重新載入收藏列表
            await loadFavorites();
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

// ========== 事件處理 ==========
/**
 * 處理分頁切換
 * @param {Number} page - 目標頁碼
 */
const handlePageChange = (page) => {
    currentPage.value = page;
};

// 載入收藏列表
const loadFavorites = async () => {
    if (!userId.value) return;
    try {
        // 取得收藏清單
        const resFavorites = await phpApi.get('social/favorites.php', { params: { user_id: userId.value } });
        const favoritesData = Array.isArray(resFavorites.data.favorites) ? resFavorites.data.favorites : [];
        // 直接用 API 回傳資料，不再 enrich public 資料
        allRecipes.value = favoritesData.map(fav => ({
            ...fav,
            id: fav.recipe_id,
            recipe_name: fav.recipe_title || fav.recipe_name || fav.title || '未命名食譜',
            image_url: fav.recipe_image_url && fav.recipe_image_url.startsWith('http')
                ? fav.recipe_image_url
                : fav.recipe_image_url
                    ? parsePublicFile(fav.recipe_image_url)
                    : '',
            author: {
                name: fav.user_name || fav.author_name || 'Recimo',
                likes: fav.recipe_like_count || fav.likes || fav.like_count || 0
            }
        }));
        // 預設自動選中第一頁的第一筆食譜（僅在大螢幕）
        if (currentPageRecipes.value.length > 0 && window.innerWidth > 1024) {
            selectedRecipe.value = currentPageRecipes.value[0];
        }
    } catch (error) {
        allRecipes.value = [];
        console.error('載入收藏資料失敗:', error);
    }
};

// 選擇食譜（點擊卡片時觸發）
onMounted(async () => {
    // 監聽視窗大小變化
    const handleResize = () => {
        windowWidth.value = window.innerWidth;
    };
    window.addEventListener('resize', handleResize);

    onUnmounted(() => {
        window.removeEventListener('resize', handleResize);
    });

    // 取得 localStorage 裡的 user 物件，並解析 user_id
    const userStr = localStorage.getItem('user');
    if (!userStr) return;
    try {
        const userObj = JSON.parse(userStr);
        userId.value = userObj.id;
    } catch (e) {
        userId.value = null;
        return;
    }
    if (!userId.value) return;

    // 統一載入收藏狀態
    await favoritesStore.fetchFavorites(userId.value);

    // 取得資料夾列表
    await fetchFolders();

    // 載入收藏列表
    await loadFavorites();
});
// ...已移除標籤相關程式碼，保留前方收藏卡片 enrich 處理...
// 分頁換頁時自動 focus 分頁中的第一個食譜卡片（大螢幕）
watch(currentPage, () => {
    if (currentPageRecipes.value.length > 0 && window.innerWidth > 1024) {
        selectedRecipe.value = currentPageRecipes.value[0];
    }
});
</script>

<template>
    <div class="my-favorites-page">
        <section class="container">
            <div class="row">
                <div class="col-12">
                    <h2 class="zh-h2 page-title">我的收藏</h2>
                </div>
            </div>

            <div class="row">
                <div class="col-12">
                    <div class="folder-section">
                        <!-- 區塊標題與編輯按鈕 -->
                        <div class="section-header">
                            <h3 class="section-title">資料夾分類</h3>
                            <button class="edit-toggle-btn" @click="isEditMode = !isEditMode"
                                :class="{ 'active': isEditMode }">
                                <i class="fa-solid fa-pen" v-if="!isEditMode"></i>
                                <i class="fa-solid fa-check" v-else></i>
                                <span>{{ isEditMode ? '完成' : '編輯' }}</span>
                            </button>
                        </div>

                        <div class="folder-filter">
                            <!-- 一般模式：顯示可選擇的標籤 -->
                            <template v-if="!isEditMode">
                                <div class="folder-tag" :class="{ 'selected': selectedFolderId === null }"
                                    @click="selectFolder(null)">
                                    <i class="fa-solid fa-heart"></i>
                                    <span>全部收藏</span>
                                    <span class="count">{{ allRecipes.length }}</span>
                                </div>
                                <div v-for="folder in folders" :key="folder.id" class="folder-tag"
                                    :class="{ 'selected': selectedFolderId === folder.id }"
                                    @click="selectFolder(folder.id)">
                                    <i class="fa-solid fa-folder"></i>
                                    <span>{{ folder.name }}</span>
                                    <span class="count">{{ folder.count }}</span>
                                </div>
                            </template>

                            <!-- 編輯模式：顯示編輯/刪除按鈕 -->
                            <template v-else>
                                <div v-for="folder in folders" :key="folder.id" class="folder-edit-card">
                                    <template v-if="editingFolderId === folder.id">
                                        <div class="edit-input-group">
                                            <i class="fa-solid fa-folder"></i>
                                            <input v-model="editFolderName" type="text" class="folder-edit-input"
                                                maxlength="10" placeholder="資料夾名稱" @keyup.enter="saveEditFolder"
                                                @keyup.esc="cancelEditFolder" />
                                        </div>
                                        <div class="edit-actions">
                                            <button class="action-btn save" @click="saveEditFolder" title="儲存">
                                                <i class="fa-solid fa-check"></i>
                                            </button>
                                            <button class="action-btn cancel" @click="cancelEditFolder" title="取消">
                                                <i class="fa-solid fa-xmark"></i>
                                            </button>
                                        </div>
                                    </template>
                                    <template v-else>
                                        <div class="folder-info">
                                            <i class="fa-solid fa-folder"></i>
                                            <span class="folder-name">{{ folder.name }}</span>
                                            <span class="folder-count">({{ folder.count }})</span>
                                        </div>
                                        <div class="edit-actions">
                                            <button class="action-btn edit" @click="startEditFolder(folder)" title="改名">
                                                <i class="fa-solid fa-pen"></i>
                                            </button>
                                            <button class="action-btn delete" @click="deleteFolder(folder)" title="刪除">
                                                <i class="fa-solid fa-trash"></i>
                                            </button>
                                        </div>
                                    </template>
                                </div>
                            </template>

                            <!-- 新增資料夾輸入框 -->
                            <div v-if="!isEditMode" class="add-folder-card">
                                <div class="add-input-group">
                                    <i class="fa-solid fa-folder-plus"></i>
                                    <input v-model="newFolderName" type="text" placeholder="新增資料夾" maxlength="10"
                                        class="add-folder-input" @keyup.enter="handleAddFolder" />
                                </div>
                                <button class="add-btn" :class="{ 'active': newFolderName.length > 0 }"
                                    :disabled="!newFolderName.trim() || loading" @click="handleAddFolder">
                                    <i class="fa-solid fa-plus"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 有食譜時顯示列表 -->
            <div v-if="allRecipes.length > 0" class="row">
                <!-- 左側食譜列表 -->
                <div class="col-8 col-lg-12">
                    <div class="recipe-grid">
                        <div v-for="recipe in currentPageRecipes" :key="recipe.id" class="recipe-card-wrapper"
                            :class="{ 'active': selectedRecipe?.id === recipe.id && windowWidth > 1024 }"
                            @click="selectRecipe(recipe)">
                            <RecipeCardSm :recipe="recipe" :disable-navigation="true" />
                        </div>
                    </div>
                </div>

                <!-- 右側預覽卡片 -->
                <div class="col-4 col-lg-12">
                    <RecipePreviewCard v-if="selectedRecipe" :recipe="selectedRecipe" />
                </div>
            </div>

            <!-- 沒有食譜時顯示空狀態 -->
            <div v-else class="row">
                <div class="col-12">
                    <div class="empty-state">
                        <i class="fa-regular fa-heart"></i>
                        <h3 class="empty-title">還沒有收藏任何食譜</h3>
                        <p class="empty-text">發現喜歡的食譜時，點擊愛心收藏起來吧！</p>
                        <BaseBtn title="探索食譜" variant="solid" :height="40" href="/workspace/recipes" />
                    </div>
                </div>
            </div>
        </section>

        <!-- 分頁（只在有食譜時顯示） -->
        <section v-if="allRecipes.length > 0" class="container page-btn-section">
            <div class="row">
                <div class="col-12">
                    <PageBtn :current-page="currentPage" :total-pages="totalPages" @update:page="handlePageChange" />
                </div>
            </div>
        </section>
    </div>

    <!-- 手機版彈窗 -->
    <Teleport to="body">
        <div v-if="isModalOpen" class="recipe-modal-overlay" @click="closeModal">
            <div class="recipe-modal-wrapper">
                <button class="modal-close-btn" @click="closeModal">
                    <i class="fa-solid fa-xmark"></i>
                </button>
                <div class="recipe-modal-content" @click.stop>
                    <RecipePreviewCard v-if="modalRecipe" :recipe="modalRecipe" />
                </div>
            </div>
        </div>
    </Teleport>
</template>

<style lang="scss" scoped>
.my-favorites-page {
    padding: 40px 0 60px;
}

.page-title {
    margin-bottom: 32px;
    color: $neutral-color-800;
}

/* ==================== 資料夾區塊 ==================== */
.folder-section {
    background: $neutral-color-white;
    border-radius: 16px;
    padding: 24px;
    margin-bottom: 32px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 16px;
    border-bottom: 2px solid $primary-color-100;

    .section-title {
        font-size: 18px;
        font-weight: 600;
        color: $neutral-color-800;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 8px;

        &::before {
            content: '';
            width: 4px;
            height: 20px;
            background: $primary-color-700;
            border-radius: 2px;
        }
    }

    .edit-toggle-btn {
        display: flex;
        align-items: center;
        gap: 6px;
        padding: 8px 16px;
        border: 1.5px solid $primary-color-400;
        background: $neutral-color-white;
        color: $primary-color-700;
        border-radius: 20px;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.3s ease;

        i {
            font-size: 12px;
        }

        &:hover {
            background: $primary-color-100;
            border-color: $primary-color-700;
        }

        &.active {
            background: $primary-color-700;
            color: $neutral-color-white;
            border-color: $primary-color-700;
        }
    }
}

.folder-filter {
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
    align-items: stretch;
}

/* 一般模式 - 資料夾標籤 */
.folder-tag {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 16px;
    background: $neutral-color-100;
    border: 2px solid transparent;
    border-radius: 12px;
    cursor: pointer;
    transition: all 0.3s ease;
    user-select: none;

    i {
        font-size: 16px;
        color: $primary-color-700;
    }

    span {
        font-size: 14px;
        font-weight: 500;
        color: $neutral-color-800;
    }

    .count {
        font-size: 12px;
        color: $neutral-color-700;
        background: $neutral-color-white;
        padding: 2px 8px;
        border-radius: 10px;
        font-weight: 600;
    }

    &:hover {
        background: $primary-color-100;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(62, 141, 96, 0.15);
    }

    &.selected {
        background: $primary-color-700;
        border-color: $primary-color-700;

        i,
        span {
            color: $neutral-color-white;
        }

        .count {
            background: rgba(255, 255, 255, 0.2);
            color: $neutral-color-white;
        }
    }
}

/* 編輯模式 - 資料夾卡片 */
.folder-edit-card {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    padding: 12px 16px;
    background: $neutral-color-white;
    border: 2px dashed $primary-color-400;
    border-radius: 12px;
    min-width: 260px;
    transition: all 0.3s ease;

    &:hover {
        border-color: $primary-color-700;
        box-shadow: 0 2px 8px rgba(62, 141, 96, 0.1);
    }

    .folder-info {
        display: flex;
        align-items: center;
        gap: 10px;
        flex: 1;

        i {
            font-size: 18px;
            color: $primary-color-700;
        }

        .folder-name {
            font-size: 14px;
            font-weight: 500;
            color: $neutral-color-800;
            max-width: 120px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .folder-count {
            font-size: 12px;
            color: $neutral-color-700;
        }
    }

    .edit-input-group {
        display: flex;
        align-items: center;
        gap: 10px;
        flex: 1;

        i {
            font-size: 18px;
            color: $primary-color-700;
        }

        .folder-edit-input {
            flex: 1;
            height: 36px;
            padding: 0 12px;
            border: 1.5px solid $primary-color-400;
            border-radius: 8px;
            outline: none;
            font-size: 14px;
            transition: all 0.3s ease;

            &:focus {
                border-color: $primary-color-700;
                box-shadow: 0 0 0 3px rgba($primary-color-400, 0.15);
            }
        }
    }

    .edit-actions {
        display: flex;
        gap: 6px;

        .action-btn {
            width: 32px;
            height: 32px;
            border: none;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s ease;
            font-size: 14px;

            &.edit {
                background: $primary-color-100;
                color: $primary-color-700;

                &:hover {
                    background: $primary-color-400;
                    color: $neutral-color-white;
                }
            }

            &.delete {
                background: $secondary-color-danger-200;
                color: $secondary-color-danger-700;

                &:hover {
                    background: $secondary-color-danger-700;
                    color: $neutral-color-white;
                }
            }

            &.save {
                background: $secondary-color-success-200;
                color: $secondary-color-success-700;

                &:hover {
                    background: $secondary-color-success-700;
                    color: $neutral-color-white;
                }
            }

            &.cancel {
                background: $neutral-color-100;
                color: $neutral-color-700;

                &:hover {
                    background: $neutral-color-400;
                    color: $neutral-color-white;
                }
            }
        }
    }
}

/* 新增資料夾卡片 */
.add-folder-card {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 12px 8px 16px;
    background: linear-gradient(135deg, $primary-color-100 0%, rgba($primary-color-400, 0.1) 100%);
    border: 2px dashed $primary-color-400;
    border-radius: 12px;
    min-width: 240px;
    transition: all 0.3s ease;

    &:hover {
        border-color: $primary-color-700;
        box-shadow: 0 4px 12px rgba(62, 141, 96, 0.15);
    }

    .add-input-group {
        display: flex;
        align-items: center;
        gap: 10px;
        flex: 1;

        i {
            font-size: 18px;
            color: $primary-color-700;
        }

        .add-folder-input {
            flex: 1;
            height: 36px;
            padding: 0 12px;
            border: none;
            background: $neutral-color-white;
            border-radius: 8px;
            outline: none;
            font-size: 14px;
            transition: all 0.3s ease;

            &:focus {
                box-shadow: 0 0 0 3px rgba($primary-color-400, 0.2);
            }

            &::placeholder {
                color: $neutral-color-400;
            }
        }
    }

    .add-btn {
        width: 36px;
        height: 36px;
        border: none;
        background: $neutral-color-400;
        color: $neutral-color-white;
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: all 0.3s ease;
        font-size: 16px;

        &:hover:not(:disabled) {
            background: $primary-color-700;
            transform: scale(1.05);
        }

        &.active {
            background: $primary-color-700;
            animation: pulse 0.6s ease-in-out;
        }

        &:disabled {
            cursor: not-allowed;
            opacity: 0.5;
        }
    }
}

@keyframes pulse {

    0%,
    100% {
        transform: scale(1);
    }

    50% {
        transform: scale(1.1);
    }
}

.edit-mode-toggle {
    margin-bottom: 16px;
    display: flex;
    justify-content: flex-end;
}

.recipe-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 24px;
}

.recipe-card-wrapper {
    cursor: pointer;
    transition: all 0.3s ease;
    border-radius: 12px;
    overflow: hidden;

    // 禁用RecipeCardSm的hover上浮效果
    :deep(.recipe-card-sm) {
        &:hover {
            transform: none !important;
        }
    }

    &:hover:not(.active) {
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    }

    &.active {
        box-shadow: 0 0 0 2px $primary-color-400;

        &:hover {
            box-shadow: 0 0 0 2px $primary-color-700;
        }
    }
}

.page-btn-section {
    margin-top: 40px;
}

/* ==================== 空狀態樣式 ==================== */
.empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 80px 20px;
    text-align: center;

    i {
        font-size: 80px;
        color: $neutral-color-400;
        margin-bottom: 24px;
        opacity: 0.5;
    }

    .empty-title {
        font-size: 24px;
        font-weight: 600;
        color: $neutral-color-800;
        margin-bottom: 12px;
    }

    .empty-text {
        font-size: 16px;
        color: $neutral-color-700;
        margin-bottom: 32px;
        max-width: 400px;
    }
}

/* ==================== 彈窗樣式 ==================== */
.recipe-modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 9999;
    padding: 20px;
    animation: fadeIn 0.3s ease;
}

.recipe-modal-wrapper {
    position: relative;
    max-width: 600px;
    width: 100%;
}

.recipe-modal-content {
    position: relative;
    width: 100%;
    max-height: 90vh;
    overflow-y: auto;
    background: $neutral-color-white;
    border-radius: 16px;
    animation: slideUp 0.3s ease;
}

.modal-close-btn {
    position: absolute;
    top: -15px;
    right: -15px;
    width: 40px;
    height: 40px;
    border: none;
    background: $neutral-color-white;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    z-index: 10;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
    transition: all 0.3s ease;

    i {
        font-size: 20px;
        color: $neutral-color-700;
    }

    &:hover {
        background: $neutral-color-100;
        transform: scale(1.1);
    }
}

@keyframes fadeIn {
    from {
        opacity: 0;
    }

    to {
        opacity: 1;
    }
}

@keyframes slideUp {
    from {
        transform: translateY(30px);
        opacity: 0;
    }

    to {
        transform: translateY(0);
        opacity: 1;
    }
}

// 響應式調整
@media screen and (max-width: 1024px) {

    .col-4,
    .col-8 {
        width: 100%;
    }

    .recipe-grid {
        grid-template-columns: repeat(2, 1fr);
        margin-bottom: 20px;
    }

    .col-4 {
        display: none;
    }

    .folder-section {
        padding: 20px;
    }

    .folder-filter {
        gap: 10px;
    }

    .folder-tag {
        min-width: auto;
        flex: 1 1 calc(50% - 5px);
        max-width: calc(50% - 5px);
    }

    .folder-edit-card,
    .add-folder-card {
        min-width: 100%;
        width: 100%;
    }
}

@media screen and (max-width: 810px) {
    .my-favorites-page {
        padding: 24px 0 60px;
    }

    .page-title {
        margin-bottom: 20px;
    }

    .folder-section {
        padding: 16px;
        margin-bottom: 24px;
    }

    .section-header {
        .section-title {
            font-size: 16px;
        }

        .edit-toggle-btn {
            padding: 6px 12px;
            font-size: 13px;
        }
    }

    .folder-filter {
        gap: 8px;
    }

    .folder-tag {
        flex: 1 1 100%;
        max-width: 100%;
        padding: 12px 14px;
    }

    .folder-edit-card {
        flex-direction: column;
        align-items: stretch;
        min-width: 100%;

        .folder-info {
            width: 100%;
        }

        .edit-actions {
            width: 100%;
            justify-content: flex-end;
        }
    }

    .recipe-grid {
        grid-template-columns: 1fr;
        gap: 16px;
    }

    .page-btn-section {
        margin-top: 24px;
    }
}
</style>
