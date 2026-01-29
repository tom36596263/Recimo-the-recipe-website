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

        // 🏆 2. 封裝你原本在詳情頁的計算邏輯
        calculateRecipeNutrition(ingredients) {
            if (!ingredients || ingredients.length === 0 || this.ingredientMaster.length === 0) {
                return { kcal: 0, protein: 0, fat: 0, carbs: 0 };
            }

            let totals = { kcal: 0, protein: 0, fat: 0, carbs: 0 };

            ingredients.forEach(ing => {
                // 尋找對照表：支援 ID 或 名稱 比對
                const master = this.ingredientMaster.find(m =>
                    String(m.ingredient_id) === String(ing.id || ing.ingredient_id) ||
                    m.ingredient_name === (ing.name || ing.ingredient_name)
                );

                // --- 核心邏輯：單位換算 ---
                let unitWeight = Number(ing.gram_conversion || master?.gram_conversion || 1);
                const unitName = ing.unit || ing.unit_name || master?.unit_name || '';

                // 🏆 這裡是你詳情頁最重要的判斷：避免重複計算克數
                if (['克', 'g', 'G', '毫升', 'ml', 'ML'].includes(unitName)) {
                    unitWeight = 1;
                }

                const amount = Number(ing.amount || 0);
                const ratio = (amount * unitWeight) / 100;

                // 累加數值
                totals.kcal += (Number(master?.kcal_per_100g || ing.kcal_per_100g || 0) * ratio);
                totals.protein += (Number(master?.protein_per_100g || ing.protein_per_100g || 0) * ratio);
                totals.fat += (Number(master?.fat_per_100g || ing.fat_per_100g || 0) * ratio);
                totals.carbs += (Number(master?.carbs_per_100g || ing.carbs_per_100g || 0) * ratio);
            });

            // 回傳四捨五入後的整數
            return {
                kcal: Math.round(totals.kcal),
                protein: totals.protein.toFixed(1),
                fat: totals.fat.toFixed(1),
                carbs: totals.carbs.toFixed(1)
            };
        }
    }
});