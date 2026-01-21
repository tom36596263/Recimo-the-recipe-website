import { defineStore } from 'pinia';

export const useRecipeStore = defineStore('recipeEditor', {
    state: () => ({
        // 存放轉換後供詳情頁顯示的資料 (Preview Mode 使用)
        previewData: null,
        // 存放編輯器原始格式的資料 (返回編輯器還原使用)
        rawEditorData: null
    }),
    actions: {
        setPreviewFromEditor(form) {
            // ✨ 1. 先把原始 form 深拷貝存起來 (用於返回編輯)
            // 注意：JSON.parse 無法拷貝 File 物件，但在上傳時已轉為 Base64 字串則沒問題
            this.rawEditorData = JSON.parse(JSON.stringify(form));

            // --- 2. 時間格式處理 (分鐘轉 HH:mm) ---
            let totalMinutes = Number(form.totalTime) || 0;
            if (totalMinutes === 0 && form.steps) {
                totalMinutes = form.steps.reduce((sum, s) => sum + (Number(s.time) || 0), 0);
            }
            const hrs = Math.floor(totalMinutes / 60);
            const mins = totalMinutes % 60;
            const formattedTime = `${hrs.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}`;

            // --- 3. 營養成分自動加總計算 ---
            let totalKcal = 0;
            let totalProtein = 0;
            let totalFat = 0;
            let totalCarbs = 0;

            const mappedIngredients = (form.ingredients || []).map(i => {
                const amountNum = parseFloat(i.amount) || 0;
                const ratio = amountNum / 100;
                totalKcal += (i.kcal_per_100g || 0) * ratio;
                totalProtein += (i.protein_per_100g || 0) * ratio;
                totalFat += (i.fat_per_100g || 0) * ratio;
                totalCarbs += (i.carbs_per_100g || 0) * ratio;

                return {
                    id: i.id, // 保留 ID 供步驟標籤匹配
                    ingredient_name: i.name || '',
                    amount: i.amount || 0,
                    unit_name: i.unit || '',
                    note: i.note || '',
                    kcal_per_100g: i.kcal_per_100g || 0,
                    protein_per_100g: i.protein_per_100g || 0,
                    fat_per_100g: i.fat_per_100g || 0,
                    carbs_per_100g: i.carbs_per_100g || 0
                };
            });

            // --- 4. 組裝成詳情頁規格資料 ---
            this.previewData = {
                recipe_id: 0,
                recipe_title: form.title || '未命名食譜',
                recipe_description: form.description || '', // 修正拼字錯誤 descreption -> description
                recipe_cover_image: form.coverImg || 'https://placehold.co/800x600?text=No+Cover',
                recipe_difficulty: form.difficulty || 3,
                recipe_total_time: formattedTime,
                totalTime: totalMinutes,
                recipe_kcal_per_100g: Math.round(totalKcal),
                recipe_protein_per_100g: parseFloat(totalProtein.toFixed(1)),
                recipe_fat_per_100g: parseFloat(totalFat.toFixed(1)),
                recipe_carbs_per_100g: parseFloat(totalCarbs.toFixed(1)),
                ingredients: mappedIngredients,

                // ✨ 步驟轉換：多重欄位判定，解決圖片與文字消失的死穴
                steps: (form.steps || []).map((s, index) => ({
                    step_id: s.id || s.step_id || `s${index + 1}`,
                    step_order: index + 1,
                    // 標題備援
                    step_title: s.title || s.step_title || `步驟 ${index + 1}`,
                    // 內容備援 (編輯器通常用 .text)
                    step_content: s.text || s.content || s.step_content || '',
                    // 圖片備援 (編輯器上傳後會存入 .img)
                    step_image_url: s.img || s.image || s.step_image_url || null,
                    // 時間格式轉換
                    step_total_time: s.time ? `00:${s.time.toString().padStart(2, '0')}:00` : '00:00:00',
                    // 食材標籤
                    tags: s.tags || []
                }))
            };

            console.log('✅ 預覽資料轉換完成:', this.previewData);
        },

        clearStorage() {
            this.previewData = null;
            this.rawEditorData = null;
        }
    }
});