import { defineStore } from 'pinia';
import { publicApi } from '@/utils/publicApi';

export const useNutritionStore = defineStore('nutrition', {
    state: () => ({
        ingredientMaster: [],
        isLoaded: false
    }),
    actions: {
        // 🏆 1. 統一載入食材庫資料 (只需執行一次)
        async fetchMasterData() {
            if (this.isLoaded) return;
            try {
                const res = await publicApi.get('data/recipe/ingredients.json');
                this.ingredientMaster = res.data || [];
                this.isLoaded = true;
            } catch (err) {
                console.error('NutritionStore: 載入食材庫失敗', err);
            }
        },

        // 🏆 優化後的計算邏輯
        calculateRecipeNutrition(ingredients) {
            if (!ingredients || ingredients.length === 0 || this.ingredientMaster.length === 0) {
                return { kcal: 0, protein: 0, fat: 0, carbs: 0 };
            }

            let totals = { kcal: 0, protein: 0, fat: 0, carbs: 0 };

            ingredients.forEach(ing => {
                const master = this.ingredientMaster.find(m =>
                    String(m.ingredient_id) === String(ing.id || ing.ingredient_id) ||
                    m.ingredient_name === (ing.name || ing.ingredient_name)
                );

                let unitWeight = Number(ing.gram_conversion || master?.gram_conversion || 1);
                const unitName = ing.unit || ing.unit_name || master?.unit_name || '';

                if (['克', 'g', 'G', '毫升', 'ml', 'ML'].includes(unitName)) {
                    unitWeight = 1;
                }

                const amount = Number(ing.amount || 0);
                // 🚀 關鍵：計算過程保持高精度
                const ratio = (amount * unitWeight) / 100;

                totals.kcal += (Number(master?.kcal_per_100g || ing.kcal_per_100g || 0) * ratio);
                totals.protein += (Number(master?.protein_per_100g || ing.protein_per_100g || 0) * ratio);
                totals.fat += (Number(master?.fat_per_100g || ing.fat_per_100g || 0) * ratio);
                totals.carbs += (Number(master?.carbs_per_100g || ing.carbs_per_100g || 0) * ratio);
            });

            // 🏆 修正處：確保回傳的數值在「存檔前」與「顯示時」邏輯一致
            // 如果是為了存進資料庫，建議保留小數點，由 UI 層決定怎麼顯示
            return {
                kcal: Math.round(totals.kcal), // 維持整數顯示
                protein: parseFloat(totals.protein.toFixed(1)), // 轉回數字，避免字串拼接
                fat: parseFloat(totals.fat.toFixed(1)),
                carbs: parseFloat(totals.carbs.toFixed(1))
            };
        }
    }
});