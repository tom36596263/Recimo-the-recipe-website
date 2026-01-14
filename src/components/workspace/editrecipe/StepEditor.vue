<script setup>
import { ref, onMounted, onUnmounted } from 'vue';

const props = defineProps(['steps', 'ingredients', 'isEditing']);
const activeStepId = ref(null);

const showTimerPop = ref(false);
const showIngPop = ref(false);
const popStyle = ref({ top: '0px', left: '0px', position: 'absolute' });

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
  input.type = 'file';
  input.accept = 'image/*';
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
  
  // RWD 彈窗定位邏輯：手機版固定在螢幕中央，桌面版跟隨按鈕
  if (window.innerWidth <= 810) {
    popStyle.value = { 
      top: '50%', 
      left: '50%', 
      transform: 'translate(-50%, -50%)',
      position: 'fixed' 
    };
  } else {
    popStyle.value = { 
      top: `${rect.bottom + window.scrollY + 8}px`, 
      left: `${rect.left + window.scrollX}px`,
      transform: 'none',
      position: 'absolute' 
    };
  }
  
  if (type === 'timer') {
    showTimerPop.value = !showTimerPop.value;
    showIngPop.value = false;
  } else {
    showIngPop.value = !showIngPop.value;
    showTimerPop.value = false;
  }
};

const closePops = () => {
  showTimerPop.value = false;
  showIngPop.value = false;
};

const getActiveStep = () => props.steps.find(s => s.id === activeStepId.value);

onMounted(() => window.addEventListener('click', closePops));
onUnmounted(() => window.removeEventListener('click', closePops));
</script>

<template>
  <div class="container">
    <div class="step-editor">
      <div class="section-header">
        <h2 class="zh-h4-bold">烹飪步驟</h2>
      </div>

      <div class="step-list">
        <div v-for="(step, idx) in steps" :key="step.id" class="step-item">
          
          <div class="step-sidebar">
            <div v-if="isEditing" class="drag-handle">
              <svg width="12" height="18" viewBox="0 0 12 18" fill="none"><circle cx="2" cy="2" r="2" fill="#CBD5E1"/><circle cx="2" cy="9" r="2" fill="#CBD5E1"/><circle cx="2" cy="16" r="2" fill="#CBD5E1"/><circle cx="10" cy="2" r="2" fill="#CBD5E1"/><circle cx="10" cy="9" r="2" fill="#CBD5E1"/><circle cx="10" cy="16" r="2" fill="#CBD5E1"/></svg>
            </div>
            <div class="step-number-badge p-p3">{{ idx + 1 }}</div>
          </div>

          <div class="step-card">
            <div class="card-header-row">
              <input 
                v-if="isEditing" 
                v-model="step.title" 
                class="zh-h5 title-input" 
                placeholder="請輸入該步驟標題..."
              >
              <div v-else class="zh-h5 title-text">{{ step.title || '步驟標題' }}</div>
              
              <button v-if="isEditing" @click="removeStep(step.id)" class="btn-remove p-p3">✕</button>
            </div>

            <hr class="card-divider">

            <div class="card-body row">
              <div class="col-4 col-md-12">
                <div 
                  class="step-image-uploader" 
                  @click="uploadStepImg(step)"
                  :style="{ backgroundImage: step.img ? `url(${step.img})` : '' }"
                >
                  <div v-if="!step.img" class="upload-placeholder">
                    <span class="plus-icon">+</span>
                    <span class="p-p3">新增圖片</span>
                  </div>
                </div>
              </div>

              <div class="col-8 col-md-12">
                <div class="step-info-column">
                  <div class="tag-action-row">
                    <BaseTag 
                      :text="step.time > 0 ? `${step.time} 分鐘` : '時間'" 
                      variant="action" 
                      :class="['btn-timer-tag', { 'is-active': step.time > 0 }]"
                      @click.stop="openPop($event, step.id, 'timer')" 
                    />
                    
                    <BaseTag 
                      text="食材" 
                      variant="action" 
                      :class="['btn-ingredient-tag', { 'is-active': step.tags.length > 0 }]"
                      @click.stop="openPop($event, step.id, 'ing')" 
                    />
                    
                    <div v-for="tid in step.tags" :key="tid" class="selected-tag p-p3">
                      {{ ingredients.find(i => i.id === tid)?.name }}
                      <span v-if="isEditing" class="tag-del" @click.stop="toggleTag(step, tid)">✕</span>
                    </div>
                  </div>

                  <textarea 
                    v-if="isEditing" 
                    v-model="step.text" 
                    class="p-p3 desc-textarea" 
                    placeholder="請輸入該步驟內容..."
                  ></textarea>
                  <div v-else class="p-p3 desc-display">{{ step.text || '暫無內容描述' }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div v-if="isEditing" class="footer-actions">
        <BaseBtn 
          title="+ 新增步驟"
          variant="outline" 
          height="40" 
          class="full-width-btn zh-h5" 
          @click="addStep" 
        />
      </div>
    </div>
  </div>

  <div v-if="showIngPop" :style="popStyle" class="popover-box" @click.stop>
    <div class="p-p3 popover-title">選擇食材</div>
    <div class="popover-content">
      <button v-for="i in ingredients" :key="i.id" @click="toggleTag(getActiveStep(), i.id)" class="p-p3 chip" :class="{ active: getActiveStep()?.tags.includes(i.id) }">{{ i.name }}</button>
    </div>
  </div>

  <div v-if="showTimerPop" :style="popStyle" class="popover-box timer-box" @click.stop>
    <div class="p-p3 popover-title">設定時間 (分)</div>
    <div class="timer-ui">
      <input type="number" v-model="getActiveStep().time" class="zh-h3">
      <div class="timer-btns">
        <button @click="getActiveStep().time += 5">+5</button>
        <button @click="getActiveStep().time = Math.max(0, getActiveStep().time - 5)">-5</button>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
// 這裡引用你的斷點設定
$md: 810px;

.step-editor {
  margin: 10px auto;
  width: 100%;

  .section-header {
    margin-bottom: 24px;
    .header-line { border: 0; border-top: 1px solid #10B981; margin-top: 12px; opacity: 0.3; }
  }

  .step-list {
    display: flex;
    flex-direction: column;
    gap: 32px;
    margin-bottom: 32px;
  }

  .step-item {
    display: flex;
    gap: 16px;
    @media (max-width: $md) { gap: 8px; }

    .step-sidebar {
      display: flex;
      flex-direction: column;
      align-items: center;
      padding-top: 14px;
      gap: 12px;
      width: 40px;
      flex-shrink: 0;
      .drag-handle { cursor: grab; display: flex; align-items: center; }
      .step-number-badge {
        width: 32px;
        height: 32px;
        background: $primary-color-100;
        color: $primary-color-700;
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
      }
    }

    .step-card {
      flex: 1;
      background: $neutral-color-white;
      border: 1px solid $neutral-color-400;
      border-radius: 10px;
      padding: 24px;
      @media (max-width: $md) { padding: 16px; }

      .card-header-row {
        display: flex;
        align-items: center;
        gap: 12px;
        .title-input { flex: 1; border: none; outline: none; background: transparent; }
        .btn-remove { background: none; border: none; color: $secondary-color-danger-700; cursor: pointer; }
      }

      .card-divider { border: 0; border-top: 1px solid $primary-color-700; margin: 16px 0; }

      .card-body {
        // 使用 row 之後會覆蓋 display: flex
        .step-image-uploader {
          width: 100%;
          max-width: 130px;
          aspect-ratio: 1 / 1;
          background-color: $neutral-color-100;
          background-size: cover;
          background-position: center;
          border-radius: 10px;
          border: 1px dashed $neutral-color-400;
          display: flex;
          align-items: center;
          justify-content: center;
          cursor: pointer;
          margin-bottom: 0;
          
          @media (max-width: $md) {
            max-width: 100%;
            height: 180px;
            margin-bottom: 16px;
          }

          .upload-placeholder {
            display: flex;
            flex-direction: column;
            align-items: center;
            color: $neutral-color-400;
            .plus-icon { font-size: 24px; margin-bottom: 4px; }
          }
        }

        .step-info-column {
          display: flex;
          flex-direction: column;
          gap: 12px;

          .tag-action-row {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            align-items: center;

            :deep(.btn-timer-tag) {
              background-color: $neutral-color-100 ; 
              color: $neutral-color-800 ;           
              border: 1px solid transparent ;
              cursor: pointer;
              transition: all 0.2s;
            }

            :deep(.btn-ingredient-tag) {
              background-color: $neutral-color-white ; 
              color: $primary-color-700 ;            
              border: 1px solid $primary-color-400;
              cursor: pointer;
              transition: all 0.2s;
            }

            .selected-tag {
              background: $primary-color-100;
              padding: 4px 12px;
              border-radius: 10px;
              display: flex;
              align-items: center;
              gap: 6px;
              .tag-del { color: $neutral-color-800; cursor: pointer; font-size: 14px; }
            }
          }

          .desc-textarea, .desc-display {
            width: 100%;
            min-height: 80px;
            border: none;
            resize: none;
            outline: none;
            background: transparent;
            line-height: 1.6;
          }
        }
      }
    }
  }

  .footer-actions {
    display: flex;
    justify-content: center;
    margin-top: 24px;
    padding-left: 56px; 
    width: 100%;
    @media (max-width: $md) { padding-left: 0; }

    :deep(.full-width-btn) {
      width: 100%;
      button { width: 100%; border-radius: 12px; }
    }
  }
}

.popover-box {
  background: $neutral-color-white;
  border: 1px solid $neutral-color-400;
  border-radius: 12px;
  padding: 16px;
  box-shadow: 0 10px 25px -5px rgba(0,0,0,0.1);
  z-index: 100;
  min-width: 220px;

  @media (max-width: $md) {
    width: 90%;
    max-width: 320px;
  }

  .popover-title { color: $primary-color-700; margin-bottom: 12px; border-bottom: 1px solid $neutral-color-400; padding-bottom: 6px; }
  
  .popover-content {
    display: flex; flex-wrap: wrap; gap: 8px;
    .chip {
      padding: 6px 12px; border-radius: 6px; border: 1px solid $neutral-color-white; background: $neutral-color-100; cursor: pointer;
      &.active { background: $primary-color-700; color: $neutral-color-white; border-color: $primary-color-700; }
    }
  }

  &.timer-box {
    text-align: center;
    .timer-ui {
      input { width: 100px; text-align: center; border: none; border-bottom: 2px solid $primary-color-700; outline: none; margin-bottom: 16px; font-size: 24px; }
      .timer-btns { display: flex; gap: 10px; button { flex: 1; padding: 8px; border-radius: 8px; border: 1px solid $neutral-color-white; cursor: pointer; background: $neutral-color-100; } }
    }
  }
}
</style>