<script setup>
import { ref, provide, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useRecipeStore } from '@/stores/recipeEditor';
import { publicApi } from '@/utils/publicApi';

import EditorHeader from '@/components/workspace/editrecipe/EditorHeader.vue';
import IngredientEditor from '@/components/workspace/editrecipe/IngredientEditor.vue';
import StepEditor from '@/components/workspace/editrecipe/StepEditor.vue';

const router = useRouter();
const route = useRoute();
const recipeStore = useRecipeStore();

const isEditing = ref(true);
const isPublished = ref(false);

// --- 1. 食譜表單資料 ---
const recipeForm = ref({
  title: '',
  description: '',
  coverImg: null,
  difficulty: 1,
  totalTime: '00:00',
  ingredients: [],
  steps: []
});

// --- 2. 核心邏輯：掛載時載入資料 ---
onMounted(async () => {
  // 情境 A：從預覽模式點擊「返回編輯」
  if (recipeStore.rawEditorData) {
    recipeForm.value = { ...recipeStore.rawEditorData };
    recipeStore.rawEditorData = null;
    return;
  }

  // 情境 B：載入正式食譜資料 (從編輯按鈕過來)
  const editId = route.query.editId || route.params.id;
  if (editId) {
    try {
      const [resR, resRecipeIng, resIngMaster, resS] = await Promise.all([
        publicApi.get('data/recipe/recipes.json'),
        publicApi.get('data/recipe/recipe_ingredient.json'),
        publicApi.get('data/recipe/ingredients.json'),
        publicApi.get('data/recipe/steps.json')
      ]);

      const recipeId = Number(editId);
      const found = resR.data.find(r => Number(r.recipe_id) === recipeId);

      if (found) {
        // 1. 基本資訊
        recipeForm.value.title = found.recipe_title;
        recipeForm.value.description = found.recipe_description || found.recipe_descreption;
        recipeForm.value.difficulty = found.recipe_difficulty || 1;
        recipeForm.value.totalTime = found.recipe_total_time || '00:30';

        // 封面圖片路徑補完
        const rawCover = found.recipe_image_url || '';
        recipeForm.value.coverImg = (rawCover && !rawCover.startsWith('http') && !rawCover.startsWith('/'))
          ? `/img/recipes/${recipeId}/${rawCover}`
          : rawCover;

        // 2. 填入食材
        const links = resRecipeIng.data.filter(i => Number(i.recipe_id) === recipeId);
        recipeForm.value.ingredients = links.map(link => {
          const master = resIngMaster.data.find(m => Number(m.ingredient_id) === Number(link.ingredient_id));
          return {
            id: link.ingredient_id,
            name: master?.ingredient_name || '',
            amount: link.amount,
            unit: link.unit_name || master?.unit_name || '份',
            // 以下為計算營養成分需要的欄位 (由 Store 加總)
            kcal_per_100g: master?.kcal_per_100g || 0,
            protein_per_100g: master?.protein_per_100g || 0,
            fat_per_100g: master?.fat_per_100g || 0,
            carbs_per_100g: master?.carbs_per_100g || 0
          };
        });

        // 3. 填入步驟 (包含圖片與時間轉換)
        const stepsData = resS.data.filter(s => Number(s.recipe_id) === recipeId)
          .sort((a, b) => (a.step_order || 0) - (b.step_order || 0));

        recipeForm.value.steps = stepsData.map((s, index) => {
          // 圖片路徑邏輯
          let rawImg = s.step_image_url || s.image || '';
          let finalImg = '';
          if (rawImg) {
            if (rawImg.startsWith('http') || rawImg.startsWith('data:') || rawImg.startsWith('/')) {
              finalImg = rawImg;
            } else {
              finalImg = `/img/recipes/${recipeId}/steps/${rawImg}`;
            }
          }

          // 時間轉換邏輯: "00:05:00" -> 5 (分鐘)
          let minuteValue = 0;
          const rawTime = s.step_total_time || s.time || '';
          if (rawTime && typeof rawTime === 'string' && rawTime.includes(':')) {
            const parts = rawTime.split(':');
            const h = parseInt(parts[0]) || 0;
            const m = parseInt(parts[1]) || 0;
            minuteValue = (h * 60) + m;
          } else {
            minuteValue = parseInt(rawTime) || 0;
          }

          return {
            id: s.step_id || `s-${recipeId}-${index}`, // 確保 Draggable 渲染有穩定 Key
            title: s.step_title || '',
            content: s.step_content || '',
            image: finalImg,   // ✨ 對應 StepEditor 的 getStepImage(step)
            time: minuteValue, // ✨ 對應 StepEditor 的 step.time (分鐘數字)
            tags: s.tags || []
          };
        });

        console.log('✅ 編輯資料載入成功：圖片與時間已正確解析');
      }
    } catch (err) {
      console.error("載入編輯資料失敗", err);
    }
  }
});

// --- 3. 預覽與儲存 ---
const handlePreview = () => {
  // 深拷貝一份表單進行預覽轉換
  const previewForm = JSON.parse(JSON.stringify(recipeForm.value));

  // 處理封面圖：如果目前是 File 物件則轉為網址
  if (recipeForm.value.coverImg instanceof File) {
    previewForm.coverImg = URL.createObjectURL(recipeForm.value.coverImg);
  }

  // 處理步驟圖：如果是 File 則轉為網址
  recipeForm.value.steps.forEach((step, index) => {
    if (step.image instanceof File) {
      previewForm.steps[index].image = URL.createObjectURL(step.image);
    }
  });

  // 存入 Store：rawEditorData 存原始含 File 的物件；setPreviewFromEditor 轉成詳情頁規格
  recipeStore.rawEditorData = { ...recipeForm.value };
  recipeStore.setPreviewFromEditor(previewForm);

  router.push({
    path: `/workspace/recipe-detail/${route.query.editId || 0}`,
    query: { mode: 'preview' }
  });
};

const handleSave = () => {
  if (window.confirm('確定要儲存目前的編輯內容嗎？')) {
    alert('💾 食譜已成功儲存！');
    recipeStore.rawEditorData = null;
    router.push('/workspace');
  }
};

provide('isEditing', isEditing);
</script>

<template>
  <div :class="['recipe-editor-page', { 'is-editing': isEditing }]">
    <main class="editor-main-layout container">
      <div class="header-section">
        <EditorHeader v-model="recipeForm" :is-editing="isEditing" />
      </div>

      <div class="recipe-main-content">
        <div class="row custom-row-fit">
          <aside class="ingredient-sidebar col-5 col-md-12">
            <IngredientEditor :ingredients="recipeForm.ingredients" :is-editing="isEditing" />
          </aside>
          <section class="step-content col-7 col-md-12">
            <StepEditor :steps="recipeForm.steps" :ingredients="recipeForm.ingredients" :is-editing="isEditing" />
          </section>
        </div>
      </div>

      <footer class="editor-footer">
        <div class="footer-center-group">
          <BaseBtn title="預覽" variant="outline" :width="100" @click="handlePreview" class="preview-btn" />

          <BaseBtn :title="isPublished ? '確認發布' : '完成編輯'" :width="200" @click="handleSave" class="save-btn" />

          <div class="publish-toggle">
            <input type="checkbox" id="publish-check" v-model="isPublished" />
            <label for="publish-check" class="p-p2">公開發布</label>
          </div>
        </div>
      </footer>
    </main>
  </div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.recipe-editor-page {
  min-height: 100vh;
  padding: 40px 0 80px;
  background-color: $neutral-color-white;
}

.recipe-main-content {
  width: 100%;
  margin-top: 20px;
  border: 1px solid $primary-color-400;
  border-radius: 12px;
  background: $neutral-color-white;
  box-sizing: border-box;
  overflow: hidden;

  .custom-row-fit {
    margin: 0;

    >[class*="col-"] {
      padding: 32px 24px;
    }
  }
}

.editor-footer {
  width: 100%;
  display: flex;
  justify-content: center;
  margin-top: 60px;

  .footer-center-group {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 20px;
    width: 100%;
    max-width: 600px; // 限制群組寬度讓它看起來更像在中心

    @media screen and (max-width: 1024px) {
      gap: 12px;
      transform: scale(0.9);
    }
  }

  .publish-toggle {
    display: flex;
    align-items: center;
    gap: 8px;
    white-space: nowrap;

    input {
      width: 18px;
      height: 18px;
      accent-color: $primary-color-800;
      cursor: pointer;
    }

    label {
      cursor: pointer;
      color: $neutral-color-700;
    }
  }
}

.preview-btn,
.save-btn {
  height: 48px !important;
  display: inline-flex !important;
  align-items: center;
  justify-content: center;
  border-radius: 8px !important;
}

// 預覽按鈕：固定較小寬度
.preview-btn {
  width: 100px !important;
  min-width: 100px !important;
  border: 1px solid $primary-color-400 !important;
  color: $primary-color-400 !important;

  &:hover {
    background-color: $primary-color-100 !important;
  }
}

// 發布按鈕：視覺重點
.save-btn {
  width: 200px !important;
}
</style>