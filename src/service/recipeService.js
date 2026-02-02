import { phpApi } from '@/utils/publicApi'

export const recipeService = {
    // 把組合邏輯封裝在這裡
    async getAllRecipes() {
        const res = await phpApi.get('get_recipes.php');
        const imgBase = import.meta.env.VITE_API_BASE.replace('/api/', '/');
        
        return res.data.data.map(recipe => ({
            id: recipe.recipe_id,
            recipe_name: recipe.recipe_title,
            image_url: `${imgBase}${recipe.recipe_image_url}`,
            tags: recipe.tags ? recipe.tags.split(',') : [],
            ingredient_ids: recipe.ingredient_ids ? recipe.ingredient_ids.split(',').map(Number) : [],
            // ...其餘格式轉換邏輯...
            difficulty: recipe.recipe_difficulty,
            nutritional_info: {
                calories: `${Math.round(recipe.recipe_kcal_per_100g)}kcal`,
                serving_size: recipe.recipe_servings,
                cooking_time: (() => {
                    const timeParts = recipe.recipe_total_time.split(':'); // [HH, mm, ss]
                    const hours = parseInt(timeParts[0]) || 0;
                    const minutes = parseInt(timeParts[1]) || 0;
                    const totalMinutes = hours * 60 + minutes;
                    return `${totalMinutes}分鐘`;
                })()
            },
            author: {
                name: 'Recimo',
                likes: recipe.recipe_like_count
            }
        }));
    }
}