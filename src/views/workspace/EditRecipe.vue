<script setup>
import { ref, computed, provide, onMounted } from 'vue';
import EditorHeader from '@/components/workspace/editrecipe/EditorHeader.vue';
import IngredientEditor from '@/components/workspace/editrecipe/IngredientEditor.vue';
import StepEditor from '@/components/workspace/editrecipe/StepEditor.vue';

// 控制編輯狀態
const isEditing = ref(true);

// 載入環境 (Tailwind & FA)
onMounted(() => {
  if (!document.getElementById('tailwind-cdn')) {
    const tw = document.createElement('script');
    tw.src = 'https://cdn.tailwindcss.com';
    document.head.appendChild(tw);
  }
  // 補上 FontAwesome 否則星星跟叉叉會消失
  const fa = document.createElement('link');
  fa.rel = 'stylesheet';
  fa.href = 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css';
  document.head.appendChild(fa);
});

// 食譜資料
const recipeForm = ref({
  title: '經典日式舒芙蕾鬆餅',
  description: '日式舒芙蕾鬆餅以其驚人的空氣感與雲朵般的綿密口感聞名。',
  coverImg: null,
  difficulty: 3,
  ingredients: [{ id: 'i1', name: '雞蛋', amount: '2 顆', memo: '需分離' }],
  steps: [{ id: 's1', title: '處理蛋白', text: '將蛋白打發至濕性發泡。', time: 5, tags: ['i1'], img: null }]
});

const totalTime = computed(() => {
  return recipeForm.value.steps.reduce((sum, s) => sum + (parseInt(s.time) || 0), 0);
});

provide('isEditing', isEditing);
</script>

<template>
  <div :class="['min-h-screen pb-20 font-sans bg-slate-50 text-slate-700', { 'is-editing': isEditing }]">
    
    <main class="max-w-[1200px] mx-auto p-10">
      <header class="flex justify-between items-center mb-10">
        <div class="px-3 py-1 rounded-full text-xs font-bold transition-colors"
             :class="isEditing ? 'bg-emerald-100 text-emerald-600' : 'bg-slate-200 text-slate-500'">
          {{ isEditing ? '編輯模式' : '預覽模式' }}
        </div>
        <div class="flex gap-3">
          <button v-if="!isEditing" @click="isEditing = true" 
                  class="bg-blue-600 text-white px-8 py-2 rounded-full font-bold shadow-lg hover:bg-blue-700 transition">
            進入編輯
          </button>
          <button v-else @click="isEditing = false" 
                  class="bg-emerald-500 text-white px-8 py-2 rounded-full font-bold shadow-lg hover:bg-emerald-600 transition">
            完成並儲存
          </button>
        </div>
      </header>

      <EditorHeader v-model="recipeForm" :is-editing="isEditing" />

      <div class="grid grid-cols-12 gap-10">
        <div class="col-span-12 lg:col-span-4">
          <IngredientEditor :ingredients="recipeForm.ingredients" :is-editing="isEditing" />
        </div>
        <div class="col-span-12 lg:col-span-8">
          <StepEditor :steps="recipeForm.steps" :ingredients="recipeForm.ingredients" :is-editing="isEditing" />
        </div>
      </div>
    </main>
  </div>
</template>

<style>
/* --- [第一部分：全域解鎖區] --- */
.workspace-layout {
  height: auto !important;
  overflow: visible !important;
  .page-content {
    height: auto !important;
    overflow: visible !important;
  }
}
html, body {
  overflow-y: auto !important;
  height: auto !important;
}

/* --- [第二部分：頁面專屬樣式] --- */

.is-editing .edit-visible { display: flex !important; }
.is-editing .edit-hidden { display: none !important; }
.edit-visible { display: none; }

.editable-input { 
  border-bottom: 1px solid #e2e8f0; 
  width: 100%; 
  transition: border-color 0.2s; 
  background: transparent; 
}
.editable-input:focus { border-color: #10b981; outline: none; }

.popover { 
  animation: fadeInScale 0.2s ease-out; 
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1); 
}
@keyframes fadeInScale {
  from { opacity: 0; transform: scale(0.95) translateY(-5px); }
  to { opacity: 1; transform: scale(1) translateY(0); }
}
.star-active { color: #fbbf24; }
.star-inactive { color: #e2e8f0; }

.step-item.dragging { opacity: 0.4; background: #f8fafc; border: 2px dashed #cbd5e1; }
.drag-handle { cursor: grab; }
</style>