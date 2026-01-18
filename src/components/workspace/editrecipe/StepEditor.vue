<script setup>
import { ref, onMounted, onUnmounted } from 'vue';

const props = defineProps(['steps', 'ingredients', 'isEditing']);
const activeStepId = ref(null);

const showTimerPop = ref(false);
const showIngPop = ref(false);

const popStyle = ref({ top: '0px', left: '0px', position: 'fixed' });

const toggleBodyScroll = (isLock) => {
  if (isLock) {
    const scrollBarWidth = window.innerWidth - document.documentElement.clientWidth;
    document.body.style.overflow = 'hidden';
    document.body.style.paddingRight = `${scrollBarWidth}px`;
    document.body.style.touchAction = 'none';
  } else {
    document.body.style.overflow = '';
    document.body.style.paddingRight = '';
    document.body.style.touchAction = '';
  }
};

const addStep = () => {
  props.steps.push({ id: 's' + Date.now(), title: '', text: '', time: 0, tags: [], img: null });
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
  input.type = 'file'; input.accept = 'image/*';
  input.onchange = (e) => {
    const reader = new FileReader();
    reader.onload = (f) => step.img = f.target.result;
    reader.readAsDataURL(e.target.files[0]);
  };
  input.click();
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

const closePops = () => {
  if (showTimerPop.value || showIngPop.value) {
    showTimerPop.value = false;
    showIngPop.value = false;
    toggleBodyScroll(false);
  }
};

const getActiveStep = () => props.steps.find(s => s.id === activeStepId.value);

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

    <div class="step-list">
      <div v-for="(step, idx) in steps" :key="step.id" class="step-item-outer">
        <div class="step-sidebar">
          <div v-if="isEditing" class="drag-dots">⋮⋮</div>
          <div class="step-number p-p2">{{ idx + 1 }}</div>
        </div>

        <div class="step-card">
          <div class="card-header">
            <input v-if="isEditing" v-model="step.title" class="step-title-input zh-h4" placeholder="步驟標題" />
            <span v-else class="step-title-display zh-h4-bold">{{ step.title || '未命名步驟' }}</span>
            <button v-if="isEditing" class="delete-step" @click="removeStep(step.id)">✕</button>
          </div>

          <div class="card-content">
            <div class="image-uploader" @click="uploadStepImg(step)"
              :style="{ backgroundImage: step.img ? `url(${step.img})` : '' }">
              <div class="image-overlay">
                <span class="plus">+</span>
                <span class="text p-p3">{{ step.img ? '更換圖片' : '新增圖片' }}</span>
              </div>
            </div>

            <div class="step-info">
              <div class="tag-row">
                <BaseTag :text="step.time > 0 ? '+ ' + step.time + ':00' : '+ 時間'" variant="action" :show-icon="false"
                  width="85px" @click.stop="openPop($event, step.id, 'timer')" />

                <BaseTag text="食材" variant="action" width="85px" @click.stop="openPop($event, step.id, 'ing')" />

                <div v-for="tid in step.tags" :key="tid" class="selected-ing-wrapper">
                  <BaseTag variant="label" width="auto">
                    <div class="ing-tag-content">
                      <span class="ing-icon">🍳</span>
                      <span class="ing-name p-p3">{{ingredients.find(i => i.id === tid)?.name || '未知'}}</span>
                      <span v-if="isEditing" class="tag-close-icon" @click.stop="toggleTag(step, tid)">✕</span>
                    </div>
                  </BaseTag>
                </div>
              </div>

              <textarea v-if="isEditing" v-model="step.text" class="step-textarea p-p2"
                placeholder="詳細說明步驟內容..."></textarea>
              <div v-else class="step-text-display p-p2">{{ step.text || '點擊編輯新增說明' }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="isEditing" class="add-step-wrapper">
      <button class="add-step-btn p-p2" @click="addStep">+ 新增步驟</button>
    </div>
  </div>

  <div v-if="showIngPop" :style="popStyle" class="popover-box" @click.stop>
    <div class="popover-title p-p2">選擇食材</div>
    <div class="popover-content">
      <button v-for="i in ingredients" :key="i.id" @click="toggleTag(getActiveStep(), i.id)" class="chip p-p3"
        :class="{ active: getActiveStep()?.tags.includes(i.id) }">{{ i.name }}</button>
    </div>
  </div>

  <div v-if="showTimerPop" :style="popStyle" class="popover-box timer-box" @click.stop>
    <div class="popover-title p-p2">設定製作時間</div>
    <div class="timer-ui">
      <div class="input-wrapper">
        <input type="number" v-model.number="getActiveStep().time" class="timer-input">
        <span class="unit zh-h4-bold">分鐘</span>
      </div>
      <div class="timer-control-grid">
        <div class="control-column">
          <button class="circle-btn minus p-p3"
            @click="getActiveStep().time = Math.max(0, getActiveStep().time - 10)">-10</button>
          <button class="circle-btn minus p-p3"
            @click="getActiveStep().time = Math.max(0, getActiveStep().time - 5)">-5</button>
        </div>
        <div class="divider"></div>
        <div class="control-column">
          <button class="circle-btn plus p-p3" @click="getActiveStep().time += 5">+5</button>
          <button class="circle-btn plus p-p3" @click="getActiveStep().time += 10">+10</button>
        </div>
      </div>
      <button class="reset-link p-p3" @click="getActiveStep().time = 0">重設為 0</button>
    </div>
  </div>
</template>

<style lang="scss" scoped>
/* 樣式部分保持不變，核心重點在上述 Template 的 BaseTag 傳參 */
.step-editor-container {
  width: 100%;
  margin-bottom: 50px;
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
  gap: 15px;

  .step-sidebar {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 30px;

    .drag-dots {
      color: $neutral-color-400;
      cursor: grab;
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
}

.step-card {
  flex: 1;
  border-top: 1px solid $neutral-color-100;

  .card-header {
    display: flex;
    align-items: center;
    padding: 12px 0;
    border-bottom: 1px solid $neutral-color-100;
    margin-bottom: 15px;

    .step-title-input {
      flex: 1;
      border: none;
      outline: none;
      background: transparent;
      color: $neutral-color-black;
    }

    .delete-step {
      color: $secondary-color-danger-400;
      background: none;
      border: none;
      cursor: pointer;

      &:hover {
        color: $secondary-color-danger-700;
      }
    }
  }

  .card-content {
    display: flex;
    gap: 20px;

    .image-uploader {
      width: 150px;
      height: 120px;
      background: $neutral-color-100;
      border: 1.5px dashed $neutral-color-400;
      border-radius: 12px;
      position: relative;
      background-size: cover;
      background-position: center;

      .image-overlay {
        position: absolute;
        inset: 0;
        background: rgba($neutral-color-white, 0.4);
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        color: $neutral-color-700;
      }
    }

    .step-info {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 12px;

      .tag-row {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
        align-items: center;
      }

      .selected-ing-wrapper {
        transform: scale(0.9);
          transform-origin: left center;
      
          :deep(.base-tag) {
            background-color: $primary-color-100;
            height: 35px;
            border-radius: 10px;
          }
      } 

      .ing-tag-content {
        display: flex;
        align-items: center;
        gap: 6px;
        padding: 0 4px;

        .ing-icon {
          font-size: 14px;
        }

        .ing-name {
          color: $neutral-color-800;
          font-size: 16px;
        }

        .tag-close-icon {
          color: $neutral-color-800;
          font-size: 14px;
          cursor: pointer;
          margin-left: 4px;
          line-height: 1;

          &:hover {
            color: $secondary-color-danger-700;
          }
        }
      }

      .step-textarea {
        border: none;
        outline: none;
        resize: none;
        min-height: 80px;
        background: transparent;
        color: $neutral-color-800;
      }

      .step-text-display {
        color: $neutral-color-800;
        white-space: pre-wrap;
      }
    }
  }
}

.popover-box {
  background: $neutral-color-white;
  border: 1px solid $primary-color-400;
  border-radius: 12px;
  padding: 15px;
  box-shadow: 0 8px 20px rgba($neutral-color-black, 0.1);
  width: 260px;
  z-index: 9999;

  .popover-title {
    color: $primary-color-800;
    font-weight: bold;
    margin-bottom: 12px;
    border-bottom: 1px solid $neutral-color-100;
    padding-bottom: 6px;
  }

  &.timer-box {
    text-align: center;

    .input-wrapper {
      display: flex;
      align-items: baseline;
      justify-content: center;
      gap: 6px;
      margin: 10px 0 20px;

      .timer-input {
        width: 70px;
        font-size: 32px;
        font-weight: bold;
        border: none;
        border-bottom: 3px solid $primary-color-800;
        text-align: center;
        outline: none;
        color: $primary-color-800;
        background: transparent;
      }

      .unit {
        color: $neutral-color-800;
      }
    }

    .timer-control-grid {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 12px;

      .control-column {
        display: flex;
        flex-direction: column;
        gap: 10px;
      }

      .divider {
        width: 1px;
        height: 60px;
        background: $neutral-color-100;
      }

      .circle-btn {
        width: 48px;
        height: 48px;
        border-radius: 50%;
        border: 1px solid $neutral-color-100;
        background: $neutral-color-white;
        cursor: pointer;
        transition: all 0.2s;

        &.plus {
          background: $primary-color-100;
          color: $primary-color-800;
          border-color: $primary-color-400;

          &:hover {
            background: $primary-color-800;
            color: $neutral-color-white;
          }
        }

        &.minus {
          color: $neutral-color-800;

          &:hover {
            background: $secondary-color-danger-200;
            color: $secondary-color-danger-700;
            border-color: $secondary-color-danger-400;
          }
        }
      }
    }

    .reset-link {
      margin-top: 15px;
      background: none;
      border: none;
      color: $neutral-color-400;
      text-decoration: underline;
      cursor: pointer;

      &:hover {
        color: $neutral-color-800;
      }
    }
  }

  .chip {
    margin: 4px;
    padding: 6px 12px;
    border-radius: 20px;
    border: 1px solid $neutral-color-100;
    background: $neutral-color-white;
    cursor: pointer;
    color: $neutral-color-800;

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
    // font-weight: bold;
    cursor: pointer;

    &:hover {
      background: $primary-color-100;
    }
  }
}
</style>