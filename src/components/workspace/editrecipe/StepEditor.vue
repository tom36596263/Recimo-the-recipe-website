<script setup>
import { ref, onMounted, onUnmounted } from 'vue';

const props = defineProps(['steps', 'ingredients', 'isEditing']);
const activeStepId = ref(null);
const showTimerPop = ref(false);
const showIngPop = ref(false);
const popStyle = ref({ top: '0px', left: '0px' });

const addStep = () => {
  props.steps.push({ id: 's' + Date.now(), title: '', text: '', time: 5, tags: [], img: null });
};

const removeStep = (id) => {
  const index = props.steps.findIndex(s => s.id === id);
  if (index !== -1) props.steps.splice(index, 1);
};

const toggleTag = (step, ingId) => {
  if (!step) return;
  const index = step.tags.indexOf(ingId);
  if (index === -1) step.tags.push(ingId);
  else step.tags.splice(index, 1);
};

const uploadStepImg = (step) => {
  if (!props.isEditing) return;
  const input = document.createElement('input');
  input.type = 'file';
  input.accept = 'image/*';
  input.onchange = (e) => {
    const reader = new FileReader();
    reader.onload = (f) => step.img = f.target.result;
    reader.readAsDataURL(e.target.files[0]);
  };
  input.click();
};

// --- 修正後的彈窗定位 ---
const openPop = (e, stepId, type) => {
  if (!props.isEditing) return;
  activeStepId.value = stepId;
  const rect = e.target.getBoundingClientRect();
  
  // 使用 fixed 定位時，不應加上 window.scrollY，否則滾動後位置會跑掉
  popStyle.value = { 
    top: `${rect.bottom + 8}px`, 
    left: `${rect.left}px` 
  };
  
  if (type === 'timer') {
    showTimerPop.value = true;
    showIngPop.value = false;
  } else {
    showIngPop.value = true;
    showTimerPop.value = false;
  }
};

const closePops = () => {
  showTimerPop.value = false;
  showIngPop.value = false;
};

// --- 生命週期管理：確保監聽器被正確移除，避免干擾滾動 ---
onMounted(() => {
  window.addEventListener('click', closePops);
});

onUnmounted(() => {
  window.removeEventListener('click', closePops);
});

// 輔助函式：取得當前操作的步驟物件
const getActiveStep = () => props.steps.find(s => s.id === activeStepId.value);
</script>

<template>
  <h2 class="text-xl font-bold mb-6 flex justify-between items-center text-slate-800">
    烹飪步驟 
    <button v-if="isEditing" @click="addStep" class="text-emerald-500 text-sm hover:underline font-medium">+ 新增步驟</button>
  </h2>

  <div class="space-y-6">
    <div v-for="(step, idx) in steps" :key="step.id" class="flex gap-4">
      <div class="flex flex-col items-center gap-2 mt-1">
        <div class="w-8 h-8 bg-slate-800 text-white rounded-full flex items-center justify-center font-bold text-xs shrink-0 shadow-md">
          {{ idx + 1 }}
        </div>
        <div v-if="isEditing" class="cursor-grab text-slate-300 hover:text-slate-500 transition-colors">⋮⋮</div>
      </div>

      <div class="flex-1 bg-white p-6 rounded-3xl border border-slate-100 shadow-sm relative hover:shadow-md transition-shadow">
        <div class="flex flex-wrap items-center gap-2 mb-4">
          <div @click.stop="openPop($event, step.id, 'timer')" 
               class="bg-slate-50 px-3 py-1 rounded-full text-[10px] font-bold transition hover:bg-emerald-50"
               :class="isEditing ? 'cursor-pointer' : ''">
            ⏱ {{ step.time }} 分
          </div>
          
          <div v-for="tid in step.tags" :key="tid" class="flex items-center gap-1 bg-blue-50 text-blue-500 px-2 py-1 rounded text-[10px] font-medium">
            <span>{{ ingredients.find(i => i.id === tid)?.name || '未知食材' }}</span>
            <button v-if="isEditing" @click.stop="toggleTag(step, tid)" class="text-blue-300 hover:text-blue-600 ml-1">✕</button>
          </div>

          <button v-if="isEditing" @click.stop="openPop($event, step.id, 'ing')" 
                  class="text-emerald-500 text-[10px] font-bold border border-emerald-200 px-2 py-1 rounded-full hover:bg-emerald-50 transition">
            + 食材
          </button>
        </div>

        <div class="flex flex-col md:flex-row gap-6">
          <div @click="uploadStepImg(step)" 
               class="w-28 h-28 bg-slate-50 rounded-2xl border-dashed border-2 flex items-center justify-center text-[10px] text-slate-400 bg-cover bg-center overflow-hidden shrink-0 border-slate-200 hover:border-emerald-300 transition-colors"
               :class="isEditing ? 'cursor-pointer' : ''"
               :style="{ backgroundImage: step.img ? `url(${step.img})` : '' }">
            <span v-if="!step.img">上傳圖片</span>
          </div>

          <div class="flex-1 flex flex-col gap-2">
            <input v-if="isEditing" v-model="step.title" type="text" 
                   class="font-bold border-b border-slate-100 focus:border-emerald-500 outline-none pb-1 transition-colors" 
                   placeholder="步驟標題">
            <div v-else class="font-bold text-slate-800">{{ step.title || '未命名步驟' }}</div>
            
            <textarea v-if="isEditing" v-model="step.text" 
                      class="w-full text-xs text-slate-500 bg-slate-50 rounded-xl p-3 h-20 outline-none focus:ring-1 focus:ring-emerald-500 resize-none" 
                      placeholder="步驟描述..."></textarea>
            <div v-else class="text-xs text-slate-500 leading-relaxed whitespace-pre-wrap">{{ step.text || '無詳細內容' }}</div>
          </div>
        </div>

        <button v-if="isEditing" @click="removeStep(step.id)" 
                class="absolute top-4 right-4 text-slate-300 hover:text-red-400 transition-colors px-2">✕</button>
      </div>
    </div>
  </div>

  <div v-if="showIngPop" :style="popStyle" class="fixed z-[100] bg-white border border-slate-100 rounded-2xl p-4 w-64 shadow-2xl" @click.stop>
    <div class="text-[10px] font-bold text-slate-400 mb-2 border-b border-slate-50 pb-1">點擊選擇食材</div>
    <div class="flex flex-wrap gap-2">
      <button v-for="i in ingredients" :key="i.id" 
              @click="toggleTag(getActiveStep(), i.id)"
              class="px-3 py-1 rounded-full text-xs border transition"
              :class="getActiveStep()?.tags.includes(i.id) ? 'bg-emerald-500 text-white border-emerald-500' : 'bg-slate-50 border-slate-100 hover:bg-emerald-50'">
        {{ i.name || '?' }}
      </button>
    </div>
  </div>

  <div v-if="showTimerPop" :style="popStyle" class="fixed z-[100] bg-white border border-slate-100 rounded-2xl p-5 w-56 shadow-2xl text-center" @click.stop>
    <div class="text-xs font-bold text-slate-400 mb-3">設定步驟時間 (分)</div>
    <input type="number" v-model="getActiveStep().time" 
           class="text-3xl font-black text-emerald-600 w-full text-center outline-none bg-transparent">
    <div class="grid grid-cols-2 gap-2 mt-4">
      <button @click="getActiveStep().time += 5" class="bg-slate-50 py-2 rounded-lg text-xs font-bold hover:bg-slate-100 transition">+5</button>
      <button @click="getActiveStep().time = Math.max(0, getActiveStep().time - 5)" class="bg-slate-50 py-2 rounded-lg text-xs font-bold hover:bg-slate-100 transition">-5</button>
    </div>
  </div>
</template>