<script setup>
import { ref, provide } from 'vue';
import EditorHeader from '@/components/workspace/editrecipe/EditorHeader.vue';
import IngredientEditor from '@/components/workspace/editrecipe/IngredientEditor.vue';
import StepEditor from '@/components/workspace/editrecipe/StepEditor.vue';

// 控制編輯狀態
const isEditing = ref(true);

// 食譜資料
const recipeForm = ref({
  title: '經典日式舒芙蕾鬆餅',
  description: '日式舒芙蕾鬆餅以其驚人的空氣感與雲朵般的綿密口感聞名。',
  coverImg: null,
  difficulty: 3,
  ingredients: [{ id: 'i1', name: '雞蛋', amount: '2 顆', memo: '需分離' }],
  steps: [
    {
      id: 's1',
      title: '處理蛋白',
      text: '將蛋白打發至濕性發泡。',
      time: 5,
      tags: ['i1'],
      img: null
    }
  ]
});

const handleSave = () => {
  console.log('儲存食譜', recipeForm.value);
};

provide('isEditing', isEditing);
</script>

<template>
  <div :class="['recipe-editor-page', { 'is-editing': isEditing }]">
    <main class="container">
      
      <div class="header-section mb-10">
        <EditorHeader v-model="recipeForm" :is-editing="isEditing" />
      </div>

      <div class="edit-main-card">
        <div class="row"> 
          <aside class="col-4 col-md-12 ingredient-sidebar">
            <IngredientEditor :ingredients="recipeForm.ingredients" :is-editing="isEditing" />
          </aside>

          <section class="col-8 col-md-12 step-content">
            <StepEditor :steps="recipeForm.steps" :ingredients="recipeForm.ingredients" :is-editing="isEditing" />
          </section>
        </div>
      </div>

      <footer class="editor-footer">
        <div class="footer-center-group">
          <BaseBtn 
            title="完成編輯" 
            :width="180"
            @click="handleSave"
            class="save-btn"
          />
    
          <div class="publish-toggle">
            <input type="checkbox" id="publish-check" />
            <label for="publish-check" class="p-p3">公開發布</label>
          </div>
        </div>
      </footer>
    </main>
  </div>
</template>

<style lang="scss" scoped>
/* --- 頁面基礎 --- */
.recipe-editor-page {
  min-height: 100vh;
  padding: 40px 0 80px;
  background-color: $neutral-color-white;
}

/* --- 大框框與格線適配 --- */
.edit-main-card {
  background: $neutral-color-white;
  border: 1.5px solid $primary-color-700;
  border-radius: 10px;
  overflow: hidden;
  margin-bottom: 40px;

  // 確保 row 內距在大框框裡表現正常
  .row { margin: 0; }
}

.ingredient-sidebar {
  padding: 30px;
  border-right: 1.5px solid rgba($primary-color-700, 0.1);

  // 當螢幕小於 810px (團隊 md 斷點)
  @media screen and (max-width: 810px) {
    border-right: none;
    border-bottom: 1.5px solid rgba($primary-color-700, 0.1);
  }
}

.step-content {
  padding: 30px;
}

/* --- 底部按鈕 --- */
.editor-footer {
  display: flex;
  justify-content: center;
  margin-top: 20px;

  .footer-center-group {
    display: flex;
    align-items: center;
    gap: 24px;

    // 手機版按鈕上下排 (sm: 390px)
    @media screen and (max-width: 390px) {
      flex-direction: column;
      gap: 16px;
    }
  }

  .save-btn :deep(button) {
    background-color: $primary-color-700;
    border-radius: 12px;
    height: 48px;
  }

  .publish-toggle {
    display: flex;
    align-items: center;
    gap: 8px;
    
    input {
      width: 18px;
      height: 18px;
      accent-color: $primary-color-700;
      cursor: pointer;
    }
  }
}

.mb-10 { margin-bottom: 40px; }

/* 基礎全域修正 */
:global(.workspace-layout), 
:global(.workspace-layout .page-content),
:global(html, body) {
    height: auto !important;
    overflow: visible !important;
    overflow-y: auto !important;
}
</style>