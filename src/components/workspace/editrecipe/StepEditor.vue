<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import draggable from 'vuedraggable';

const props = defineProps(['steps', 'ingredients', 'isEditing']);
const activeStepId = ref(null);

const showTimerPop = ref(false);
const showIngPop = ref(false);
const popStyle = ref({ top: '0px', left: '0px', position: 'fixed' });

// --- ✨ 圖片解析 ---
const getStepImage = (step) => {
  if (!step) return null;
  const imgSource = step.image;
  if (imgSource && typeof imgSource === 'string' && imgSource.trim().length > 0) {
    if (imgSource.startsWith('data:') || imgSource.startsWith('http')) return imgSource;
    let path = imgSource.trim();
    if (!path.startsWith('/') && !path.startsWith('.')) path = `/${path}`;
    return path;
  }
  return null;
};

const handleImgError = (e) => {
  const img = e.target;
  if (img.dataset.tried === 'true') {
    img.src = 'https://placehold.co/150x120?text=No+Image';
    return;
  }
  img.dataset.tried = 'true';
  const currentSrc = img.src;
  if (currentSrc.toLowerCase().endsWith('.png')) img.src = currentSrc.replace(/\.png$/i, '.jpg');
  else if (currentSrc.toLowerCase().endsWith('.jpg')) img.src = currentSrc.replace(/\.jpg$/i, '.png');
  else img.src = 'https://placehold.co/150x120?text=No+Image';
};

const toggleBodyScroll = (isLock) => {
  if (isLock) {
    const scrollBarWidth = window.innerWidth - document.documentElement.clientWidth;
    document.body.style.overflow = 'hidden';
    document.body.style.paddingRight = `${scrollBarWidth}px`;
  } else {
    document.body.style.overflow = '';
    document.body.style.paddingRight = '';
  }
};

const addStep = () => {
  props.steps.push({
    id: 's' + Date.now(),
    title: '',
    content: '',
    image: null,
    time: null,
    tags: []
  });
};

const removeStep = (id) => {
  const index = props.steps.findIndex(s => (s.id || s.step_id) === id);
  if (index !== -1) props.steps.splice(index, 1);
};

const toggleTag = (step, ingId) => {
  if (!step) return;
  if (!step.tags) step.tags = [];
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

const openPop = (e, stepId, type) => {
  if (!props.isEditing) return;
  activeStepId.value = stepId;
  const rect = e.currentTarget.getBoundingClientRect();
  popStyle.value = { top: `${rect.bottom + 8}px`, left: `${rect.left}px`, position: 'fixed', zIndex: 9999 };
  if (type === 'timer') { showTimerPop.value = true; showIngPop.value = false; }
  else { showIngPop.value = true; showTimerPop.value = false; }
  toggleBodyScroll(true);
};

const closePops = () => {
  showTimerPop.value = false;
  showIngPop.value = false;
  toggleBodyScroll(false);
};

const getActiveStep = () => props.steps.find(s => (s.id || s.step_id) === activeStepId.value);

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

    <draggable :list="steps" class="step-list" handle=".drag-dots" item-key="id" :disabled="!isEditing"
      ghost-class="ghost-step" animation="300">
      <template #item="{ element: step, index: idx }">
        <div class="step-item-outer">
          <div class="step-card">
            <div class="card-header">
              <div class="step-sidebar-inline">
                <div v-if="isEditing" class="drag-dots">⋮⋮</div>
                <div class="step-number p-p2">{{ idx + 1 }}</div>
              </div>

              <input v-if="isEditing" v-model="step.title" class="step-title-input zh-h4" placeholder="步驟標題" />
              <span v-else class="step-title-display zh-h4">
                {{ step.title || ('步驟 ' + (idx + 1)) }}
              </span>
              <button v-if="isEditing" class="delete-step" @click="removeStep(step.id)">✕</button>
            </div>

            <div class="card-content">
              <div class="image-uploader-area">
                <div class="image-box" @click="uploadStepImg(step)">
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
                        <span class="ing-icon">🍳</span>
                        <span class="ing-name p-p3">{{ingredients?.find(i => i.id === tid)?.name || '食材'}}</span>
                        <span v-if="isEditing" class="tag-close-icon" @click.stop="toggleTag(step, tid)">✕</span>
                      </div>
                    </BaseTag>
                  </div>
                </div>

                <textarea v-if="isEditing" v-model="step.content" class="step-textarea p-p2"
                  placeholder="詳細說明步驟內容..."></textarea>
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
        <input type="number" v-model.number="getActiveStep().time"
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
      // font-weight: bold;
    }

    .delete-step {
      color: $secondary-color-danger-400;
      background: none;
      border: none;
      cursor: pointer;
      padding: 4px 8px;
    }
  }

  .card-content {
    display: flex;
    gap: 20px;

    @media (max-width: 768px) {
      flex-direction: column;
      gap: 12px;
    }
  }
}

.image-uploader-area {
  flex-shrink: 0;

  @media (max-width: 768px) {
    width: 100%;
  }
}

.image-box {
  width: 150px;
  height: 120px;
  background: $neutral-color-100;
  border: 1.5px dashed $neutral-color-400;
  border-radius: 12px;
  position: relative;
  cursor: pointer;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;

  @media (max-width: 768px) {
    width: 100%;
    height: 180px;
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
    color: white;
    opacity: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: opacity 0.2s;
  }

  &:hover .change-hint {
    opacity: 1;
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

  .step-textarea {
    border: none;
    outline: none;
    resize: none;
    min-height: 80px;
    padding: 8px 0;
    width: 100%;
    box-sizing: border-box;
    background: transparent;

    &:focus {
      border: none;
      outline: none;
    }
  }

  .step-text-display {
    white-space: pre-wrap;
    color: $neutral-color-800;
    word-break: break-all;
  }
}

.popover-box {
  background: white;
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
    border: 1px solid #ddd;
    cursor: pointer;
    background: white;

    &.active {
      background: $primary-color-800;
      color: white;
      border-color: $primary-color-800;
    }
  }
}

.add-step-wrapper {
  margin-top: 30px;
  border-top: 1px solid #eee;
  padding-top: 20px;

  .add-step-btn {
    width: 100%;
    height: 48px;
    border: 1.5px solid $primary-color-400;
    color: $primary-color-800;
    border-radius: 10px;
    background: white;
    cursor: pointer;
    transition: all 0.2s ease-in-out;

    &:hover {
      background: $primary-color-100;
      transform: translateY(-1px);
    }

    &:active {
      background: $primary-color-400;
      transform: translateY(0);
    }
  }
}

.selected-ing-wrapper {
  display: inline-flex;
  align-items: center;

  :deep(.base-tag) {
    height: 32px !important;
    min-height: 32px !important;
    background-color: $primary-color-100 !important;
    border-radius: 10px !important;
    border: none !important;
    padding: 0 8px !important;
    max-width: 120px;
  }
}

.ing-tag-content {
  display: flex;
  align-items: center;
  gap: 4px;
  overflow: hidden;

  .ing-name {
    color: $neutral-color-800;
    font-weight: 500;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
}

.ghost-step {
  opacity: 0.5;
  background: $primary-color-100 !important;
  border: 2px dashed $primary-color-400 !important;
  border-radius: 12px;
}
</style>