<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import RecipeCardSm from '@/components/common/RecipeCardSm.vue';
import recipesData from '/public/data/recipe/recipes.json';
import tagsData from '/public/data/recipe/tags.json';
import recipeTagData from '/public/data/recipe/recipe_tag.json';

const router = useRouter();

// 食譜列表
const recentRecipes = ref([]);
const favoriteRecipes = ref([]);
const personalRecipes = ref([]);

// 獲取食譜標籤的輔助函數
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

// 初始化數據
onMounted(() => {
    // 最近觀看：取前3筆
    recentRecipes.value = recipesData.slice(0, 3).map(recipe => ({
        id: recipe.recipe_id,
        recipe_name: recipe.recipe_title,
        image_url: recipe.recipe_image_url,
        tags: getRecipeTags(recipe.recipe_id),
        author: {
            name: 'Recimo',
            likes: recipe.recipe_like_count || 0
        }
    }));

    // 我的收藏：取第4-6筆
    favoriteRecipes.value = recipesData.slice(3, 6).map(recipe => ({
        id: recipe.recipe_id,
        recipe_name: recipe.recipe_title,
        image_url: recipe.recipe_image_url,
        tags: getRecipeTags(recipe.recipe_id),
        author: {
            name: 'Recimo',
            likes: recipe.recipe_like_count || 0
        }
    }));

    // 個人食譜：取第7-9筆
    personalRecipes.value = recipesData.slice(6, 9).map(recipe => ({
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

// 跳轉到詳細頁面
const goToRecentRecipes = () => {
    router.push({ name: 'recent-recipes' });
};

const goToMyFavorites = () => {
    router.push({ name: 'my-favorites' });
};

const goToPersonalRecipes = () => {
    router.push({ name: 'personal-recipes' });
};
</script>

<template>
    <div class="my-recipes-page">
        <!-- 最近觀看食譜 -->
        <section class="recipe-section">
            <div class="container">
                <div class="row">
                    <div class="col-12 section-header">
                        <h3 class="zh-h3 section-title">最近觀看食譜</h3>
                        <button class="view-more-btn" @click="goToRecentRecipes">
                            查看更多
                            <i class="fa-solid fa-chevron-right"></i>
                        </button>
                    </div>
                </div>
                <div class="row">
                    <div v-for="recipe in recentRecipes" :key="recipe.id" class="col-4 col-lg-6 col-md-12">
                        <RecipeCardSm :recipe="recipe" />
                    </div>
                </div>
            </div>
        </section>

        <!-- 我的收藏 -->
        <section class="recipe-section">
            <div class="container">
                <div class="row">
                    <div class="col-12 section-header">
                        <h3 class="zh-h3 section-title">我的收藏</h3>
                        <button class="view-more-btn" @click="goToMyFavorites">
                            查看更多
                            <i class="fa-solid fa-chevron-right"></i>
                        </button>
                    </div>
                </div>
                <div class="row">
                    <div v-for="recipe in favoriteRecipes" :key="recipe.id" class="col-4 col-lg-6 col-md-12">
                        <RecipeCardSm :recipe="recipe" />
                    </div>
                </div>
            </div>
        </section>

        <!-- 個人食譜 -->
        <section class="recipe-section">
            <div class="container">
                <div class="row">
                    <div class="col-12 section-header">
                        <h3 class="zh-h3 section-title">個人食譜</h3>
                        <button class="view-more-btn" @click="goToPersonalRecipes">
                            查看更多
                            <i class="fa-solid fa-chevron-right"></i>
                        </button>
                    </div>
                </div>
                <div class="row">
                    <div v-for="recipe in personalRecipes" :key="recipe.id" class="col-4 col-lg-6 col-md-12">
                        <RecipeCardSm :recipe="recipe" />
                    </div>
                </div>
            </div>
        </section>
    </div>
</template>

<style lang="scss" scoped>
.my-recipes-page {
    padding: 40px 0;
}

.recipe-section {
    margin-bottom: 60px;

    &:last-child {
        margin-bottom: 0;
    }
}

.section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.section-title {
    margin-bottom: 0;
    color: $neutral-color-800;
}

.view-more-btn {
    background: none;
    border: none;
    color: $primary-color-700;
    font-size: 16px;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 8px;
    transition: all 0.2s ease;
    padding: 8px 12px;
    border-radius: 4px;

    &:hover {
        background-color: $primary-color-100;
        color: $primary-color-800;
    }

    i {
        font-size: 14px;
        transition: transform 0.2s ease;
    }

    &:hover i {
        transform: translateX(4px);
    }
}

// 響應式調整
@media screen and (max-width: 1320px) {
    .create-recipe-card {
        height: 340px;
    }
}

@media screen and (max-width: 810px) {
    .my-recipes-page {
        padding: 24px 0;
    }

    .recipe-section {
        margin-bottom: 40px;
    }

    .section-title {
        margin-bottom: 16px;
    }
}
</style>