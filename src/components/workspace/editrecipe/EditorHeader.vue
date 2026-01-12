<script setup>
import { computed } from 'vue';

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  },
  isEditing: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['update:modelValue']);

// 內部更新方法，確保雙向綁定 (v-model)
const updateField = (field, value) => {
  emit('update:modelValue', { ...props.modelValue, [field]: value });
};

// 處理難度星星點擊
const setDifficulty = (val) => {
  if (props.isEditing) {
    updateField('difficulty', val);
  }
};

// 處理封面圖上傳
const handleCoverUpload = (e) => {
  const file = e.target.files[0];
  if (file) {
    const reader = new FileReader();
    reader.onload = (f) => {
      updateField('coverImg', f.target.result);
    };
    reader.readAsDataURL(file);
  }
};

// 計算總時間 (如果父層沒傳總時間，可以從 steps 算)
const displayTime = computed(() => {
  if (props.modelValue.steps) {
    return props.modelValue.steps.reduce(
      (sum, step) => sum + (parseInt(step.time) || 0),
      0
    );
  }
  return props.modelValue.totalTime || 0;
});
</script>

<template>
  <section
    class="bg-white p-8 rounded-3xl shadow-sm border border-slate-100 mb-8 flex flex-col md:flex-row gap-8"
  >
    <div
      @click="isEditing && $refs.fileInput.click()"
      class="w-full md:w-64 h-52 bg-slate-50 rounded-2xl border-dashed border-2 flex flex-col items-center justify-center text-slate-400 cursor-pointer overflow-hidden bg-cover bg-center transition hover:bg-slate-100 relative"
      :style="{ backgroundImage: `url(${modelValue.coverImg})` }"
    >
      <input
        type="file"
        ref="fileInput"
        class="hidden"
        accept="image/*"
        @change="handleCoverUpload"
      />

      <div v-if="isEditing && !modelValue.coverImg" class="text-center">
        <span class="text-2xl block">+</span>
        <span class="text-xs">上傳封面</span>
      </div>

      <div v-if="!isEditing && !modelValue.coverImg" class="text-slate-200">
        <i class="fa-solid fa-image fa-3x"></i>
      </div>
    </div>

    <div class="flex-1 space-y-4">
      <div v-if="isEditing">
        <input
          type="text"
          :value="modelValue.title"
          @input="updateField('title', $event.target.value)"
          class="w-full text-3xl font-black border-none focus:ring-0 p-0 outline-none placeholder-slate-300"
          placeholder="食譜名稱"
        />
      </div>
      <h1 v-else class="text-3xl font-black text-slate-800">
        {{ modelValue.title || '未命名食譜' }}
      </h1>

      <div class="flex items-center gap-8 py-2 border-y border-slate-50">
        <div>
          <div
            class="text-[10px] font-bold text-slate-400 uppercase tracking-wider"
          >
            總烹飪時間
          </div>
          <div class="flex items-center gap-1 font-bold text-emerald-600">
            <span class="text-xl">{{ displayTime }}</span>
            <span class="text-xs">分鐘</span>
          </div>
        </div>

        <div>
          <div
            class="text-[10px] font-bold text-slate-400 uppercase tracking-wider"
          >
            難易度
          </div>
          <div class="flex gap-1 mt-1">
            <span
              v-for="n in 5"
              :key="n"
              @click="setDifficulty(n)"
              class="text-xl transition-colors"
              :class="[
                n <= modelValue.difficulty
                  ? 'text-amber-400'
                  : 'text-slate-200',
                isEditing ? 'cursor-pointer hover:scale-110' : ''
              ]"
            >
              ★
            </span>
          </div>
        </div>
      </div>

      <div v-if="isEditing">
        <textarea
          :value="modelValue.description"
          @input="updateField('description', $event.target.value)"
          class="w-full text-slate-500 border-none focus:ring-0 p-0 resize-none h-20 text-sm bg-transparent"
          placeholder="輸入食譜簡介，吸引大家來試做..."
        ></textarea>
      </div>
      <p v-else class="text-slate-500 text-sm leading-relaxed">
        {{ modelValue.description || '這個作者很懶，還沒寫簡介...' }}
      </p>
    </div>
  </section>
</template>

<style scoped>
/* 可以在這裡微調樣式 */
textarea {
  line-height: 1.6;
}
</style>
