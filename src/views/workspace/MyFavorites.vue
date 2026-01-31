/**
* 我的收藏頁面
* 功能：
* 1. 顯示用戶收藏的食譜列表
* 2. 支持按標籤篩選食譜
* 3. 雙欄佈局：左側為食譜列表，右側為預覽詳情
* 4. 分頁功能：每頁顯示 6 個食譜
* 5. 空狀態處理：無收藏時引導用戶探索食譜
*/
<script setup>
// ...existing code...
// ...existing code...
// ...existing code...
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

// ========== 狀態管理 ==========
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

// ========== 標籤篩選 ==========
// 只顯示「全部」
const tags = ref(['全部']);
const selectedTag = ref('全部');

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
 * 根據選中的標籤篩選食譜
 * 若選擇「全部」或未選擇，則返回所有食譜
 */
const filteredRecipes = computed(() => {
    if (!selectedTag.value || selectedTag.value === '全部') {
        return allRecipes.value;
    }
    return allRecipes.value.filter(recipe => recipe.tags.includes(selectedTag.value));
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

// ========== 事件處理 ==========
/**
 * 處理分頁切換
 * @param {Number} page - 目標頁碼
 */
const handlePageChange = (page) => {
    currentPage.value = page;
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

            <!-- 標籤篩選已移除 -->

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
    margin-bottom: 24px;
    color: $neutral-color-800;
}

.tag-filter {
    display: flex;
    gap: 12px;
    margin-bottom: 32px;
    flex-wrap: wrap;
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

    // 隱藏右側預覽卡片
    .col-4 {
        display: none;
    }
}

@media screen and (max-width: 810px) {
    .my-favorites-page {
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
