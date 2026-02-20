<script setup>
import { ref, onMounted, computed, watch, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import { phpApi } from '@/utils/publicApi';
import { parsePublicFile } from '@/utils/parseFile'; // 圖片路徑處理
import RecipeCardSm from '@/components/common/RecipeCardSm.vue';
import RecipePreviewCard from '@/components/common/RecipePreviewCard.vue';
import BaseTag from '@/components/common/BaseTag.vue';
import PageBtn from '@/components/common/PageBtn.vue';
import BaseBtn from '@/components/common/BaseBtn.vue';
import { useFavoritesStore } from '@/stores/favoritesStore';

const router = useRouter();
const favoritesStore = useFavoritesStore();

// ========== 狀態管理 ==========
// 所有個人食譜列表（完整數據）
const allRecipes = ref([]);

// 當前選中的食譜（用於右側預覽卡片）
const selectedRecipe = ref(null);

// 彈窗狀態（用於手機版）
const isModalOpen = ref(false);

// 彈窗中顯示的食譜
const modalRecipe = ref(null);

// 螢幕寬度（用於模板中判斷）
const windowWidth = ref(window.innerWidth);

const userId = ref(null);

// 標籤功能暫不處理

// ========== 分頁設置 ==========
// 當前頁碼
const currentPage = ref(1);
// 每頁顯示食譜數量（不含創建卡片）
const pageSize = 5;

// ========== 計算屬性 ==========
// 只做分頁，不做標籤篩選
const totalPages = computed(() => {
    return Math.ceil(allRecipes.value.length / pageSize);
});
const currentPageRecipes = computed(() => {
    const start = (currentPage.value - 1) * pageSize;
    const end = start + pageSize;
    return allRecipes.value.slice(start, end);
});

// ========== 事件處理 ==========
/**
 * 處理分頁切換
 * @param {Number} page - 目標頁碼
 */
const handlePageChange = (page) => {
    currentPage.value = page;
};

/**
 * 選擇食譜（點擊卡片時觸發）
 * @param {Object} recipe - 選中的食譜對象
 */
const selectRecipe = (recipe) => {
    // 在小螢幕上打開彈窗，不設置激活狀態
    if (window.innerWidth <= 1024) {
        modalRecipe.value = recipe;
        isModalOpen.value = true;
    } else {
        selectedRecipe.value = recipe;
    }
};

/**
 * 關閉彈窗
 */
const closeModal = () => {
    isModalOpen.value = false;
};

// 標籤功能暫不處理

/**
 * 創建新食譜
 * 跳轉到食譜編輯頁面
 */
const createNewRecipe = () => {
    router.push({ name: 'edit-recipe' });
};

// ========== 監聽器 ==========
/**
 * 監聽頁面切換
 * 當用戶切換頁碼時，自動選中該頁第一筆食譜（僅在大卡片）
 */
watch(currentPage, () => {
    if (currentPageRecipes.value.length > 0 && window.innerWidth > 1024) {
        selectedRecipe.value = currentPageRecipes.value[0];
    }
});

// 標籤功能暫不處理


onMounted(async () => {
    // 監聽視窗大小變化
    const handleResize = () => {
        windowWidth.value = window.innerWidth;
    };
    window.addEventListener('resize', handleResize);

    // 組件卸載時移除監聽器
    onUnmounted(() => {
        window.removeEventListener('resize', handleResize);
    });


    const userStr = localStorage.getItem('user');
    if (userStr) {
        try {
            const userObj = JSON.parse(userStr);
            userId.value = userObj.user_id;
            
            // 統一載入收藏狀態
            if (userId.value) {
                await favoritesStore.fetchFavorites(userId.value);
            }

            if (userId.value) {
                try {
                    const resMyRecipes = await phpApi.get(`personal/myrecipe_get.php`, { params: { user_id: userId.value } });
                    const myRecipesData = Array.isArray(resMyRecipes.data) ? resMyRecipes.data : [];
                    allRecipes.value = myRecipesData.map(recipe => ({
                        ...recipe,
                        id: recipe.recipe_id,
                        recipe_name: recipe.recipe_title || '未命名食譜',
                        image_url: recipe.recipe_image_url && recipe.recipe_image_url.startsWith('http')
                            ? recipe.recipe_image_url
                            : recipe.recipe_image_url
                                ? parsePublicFile(recipe.recipe_image_url)
                                : '',
                        author: {
                            name: recipe.user_name || 'Recimo',
                            likes: recipe.recipe_like_count || 0
                        }
                    }));
                    // 載入後自動 focus 第一個（大卡片）
                    if (allRecipes.value.length > 0 && window.innerWidth > 1024) {
                        selectedRecipe.value = allRecipes.value[0];
                    }
                } catch (e) {
                    allRecipes.value = [];
                }
            } else {
                allRecipes.value = [];
            }

            // 建立標籤篩選列表
            // tags.value = ['全部', ...Array.from(allTagIds)
            //     .map(tagId => tagMap[tagId])
            //     .filter(Boolean)
            //     .slice(0, 6)];

            // 預設選擇「全部」標籤
            // selectedTag.value = '全部';

            // 預設自動選中第一頁的第一筆食譜（僅在大螢幕）
            if (currentPageRecipes.value.length > 0 && window.innerWidth > 1024) {
                selectedRecipe.value = currentPageRecipes.value[0];
            }
        } catch (error) {
            console.error('載入資料失敗:', error);
        }
    }

    console.log(selectedRecipe.value);

});
</script>

<template>
    <div class="personal-recipes-page">
        <section class="container">
            <div class="row">
                <div class="col-12">
                    <h2 class="zh-h2 page-title">個人食譜</h2>
                </div>
            </div>
            <div class="row">
                <div class="col-12">
                    <div class="tag-filter">
                        <!-- <BaseTag v-for="tag in tags" :key="tag" :text="tag"
                            :variant="selectedTag === tag ? 'primary' : 'action'" :show-icon="false"
                            @click="selectTag(tag)" /> -->
                        <!-- 新增分類功能暫未實現 -->
                        <!-- <BaseTag
                            text="新增分類"
                            variant="action"
                            :show-icon="true"
                            @click="addNewCategory"
                        /> -->
                    </div>
                </div>
            </div>

            <!-- 有食譜時顯示列表 -->
            <div v-if="allRecipes.length > 0" class="row">
                <!-- 左側食譜列表 -->
                <div class="col-8 col-lg-12">
                    <div class="recipe-grid">
                        <!-- 新建食譜卡片 -->
                        <div class="create-recipe-card" @click="createNewRecipe">
                            <i class="fa-solid fa-plus"></i>
                            <p class="p-p1">創建食譜</p>
                        </div>

                        <!-- 食譜卡片 -->
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
                        <i class="fa-solid fa-book"></i>
                        <h3 class="empty-title">還沒有創建任何食譜</h3>
                        <p class="empty-text">開始創建你的第一個專屬食譜吧！</p>
                        <BaseBtn title="創建食譜" variant="solid" :height="40" @click="createNewRecipe" />
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
/* ==================== 頁面容器 ==================== */
.personal-recipes-page {
    padding: 40px 0 60px;
}

/* ==================== 標題樣式 ==================== */
.page-title {
    margin-bottom: 24px;
    color: $neutral-color-800;
}

/* ==================== 標籤篩選區 ==================== */
.tag-filter {
    display: flex;
    gap: 12px;
    margin-bottom: 32px;
    flex-wrap: wrap; // 標籤過多時自動換行
}

/* ==================== 食譜網格佈局 ==================== */
.recipe-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr); // 2欄佈局
    gap: 24px;
    grid-auto-rows: 1fr; // 確保同一行的卡片高度一致
}

/* ==================== 食譜卡片容器 ==================== */
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

    // 懸停效果（非激活狀態）
    &:hover:not(.active) {
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    }

    // 選中狀態：顯示主色邊框
    &.active {
        box-shadow: 0 0 0 2px $primary-color-400;

        // 激活狀態下的hover效果：加深邊框顏色
        &:hover {
            box-shadow: 0 0 0 2px $primary-color-700;
        }
    }
}

/* ==================== 創建食譜卡片 ==================== */
.create-recipe-card {
    border: 2px dashed $neutral-color-400; // 虛線邊框
    border-radius: $radius-base;
    background-color: $neutral-color-100;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.3s ease;

    // 懸停效果：改變顏色突出互動性
    &:hover {
        border-color: $primary-color-700;
        background-color: $primary-color-100;

        i {
            color: $primary-color-700;
        }
    }

    i {
        font-size: 48px;
        color: $neutral-color-700;
        transition: color 0.3s ease;
    }

    .p-p1 {
        margin-top: 12px;
        color: $neutral-color-700;
    }
}

/* ==================== 分頁區域 ==================== */
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

/* ==================== 響應式設計 ==================== */
// 平板尺寸：雙欄佈局改為上下排列
@media screen and (max-width: 1024px) {

    .col-4,
    .col-8 {
        width: 100%;
    }

    .recipe-grid {
        grid-template-columns: repeat(2, 1fr); // 保持2欄網格
        margin-bottom: 32px; // 為下方預覽卡片留出間距
    }

    // 隱藏右側預覽卡片
    .col-4 {
        display: none;
    }
}

// 手機尺寸：網格改為單欄
@media screen and (max-width: 810px) {
    .personal-recipes-page {
        padding: 24px 0 60px;
    }

    .page-title {
        margin-bottom: 20px;
    }

    .tag-filter {
        margin-bottom: 24px;
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
