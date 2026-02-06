<script setup>
import { ref, onMounted, onUnmounted, watch, computed } from 'vue';
import draggable from 'vuedraggable';

const props = defineProps(['steps', 'ingredients', 'isEditing']);
const emit = defineEmits(['update:steps']);

// --- ✨ 關鍵修正 1：建立本地副本，並與父組件隔離 ---
const localSteps = ref([]);

// 監控 props.steps，只有在「內容真正改變」時才更新本地副本，防止遞迴
watch(() => props.steps, (newVal) => {
  if (!newVal) return;

  const newStr = JSON.stringify(newVal);
  const oldStr = JSON.stringify(localSteps.value);

  // 只有當父組件傳入的資料跟本地不一樣時（例如 API 剛載入），才更新 localSteps
  if (newStr !== oldStr) {
    localSteps.value = JSON.parse(newStr);
  }
}, { immediate: true, deep: true });

// 監控 localSteps，當本地改動時同步回父組件
watch(localSteps, (newVal) => {
  const newStr = JSON.stringify(newVal);
  const oldStr = JSON.stringify(props.steps);

  // 防止回傳一模一樣的資料觸發父組件更新
  if (newStr !== oldStr) {
    emit('update:steps', JSON.parse(newStr));
  }
}, { deep: true });

const activeStepId = ref(null);
const showTimerPop = ref(false);
const showIngPop = ref(false);
const popStyle = ref({ top: '0px', left: '0px', position: 'fixed' });

// --- ✨ 核心修正：雙向綁定中轉站 ---
const internalSteps = computed({
  get: () => props.steps,
  set: (val) => emit('update:steps', val)
});

// --- 修改資料的方法，都改用複製陣列後 emit ---
const updateStepField = (index, field, value) => {
  const newSteps = [...props.steps];
  newSteps[index] = { ...newSteps[index], [field]: value };
  emit('update:steps', newSteps);
};

const addStep = () => {
  const newStep = {
    id: 's' + Date.now(),
    title: '',
    content: '',
    image: null,
    time: null,
    tags: []
  };

  // ✅ 只修改本地副本，watch 會自動 emit 給父組件
  localSteps.value.push(newStep);
};

const removeStep = (id) => {
  // ✅ 使用 filter 產生新陣列，觸發響應
  localSteps.value = localSteps.value.filter(s => (s.id !== id && s.step_id !== id));
  const newSteps = props.steps.filter(s => (s.id || s.step_id) !== id);
  // if (index !== -1) props.steps.splice(index, 1);
  emit('update:steps', newSteps);
  
};

const getActiveStep = () => {
  if (activeStepId.value === null) return null;
  return localSteps.value.find(s => (s.id === activeStepId.value || s.step_id === activeStepId.value));
};

const openPop = (e, stepId, type) => {
  if (!props.isEditing) return;
  activeStepId.value = stepId;
  const rect = e.currentTarget.getBoundingClientRect();
  popStyle.value = {
    top: `${rect.bottom + 8}px`,
    left: `${rect.left}px`,
    position: 'fixed',
    zIndex: 9999
  };

  if (type === 'timer') {
    showTimerPop.value = true;
    showIngPop.value = false;
  } else {
    showIngPop.value = true;
    showTimerPop.value = false;
  }
  toggleBodyScroll(true);
};

const toggleTag = (step, ingId) => {
  if (!step) return;
  if (!step.tags) step.tags = [];
  const index = step.tags.indexOf(ingId);
  if (index === -1) {
    step.tags.push(ingId);
  } else {
    step.tags.splice(index, 1);
  }
};

// const getStepImage = (step) => {
//   if (!step || !step.image) return null;
//   const imgSource = step.image;
//   if (typeof imgSource === 'string' && imgSource.trim().length > 0) {
//     if (imgSource.startsWith('data:') || imgSource.startsWith('http')) return imgSource;
//     return imgSource.startsWith('/') || imgSource.startsWith('.') ? imgSource : `/${imgSource}`;
//   }
//   return null;
// };
const getStepImage = (step) => {
  if (!step || !step.image) return null;
  
  // 如果是 File 物件 (剛上傳)，產生臨時預覽圖
  if (step.image instanceof File) {
    return URL.createObjectURL(step.image);
  }
  // 2. 如果是字串 (資料庫來的路徑)
  const imgSource = step.image;
  if (typeof imgSource === 'string' && imgSource.trim().length > 0) {
    // 如果已經是完整 URL (http) 或 Base64 (data:)，直接回傳
    if (imgSource.startsWith('data:') || imgSource.startsWith('http')) {
      return imgSource;
    }
    // ✅ 核心修改：使用 parsePublicFile 處理相對路徑 (如 img/recipes/...)
    return parsePublicFile(imgSource);
  }
};

const handleImgError = (e) => {
  const img = e.target;
  if (img.dataset.tried === 'true') {
    img.src = 'https://placehold.co/150x120?text=No+Image';
    return;
  }
  img.dataset.tried = 'true';
  img.src = img.src.toLowerCase().endsWith('.png') ? img.src.replace(/\.png$/i, '.jpg') : img.src.replace(/\.jpg$/i, '.png');
};

const toggleBodyScroll = (isLock) => {
  const scrollBarWidth = window.innerWidth - document.documentElement.clientWidth;
  document.body.style.overflow = isLock ? 'hidden' : '';
  document.body.style.paddingRight = isLock ? `${scrollBarWidth}px` : '';
};

const uploadStepImg = (step) => {
  if (!props.isEditing) return;
  const input = document.createElement('input');
  input.type = 'file';
  input.accept = 'image/*';
  input.onchange = (e) => {
    const file = e.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (f) => {
      step.image = f.target.result;
    };
    reader.readAsDataURL(file);
  };
  input.click();
};

const closePops = () => {
  showTimerPop.value = false;
  showIngPop.value = false;
  toggleBodyScroll(false);
};

onMounted(() => window.addEventListener('click', closePops));
onUnmounted(() => {
  window.removeEventListener('click', closePops);
  toggleBodyScroll(false);
});
</script>

<template>
  <div class="step-editor-container">
    <div class="section-header">
      <h2 class="header-title zh-h4-bold">烹飪步驟</h2>
    </div>

    <draggable :list="localSteps" class="step-list" handle=".drag-dots" item-key="id" :disabled="!isEditing"
      ghost-class="ghost-step" animation="300">
      <template #item="{ element: step, index: idx }">
        <div class="step-item-outer">
          <div class="step-card">
            <div class="card-header">
              <div class="step-sidebar-inline">
                <div v-if="isEditing" class="drag-dots">⋮⋮</div>
                <div class="step-number p-p2">{{ idx + 1 }}</div>
              </div>

              <input v-if="isEditing" v-model="step.title" class="step-title-input zh-h4" placeholder="步驟標題"
                maxlength="30" />
              <span v-else class="step-title-display zh-h4">
                {{ step.title || ('步驟 ' + (idx + 1)) }}
              </span>
              <button v-if="isEditing" class="delete-step" @click="removeStep(step.id)">✕</button>
            </div>

            <div class="card-content">
              <div class="image-uploader-area">
                <div class="image-box" :class="{ 'has-image': getStepImage(step) }" @click="uploadStepImg(step)">
                  <img v-if="getStepImage(step)" :src="getStepImage(step)" class="step-img" @error="handleImgError" />
                  <div v-else class="image-placeholder">
                    <span class="plus">+</span>
                    <span class="text p-p3">新增圖片</span>
                  </div>
                  <div v-if="getStepImage(step) && isEditing" class="change-hint">
                    <span>更換圖片</span>
                  </div>
                </div>
              </div>

              <div class="step-info">
                <div class="tag-row">
                  <BaseTag :text="step.time ? `${step.time} 分鐘` : '+ 時間'" variant="action" :show-icon="false"
                    width="85px" @click.stop="openPop($event, step.id || idx, 'timer')" />
                  <BaseTag text="食材" variant="action" width="85px"
                    @click.stop="openPop($event, step.id || idx, 'ing')" />

                  <div v-for="tid in (step.tags || [])" :key="tid" class="selected-ing-wrapper">
                    <BaseTag variant="label" width="auto">
                      <div class="ing-tag-content">
                        <img src="@/assets/images/recipe/Vector.svg" class="ing-icon-img" alt="icon" />
                        <span class="ing-name p-p3">{{ingredients?.find(i => i.id === tid)?.name || '食材'}}</span>
                        <span v-if="isEditing" class="tag-close-icon" @click.stop="toggleTag(step, tid)">✕</span>
                      </div>
                    </BaseTag>
                  </div>
                </div>

                <div v-if="isEditing" class="textarea-wrapper">
                  <textarea v-model="step.content" class="step-textarea p-p2" placeholder="詳細說明步驟內容..."
                    maxlength="100"></textarea>
                  <span class="char-counter">{{ step.content?.length || 0 }}/100</span>
                </div>
                <div v-else class="step-text-display p-p2">
                  {{ step.content || '無步驟說明' }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </template>
    </draggable>

    <div v-if="isEditing" class="add-step-wrapper">
      <button class="add-step-btn p-p2" @click="addStep">+ 新增步驟</button>
    </div>
  </div>

  <div v-if="showIngPop" :style="popStyle" class="popover-box" @click.stop>
    <div class="popover-title p-p2">選擇食材</div>
    <div class="popover-content">
      <button v-for="i in ingredients" :key="i.id" @click="toggleTag(getActiveStep(), i.id)" class="chip p-p3"
        :class="{ active: getActiveStep()?.tags?.includes(i.id) }">
        {{ i.name }}
      </button>
    </div>
  </div>

  <div v-if="showTimerPop" :style="popStyle" class="popover-box" @click.stop>
    <div class="popover-title p-p2">設定烹飪時間</div>
    <div class="popover-content" style="display: flex; flex-direction: column; gap: 12px; padding: 10px 0;">
      <div style="display: flex; align-items: center; gap: 8px;">
        <input type="number" v-model.number="getActiveStep().time" step="1" min="0" max="1440"
          style="flex: 1; padding: 8px; border: 1px solid #ddd; border-radius: 6px; outline: none;" placeholder="輸入分鐘"
          @keyup.enter="closePops" />
        <span class="p-p3">分鐘</span>
      </div>
      <button @click="closePops"
        style="background: #3E8D60; color: white; border: none; padding: 8px; border-radius: 6px; cursor: pointer;">確定</button>
    </div>
  </div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.step-editor-container {
  width: 100%;
  margin-bottom: 50px;
  box-sizing: border-box;
}

.section-header {
  margin-bottom: 24px;

  .header-title {
    color: $primary-color-800;
    border-bottom: 1.5px solid $primary-color-400;
    padding-bottom: 12px;
  }
}

.step-list {
  display: flex;
  flex-direction: column;
  gap: 40px;
}

.step-item-outer {
  display: flex;
  width: 100%;
}

.step-card {
  flex: 1;
  border-top: 1px solid $neutral-color-400;
  min-width: 0;

  .card-header {
    display: flex;
    align-items: center;
    padding: 12px 0;
    border-bottom: 1px solid $neutral-color-400;
    margin-bottom: 15px;
    gap: 12px;

    .step-sidebar-inline {
      display: flex;
      align-items: center;
      gap: 8px;
      flex-shrink: 0;

      .drag-dots {
        cursor: grab;
        color: $neutral-color-400;
        font-size: 20px;
        letter-spacing: 2px;
        user-select: none;
        transition: color 0.2s;
        display: flex;
        align-items: center;

        &:hover {
          color: $primary-color-700;
        }

        &:active {
          cursor: grabbing;
        }
      }

      .step-number {
        width: 28px;
        height: 28px;
        background: $primary-color-100;
        color: $primary-color-800;
        border-radius: 6px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: bold;
      }
    }

    .step-title-input {
      flex: 1;
      border: none;
      outline: none;
      background: transparent;
      min-width: 0;
    }

    .delete-step {
      color: $secondary-color-danger-400;
      background: none;
      border: none;
      cursor: pointer;
      padding: 4px 8px;

      @media (max-width: 768px) {
        font-size: 20px; // 放大刪除鈕，手機好點擊
        padding: 8px;
      }
    }
  }

  .card-content {
    display: flex;
    gap: 20px;

    @media (max-width: 768px) {
      flex-direction: column; // 🚀 關鍵：手機版圖上文下
      gap: 16px;
    }
  }
}

.image-uploader-area {
  flex-shrink: 0;
}

.image-box {
  width: 150px;
  height: 150px;
  background: $neutral-color-100;
  border: 1.5px dashed $neutral-color-400;
  border-radius: 12px;
  position: relative;
  cursor: pointer;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;

  @media (max-width: 768px) {
    width: 100%; // 🚀 關鍵：手機版圖片寬度 100%
    height: 180px; // 稍微拉高高度
  }

  &.has-image {
    border-style: solid;
    border-color: $primary-color-400;
  }

  .step-img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .image-placeholder {
    display: flex;
    flex-direction: column;
    align-items: center;
    color: $neutral-color-400;

    .plus {
      font-size: 24px;
    }
  }

  .change-hint {
    position: absolute;
    inset: 0;
    background: rgba(0, 0, 0, 0.3);
    color: $neutral-color-white;
    opacity: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: opacity 0.2s;
  }

  &:hover {
    border-color: $primary-color-700;

    .change-hint {
      opacity: 1;
    }
  }
}

.step-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-width: 0;

  .tag-row {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    align-items: center;
  }

  .textarea-wrapper {
    position: relative;
    width: 100%;

    .char-counter {
      position: absolute;
      right: 0;
      bottom: -18px;
      font-size: 12px;
      color: $neutral-color-400;
    }
  }

  .step-textarea {
    border: none;
    outline: none;
    resize: none;
    min-height: 80px;
    padding: 8px 0;
    width: 100%;
    box-sizing: border-box;
    background: transparent;
    overflow-wrap: break-word;

    @media (max-width: 768px) {
      min-height: 120px; // 🚀 手機版輸入框高一點
      font-size: 16px; // 防止 iOS 自動放大畫面
    }
  }

  .step-text-display {
    white-space: pre-wrap;
    color: $neutral-color-800;
    word-break: break-word;
    overflow-wrap: break-word;
    width: 100%;
  }
}

// ... 下方 popover-box, add-step-wrapper 等樣式維持不變 ...
.popover-box {
  background: $neutral-color-white;
  border: 1px solid $primary-color-400;
  border-radius: 12px;
  padding: 15px;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
  width: 260px;
  z-index: 9999;
  max-width: calc(100vw - 40px);

  .chip {
    margin: 4px;
    padding: 6px 12px;
    border-radius: 20px;
    border: 1px solid $neutral-color-100;
    cursor: pointer;
    background: $neutral-color-white;

    &.active {
      background: $primary-color-800;
      color: $neutral-color-white;
      border-color: $primary-color-800;
    }
  }
}

.add-step-wrapper {
  margin-top: 30px;
  border-top: 1px solid $neutral-color-100;
  padding-top: 20px;

  .add-step-btn {
    width: 100%;
    height: 48px;
    border: 1.5px solid $primary-color-400;
    color: $primary-color-800;
    border-radius: 10px;
    background: $neutral-color-white;
    cursor: pointer;
    transition: all 0.2s ease-in-out;

    &:hover {
      background: $primary-color-100;
      transform: translateY(-1px);
    }
  }
}

.selected-ing-wrapper {
  display: inline-flex;
  align-items: center;

  :deep(.base-tag) {
    height: 32px !important;
    background-color: $primary-color-100 !important;
    border-radius: 10px !important;
    padding: 0 10px !important;
  }
}

.ing-tag-content {
  display: flex;
  align-items: center;
  gap: 6px;

  .ing-name {
    font-size: 14px;
    color: $neutral-color-800;
  }

  .tag-close-icon {
    cursor: pointer;
    margin-left: 2px;
  }
}

.ghost-step {
  opacity: 0.5;
  background: $primary-color-100 !important;
  border: 2px dashed $primary-color-400 !important;
}
</style>