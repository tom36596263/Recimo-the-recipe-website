<script setup>
    import RecipeCardLg from '@/components/common/RecipeCardLg.vue'
    import CircleBtn from '@/components/common/CircleBtn.vue'
    import { useAuthGuard } from '@/composables/useAuthGuard'
    import { useRouter } from 'vue-router';
    import { ref, onMounted } from 'vue';
    import { phpApi } from '@/utils/publicApi'
    import { useFavoritesStore } from '@/stores/favoritesStore';
    import { useAuthStore } from '@/stores/authStore';

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
    // 統一載入收藏狀態
    const userId = authStore.user?.id || authStore.user?.user_id;
    if (userId) {
        await favoritesStore.fetchFavorites(userId);
    }

    try {
        // const [resRecipes, resRecipeTags, resTags] = await Promise.all([
        //     publicApi.get('data/recipe/recipes.json'),
        //     publicApi.get('data/recipe/recipe_tag.json'),
        //     publicApi.get('data/recipe/tags.json')  
        // ]);
        const res = await phpApi.get('recipes/all_recipe_get.php?mode=public');
        if (res.data.status === 'success') {
            const recipeData = res.data.data;

            // 2. 隨機取 3 筆
            const randomRecipes = [...recipeData]
                .sort(() => Math.random() - 0.5)
                .slice(0, 3);

            recipes.value = randomRecipes.map(recipe => {
                // 3. 處理時間顯示
                const timeParts = recipe.recipe_total_time.split(':');
                const hours = parseInt(timeParts[0]);
                const minutes = parseInt(timeParts[1]);
                const displayTime = hours > 0 ? `${hours * 60 + minutes}分鐘` : `${minutes}分鐘`;

                // 4. 處理標籤 (假設 SQL 使用 GROUP_CONCAT 回傳逗號分隔字串)
                // 範例："素食,家常菜" -> ["素食", "家常菜"]
                const recipeTagsNames = recipe.tag_names ? recipe.tag_names.split(',') : [];

                return {
                    id: recipe.recipe_id,
                    recipe_name: recipe.recipe_title,
                    difficulty: recipe.recipe_difficulty,
                    image_url: recipe.recipe_image_url,
                    tags: recipeTagsNames,
                    nutritional_info: {
                        calories: `${Math.round(recipe.recipe_kcal_per_100g)}kcal`,
                        serving_size: recipe.recipe_servings,
                        cooking_time: displayTime
                    },
                    author: {
                        name: recipe.author_name || 'Recimo', // 如果 SQL 有 join 到作者名
                        likes: recipe.recipe_like_count,
                        id: recipe.author_id // 如果 SQL 有 join 到作者 ID
                    }
                };
            });
        }
        // const recipeData = res.data;
        // const recipeTagsData = res.data.recipe_tags || [];
        // const tagsData = res.data.tags || [];

        // const tagMap = {};
        // tagsData.forEach(tag => {
        //     tagMap[tag.tag_id] = tag.tag_name;
        // });

        // const randomRecipes = [...recipeData]
        // .sort(() => Math.random() - 0.5)
        // .slice(0, 3);

        // const base = import.meta.env.BASE_URL;
        // recipes.value = randomRecipes.map(recipe => {

        //     const matchedTagIds = recipeTagsData
        //         .filter(rt => rt.recipe_id === recipe.recipe_id)
        //         .map(rt => rt.tag_id);

        //     // 透過 tagMap 轉換成 tag_name 陣列
        //     const recipeTagsNames = matchedTagIds.map(id => tagMap[id]).filter(Boolean);
        //     const timeParts = recipe.recipe_total_time.split(':');
        //     const hours = parseInt(timeParts[0]);
        //     const minutes = parseInt(timeParts[1]);
        //     const displayTime = hours > 0 ? `${hours * 60 + minutes}分鐘` : `${minutes}分鐘`;

        //     return {
        //         id: recipe.recipe_id,
        //         recipe_name: recipe.recipe_title,
        //         difficulty: recipe.recipe_difficulty,
        //         image_url: recipe.recipe_image_url,
        //         tags: recipeTagsNames,
        //         nutritional_info: {
        //             calories: `${Math.round(recipe.recipe_kcal_per_100g)}kcal`,
        //             serving_size: recipe.recipe_servings,
        //             cooking_time: displayTime
        //         },
        //         author: {
        //             name: 'Recimo',
        //             likes: recipe.recipe_like_count
        //         }
        //     };
        // });
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
    <div 
    v-for="item in recipes" 
    :key="item.id"
    @click.prevent="handleCardClick(item.id)"
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
    .hot-recipe-title{
        margin: 20px 0 50px 0;
        color: $primary-color-700;
        text-align: center;
        .zh-h2{
            margin-bottom: 10px;
        }
    }
    .recipe-cards{
        text-decoration: none;
        color: $neutral-color-800;
        margin-bottom: 20px;
        cursor: pointer;
    }
    .more-recipe-btn{
        display: flex;
        justify-content: center;
        margin-top: 30px;
    }
    @media screen and (max-width: 810px){
        .hotrecipe-card{
            margin-bottom: 20px;
        }
    }
</style>