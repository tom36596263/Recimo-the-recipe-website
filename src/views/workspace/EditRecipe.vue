<script setup>
import { ref, provide, onMounted, computed, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useRecipeStore } from '@/stores/recipeEditor';
import { publicApi } from '@/utils/publicApi';
import { parsePublicFile } from '@/utils/parseFile';

import EditorHeader from '@/components/workspace/editrecipe/EditorHeader.vue';
import IngredientEditor from '@/components/workspace/editrecipe/IngredientEditor.vue';
import StepEditor from '@/components/workspace/editrecipe/StepEditor.vue';
import TagModal from '@/components/workspace/editrecipe/modals/TagModal.vue';
import { phpApi } from '@/utils/phpApi';

const router = useRouter();
const route = useRoute();
const recipeStore = useRecipeStore();

const isEditing = ref(true);
const isPublished = ref(false);

const ingredientsMasterList = ref([]);
const tagsMasterList = ref([]);
const isTagModalOpen = ref(false);

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
  tags: [],
  original_title: '',
  adapt_title: '',
  adapt_description: '',
  recipe_servings: 1 // 預設值為 1
});

// --- 2. 監聽步驟時間自動加總 ---
watch(
  () => recipeForm.value.steps,
  (newSteps) => {
    if (!newSteps || !isEditing.value) return;
    const autoSum = newSteps.reduce((sum, s) => sum + (Number(s.time) || 0), 0);
    if (Number(recipeForm.value.totalTime) === 0) {
      recipeForm.value.totalTime = autoSum;
    }
  },
  { deep: true }
);

// --- 3. 監聽食材變動補齊營養係數 ---
watch(
  () => recipeForm.value.ingredients,
  (newIngs) => {
    newIngs.forEach(ing => {
      if (ing.id && (ing.kcal_per_100g === undefined || ing.kcal_per_100g === null)) {
        const master = ingredientsMasterList.value.find(m => Number(m.ingredient_id) === Number(ing.id));
        if (master) {
          ing.kcal_per_100g = master.kcal_per_100g || 0;
          ing.protein_per_100g = master.protein_per_100g || 0;
          ing.fat_per_100g = master.fat_per_100g || 0;
          ing.carbs_per_100g = master.carbs_per_100g || 0;
          ing.gram_conversion = master.gram_conversion || 1.0;
          if (!ing.unit) ing.unit = master.unit_name || '份';
        }
      }
    });
  },
  { deep: true }
);

const isAdaptModeActive = computed(() => {
  const hasParentId = !!recipeForm.value.parent_recipe_id;
  const hasAdaptQuery = route.query.action === 'adapt';
  return hasParentId || hasAdaptQuery;
});

const fileToBase64 = (file) => {
  return new Promise((resolve, reject) => {
    if (!file) return resolve(null);
    if (typeof file === 'string') return resolve(file);
    if (file instanceof File) {
      const reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onload = () => resolve(reader.result);
      reader.onerror = (error) => reject(error);
    } else {
      resolve(null);
    }
  });
};

onMounted(async () => {
  const rawId = route.query.editId || route.params.id;
  const editIdFromUrl = rawId ? Number(rawId) : null;
  const isAdapt = route.query.action === 'adapt';

  try {
    const [resIng, resTag] = await Promise.all([
      publicApi.get('data/recipe/ingredients.json'),
      publicApi.get('data/recipe/tags.json')
    ]);
    ingredientsMasterList.value = resIng.data || [];
    tagsMasterList.value = resTag.data || [];

    if (recipeStore.rawEditorData) {
      recipeForm.value = { ...recipeStore.rawEditorData };
      if (isAdapt) {
        recipeForm.value.parent_recipe_id = editIdFromUrl;
        recipeForm.value.recipe_id = null;
      }
      recipeStore.rawEditorData = null;
      return;
    }

    if (!editIdFromUrl) return;

    const response = await phpApi.get(`recipes/recipe_detail_get.php?recipe_id=${editIdFromUrl}`);

    if (response.data && response.data.success) {
      const { main, ingredients, steps, tags } = response.data.data;

      if (isAdapt) {
        recipeForm.value.recipe_id = null;
        recipeForm.value.parent_recipe_id = editIdFromUrl;
        recipeForm.value.original_title = main.recipe_title;
        recipeForm.value.adapt_title = main.recipe_title + ' (改編版)';
        recipeForm.value.title = main.recipe_title;
        recipeForm.value.adapt_description = '';
        const baseDesc = main.recipe_description || main.recipe_descreption || '';
        recipeForm.value.description = baseDesc;
      }

      recipeForm.value.difficulty = Number(main.recipe_difficulty) || 1;
      // 🏆 確保從後端讀取的份數正確填入
      recipeForm.value.recipe_servings = Number(main.recipe_servings) || 1;
      recipeForm.value.coverImg = parsePublicFile(main.recipe_image_url || '');
      recipeForm.value.totalTime = parseInt(main.recipe_total_time, 10) || 0;

      recipeForm.value.tags = tags.map(t => ({
        tag_id: t.tag_id,
        tag_name: t.tag_name
      }));

      recipeForm.value.ingredients = ingredients.map(ing => ({
        id: Number(ing.ingredient_id),
        name: ing.ingredient_name,
        amount: ing.amount,
        unit: ing.unit_name || '份',
        note: ing.remark || '',
        kcal_per_100g: Number(ing.kcal_per_100g) || 0,
        protein_per_100g: Number(ing.protein_per_100g) || 0,
        fat_per_100g: Number(ing.fat_per_100g) || 0,
        carbs_per_100g: Number(ing.carbs_per_100g) || 0,
        gram_conversion: Number(ing.gram_conversion) || 1.0,
        color_tag: ing.color_tag || ''
      }));

      recipeForm.value.steps = steps.map((s, idx) => ({
        id: isAdapt ? `adapt-s-${idx}` : (s.step_id || `s-${idx}`),
        title: s.step_title || `步驟 ${idx + 1}`,
        content: s.step_content || '',
        image: parsePublicFile(s.step_image_url || ''),
        time: s.total_seconds ? Math.floor(Number(s.total_seconds) / 60) : 0,
        tags: s.step_ingredients ? s.step_ingredients.map(id => Number(id)) : []
      }));

      const actualSum = recipeForm.value.steps.reduce((sum, s) => sum + (Number(s.time) || 0), 0);
      if (actualSum > 0) {
        recipeForm.value.totalTime = actualSum;
      }
    }
  } catch (err) {
    console.error('❌ 載入失敗:', err);
  }
});

const handleSave = async () => {
  const finalTitle = isAdaptModeActive.value
    ? (recipeForm.value.adapt_title || `${recipeForm.value.original_title} (改編版)`)
    : recipeForm.value.title;

  const sourceId = route.query.editId || route.params.id;

  if (isPublished.value) {
    try {
      const coverBase64 = await fileToBase64(recipeForm.value.coverImg);
      const processedSteps = await Promise.all(
        recipeForm.value.steps.map(async (s) => ({ ...s, image: await fileToBase64(s.image) }))
      );

      const localRevisions = JSON.parse(localStorage.getItem('user_revisions') || '[]');

      const saveData = {
        ...recipeForm.value,
        id: Date.now(),
        title: finalTitle,
        coverImg: coverBase64,
        steps: processedSteps,
        description: isAdaptModeActive.value ? recipeForm.value.adapt_description : recipeForm.value.description,
        publishDate: new Date().toLocaleDateString(),
        is_local: true,
        is_mine: true
      };

      localRevisions.unshift(saveData);
      localStorage.setItem('user_revisions', JSON.stringify(localRevisions));
      alert(`🎉「${finalTitle}」已發布！`);

      if (isAdaptModeActive.value && sourceId) {
        router.push(`/workspace/modify-recipe/${sourceId}`);
      } else {
        router.push('/workspace/my-recipes');
      }
    } catch (err) {
      console.error("儲存失敗:", err);
    }
  } else {
    alert('草稿儲存成功！');
    router.push('/workspace/my-recipes');
  }
  recipeStore.rawEditorData = null;
};

// --- ✨ 核心修正：handlePreview ---
const handlePreview = async () => {
  // 1. 確保拿到最新的份數並轉換為數字
  const currentServings = Number(recipeForm.value.recipe_servings || 1);

  // 2. 轉換圖片與步驟
  const coverBase64 = await fileToBase64(recipeForm.value.coverImg);
  const processedSteps = await Promise.all(
    recipeForm.value.steps.map(async (s, idx) => ({
      step_id: s.id,
      step_title: s.title,
      step_content: s.content,
      step_total_time: s.time ? `${s.time} 分鐘` : '0 分鐘',
      step_order: idx,
      image: await fileToBase64(s.image),
      step_image_url: await fileToBase64(s.image)
    }))
  );

  // 3. 食材欄位對齊與狀態轉換
  const tagToStatus = {
    'tag-green': 'add',
    'tag-orange': 'mod',
    'tag-blue': 'rep'
  };

  const processedIngredients = recipeForm.value.ingredients.map(ing => ({
    ...ing,
    ingredient_id: ing.id,
    ingredient_name: ing.name,
    unit_name: ing.unit,
    status: tagToStatus[ing.color_tag] || '',
    kcal_per_100g: Number(ing.kcal_per_100g) || 0,
    protein_per_100g: Number(ing.protein_per_100g) || 0,
    fat_per_100g: Number(ing.fat_per_100g) || 0,
    carbs_per_100g: Number(ing.carbs_per_100g) || 0,
    gram_conversion: Number(ing.gram_conversion) || 1.0
  }));

  // 4. 🏆 組裝預覽資料：同時塞入 recipe_servings 與 servings
  const previewData = {
    ...recipeForm.value,
    recipe_title: recipeForm.value.title,
    recipe_description: recipeForm.value.description,
    recipe_cover_image: coverBase64,
    coverImg: coverBase64,
    recipe_servings: currentServings, // 用於後端欄位格式
    servings: currentServings,        // 用於詳細頁 UI 計算格式
    ingredients: processedIngredients,
    steps: processedSteps,
    recipe_tags: recipeForm.value.tags,
    totalTime: recipeForm.value.totalTime
  };

  // 5. 存入 Store 並跳轉
  recipeStore.rawEditorData = { ...recipeForm.value };
  recipeStore.setPreviewFromEditor(previewData);

  console.log('🚀 編輯頁發出的預覽份數:', currentServings);

  router.push({
    path: `/workspace/recipe-detail/${route.query.editId || route.params.id || 0}`,
    query: {
      mode: 'preview',
      editId: route.query.editId || route.params.id,
      action: route.query.action
    }
  });
};

const handleAddTags = (newTags) => {
  recipeForm.value.tags.push(...newTags);
};

provide('isEditing', isEditing);
</script>

<template>
  <div :class="['recipe-editor-page', { 'is-editing': isEditing }]">
    <main class="editor-main-layout container">
      <div class="header-section">
        <EditorHeader v-model="recipeForm" :is-editing="isEditing" :is-adapt-mode="isAdaptModeActive"
        @open-tag-modal="isTagModalOpen = true" />
      </div>

      <div class="recipe-main-content">
        <div class="row custom-row-fit">
          <aside class="ingredient-sidebar col-5 col-md-12">
            <IngredientEditor :ingredients="recipeForm.ingredients" :is-editing="isEditing"
              :is-adapt-mode="isAdaptModeActive" />
          </aside>
          <section class="step-content col-7 col-md-12">
            <StepEditor v-model:steps="recipeForm.steps" :ingredients="recipeForm.ingredients"
              :is-editing="isEditing" />
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
      <TagModal v-model="isTagModalOpen" :selected-list="recipeForm.tags" @add-multiple="handleAddTags" />
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