// 收藏全域狀態管理（Pinia）
import { defineStore } from 'pinia';
import { getFavorites, addFavorite, removeFavorite } from '@/utils/favoritesApi';

export const useFavoritesStore = defineStore('favorites', {
    state: () => ({
        favoriteIds: [] // 收藏的食譜ID陣列
    }),
    actions: {
        async fetchFavorites(userId) {
            if (!userId) return;
            const { data } = await getFavorites(userId);
            if (data.success) {
                this.favoriteIds = data.favorites.map(f => Number(f.recipe_id));
            }
        },
        async addFavorite(userId, recipeId) {
            const res = await addFavorite(userId, recipeId);
            if (res.data.success) {
                if (!this.favoriteIds.includes(Number(recipeId))) {
                    this.favoriteIds.push(Number(recipeId));
                }
            }
            return res.data;
        },
        async removeFavorite(userId, recipeId) {
            const res = await removeFavorite(userId, recipeId);
            if (res.data.success) {
                this.favoriteIds = this.favoriteIds.filter(id => id !== Number(recipeId));
            }
            return res.data;
        }
    },
    getters: {
        isFavorited: (state) => (id) => state.favoriteIds.includes(Number(id))
    }
});
