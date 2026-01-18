<script setup>
import { ref, provide } from 'vue';
import EditorHeader from '@/components/workspace/editrecipe/EditorHeader.vue';
import IngredientEditor from '@/components/workspace/editrecipe/IngredientEditor.vue';
import StepEditor from '@/components/workspace/editrecipe/StepEditor.vue';

const isEditing = ref(true);

const recipeForm = ref({
  title: '經典日式舒芙蕾鬆餅',
  description: '日式舒芙蕾鬆餅以其驚人的空氣感與雲朵般的綿密口感聞名。',
  coverImg: null,
  difficulty: 3,
  totalTime: 'null',
  ingredients: [{ id: 'i1', name: '雞蛋', amount: '2', unit: '顆', note: '需分離' }],
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
          <BaseBtn title="完成編輯" :width="180" @click="handleSave" class="save-btn" />

          <div class="publish-toggle">
            <input type="checkbox" id="publish-check" />
            <label for="publish-check" class="p-p2">公開發布</label>
          </div>
        </div>
      </footer>
    </main>
  </div>
</template>

<style lang="scss" scoped>
// 使用團隊變數定義邊框樣式
$editor-border-style: 1px solid $primary-color-400;

.recipe-editor-page {
  min-height: 100vh;
  padding: 40px 0 80px;
  background-color: $neutral-color-white;
}

.editor-main-layout {
  margin: 0 auto;
}

.header-section {
  width: 100%;
  margin-bottom: 24px;
}

.recipe-main-content {
  width: 100%;
  border: $editor-border-style;
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

.ingredient-sidebar {
  @media screen and (max-width: 810px) {
    border-bottom: 1px solid $neutral-color-100;
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
    gap: 24px;
  }

  .publish-toggle {
    display: flex;
    align-items: center;
    gap: 8px;
    // 移除 font-size，改用 HTML class 管理
    color: $neutral-color-700;

    input {
      width: 18px;
      height: 18px;
      accent-color: $primary-color-800; // 替換為網站主色
    }
  }
}
</style>