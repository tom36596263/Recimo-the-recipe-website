<script setup>
import { ref, provide, onMounted, computed, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useRecipeStore } from '@/stores/recipeEditor';
import { useAuthStore } from '@/stores/authStore';
import { publicApi } from '@/utils/publicApi';
import { parsePublicFile } from '@/utils/parseFile';
import { phpApi } from '@/utils/phpApi';

import EditorHeader from '@/components/workspace/editrecipe/EditorHeader.vue';
import IngredientEditor from '@/components/workspace/editrecipe/IngredientEditor.vue';
import StepEditor from '@/components/workspace/editrecipe/StepEditor.vue';
import TagModal from '@/components/workspace/editrecipe/modals/TagModal.vue';

const router = useRouter();
const route = useRoute();
const recipeStore = useRecipeStore();
const authStore = useAuthStore();

const isEditing = ref(true);
const isPublished = ref(false);

const ingredientsMasterList = ref([]);
const tagsMasterList = ref([]);
const isTagModalOpen = ref(false);

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
  recipe_servings: 1
});

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

watch(() => recipeForm.value.steps, (newSteps) => {
  if (!newSteps || !isEditing.value) return;
  const autoSum = newSteps.reduce((sum, s) => sum + (Number(s.time) || 0), 0);

  // 只有當使用者沒動過總時間，或者總時間不合理時才同步
  recipeForm.value.totalTime = autoSum;
}, { deep: true });

watch(() => recipeForm.value.ingredients, (newIngs) => {
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
}, { deep: true });

onMounted(async () => {
  const rawId = route.query.editId || route.params.id;
  const editIdFromUrl = rawId ? Number(rawId) : null;
  const isAdapt = route.query.action === 'adapt';

  if (isAdapt) isPublished.value = true;

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
        recipeForm.value.description = main.recipe_description || '';
      }

      recipeForm.value.difficulty = Number(main.recipe_difficulty) || 1;
      recipeForm.value.recipe_servings = Number(main.recipe_servings) || 1;
      recipeForm.value.coverImg = parsePublicFile(main.recipe_image_url || '');
      recipeForm.value.totalTime = parseInt(main.recipe_total_time, 10) || 0;
      recipeForm.value.tags = tags.map(t => ({ tag_id: t.tag_id, tag_name: t.tag_name }));
      recipeForm.value.ingredients = ingredients.map(ing => ({
        id: Number(ing.ingredient_id),
        name: ing.ingredient_name,
        amount: ing.amount,
        unit: ing.unit_name || '份',
        note: ing.remark || '',
        color_tag: ing.color_tag || '',
        kcal_per_100g: Number(ing.kcal_per_100g),
        protein_per_100g: Number(ing.protein_per_100g),
        fat_per_100g: Number(ing.fat_per_100g),
        carbs_per_100g: Number(ing.carbs_per_100g),
        gram_conversion: Number(ing.gram_conversion)
      }));
      recipeForm.value.steps = steps.map((s, idx) => ({
        id: isAdapt ? `adapt-s-${idx}` : (s.step_id || `s-${idx}`),
        title: s.step_title || `步驟 ${idx + 1}`,
        content: s.step_content || '',
        image: parsePublicFile(s.step_image_url || ''),
        time: s.total_seconds ? Math.round(Number(s.total_seconds) / 60) : 0,
        tags: s.step_ingredients ? s.step_ingredients.map(id => Number(id)) : []
      }));
    }
  } catch (err) {
    console.error('❌ 載入失敗:', err);
  }
});

const publishToDb = async () => {
  if (!authStore.isLoggedIn) {
    authStore.openLoginAlert();
    return;
  }

  try {
    const handleImage = async (img) => {
      if (!img) return null;
      if (img instanceof File) return await fileToBase64(img);
      return typeof img === 'string' ? img : null;
    };

    const coverData = await handleImage(recipeForm.value.coverImg);

    // 在 publishToDb 內修改
    const processedSteps = await Promise.all(
      recipeForm.value.steps.map(async (s) => {
        const totalMinutes = Number(s.time) || 0;
        const hrs = Math.floor(totalMinutes / 60);
        const mins = totalMinutes % 60;
        const timeString = `${String(hrs).padStart(2, '0')}:${String(mins).padStart(2, '0')}:00`;

        return {
          step_title: s.title,
          step_content: s.content || '',
          step_image_url: await handleImage(s.image),
          step_total_time: timeString, // 這樣 60 分鐘會變成 01:00:00
          step_ingredients: s.tags
        };
      })
    );

    const payload = {
      parent_recipe_id: recipeForm.value.parent_recipe_id || null,
      author_id: authStore.user.id || authStore.user.user_id,

      // 標題邏輯：如果是改編模式，優先用改編標題
      recipe_title: isAdaptModeActive.value
        ? (recipeForm.value.adapt_title || recipeForm.value.title)
        : recipeForm.value.title,

      // 🔥 修正：這裡永遠只放詳細介紹 (aaa)
      // 不管是不是改編模式，都要保留這份完整的食譜說明
      recipe_description: recipeForm.value.description || '暫無詳細說明',

      // ✨ 新增：這裡專門放改編重點 (bbb)
      // 對應後端 recipes 表中的 adaptation_note 欄位
      adaptation_note: isAdaptModeActive.value
        ? (recipeForm.value.adapt_description || '')
        : '',

      // 改編版本的小標題 (bbb 的標題)
      adaptation_title: isAdaptModeActive.value
        ? (recipeForm.value.adapt_title || recipeForm.value.title)
        : '',

      recipe_image_url: coverData,
      recipe_difficulty: recipeForm.value.difficulty,
      total_time: recipeForm.value.totalTime,
      recipe_servings: recipeForm.value.recipe_servings,
      ingredients: recipeForm.value.ingredients.map(ing => ({
        ingredient_id: ing.id,
        amount: ing.amount,
        remark: ing.note,
        unit_name: ing.unit || '份'
      })),
      steps: processedSteps,
      tags: recipeForm.value.tags.map(t => t.tag_id)
    };

    const response = await phpApi.post('recipes/recipe_adaptation_add.php', payload);

    if (response.data && response.data.success) {
      alert('🎉 感謝分享！改編版本已正式發布。');

      if (isAdaptModeActive.value) {
        const parentId = recipeForm.value.parent_recipe_id;
        router.push(`/workspace/modify-recipe/${parentId}`);
      } else {
        router.push('/workspace/my-recipes');
      }
    } else {
      const errorMsg = response.data?.message || '資料庫寫入失敗';
      alert(`發布失敗：${errorMsg}`);
    }

  } catch (err) {
    console.error('❌ 發布過程發生異常:', err);
    const errorDetail = err.response?.data?.message || err.message;
    alert(`發布異常：${errorDetail}`);
  }
};

const handleSave = async () => {
  if (isAdaptModeActive.value) {
    await publishToDb();
    return;
  }
  if (isPublished.value) {
    alert('全新食譜發布功能開發中，目前僅存為本地快取');
  } else {
    alert('草稿已存至本地！');
    router.push('/workspace/my-recipes');
  }
  recipeStore.rawEditorData = null;
};

const handlePreview = async () => {
  const coverBase64 = await fileToBase64(recipeForm.value.coverImg);
  const processedSteps = await Promise.all(
    recipeForm.value.steps.map(async (s, idx) => ({
      ...s,
      step_id: s.id || `s-${idx}`,
      step_title: s.title || `步驟 ${idx + 1}`,
      step_content: s.content || s.step_content || '',
      step_total_time: s.time ? `${s.time} 分鐘` : '0 分鐘',
      step_order: idx + 1,
      step_image_url: await fileToBase64(s.image)
    }))
  );
  const tagToStatus = { 'tag-green': 'add', 'tag-orange': 'mod', 'tag-blue': 'rep' };
  const processedIngredients = recipeForm.value.ingredients.map(ing => ({
    ...ing,
    ingredient_id: ing.id,
    ingredient_name: ing.name,
    unit_name: ing.unit || '份',
    status: tagToStatus[ing.color_tag] || '',
    kcal_per_100g: Number(ing.kcal_per_100g || 0),
    protein_per_100g: Number(ing.protein_per_100g || 0),
    fat_per_100g: Number(ing.fat_per_100g || 0),
    carbs_per_100g: Number(ing.carbs_per_100g || 0),
    gram_conversion: Number(ing.gram_conversion || 1.0)
  }));
  const previewData = {
    ...recipeForm.value,
    recipe_title: isAdaptModeActive.value ? (recipeForm.value.adapt_title || recipeForm.value.title) : recipeForm.value.title,
    recipe_description: isAdaptModeActive.value ? (recipeForm.value.adapt_description || recipeForm.value.description) : recipeForm.value.description,
    recipe_cover_image: coverBase64,
    recipe_servings: Number(recipeForm.value.recipe_servings || 1),
    ingredients: processedIngredients,
    steps: processedSteps,
    recipe_tags: recipeForm.value.tags,
    totalTime: Number(recipeForm.value.totalTime || 0)
  };
  recipeStore.rawEditorData = JSON.parse(JSON.stringify(recipeForm.value));
  recipeStore.setPreviewFromEditor(previewData);
  router.push({
    path: `/workspace/recipe-detail/${route.query.editId || route.params.id || 0}`,
    query: { mode: 'preview', editId: route.query.editId || route.params.id, action: route.query.action }
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
          <BaseBtn :title="isAdaptModeActive ? '分享我的版本' : (isPublished ? '確認發布' : '完成編輯')" :width="200"
            @click="handleSave" class="save-btn" />
          <div v-if="!isAdaptModeActive" class="publish-toggle">
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
  }

  .publish-toggle {
    display: flex;
    align-items: center;
    gap: 8px;

    input {
      width: 18px;
      height: 18px;
      cursor: pointer;
    }

    label {
      cursor: pointer;
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