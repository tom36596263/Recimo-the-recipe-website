<script setup>
import { ref, provide, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useRecipeStore } from '@/stores/recipeEditor';

import EditorHeader from '@/components/workspace/editrecipe/EditorHeader.vue';
import IngredientEditor from '@/components/workspace/editrecipe/IngredientEditor.vue';
import StepEditor from '@/components/workspace/editrecipe/StepEditor.vue';

const isEditing = ref(true);
const router = useRouter();
const recipeStore = useRecipeStore();
const isPublished = ref(false);

// --- 1. 食譜表單資料 (初始化為空) ---
const recipeForm = ref({
  title: '',
  description: '',
  coverImg: null,
  difficulty: 1,
  totalTime: '00:00',
  ingredients: [],
  steps: []
});

// --- 2. 生命週期 ---
onMounted(() => {
  if (recipeStore.rawEditorData) {
    recipeForm.value = { ...recipeStore.rawEditorData };
  }
});

const handlePreview = () => {
  recipeStore.rawEditorData = { ...recipeForm.value };
  recipeStore.setPreviewFromEditor(recipeForm.value);
  router.push({ path: '/workspace/recipe-detail/0', query: { mode: 'preview' } });
};

const handleSave = () => {
  const actionText = isPublished.value ? '公開發布' : '儲存編輯';
  const confirmMessage = isPublished.value
    ? `確定要公開發布《${recipeForm.value.title || '這份食譜'}》嗎？`
    : '確定要儲存目前的編輯內容嗎？';

  if (window.confirm(confirmMessage)) {
    alert(isPublished.value ? '🎉 食譜已成功發布！' : '💾 食譜已成功暫存！');
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