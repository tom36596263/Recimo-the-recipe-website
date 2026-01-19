<script setup>
import { ref, provide, onMounted } from 'vue'; // 引入 onMounted
import { useRouter } from 'vue-router';
import { useRecipeStore } from '@/stores/recipeEditor';

// 元件引入
import EditorHeader from '@/components/workspace/editrecipe/EditorHeader.vue';
import IngredientEditor from '@/components/workspace/editrecipe/IngredientEditor.vue';
import StepEditor from '@/components/workspace/editrecipe/StepEditor.vue';

const isEditing = ref(true);
const router = useRouter();
const recipeStore = useRecipeStore();

// --- 1. 食譜表單資料 (這是初始值) ---
const recipeForm = ref({
  title: '',
  description: '',
  coverImg: null,
  difficulty: 3,
  totalTime: '00:30',
  ingredients: [],
  steps: []
});

// --- 2. 生命週期：還原資料 ---
onMounted(() => {
  // 檢查 Store 裡是否有「原始編輯格式」的暫存資料
  // 假設你的 store 裡有一個 rawEditorData 用來存放未轉化前的原始資料
  if (recipeStore.rawEditorData) {
    console.log('偵測到暫存草稿，正在還原...', recipeStore.rawEditorData);
    recipeForm.value = { ...recipeStore.rawEditorData };
  } else {
    // 如果沒有暫存，才給予初始預設值（例如這份經典鬆餅）
    recipeForm.value = {
      title: '經典日式舒芙蕾鬆餅',
      description: '日式舒芙蕾鬆餅以其驚人的空氣感與雲朵般的綿密口感聞名。',
      coverImg: null,
      difficulty: 3,
      totalTime: '00:30',
      ingredients: [{ id: 'i1', name: '雞蛋', amount: '2', unit: '顆', note: '需分離' }],
      steps: [{ id: 's1', title: '處理蛋白', text: '將蛋白打發至濕性發泡。', time: 5, tags: ['i1'], img: null }]
    };
  }
});

// --- 3. 核心邏輯：預覽功能 ---
const handlePreview = () => {
  console.log('正在儲存草稿並產生預覽...', recipeForm.value);

  // ✨ 重點：在跳轉前，先把當前的原始資料存進 Store
  // 你需要在 store 增加一個 action 處理這個：recipeStore.saveRawDoc(recipeForm.value)
  recipeStore.rawEditorData = { ...recipeForm.value };

  // 執行原本的轉接邏輯（轉成詳情頁格式）
  recipeStore.setPreviewFromEditor(recipeForm.value);

  router.push({
    path: '/workspace/recipe-detail/0',
    query: { mode: 'preview' }
  });
};

// --- 核心邏輯：儲存/發布 ---
const handleSave = () => {
  console.log('正式儲存食譜資料', recipeForm.value);
  // 儲存成功後可以清空暫存，避免下次進來還是舊資料
  recipeStore.rawEditorData = null;
  alert('食譜已暫存（模擬）');
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

          <BaseBtn title="預覽食譜" variant="outline" :width="150" @click="handlePreview" class="preview-btn" />

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
@import '@/assets/scss/abstracts/_color.scss';

$editor-border-style: 1px solid $primary-color-100;

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
    gap: 24px;
  }

  .publish-toggle {
    display: flex;
    align-items: center;
    gap: 8px;
    color: $neutral-color-700;

    input {
      width: 18px;
      height: 18px;
      accent-color: $primary-color-800;
    }
  }
}

// 預覽按鈕微調
.preview-btn {
  border: 1px solid $primary-color-400 !important;
  color: $primary-color-400 !important;

  &:hover {
    background-color: $primary-color-100 !important;
  }
}
</style>