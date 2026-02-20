<script setup>
import RecipeCardLg from '@/components/common/RecipeCardLg.vue'
import CircleBtn from '@/components/common/CircleBtn.vue'
import { useAuthGuard } from '@/composables/useAuthGuard'
import { useRouter } from 'vue-router';
import { ref, onMounted } from 'vue';
import { phpApi } from '@/utils/publicApi'
import { useFavoritesStore } from '@/stores/favoritesStore';
import { useAuthStore } from '@/stores/authStore';
import { parsePublicFile } from '@/utils/parseFile';

const { runWithAuth } = useAuthGuard();
const router = useRouter();
const recipes = ref([])
const favoritesStore = useFavoritesStore();
const authStore = useAuthStore();

const handleCardClick = (id) => {
    runWithAuth(() => {
        router.push({
            name: 'workspace-recipe-detail',
            params: { id: id }
        })
    })
}

onMounted(async () => {
    const userId = authStore.user?.id || authStore.user?.user_id;
    if (userId) {
        await favoritesStore.fetchFavorites(userId);
    }

    try {
        const res = await phpApi.get('recipes/all_recipe_get.php?mode=public');
        if (res.data.status === 'success') {
            const recipeData = res.data.data;

            // 1. 路徑清理工具
            const cleanPath = (path) => {
                if (!path) return '';
                return path.startsWith('/') ? path.slice(1) : path;
            };

            // 2. 隨機並處理資料
            recipes.value = [...recipeData]
                .sort(() => Math.random() - 0.5)
                .slice(0, 3)
                .map(recipe => {
                    // 處理時間
                    const timeParts = recipe.recipe_total_time.split(':');
                    const totalMinutes = (parseInt(timeParts[0]) || 0) * 60 + (parseInt(timeParts[1]) || 0);

                    // 處理圖片與頭像路徑
                    // 確保丟進 parsePublicFile 的路徑開頭沒有斜線
                    const rawImg = recipe.recipe_image_url || recipe.recipe_image;
                    const rawAvatar = recipe.user_url || recipe.author_image || recipe.avatar_url;

                    return {
                        id: recipe.recipe_id,
                        recipe_name: recipe.recipe_title,
                        difficulty: recipe.recipe_difficulty,
                        image_url: parsePublicFile(cleanPath(rawImg)), // 處理後的完整路徑
                        tags: recipe.tag_names ? recipe.tag_names.split(',') : [],
                        nutritional_info: {
                            calories: `${Math.round(recipe.recipe_kcal_per_100g || 0)}kcal`,
                            serving_size: recipe.recipe_servings,
                            cooking_time: `${totalMinutes}分鐘`
                        },
                        author: {
                            name: recipe.author_name || recipe.user_name || 'Recimo',
                            likes: recipe.recipe_like_count || 0,
                            id: recipe.author_id || 0,
                            handle: recipe.author_email || `user_${recipe.author_id}`
                        },
                        user_url: parsePublicFile(cleanPath(rawAvatar)) // 處理後的完整頭像
                    };
                });
        }
    } catch (error) {
        console.error('載入資料失敗:', error);
    }
});

</script>
<template>

    <div class="col-12 hot-recipe-title">
        <h2 class="zh-h2">熱門食譜推薦</h2>
        <h2 class="en-h3">Hot Recipe</h2>
    </div>
    <div v-for="item in recipes" :key="item.id" @click.prevent="handleCardClick(item.id)"
        class="col-4 col-md-12 recipe-cards">
        <RecipeCardLg :recipe="item" class="recipe-card" />
    </div>
    <div class="col-12 more-recipe-btn">
        <router-link to="/recipes">
            <CircleBtn title="看更多食譜" />
        </router-link>

    </div>

</template>
<style lang="scss" scoped>
.hot-recipe-title {
    margin: 20px 0 50px 0;
    color: $primary-color-700;
    text-align: center;

    .zh-h2 {
        margin-bottom: 10px;
    }
}

.recipe-cards {
    text-decoration: none;
    color: $neutral-color-800;
    margin-bottom: 20px;
    cursor: pointer;
}

.more-recipe-btn {
    display: flex;
    justify-content: center;
    margin-top: 30px;
}

@media screen and (max-width: 810px) {
    .hotrecipe-card {
        margin-bottom: 20px;
    }
}
</style>