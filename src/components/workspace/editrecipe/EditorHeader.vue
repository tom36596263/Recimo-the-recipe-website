<script setup>
import { computed, watch } from 'vue';

const props = defineProps({
  modelValue: { type: Object, required: true },
  isEditing: { type: Boolean, default: false }
});

const emit = defineEmits(['update:modelValue']);

const updateField = (field, value) => {
  emit('update:modelValue', { ...props.modelValue, [field]: value });
};

const setDifficulty = (val) => {
  if (props.isEditing) updateField('difficulty', val);
};

// ================================
// 🔢 自動加總步驟時間
// ================================
const autoTotalTime = computed(() => {
  if (!props.modelValue.steps) return 0;
  return props.modelValue.steps.reduce((sum, step) => {
    return sum + (Number(step.time) || 0);
  }, 0);
});

// ================================
// 👀 顯示用時間
// ================================
const displayTime = computed(() => {
  const manualTime = Number(props.modelValue.totalTime);
  return manualTime > 0 ? manualTime : autoTotalTime.value;
});

// ================================
// ⭐ 監聽步驟時間變化並同步
// ================================
watch(
  () => props.modelValue.steps,
  (newSteps) => {
    const newSum = newSteps?.reduce((sum, s) => sum + (Number(s.time) || 0), 0) || 0;
    if (!props.modelValue.totalTime || props.modelValue.totalTime == 0) {
      updateField('totalTime', newSum);
    }
  },
  { deep: true }
);

// ================================
// 📷 上傳封面圖
// ================================
const handleCoverUpload = (e) => {
  const file = e.target.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = (evt) => {
    updateField('coverImg', evt.target.result);
  };
  reader.readAsDataURL(file);
};
</script>

<template>
  <section class="recipe-card-container">
    <div class="cover-section" :class="{ 'has-image': modelValue.coverImg }"
      :style="{ backgroundImage: modelValue.coverImg ? `url(${modelValue.coverImg})` : '' }"
      @click="isEditing && $refs.fileInput.click()">
      <input ref="fileInput" type="file" class="hidden-input" accept="image/*" @change="handleCoverUpload" />

      <div v-if="!modelValue.coverImg" class="upload-placeholder">
        <div class="placeholder-content">
          <span class="plus-icon">+</span>
          <p class="label p-p2">新增成品照</p>
        </div>
      </div>

      <div v-if="modelValue.coverImg && isEditing" class="change-hint">
        <span class="p-p2">更換成品照</span>
      </div>
    </div>

    <div class="info-section">
      <div class="row-title">
        <input v-if="isEditing" :value="modelValue.title" @input="updateField('title', $event.target.value)"
          class="title-input zh-h3" placeholder="請輸入標題..." />
        <h2 v-else class="title-display zh-h2-bold">{{ modelValue.title || '未命名食譜' }}</h2>
      </div>

      <div class="row-meta p-p2">
        <div class="meta-item">
          <span class="label">製作時間：</span>
          <template v-if="isEditing">
            <input type="number" class="inline-input" :value="modelValue.totalTime"
              @input="updateField('totalTime', $event.target.value)" :placeholder="autoTotalTime" />
            <span class="unit">分鐘</span>
            <small v-if="!modelValue.totalTime && autoTotalTime > 0" class="auto-hint">(已自動加總)</small>
          </template>
          <span v-else class="value">{{ displayTime }} 分鐘</span>
        </div>

        <div class="meta-item">
          <span class="label">難易度：</span>
          <div class="stars-group" :class="{ 'is-editing': isEditing }">
            <span v-for="n in 5" :key="n" class="star" :class="{ active: n <= modelValue.difficulty }"
              @click="setDifficulty(n)">
              {{ n <= modelValue.difficulty ? '★' : '☆' }} </span>
          </div>
        </div>
      </div>

      <div class="row-description" :class="{ 'editing-border': isEditing }">
        <textarea v-if="isEditing" :value="modelValue.description"
          @input="updateField('description', $event.target.value)" class="desc-textarea p-p2" placeholder="請輸入說明..."
          maxlength="200"></textarea>
        <p v-else class="desc-display p-p2">{{ modelValue.description || '暫無簡介' }}</p>

        <div v-if="isEditing" class="char-counter p-p3">{{ modelValue.description?.length || 0 }}/200</div>
      </div>
    </div>
  </section>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.recipe-card-container {
  display: flex;
  flex-direction: column;
  background: $neutral-color-white;
  border: 1px solid $primary-color-400;
  border-radius: 12px;
  padding: 24px;
  gap: 24px;

  @media (min-width: 768px) {
    flex-direction: row;
  }
}

.cover-section {
  position: relative;
  border: 2px dashed $neutral-color-400;
  width: 100%;
  height: 220px;
  background: $neutral-color-100;
  border-radius: 8px;
  cursor: pointer;
  background-size: cover;
  background-position: center;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  transition: border-color 0.2s;

  &.has-image {
    border-style: solid; // 有圖片時虛線轉實線（或隱藏邊框）
  }

  @media (min-width: 768px) {
    width: 320px;
  }

  .hidden-input {
    display: none;
  }

  /* ✨ 更換提示遮罩：預設隱藏 */
  .change-hint {
    position: absolute;
    inset: 0;
    background: rgba(0, 0, 0, 0.4);
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0; // 👈 預設看不見
    transition: opacity 0.2s ease-in-out;
  }

  /* ✨ 滑鼠移入時才顯現遮罩 */
  &:hover {
    border-color: $primary-color-700;

    .change-hint {
      opacity: 1; // 👈 Hover 時出現
    }
  }

  .upload-placeholder .placeholder-content {
    text-align: center;
    color: $neutral-color-700;

    .plus-icon {
      font-size: 30px;
      display: block;
    }
  }
}

.info-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* ...其餘樣式維持不變... */
.row-title {
  .title-input {
    width: 100%;
    border: none;
    outline: none;
    border-bottom: 1px solid $neutral-color-100;
    background: transparent;
  }

  .title-display {
    color: $primary-color-800;
    margin: 0;
  }
}

.row-meta {
  display: flex;
  gap: 30px;
  align-items: center;
  color: $neutral-color-800;

  .inline-input {
    border: none;
    border-bottom: 1px solid $neutral-color-400;
    width: 60px;
    text-align: center;
    outline: none;
    background: transparent;
  }

  .auto-hint {
    color: $primary-color-700;
    margin-left: 8px;
  }

  .stars-group {
    display: flex;
    gap: 4px;

    .star {
      font-size: 20px;
      color: $neutral-color-400;
      transition: transform 0.2s;
    }

    &.is-editing .star {
      cursor: pointer;

      &:hover {
        transform: scale(1.2);
      }
    }

    .star.active {
      color: $secondary-color-warning-700;
    }
  }
}

.row-description {
  position: relative;
  min-height: 100px;
  padding: 12px;
  background: $neutral-color-100;
  border-radius: 8px;

  &.editing-border {
    border: 1px dashed $primary-color-700;
    background: $neutral-color-white;
  }

  .desc-textarea {
    width: 100%;
    height: 70px;
    border: none;
    resize: none;
    outline: none;
    background: transparent;
  }

  .desc-display {
    white-space: pre-wrap;
    margin: 0;
  }

  .char-counter {
    position: absolute;
    bottom: 8px;
    right: 12px;
    color: $neutral-color-400;
  }
}
</style>