<script setup>
import { ref, provide, onMounted, computed, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useRecipeStore } from '@/stores/recipeEditor';
import { publicApi } from '@/utils/publicApi';
import { parsePublicFile } from '@/utils/parseFile';

import EditorHeader from '@/components/workspace/editrecipe/EditorHeader.vue';
import IngredientEditor from '@/components/workspace/editrecipe/IngredientEditor.vue';
import StepEditor from '@/components/workspace/editrecipe/StepEditor.vue';

const router = useRouter();
const route = useRoute();
const recipeStore = useRecipeStore();

const isEditing = ref(true);
const isPublished = ref(false);

// 暫存資料庫的食材 Master Data，供手動新增時查詢營養係數
const ingredientsMasterList = ref([]);

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
  adapt_description: '',
  recipe_servings: 1
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

// ✨ 關鍵修正：監聽食材變動，當使用者手動新增食材（只有 ID）時，自動補齊營養係數
watch(
  () => recipeForm.value.ingredients,
  (newIngs) => {
    newIngs.forEach(ing => {
      // 如果這筆食材還沒有營養係數，嘗試從 master 中補齊
      if (ing.id && (ing.kcal_per_100g === undefined || ing.kcal_per_100g === null)) {
        const master = ingredientsMasterList.value.find(m => Number(m.ingredient_id) === Number(ing.id));
        if (master) {
          ing.kcal_per_100g = master.kcal_per_100g || 0;
          ing.protein_per_100g = master.protein_per_100g || 0;
          ing.fat_per_100g = master.fat_per_100g || 0;
          ing.carbs_per_100g = master.carbs_per_100g || 0;
          ing.gram_conversion = master.gram_conversion || 1.0;
          // 如果沒有單位也順便補上
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

// --- 3. 核心邏輯 (資料載入) ---
onMounted(async () => {
  const rawId = route.query.editId || route.params.id;
  const editIdFromUrl = rawId ? Number(rawId) : null;
  const isAdapt = route.query.action === 'adapt';

  try {
    // 💡 無論是否為新食譜，都先載入食材 Master Data
    const resIngMaster = await publicApi.get('data/recipe/ingredients.json');
    ingredientsMasterList.value = resIngMaster.data || [];

    // 優先檢查 Store 是否已有暫存數據
    if (recipeStore.rawEditorData) {
      recipeForm.value = { ...recipeStore.rawEditorData };
      recipeStore.rawEditorData = null;
      return;
    }

    if (!editIdFromUrl) return;

    // 載入現有食譜數據
    const [resR, resRecipeIng, resS, resStepIng] = await Promise.all([
      publicApi.get('data/recipe/recipes.json'),
      publicApi.get('data/recipe/recipe_ingredient.json'),
      publicApi.get('data/recipe/steps.json'),
      publicApi.get('data/recipe/step_ingredients.json')
    ]);

    const found = resR.data.find(r => Number(r.recipe_id) === editIdFromUrl);
    if (!found) return;

    // 設定基礎資訊
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
    recipeForm.value.recipe_servings = found.recipe_servings || 1;

    recipeForm.value.coverImg = parsePublicFile(found.recipe_image_url || found.recipe_cover_image || '');

    const totalTimeStr = String(found.recipe_total_time || '30');
    recipeForm.value.totalTime = totalTimeStr.includes(':')
      ? (p => parseInt(p[0], 10) * 60 + parseInt(p[1], 10))(totalTimeStr.split(':'))
      : parseInt(totalTimeStr, 10) || 30;

    // 混合食材數據
    const links = resRecipeIng.data.filter(i => Number(i.recipe_id) === editIdFromUrl);
    recipeForm.value.ingredients = links.map(link => {
      const master = ingredientsMasterList.value.find(m => Number(m.ingredient_id) === Number(link.ingredient_id));
      return {
        id: link.ingredient_id,
        name: master?.ingredient_name || '',
        amount: link.amount,
        unit: link.unit_name || master?.unit_name || '份',
        note: link.remark || '',
        kcal_per_100g: master?.kcal_per_100g || 0,
        protein_per_100g: master?.protein_per_100g || 0,
        fat_per_100g: master?.fat_per_100g || 0,
        carbs_per_100g: master?.carbs_per_100g || 0,
        gram_conversion: master?.gram_conversion || 1.0
      };
    });

    // 載入步驟
    const stepsData = resS.data
      .filter(s => Number(s.recipe_id) === editIdFromUrl)
      .sort((a, b) => (a.step_order || 0) - (b.step_order || 0));

    recipeForm.value.steps = stepsData.map((s, index) => ({
      id: isAdapt ? `adapt-step-${editIdFromUrl}-${index}` : (s.step_id || `s-${editIdFromUrl}-${index}`),
      origin_step_id: s.step_id || null,
      title: s.step_title || `步驟 ${index + 1}`,
      content: s.step_content || '',
      image: parsePublicFile(s.step_image_url || s.image || ''),
      time: s.step_total_time?.toString().includes(':')
        ? (p => parseInt(p[0], 10) * 60 + parseInt(p[1], 10))(s.step_total_time.split(':'))
        : parseInt(s.step_total_time, 10) || 0,
      tags: resStepIng.data.filter(si => Number(si.step_id) === Number(s.step_id)).map(si => si.ingredient_id)
    }));

  } catch (err) {
    console.error('❌ 載入食譜失敗:', err);
  }
});

// --- 4. 預覽 ---
const handlePreview = () => {
  // ✨ 額外檢查：確保份數大於 0，否則熱量計算會出錯
  if (Number(recipeForm.value.recipe_servings) <= 0) {
    recipeForm.value.recipe_servings = 1;
  }

  // 深拷貝，確保 ingredients 帶有所有營養係數
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

// --- 5. 儲存 ---
const handleSave = async () => {
  const finalTitle = isAdaptModeActive.value
    ? (recipeForm.value.adapt_title || `${recipeForm.value.original_title} (改編版)`)
    : recipeForm.value.title;

  const currentOriginId = route.query.editId || route.params.id;

  if (isPublished.value) {
    try {
      const coverBase64 = await fileToBase64(recipeForm.value.coverImg);
      const processedSteps = await Promise.all(
        recipeForm.value.steps.map(async (s) => ({
          ...s,
          image: await fileToBase64(s.image)
        }))
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

      if (isAdaptModeActive.value && currentOriginId) {
        router.push(`/workspace/modify-recipe/${currentOriginId}`);
      } else {
        router.push('/workspace');
      }

    } catch (err) {
      console.error("儲存失敗:", err);
    }
  } else {
    alert('草稿儲存成功！');
    if (isAdaptModeActive.value && currentOriginId) {
      router.push(`/workspace/modify-recipe/${currentOriginId}`);
    } else {
      router.push('/workspace');
    }
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