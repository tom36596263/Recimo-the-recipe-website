<script setup>
import { ref, provide, onMounted, computed } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useRecipeStore } from '@/stores/recipeEditor';
import { publicApi } from '@/utils/publicApi';

import EditorHeader from '@/components/workspace/editrecipe/EditorHeader.vue';
import IngredientEditor from '@/components/workspace/editrecipe/IngredientEditor.vue';
import StepEditor from '@/components/workspace/editrecipe/StepEditor.vue';

const router = useRouter();
const route = useRoute();
const recipeStore = useRecipeStore();

// --- 讀取 Vite 的 Base 路徑 ---
const baseUrl = import.meta.env.BASE_URL;

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
  totalTime: 30,
  ingredients: [],
  steps: [],
  original_title: '',
  adapt_title: '',
  adapt_description: ''
});

const isAdaptModeActive = computed(() => {
  const hasParentId = !!recipeForm.value.parent_recipe_id;
  const hasAdaptQuery = route.query.action === 'adapt';
  return hasParentId || hasAdaptQuery;
});

// --- 2. 核心邏輯 ---
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
      recipeForm.value.title = `${found.recipe_title} (改編版)`;
    } else {
      recipeForm.value.recipe_id = editIdFromUrl;
      recipeForm.value.title = found.recipe_title;
    }

    recipeForm.value.description = found.recipe_description || found.recipe_descreption || '';
    recipeForm.value.difficulty = found.recipe_difficulty || 1;

    // --- 修正：封面圖路徑拼接 ---
    const rawCover = found.recipe_image_url || found.recipe_cover_image || '';
    if (rawCover && !rawCover.startsWith('http') && !rawCover.startsWith('data:')) {
      const cleanPath = rawCover.replace(/^\//, '');
      // 使用正則確保路徑中沒有重複的斜線
      recipeForm.value.coverImg = `${baseUrl}/${cleanPath}`.replace(/\/+/g, '/');
    } else {
      recipeForm.value.coverImg = rawCover || 'https://placehold.co/800x600?text=No+Image';
    }

    const totalTimeStr = String(found.recipe_total_time || '30');
    recipeForm.value.totalTime = totalTimeStr.includes(':')
      ? parseInt(totalTimeStr.split(':')[0], 10) * 60 + (parseInt(totalTimeStr.split(':')[1], 10) || 0)
      : parseInt(totalTimeStr, 10) || 30;

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
      const rawImg = s.step_image_url || s.image || '';
      let finalStepImg = '';

      if (rawImg) {
        if (rawImg.startsWith('http') || rawImg.startsWith('data:')) {
          finalStepImg = rawImg;
        } else {
          // --- 修正：步驟圖片路徑拼接 ---
          const cleanPath = rawImg.replace(/^img\/recipes\/\d+\/steps\//, '').replace(/^\//, '');
          // 強制使用 / 作為分隔並清理重複斜線
          finalStepImg = `${baseUrl}/img/recipes/${editIdFromUrl}/steps/${cleanPath}`.replace(/\/+/g, '/');
        }
      }

      const stepTimeStr = String(s.step_total_time || '0');
      const stepMinutes = stepTimeStr.includes(':')
        ? parseInt(stepTimeStr.split(':')[0], 10) * 60 + (parseInt(stepTimeStr.split(':')[1], 10) || 0)
        : parseInt(stepTimeStr, 10) || 0;

      return {
        id: isAdapt ? `adapt-step-${editIdFromUrl}-${index}` : (s.step_id || `s-${editIdFromUrl}-${index}`),
        origin_step_id: s.step_id || null,
        title: s.step_title || `步驟 ${index + 1}`,
        content: s.step_content || '',
        image: finalStepImg,
        time: stepMinutes,
        tags: resStepIng.data
          .filter(si => Number(si.step_id) === Number(s.step_id))
          .map(si => si.ingredient_id)
      };
    });
  } catch (err) {
    console.error('❌ 載入食譜失敗:', err);
  }
});

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

const handleSave = () => {
  // 1. 基礎檢查：改編模式優先檢查 adapt_title，普通模式檢查 title
  const finalTitle = isAdaptModeActive.value
    ? (recipeForm.value.adapt_title || recipeForm.value.title)
    : recipeForm.value.title;

  if (!finalTitle) {
    alert('請輸入食譜標題再發布喔！');
    return;
  }

  if (isPublished.value) {
    const localRevisions = JSON.parse(localStorage.getItem('user_revisions') || '[]');

    // 2. 存入時，確保包含了所有關鍵欄位
    localRevisions.unshift({
      ...recipeForm.value, // 這裡已經包含了步驟、食材、highlightTags 等
      id: Date.now(),
      display_title: finalTitle, // 額外存一個顯示用的標題，方便列表抓取
      display_desc: isAdaptModeActive.value ? recipeForm.value.adapt_description : recipeForm.value.description,
      publishDate: new Date().toLocaleDateString(),
      is_local: true,
      is_adaptation: isAdaptModeActive.value
    });

    localStorage.setItem('user_revisions', JSON.stringify(localRevisions));
    alert(`🎉「${finalTitle}」已公開發布！`);
  } else {
    alert('草稿儲存成功！');
  }

  recipeStore.rawEditorData = null;

  // 3. 跳轉邏輯
  if (isAdaptModeActive.value && recipeForm.value.parent_recipe_id) {
    // 如果是從改編頁來的，回改編列表
    router.push(`/workspace/modify-recipe/${recipeForm.value.parent_recipe_id}`);
  } else {
    // 否則回總工作區
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