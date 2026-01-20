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
const isAdaptModeActive = ref(false);

// --- 1. 食譜表單資料 ---
const recipeForm = ref({
  recipe_id: null,
  parent_recipe_id: null,
  title: '',
  description: '',
  coverImg: null,
  difficulty: 1,
  totalTime: '00:00',
  ingredients: [],
  steps: [],
  original_title: '',
  adapt_title: '',
  adapt_description: ''
});

// --- 輔助函式：將 HH:mm:ss 轉為 分鐘數 ---
const parseToMinutes = (timeStr) => {
  if (!timeStr || typeof timeStr !== 'string') return 0;
  if (!timeStr.includes(':')) return parseInt(timeStr, 10) || 0;
  const parts = timeStr.split(':');
  const h = parseInt(parts[0], 10) || 0;
  const m = parseInt(parts[1], 10) || 0;
  return (h * 60) + m;
};

// --- 2. 核心邏輯 ---
onMounted(async () => {
  const rawId = route.query.editId || route.params.id;
  const editIdFromUrl = rawId ? Number(rawId) : null;
  const isAdapt = route.query.action === 'adapt';

  isAdaptModeActive.value = isAdapt;

  if (recipeStore.rawEditorData) {
    recipeForm.value = { ...recipeStore.rawEditorData };
    recipeStore.rawEditorData = null;
    return;
  }

  if (editIdFromUrl) {
    try {
      const [resR, resRecipeIng, resIngMaster, resS, resStepIng] = await Promise.all([
        publicApi.get('data/recipe/recipes.json'),
        publicApi.get('data/recipe/recipe_ingredient.json'),
        publicApi.get('data/recipe/ingredients.json'),
        publicApi.get('data/recipe/steps.json'),
        publicApi.get('data/recipe/step_ingredients.json')
      ]);

      const recipeId = editIdFromUrl;
      const found = resR.data.find(r => Number(r.recipe_id) === recipeId);

      if (found) {
        if (isAdapt) {
          recipeForm.value.recipe_id = null;
          recipeForm.value.parent_recipe_id = recipeId;
          recipeForm.value.original_title = found.recipe_title;
          recipeForm.value.adapt_title = `${found.recipe_title} (改編版)`;
          recipeForm.value.title = recipeForm.value.adapt_title;
          recipeForm.value.description = found.recipe_description || found.recipe_descreption || '';
          recipeForm.value.coverImg = found.recipe_image_url;
        } else {
          recipeForm.value.recipe_id = recipeId;
          recipeForm.value.title = found.recipe_title;
          recipeForm.value.description = found.recipe_description || found.recipe_descreption || '';
          recipeForm.value.coverImg = found.recipe_image_url;
        }

        recipeForm.value.difficulty = found.recipe_difficulty || 1;
        // 修正：確保總時間能正確轉換為分鐘或維持字串
        recipeForm.value.totalTime = found.recipe_total_time || '00:30';

        const rawCover = recipeForm.value.coverImg || '';
        if (rawCover && !rawCover.startsWith('http') && !rawCover.startsWith('/') && !rawCover.startsWith('data:')) {
          recipeForm.value.coverImg = `/img/recipes/${recipeId}/${rawCover}`;
        }

        const links = resRecipeIng.data.filter(i => Number(i.recipe_id) === recipeId);
        recipeForm.value.ingredients = links.map(link => {
          const master = resIngMaster.data.find(m => Number(m.ingredient_id) === Number(link.ingredient_id));
          return {
            id: link.ingredient_id,
            name: master?.ingredient_name || '',
            amount: link.amount,
            unit: link.unit_name || master?.unit_name || '份',
            note: link.remark || '',
            kcal_per_100g: master?.kcal_per_100g || 0
          };
        });

        const stepsData = resS.data.filter(s => Number(s.recipe_id) === recipeId).sort((a, b) => (a.step_order || 0) - (b.step_order || 0));
        recipeForm.value.steps = stepsData.map((s, index) => {
          let rawImg = s.step_image_url || s.image || '';
          let finalImg = (rawImg && !rawImg.startsWith('http') && !rawImg.startsWith('data:') && !rawImg.startsWith('/'))
            ? `/img/recipes/${recipeId}/steps/${rawImg}`
            : rawImg;
          return {
            id: isAdapt ? null : (s.step_id || `s-${recipeId}-${index}`),
            title: s.step_title || '',
            content: s.step_content || '',
            image: finalImg,
            // ✨ 關鍵修正：解析 HH:mm:ss 為純分鐘數給編輯器
            time: parseToMinutes(s.step_total_time),
            tags: resStepIng.data.filter(si => Number(si.step_id) === Number(s.step_id)).map(si => si.ingredient_id)
          };
        });

        console.log('✅ 資料加載成功');
      }
    } catch (err) {
      console.error("❌ 載入食譜失敗:", err);
    }
  }
});

// --- 3. 預覽與儲存 ---
const handlePreview = () => {
  const previewForm = JSON.parse(JSON.stringify(recipeForm.value));

  if (recipeForm.value.coverImg instanceof File) {
    previewForm.coverImg = URL.createObjectURL(recipeForm.value.coverImg);
  }

  recipeForm.value.steps.forEach((step, index) => {
    if (step.image instanceof File) {
      previewForm.steps[index].image = URL.createObjectURL(step.image);
    }
  });

  recipeStore.rawEditorData = { ...recipeForm.value };
  recipeStore.setPreviewFromEditor(previewForm);

  const currentId = route.query.editId || route.params.id || 0;

  router.push({
    path: `/workspace/recipe-detail/${currentId}`,
    query: {
      mode: 'preview',
      editId: currentId
    }
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
        <EditorHeader v-model="recipeForm" :is-editing="isEditing" :is-adapt-mode="isAdaptModeActive" />
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
/* 樣式保持不變... */
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
    max-width: 600px;

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

.preview-btn {
  width: 100px !important;
  min-width: 100px !important;
  border: 1px solid $primary-color-400 !important;
  color: $primary-color-400 !important;

  &:hover {
    background-color: $primary-color-100 !important;
  }
}

.save-btn {
  width: 200px !important;
}
</style>