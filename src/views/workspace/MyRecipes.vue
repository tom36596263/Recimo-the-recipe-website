/**
* 我的食譜總覽頁面（Dashboard）
* 功能：
* 1. 顯示最近觀看食譜、我的收藏、個人食譜三個區塊
* 2. 每個區塊顯示 4 筆預覽數據
* 3. 提供「查看更多」按鈕跳轉到對應的完整列表頁
* 4. 空狀態處理：無數據時顯示引導信息
* 5. 使用 4欄網格佈局，響應式設計支持平板和手機
*/
<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import RecipeCardSm from '@/components/common/RecipeCardSm.vue';
import BaseBtn from '@/components/common/BaseBtn.vue';
import recipesData from '/public/data/recipe/recipes.json';
import tagsData from '/public/data/recipe/tags.json';
import recipeTagData from '/public/data/recipe/recipe_tag.json';

const router = useRouter();

// ========== 狀態管理 ==========
// 最近觀看食譜列表（顯示 4 筆）
const recentRecipes = ref([]);
// 我的收藏食譜列表（顯示 4 筆）
const favoriteRecipes = ref([]);
// 個人食譜列表（顯示 4 筆）
const personalRecipes = ref([]);

// ========== 統計數據（模擬）==========
// 最近觀看總數
const totalRecentCount = ref(0);
// 收藏總數
const totalFavoriteCount = ref(0);
// 個人食譜總數
const totalPersonalCount = ref(0);

// ========== 工具函數 ==========
/**
 * 獲取食譜的標籤列表
 * 通過關聯表查找該食譜的所有標籤
 * @param {Number} recipeId - 食譜 ID
 * @returns {Array} 標籤名稱數組
 */
const getRecipeTags = (recipeId) => {
    const recipeTags = recipeTagData
        .filter(rt => rt.recipe_id === recipeId)
        .map(rt => {
            const tag = tagsData.find(t => t.tag_id === rt.tag_id);
            return tag ? tag.tag_name : null;
        })
        .filter(Boolean);
    return recipeTags.length > 0 ? recipeTags : ['未分類'];
};

// ========== 路由跳轉 ==========
/**
 * 跳轉到最近觀看食譜頁面
 */
const goToRecentRecipes = () => {
    router.push({ name: 'recent-recipes' });
};

/**
 * 跳轉到我的收藏頁面
 */
const goToMyFavorites = () => {
    router.push({ name: 'my-favorites' });
};

/**
 * 跳轉到個人食譜頁面
 */
const goToPersonalRecipes = () => {
    router.push({ name: 'personal-recipes' });
};

// ========== 生命週期 ==========
/**
 * 組件掛載時初始化數據
 * 1. 設置模擬的統計數據（實際應用中應從 API 獲取）
 * 2. 載入最近觀看食譜（前 4 筆）
 * 3. 載入收藏食譜（第 5-8 筆）
 * 4. 載入個人食譜（第 9-12 筆）
 */
onMounted(() => {
    // 設置統計總數（模擬數據，實際應用中應從後端 API 獲取）
    totalRecentCount.value = 15;
    totalFavoriteCount.value = 23;
    totalPersonalCount.value = 8;

    // 最近觀看：載入前 4 筆食譜
    recentRecipes.value = recipesData.slice(0, 4).map(recipe => ({
        id: recipe.recipe_id,
        recipe_name: recipe.recipe_title,
        image_url: recipe.recipe_image_url,
        tags: getRecipeTags(recipe.recipe_id),
        author: {
            name: 'Recimo',
            likes: recipe.recipe_like_count || 0
        }
    }));

    // 我的收藏：載入第 5-8 筆食譜
    favoriteRecipes.value = recipesData.slice(4, 8).map(recipe => ({
        id: recipe.recipe_id,
        recipe_name: recipe.recipe_title,
        image_url: recipe.recipe_image_url,
        tags: getRecipeTags(recipe.recipe_id),
        author: {
            name: 'Recimo',
            likes: recipe.recipe_like_count || 0
        }
    }));

    // 個人食譜：載入第 9-12 筆食譜
    personalRecipes.value = recipesData.slice(8, 12).map(recipe => ({
        id: recipe.recipe_id,
        recipe_name: recipe.recipe_title,
        image_url: recipe.recipe_image_url,
        tags: getRecipeTags(recipe.recipe_id),
        author: {
            name: 'Recimo',
            likes: recipe.recipe_like_count || 0
        }
    }));
});
</script>

<template>
    <div class="my-recipes-page">
        <!-- 最近觀看食譜 -->
        <section class="recipe-section recent-section">
            <div class="container">
                <div class="row">
                    <div class="col-12 section-header">
                        <div class="header-left">
                            <div class="section-icon-wrapper">
                                <i class="fa-regular fa-clock section-icon"></i>
                            </div>
                            <div class="title-group">
                                <h4 class="zh-h4 section-title">最近觀看食譜</h4>
                                <span class="count-badge">{{ totalRecentCount }} 筆記錄</span>
                            </div>
                        </div>
                        <BaseBtn class="view-more-btn" @click="goToRecentRecipes">
                            查看更多
                            <i class="fa-solid fa-chevron-right"></i>
                        </BaseBtn>
                    </div>
                </div>
                <div class="row recipe-cards-container" v-if="recentRecipes.length > 0">
                    <div v-for="recipe in recentRecipes" :key="recipe.id"
                        class="col-3 col-lg-6 col-md-12 recipe-card-col">
                        <RecipeCardSm :recipe="recipe" />
                    </div>
                </div>
                <div class="empty-state" v-else>
                    <div class="empty-icon-wrapper">
                        <i class="fa-regular fa-clock"></i>
                    </div>
                    <p class="empty-text">還沒有觀看任何食譜</p>
                    <p class="empty-hint">開始探索美味食譜，發現更多靈感吧！</p>
                </div>
            </div>
        </section>

        <!-- 我的收藏 -->
        <section class="recipe-section favorites-section">
            <div class="container">
                <div class="row">
                    <div class="col-12 section-header">
                        <div class="header-left">
                            <div class="section-icon-wrapper favorites">
                                <i class="fa-regular fa-heart section-icon"></i>
                            </div>
                            <div class="title-group">
                                <h4 class="zh-h4 section-title">我的收藏</h4>
                                <span class="count-badge">{{ totalFavoriteCount }} 個最愛</span>
                            </div>
                        </div>
                        <BaseBtn class="view-more-btn" @click="goToMyFavorites">
                            查看更多
                            <i class="fa-solid fa-chevron-right"></i>
                        </BaseBtn>
                    </div>
                </div>
                <div class="row recipe-cards-container" v-if="favoriteRecipes.length > 0">
                    <div v-for="recipe in favoriteRecipes" :key="recipe.id"
                        class="col-3 col-lg-6 col-md-12 recipe-card-col">
                        <RecipeCardSm :recipe="recipe" />
                    </div>
                </div>
                <div class="empty-state" v-else>
                    <div class="empty-icon-wrapper favorites">
                        <i class="fa-regular fa-heart"></i>
                    </div>
                    <p class="empty-text">還沒有收藏任何食譜</p>
                    <p class="empty-hint">點擊食譜上的愛心圖示來收藏喜歡的食譜</p>
                </div>
            </div>
        </section>

        <!-- 個人食譜 -->
        <section class="recipe-section personal-section">
            <div class="container">
                <div class="row">
                    <div class="col-12 section-header">
                        <div class="header-left">
                            <div class="section-icon-wrapper personal">
                                <i class="fa-regular fa-file-lines section-icon"></i>
                            </div>
                            <div class="title-group">
                                <h4 class="zh-h4 section-title">個人食譜</h4>
                                <span class="count-badge">{{ totalPersonalCount }} 個原創</span>
                            </div>
                        </div>
                        <BaseBtn class="view-more-btn" @click="goToPersonalRecipes">
                            查看更多
                            <i class="fa-solid fa-chevron-right"></i>
                        </BaseBtn>
                    </div>
                </div>
                <div class="row recipe-cards-container" v-if="personalRecipes.length > 0">
                    <div v-for="recipe in personalRecipes" :key="recipe.id"
                        class="col-3 col-lg-6 col-md-12 recipe-card-col">
                        <RecipeCardSm :recipe="recipe" />
                    </div>
                </div>
                <div class="empty-state" v-else>
                    <div class="empty-icon-wrapper personal">
                        <i class="fa-regular fa-file-lines"></i>
                    </div>
                    <p class="empty-text">還沒有創建個人食譜</p>
                    <p class="empty-hint">開始創建你的專屬食譜，分享你的烹飪創意</p>
                </div>
            </div>
        </section>
    </div>
</template>

<style lang="scss" scoped>
/* ==================== 頁面容器 ==================== */
.my-recipes-page {
    padding: 32px 0 60px;
    // background: linear-gradient(180deg, rgba(62, 141, 96, 0.02) 0%, rgba(255, 255, 255, 0) 100%);
    min-height: calc(100vh - 80px);

    .row:not(.section-header) {
        row-gap: 24px;
    }
}

/* ==================== 區塊樣式 ==================== */
.recipe-section {
    margin-bottom: 48px;
    position: relative;

    &:last-child {
        margin-bottom: 0;
    }

    &::before {
        content: '';
        position: absolute;
        top: 0;
        right: 0;
        width: 200px;
        height: 200px;
        opacity: 0.03;
        pointer-events: none;
        border-radius: 50%;
    }

    &.recent-section::before {
        background: radial-gradient(circle, $primary-color-700 0%, transparent 70%);
    }

    &.favorites-section::before {
        background: radial-gradient(circle, #FF5858 0%, transparent 70%);
    }

    &.personal-section::before {
        background: radial-gradient(circle, $accent-color-700 0%, transparent 70%);
    }
}

/* ==================== 區塊頭部 ==================== */
.section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 32px;
    padding-bottom: 16px;
    border-bottom: 2px solid $neutral-color-100;
    position: relative;

    &::after {
        content: '';
        position: absolute;
        bottom: -2px;
        left: 0;
        width: 80px;
        height: 2px;
        background: $primary-color-700;
        border-radius: 2px;
    }
}

.header-left {
    display: flex;
    align-items: center;
    gap: 16px;
}

.section-icon-wrapper {
    display: flex;
    align-items: center;
    justify-content: center;

    .section-icon {
        font-size: 28px;
        color: $primary-color-700;
    }

    &.favorites .section-icon {
        color: #FF5858;
    }

    &.personal .section-icon {
        color: $accent-color-700;
    }
}

.title-group {
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.section-title {
    margin-bottom: 0;
}

.count-badge {
    font-size: 14px;
    color: $neutral-color-700;
    font-weight: 400;
    display: flex;
    align-items: center;
    gap: 4px;
}

.view-more-btn {
    background: $primary-color-700;
    border: none;
    color: white;
    font-size: 15px;
    font-weight: 500;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 8px;
    transition: all 0.3s ease;
    padding: 10px 20px;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(62, 141, 96, 0.2);

    &:hover {
        background: $primary-color-800;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(62, 141, 96, 0.3);
    }

    &:active {
        transform: translateY(0);
    }

    i {
        font-size: 14px;
        transition: transform 0.3s ease;
    }

    &:hover i {
        transform: translateX(4px);
    }
}

/* ==================== 食譜卡片容器 ==================== */
.recipe-cards-container {
    animation: fadeInUp 0.6s ease;
}

.recipe-card-col {
    animation: fadeInScale 0.4s ease;
    animation-fill-mode: backwards;

    &:nth-child(1) {
        animation-delay: 0.1s;
    }

    &:nth-child(2) {
        animation-delay: 0.2s;
    }

    &:nth-child(3) {
        animation-delay: 0.3s;
    }

    &:nth-child(4) {
        animation-delay: 0.4s;
    }
}

.col-3,
.col-lg-6,
.col-md-12 {
    margin-bottom: 0;
}

/* ==================== 空狀態優化 ==================== */
.empty-state {
    text-align: center;
    padding: 80px 20px;
    animation: fadeIn 0.6s ease;
}

.empty-icon-wrapper {
    width: 120px;
    height: 120px;
    margin: 0 auto 24px;
    border-radius: 50%;
    background: linear-gradient(135deg, $primary-color-100 0%, $primary-color-400 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 8px 24px rgba(62, 141, 96, 0.15);
    animation: pulse 2s ease-in-out infinite;

    &.favorites {
        background: linear-gradient(135deg, #FFE5E5 0%, #FFCFCF 100%);
        box-shadow: 0 8px 24px rgba(255, 88, 88, 0.15);
    }

    &.personal {
        background: linear-gradient(135deg, $accent-color-100 0%, $accent-color-400 100%);
        box-shadow: 0 8px 24px rgba(255, 165, 39, 0.15);
    }

    i {
        font-size: 56px;
        color: $primary-color-700;
    }

    &.favorites i {
        color: #FF5858;
    }

    &.personal i {
        color: $accent-color-700;
    }
}

.empty-text {
    font-size: 20px;
    color: $neutral-color-800;
    margin-bottom: 8px;
    font-weight: 600;
}

.empty-hint {
    font-size: 15px;
    color: $neutral-color-700;
    margin-bottom: 0;
    line-height: 1.6;
}

/* ==================== 動畫效果 ==================== */
@keyframes fadeInUp {
    from {
        opacity: 0;
        transform: translateY(20px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}

@keyframes fadeInScale {
    from {
        opacity: 0;
        transform: scale(0.9);
    }

    to {
        opacity: 1;
        transform: scale(1);
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

@keyframes pulse {

    0%,
    100% {
        transform: scale(1);
    }

    50% {
        transform: scale(1.05);
    }
}

/* ==================== 響應式設計 ==================== */
@media screen and (max-width: 810px) {
    .my-recipes-page {
        padding: 24px 0 100px;
    }

    .recipe-section {
        margin-bottom: 40px;

        &::before {
            width: 120px;
            height: 120px;
        }
    }

    .section-header {
        margin-bottom: 24px;
        flex-direction: column;
        align-items: flex-start;
        gap: 16px;
    }

    .header-left {
        width: 100%;
    }

    .section-icon-wrapper {
        .section-icon {
            font-size: 24px;
        }
    }

    .section-title {
        font-size: 20px;
    }

    .count-badge {
        font-size: 13px;
    }

    .view-more-btn {
        width: 100%;
        justify-content: center;
        padding: 12px 20px;
    }

    .empty-icon-wrapper {
        width: 100px;
        height: 100px;

        i {
            font-size: 48px;
        }
    }

    .empty-text {
        font-size: 18px;
    }

    .empty-hint {
        font-size: 14px;
    }
}
</style>