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
import { ref, onMounted, computed, watch } from 'vue';
import RecipeCardSm from '@/components/common/RecipeCardSm.vue';
import RecipePreviewCard from '@/components/common/RecipePreviewCard.vue';
import BaseTag from '@/components/common/BaseTag.vue';
import PageBtn from '@/components/common/PageBtn.vue';
import BaseBtn from '@/components/common/BaseBtn.vue';
import recipesData from '/public/data/recipe/recipes.json';
import tagsData from '/public/data/recipe/tags.json';
import recipeTagData from '/public/data/recipe/recipe_tag.json';

// ========== 狀態管理 ==========
// 所有收藏食譜列表（完整數據）
const allRecipes = ref([]);

// 當前選中的食譜（用於右側預覽卡片）
const selectedRecipe = ref(null);

// ========== 標籤篩選 ==========
// 可用的標籤列表
const tags = ref([]);
// 當前選中的標籤
const selectedTag = ref(null);

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

/**
 * 選擇食譜（點擊卡片時觸發）
 * @param {Object} recipe - 選中的食譜對象
 */
const selectRecipe = (recipe) => {
    selectedRecipe.value = recipe;
};

/**
 * 選擇標籤（點擊標籤時觸發）
 * @param {String} tag - 選中的標籤名稱
 */
const selectTag = (tag) => {
    selectedTag.value = tag;
};

// ========== 監聽器 ==========
/**
 * 監聽頁面切換
 * 當用戶切換頁碼時，自動選中該頁第一筆食譜
 */
watch(currentPage, () => {
    if (currentPageRecipes.value.length > 0) {
        selectedRecipe.value = currentPageRecipes.value[0];
    }
});

/**
 * 監聽標籤切換
 * 當用戶切換標籤時，重置到第一頁並選中第一筆食譜
 */
watch(selectedTag, () => {
    currentPage.value = 1;
    if (currentPageRecipes.value.length > 0) {
        selectedRecipe.value = currentPageRecipes.value[0];
    }
});

// ========== 生命週期 ==========
/**
 * 組件掛載時初始化數據
 * 1. 從 JSON 文件載入收藏食譜數據（模擬從後端獲取）
 * 2. 處理食譜與標籤的關聯關係
 * 3. 建立標籤篩選列表
 * 4. 預設選中第一頁第一筆食譜
 */
onMounted(() => {
    // 載入收藏食譜數據（取前 20 筆）
    const selectedRecipes = recipesData.slice(0, 20);

    // 使用 Set 收集所有不重複的標籤ID
    const allTagIds = new Set();

    // 將原始食譜數據轉換為組件所需的格式
    allRecipes.value = selectedRecipes.map(recipe => {
        // 通過關聯表查找該食譜的所有標籤
        const recipeTags = recipeTagData
            .filter(rt => rt.recipe_id === recipe.recipe_id) // 篩選出該食譜的標籤關聯
            .map(rt => {
                const tag = tagsData.find(t => t.tag_id === rt.tag_id); // 根據 tag_id 查找標籤詳情
                if (tag) {
                    allTagIds.add(rt.tag_id); // 收集標籤ID用於建立篩選列表
                    return tag.tag_name;
                }
                return null;
            })
            .filter(Boolean); // 過濾掉 null 值

        // 返回格式化的食譜對象
        return {
            id: recipe.recipe_id,
            recipe_name: recipe.recipe_title,
            image_url: recipe.recipe_image_url,
            tags: recipeTags.length > 0 ? recipeTags : ['未分類'],
            difficulty: recipe.recipe_difficulty,
            nutritional_info: {
                calories: `${Math.round(recipe.recipe_kcal_per_100g)}kcal`,
                serving_size: recipe.recipe_servings,
                cooking_time: `${recipe.recipe_total_time.split(':')[1]}分鐘`
            },
            author: {
                name: 'Recimo',
                likes: recipe.recipe_like_count || 0
            }
        };
    });

    // 建立標籤篩選列表
    // 從收集到的標籤ID中查找對應的標籤名稱，並添加「全部」選項
    tags.value = ['全部', ...Array.from(allTagIds)
        .map(tagId => {
            const tag = tagsData.find(t => t.tag_id === tagId);
            return tag ? tag.tag_name : null;
        })
        .filter(Boolean) // 過濾掉 null 值
        .slice(0, 6)]; // 限制最多顯示 6 個標籤（加上「全部」共 7 個）

    // 預設選擇「全部」標籤
    selectedTag.value = '全部';

    // 預設自動選中第一頁的第一筆食譜
    if (currentPageRecipes.value.length > 0) {
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

            <!-- 標籤篩選 -->
            <div class="row">
                <div class="col-12">
                    <div class="tag-filter">
                        <BaseTag v-for="tag in tags" :key="tag" :text="tag"
                            :variant="selectedTag === tag ? 'primary' : 'action'" :show-icon="false"
                            @click="selectTag(tag)" />
                        <!-- 新增分類功能暫未實現 -->
                        <!-- <BaseTag text="新增分類" variant="action" :show-icon="true" @click="addNewCategory" /> -->
                    </div>
                </div>
            </div>

            <!-- 有食譜時顯示列表 -->
            <div v-if="allRecipes.length > 0" class="row">
                <!-- 左側食譜列表 -->
                <div class="col-8 col-lg-12">
                    <div class="recipe-grid">
                        <div v-for="recipe in currentPageRecipes" :key="recipe.id" class="recipe-card-wrapper"
                            :class="{ 'active': selectedRecipe?.id === recipe.id }" @click="selectRecipe(recipe)">
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

    &:hover {
        transform: translateY(-4px);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    }

    &.active {
        box-shadow: 0 0 0 2px $primary-color-400;
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

// 響應式調整
@media screen and (max-width: 1024px) {

    .col-4,
    .col-8 {
        width: 100%;
    }

    .recipe-grid {
        grid-template-columns: repeat(2, 1fr);
        margin-bottom: 32px;
    }
}

@media screen and (max-width: 810px) {
    .my-favorites-page {
        padding: 24px 0 40px;
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
