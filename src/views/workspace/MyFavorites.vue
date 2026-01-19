<script setup>
import { ref, onMounted } from 'vue';
import RecipeCardSm from '@/components/common/RecipeCardSm.vue';
import BaseTag from '@/components/common/BaseTag.vue';
import PageBtn from '@/components/common/PageBtn.vue';
import recipesData from '/public/data/recipe/recipes.json';
import tagsData from '/public/data/recipe/tags.json';
import recipeTagData from '/public/data/recipe/recipe_tag.json';

// 食譜列表
const recipes = ref([]);

// 標籤篩選
const tags = ref([]);
const selectedTag = ref(null);

const selectTag = (tag) => {
    selectedTag.value = tag;
};

const addNewCategory = () => {
    console.log('新增分類');
};

// 分頁相關
const currentPage = ref(1);
const totalPages = ref(5);

const handlePageChange = (page) => {
    currentPage.value = page;
    console.log('切換到第', page, '頁');
};

// 初始化數據
onMounted(() => {
    // 載入第4-9筆食譜（共6筆）
    const selectedRecipes = recipesData.slice(3, 9);
    
    // 收集所有標籤ID（不重複）
    const allTagIds = new Set();
    
    recipes.value = selectedRecipes.map(recipe => {
        // 找到該食譜的標籤關聯
        const recipeTags = recipeTagData
            .filter(rt => rt.recipe_id === recipe.recipe_id)
            .map(rt => {
                const tag = tagsData.find(t => t.tag_id === rt.tag_id);
                if (tag) {
                    allTagIds.add(rt.tag_id);
                    return tag.tag_name;
                }
                return null;
            })
            .filter(Boolean);

        return {
            id: recipe.recipe_id,
            recipe_name: recipe.recipe_title,
            image_url: recipe.recipe_image_url,
            tags: recipeTags.length > 0 ? recipeTags : ['未分類'],
            author: {
                name: 'Recimo',
                likes: recipe.recipe_like_count || 0
            }
        };
    });

    // 建立標籤篩選列表（從收藏的食譜中提取）
    tags.value = Array.from(allTagIds)
        .map(tagId => {
            const tag = tagsData.find(t => t.tag_id === tagId);
            return tag ? tag.tag_name : null;
        })
        .filter(Boolean)
        .slice(0, 6); // 限制顯示前6個標籤
    
    // 預設選擇第一個標籤
    if (tags.value.length > 0) {
        selectedTag.value = tags.value[0];
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
                    <div class="tag-filter">
                        <BaseTag v-for="tag in tags" :key="tag" :text="tag"
                            :variant="selectedTag === tag ? 'primary' : 'action'" 
                            :show-icon="false"
                            @click="selectTag(tag)" />
                        <BaseTag text="新增分類" variant="action" :show-icon="true" @click="addNewCategory" />
                    </div>
                </div>
            </div>
            <div class="row">
                <!-- 收藏食譜卡片 -->
                <div v-for="recipe in recipes" :key="recipe.id" class="col-4 col-lg-6 col-md-12">
                    <RecipeCardSm :recipe="recipe" />
                </div>
            </div>
        </section>

        <!-- 分頁 -->
        <section class="container page-btn-section">
            <div class="row">
                <div class="col-12">
                    <PageBtn :current-page="currentPage" :total-pages="totalPages" @page-change="handlePageChange" />
                </div>
            </div>
        </section>
    </div>
</template>

<style lang="scss" scoped>
.my-favorites-page {
    padding: 40px 0 60px;

    .row:not(.page-btn-section .row) {
        row-gap: 24px;
    }

    .col-4,
    .col-lg-6,
    .col-md-12 {
        margin-bottom: 0;
    }
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

.page-btn-section {
    margin-top: 40px;
}

// 響應式調整
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

    .page-btn-section {
        margin-top: 24px;
    }
}
</style>
