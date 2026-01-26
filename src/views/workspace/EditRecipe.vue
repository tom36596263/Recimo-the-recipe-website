<script setup>
import { ref, provide, onMounted, computed, watch } from 'vue';
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
  recipe_id: null,
  parent_recipe_id: null,
  title: '',
  description: '',
  coverImg: null,
  difficulty: 1,
  totalTime: 0,
  ingredients: [],
  steps: [],
  original_title: '',
  adapt_title: '',
  adapt_description: ''
});

// 自動計算步驟總時間邏輯
watch(
  () => recipeForm.value.steps,
  (newSteps) => {
    if (!newSteps) return;
    const newSum = newSteps.reduce((sum, s) => sum + (Number(s.time) || 0), 0);
    if (!recipeForm.value.totalTime || recipeForm.value.totalTime == 0) {
      recipeForm.value.totalTime = newSum;
    }
  },
  { deep: true }
);

const isAdaptModeActive = computed(() => {
  const hasParentId = !!recipeForm.value.parent_recipe_id;
  const hasAdaptQuery = route.query.action === 'adapt';
  return hasParentId || hasAdaptQuery;
});

// --- 2. 核心邏輯 (資料載入) ---
onMounted(async () => {
  const rawId = route.query.editId || route.params.id;
  const editIdFromUrl = rawId ? Number(rawId) : null;
  const isAdapt = route.query.action === 'adapt';

  if (recipeStore.rawEditorData) {
    recipeForm.value = { ...recipeStore.rawEditorData };
    recipeStore.rawEditorData = null;
    return;
  }

  if (!editIdFromUrl) return;

  try {
    const [resR, resRecipeIng, resIngMaster, resS, resStepIng] = await Promise.all([
      publicApi.get('data/recipe/recipes.json'),
      publicApi.get('data/recipe/recipe_ingredient.json'),
      publicApi.get('data/recipe/ingredients.json'),
      publicApi.get('data/recipe/steps.json'),
      publicApi.get('data/recipe/step_ingredients.json')
    ]);

    const found = resR.data.find(r => Number(r.recipe_id) === editIdFromUrl);
    if (!found) return;

    if (isAdapt) {
      recipeForm.value.recipe_id = null;
      recipeForm.value.parent_recipe_id = editIdFromUrl;
      recipeForm.value.original_title = found.recipe_title;
      recipeForm.value.adapt_title = `${found.recipe_title} (改編版)`;
      recipeForm.value.title = found.recipe_title;
    } else {
      recipeForm.value.recipe_id = editIdFromUrl;
      recipeForm.value.title = found.recipe_title;
    }

    recipeForm.value.description = found.recipe_description || found.recipe_descreption || '';
    recipeForm.value.difficulty = found.recipe_difficulty || 1;

    const rawCover = found.recipe_image_url || found.recipe_cover_image || '';
    recipeForm.value.coverImg = (rawCover && !rawCover.startsWith('http') && !rawCover.startsWith('data:'))
      ? `/${rawCover.replace(/^\//, '')}`
      : (rawCover || 'https://placehold.co/800x600?text=No+Image');

    const totalTimeStr = String(found.recipe_total_time || '30');
    if (totalTimeStr.includes(':')) {
      const p = totalTimeStr.split(':');
      recipeForm.value.totalTime = parseInt(p[0], 10) * 60 + parseInt(p[1], 10);
    } else {
      recipeForm.value.totalTime = parseInt(totalTimeStr, 10) || 30;
    }

    const links = resRecipeIng.data.filter(i => Number(i.recipe_id) === editIdFromUrl);
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

    const stepsData = resS.data
      .filter(s => Number(s.recipe_id) === editIdFromUrl)
      .sort((a, b) => (a.step_order || 0) - (b.step_order || 0));

    recipeForm.value.steps = stepsData.map((s, index) => {
      let parsedTime = 0;
      const rawStepTime = String(s.step_total_time || '');
      if (rawStepTime.includes(':')) {
        const parts = rawStepTime.split(':');
        parsedTime = parseInt(parts[0], 10) * 60 + parseInt(parts[1], 10);
      } else {
        parsedTime = parseInt(rawStepTime, 10) || 0;
      }

      const rawImg = s.step_image_url || s.image || '';
      let finalStepImg = rawImg;
      if (rawImg && !rawImg.startsWith('http') && !rawImg.startsWith('data:') && !rawImg.startsWith('/')) {
        const cleanPath = rawImg.replace(/^img\/recipes\/\d+\/steps\//, '').replace(/^\//, '');
        finalStepImg = `/img/recipes/${editIdFromUrl}/steps/${cleanPath}`;
      }
      return {
        id: isAdapt ? `adapt-step-${editIdFromUrl}-${index}` : (s.step_id || `s-${editIdFromUrl}-${index}`),
        origin_step_id: s.step_id || null,
        title: s.step_title || `步驟 ${index + 1}`,
        content: s.step_content || '',
        image: finalStepImg,
        time: parsedTime,
        tags: resStepIng.data.filter(si => Number(si.step_id) === Number(s.step_id)).map(si => si.ingredient_id)
      };
    });
  } catch (err) {
    console.error('❌ 載入食譜失敗:', err);
  }
});

// --- 3. 預覽 ---
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
  const query = { mode: 'preview', editId: currentId };
  if (isAdaptModeActive.value) query.action = 'adapt';
  router.push({ path: `/workspace/recipe-detail/${currentId}`, query });
};

// --- 4. 儲存 ---
const handleSave = () => {
  const finalTitle = isAdaptModeActive.value
    ? (recipeForm.value.adapt_title || `${recipeForm.value.original_title} (改編版)`)
    : recipeForm.value.title;

  if (isPublished.value) {
    const localRevisions = JSON.parse(localStorage.getItem('user_revisions') || '[]');

    const saveData = {
      ...recipeForm.value,
      id: Date.now(),
      title: finalTitle,
      description: isAdaptModeActive.value ? recipeForm.value.adapt_description : recipeForm.value.description,
      adaptation_note: isAdaptModeActive.value ? recipeForm.value.adapt_description : '',
      publishDate: new Date().toLocaleDateString(),
      is_local: true,
      is_adaptation: isAdaptModeActive.value,
      is_mine: true
    };

    localRevisions.unshift(saveData);
    localStorage.setItem('user_revisions', JSON.stringify(localRevisions));
    alert(`🎉「${finalTitle}」已公開發布！`);

    // --- ✨ 重點修正：跳轉邏輯 ---
    if (isAdaptModeActive.value && recipeForm.value.parent_recipe_id) {
      // 改編模式：跳轉回改編管理頁面 (ModifyRecipe.vue 對應的路由)
      router.push(`/workspace/modify-recipe/${recipeForm.value.parent_recipe_id}`);
    } else {
      // 創建/一般編輯模式：跳轉回我的食譜
      router.push('/workspace');
    }
  } else {
    alert('草稿儲存成功！');
    router.push('/workspace');
  }

  recipeStore.rawEditorData = null;
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