// 收藏全域狀態管理（Pinia）
import { defineStore } from 'pinia';
import { getFavorites, addFavorite, removeFavorite } from '@/utils/favoritesApi';

export const useFavoritesStore = defineStore('favorites', {
    state: () => ({
        favoriteIds: [], // 收藏的食譜ID陣列
        isLoading: false, // 是否正在載入數據
        isLoaded: false // 是否已經載入過數據
    }),
    actions: {
        async fetchFavorites(userId) {
            // 防止重複請求：如果正在載入或已載入，直接返回
            if (!userId || this.isLoading || this.isLoaded) return;
            
            this.isLoading = true;
            try {
                const { data } = await getFavorites(userId);
                if (data.success) {
                    this.favoriteIds = data.favorites.map(f => Number(f.recipe_id));
                    this.isLoaded = true;
                }
            } catch (error) {
                console.error('載入收藏失敗:', error);
            } finally {
                this.isLoading = false;
            }
        },
        // 強制重新載入（用於新增/移除收藏後）
        async refetchFavorites(userId) {
            if (!userId) return;
            this.isLoaded = false; // 重置已載入狀態
            await this.fetchFavorites(userId);
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
