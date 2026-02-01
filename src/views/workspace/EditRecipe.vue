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
import { phpApi } from '@/utils/phpApi'; // ✨ 確保有這行

const router = useRouter();
const route = useRoute();
const recipeStore = useRecipeStore();

const isEditing = ref(true);
const isPublished = ref(false);

const ingredientsMasterList = ref([]);
const tagsMasterList = ref([]);
const isTagModalOpen = ref(false); // 在 <script setup> 頂部加入

// --- 1. 食譜表單資料 (確保 tags 初始存在) ---
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
  tags: [], // ✨ 必須在這裡預設，Vue 才能監聽變動
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

// ✨ 監聽食材變動補齊營養係數
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
    // 1. 載入 Master Data
    const [resIng, resTag] = await Promise.all([
      publicApi.get('data/recipe/ingredients.json'),
      publicApi.get('data/recipe/tags.json')
    ]);
    ingredientsMasterList.value = resIng.data || [];
    tagsMasterList.value = resTag.data || [];

    // 2. 處理暫存恢復
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

    // 3. 🚀 呼叫 PHP 取得食譜
    const response = await phpApi.get(`recipes/recipe_detail_get.php?recipe_id=${editIdFromUrl}`);

    if (response.data && response.data.success) {
      const { main, ingredients, steps, tags } = response.data.data;

      // --- 填充主資訊 ---
      if (isAdapt) {
        recipeForm.value.recipe_id = null;
        recipeForm.value.parent_recipe_id = editIdFromUrl;
        recipeForm.value.original_title = main.recipe_title;
        recipeForm.value.adapt_title = main.recipe_title + ' (改編版)';
        recipeForm.value.title = main.recipe_title;
        const baseDesc = main.recipe_description || main.recipe_descreption || '';
        recipeForm.value.adapt_description = baseDesc;
        recipeForm.value.description = baseDesc;
      } else {
        recipeForm.value.recipe_id = editIdFromUrl;
        recipeForm.value.title = main.recipe_title;
        recipeForm.value.description = main.recipe_description || main.recipe_descreption || '';
      }

      recipeForm.value.difficulty = Number(main.recipe_difficulty) || 1;
      recipeForm.value.recipe_servings = Number(main.recipe_servings) || 1;
      recipeForm.value.coverImg = parsePublicFile(main.recipe_image_url || '');
      recipeForm.value.totalTime = parseInt(main.recipe_total_time, 10) || 0;

      // --- 填充標籤 ---
      recipeForm.value.tags = tags.map(t => ({
        tag_id: t.tag_id,
        tag_name: t.tag_name
      }));

      // --- 填充食材 ---
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
        gram_conversion: Number(ing.gram_conversion) || 1.0
      }));

      // --- 填充步驟 
      recipeForm.value.steps = steps.map((s, idx) => ({
        id: isAdapt ? `adapt-s-${idx}` : (s.step_id || `s-${idx}`),
        title: s.step_title || `步驟 ${idx + 1}`,
        content: s.step_content || '',
        image: parsePublicFile(s.step_image_url || ''),
        time: s.total_seconds ? Math.floor(Number(s.total_seconds) / 60) : 0,
        tags: s.step_ingredients ? s.step_ingredients.map(id => Number(id)) : []
      }));

      const actualSum = recipeForm.value.steps.reduce((sum, s) => sum + (Number(s.time) || 0), 0);

      // 如果加總出來的時間跟資料庫抓到的時間不一樣，強制修正它
      if (actualSum > 0) {
        recipeForm.value.totalTime = actualSum;
      }

      console.log('✅ 資料同步載入完成', recipeForm.value);
    }
  } catch (err) {
    console.error('❌ 載入失敗:', err);
  }
});

const handleSave = async () => {
  const finalTitle = isAdaptModeActive.value
    ? (recipeForm.value.adapt_title || `${recipeForm.value.original_title} (改編版)`)
    : recipeForm.value.title;

  // 取得來源 ID (如果是改編，這就是原食譜 ID)
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

      // ✨✨✨ 關鍵跳轉邏輯 ✨✨✨
      if (isAdaptModeActive.value && sourceId) {
        // 🚀 如果是改編模式：回到原本食譜的「改編一覽」頁面
        router.push(`/workspace/modify-recipe/${sourceId}`);
      } else {
        // 📝 如果是全新創建：回到「我的食譜」
        router.push('/workspace/my-recipes');
      }

    } catch (err) {
      console.error("儲存失敗:", err);
    }
  } else {
    // 儲存草稿的情況 (非公開發布)
    alert('草稿儲存成功！');
    router.push('/workspace/my-recipes');
  }

  recipeStore.rawEditorData = null;
};

const handlePreview = () => {
  recipeStore.rawEditorData = { ...recipeForm.value };
  recipeStore.setPreviewFromEditor(JSON.parse(JSON.stringify(recipeForm.value)));

  // 🚀 加上 query 參數，這樣預覽頁返回時才會知道自己還在 'adapt' 模式
  router.push({
    path: `/workspace/recipe-detail/${route.params.id || 0}`,
    query: {
      mode: 'preview',
      editId: route.query.editId || route.params.id,
      action: route.query.action
    }
  });
};

// 處理 Modal 傳回來的標籤
const handleAddTags = (newTags) => {
  // 使用解構賦值將新標籤塞進 recipeForm
  // Modal 內部已經處理過「重複選取」的過濾，所以這裡可以直接 push
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