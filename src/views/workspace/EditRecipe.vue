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
          recipeForm.value.title = `${found.recipe_title} (改編版)`;
        } else {
          recipeForm.value.recipe_id = recipeId;
          recipeForm.value.title = found.recipe_title;
        }

        recipeForm.value.description = found.recipe_description || found.recipe_descreption || '';
        recipeForm.value.difficulty = found.recipe_difficulty || 1;

        let rawCover = found.recipe_image_url || found.recipe_cover_image || '';
        if (rawCover && !rawCover.startsWith('http') && !rawCover.startsWith('data:')) {
          const cleanCover = rawCover.replace(/^\//, '');
          recipeForm.value.coverImg = `/${cleanCover}`;
        } else {
          recipeForm.value.coverImg = rawCover;
        }

        const totalTimeStr = String(found.recipe_total_time || '30');
        if (totalTimeStr.includes(':')) {
          const tParts = totalTimeStr.split(':');
          recipeForm.value.totalTime = (parseInt(tParts[0], 10) * 60) + (parseInt(tParts[1], 10) || 0);
        } else {
          recipeForm.value.totalTime = parseInt(totalTimeStr, 10) || 30;
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
          let rawStepImg = s.step_image_url || s.image || '';
          let finalStepImg = '';

          if (rawStepImg && !rawStepImg.startsWith('http') && !rawStepImg.startsWith('data:')) {
            const cleanStepPath = rawStepImg.replace(/^\//, '');
            if (cleanStepPath.startsWith('img/')) {
              finalStepImg = `/${cleanStepPath}`;
            } else {
              finalStepImg = `/img/recipes/${recipeId}/steps/${cleanStepPath}`;
            }
          } else {
            finalStepImg = rawStepImg;
          }

          const stepTimeStr = String(s.step_total_time || '0');
          let stepMinutes = 0;
          if (stepTimeStr.includes(':')) {
            const sParts = stepTimeStr.split(':');
            stepMinutes = (parseInt(sParts[0], 10) * 60) + (parseInt(sParts[1], 10) || 0);
          } else {
            stepMinutes = parseInt(stepTimeStr, 10) || 0;
          }

          return {
            id: isAdapt ? null : (s.step_id || `s-${recipeId}-${index}`),
            title: s.step_title || '',
            content: s.step_content || '',
            image: finalStepImg,
            time: stepMinutes,
            tags: resStepIng.data.filter(si => Number(si.step_id) === Number(s.step_id)).map(si => si.ingredient_id)
          };
        });
        console.log('✅ 編輯頁資料載入完成');
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
    query: { mode: 'preview', editId: currentId }
  });
};

const handleSave = () => {
  // 1. 基本驗證
  if (!recipeForm.value.title) {
    alert('請輸入食譜標題再發布喔！');
    return;
  }

  // 2. 儲存邏輯
  if (isPublished.value) {
    const localRevisions = JSON.parse(localStorage.getItem('user_revisions') || '[]');
    const newPublishData = {
      ...recipeForm.value,
      id: Date.now(),
      publishDate: new Date().toLocaleDateString(),
      is_local: true,
      is_adaptation: isAdaptModeActive.value
    };
    localRevisions.unshift(newPublishData);
    localStorage.setItem('user_revisions', JSON.stringify(localRevisions));
    alert(`🎉 恭喜！「${recipeForm.value.title}」已公開發布！`);
  } else {
    alert('草稿儲存成功！');
  }

  // 3. 導向邏輯
  recipeStore.rawEditorData = null; // 清除 Store 暫存

  if (isAdaptModeActive.value && recipeForm.value.parent_recipe_id) {
    // 【改編模式】有原食譜 ID，去改編集一覽
    router.push(`/workspace/modify-recipe/${recipeForm.value.parent_recipe_id}`);
  } else {
    // 【創建模式 / 一般編輯】去我的食譜
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