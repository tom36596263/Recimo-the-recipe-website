<script setup>
import { ref, computed, watch } from 'vue';
import AdaptRecipeCard from '@/components/workspace/modifyrecipe/AdaptRecipeCard.vue';
import { useRouter, useRoute } from 'vue-router';

const router = useRouter();
const route = useRoute();

const props = defineProps({
  modelValue: { type: Object, required: true },
  isEditing: { type: Boolean, default: false },
  isAdaptMode: { type: Boolean, default: false }
});

const emit = defineEmits(['update:modelValue', 'open-tag-modal']);

// 1. 宣告 ref 來對應 template 中的 input
const fileInput = ref(null);

// 2. 處理從小卡傳上來的點擊訊號
const handleUploadClick = () => {
  if (props.isEditing && fileInput.value) {
    fileInput.value.click();
  }
};

// 跳轉邏輯
const goToOriginal = () => {
  const targetId = props.modelValue.parent_recipe_id || props.modelValue.recipe_id;
  if (targetId) {
    router.push(`/workspace/recipe-detail/${targetId}`);
  } else {
    alert("找不到原始食譜編號");
  }
};


// EditorHeader.vue 

// EditorHeader.vue

// const updateField = (field, value) => {
//   const nextData = { ...props.modelValue };
//   nextData[field] = value;

//   // ❌ 刪除原本這裡所有 if (field === 'adapt_description') 的邏輯
//   // 保持數據純淨，不要手動去同步 description 或 clean_description

//   emit('update:modelValue', nextData);
// };

const updateField = (field, value) => {
  // 確保每次更新都是產生一個新的物件引用，Vue 才能偵測到變化
  emit('update:modelValue', { 
    ...props.modelValue, 
    [field]: value 
  });
};
const removeTag = (tagId) => {
  const updatedTags = props.modelValue.tags.filter(t => t.tag_id !== tagId);
  updateField('tags', updatedTags);
};

const setDifficulty = (val) => {
  if (props.isEditing) updateField('difficulty', Number(val));
};

// --- EditorHeader.vue ---

// 1. 確保 autoTotalTime 計算出來一定是數字
const autoTotalTime = computed(() => {
  const steps = props.modelValue.steps || [];
  if (steps.length === 0) return 0;
  return steps.reduce((sum, step) => {
    // 確保這裡把字串轉成數字，防止 60 變成 "60"
    const stepTime = parseInt(step.time, 10) || 0;
    return sum + stepTime;
  }, 0);
});

const displayTime = computed(() => {
  return Number(props.modelValue.totalTime) || 0;
});


// EditorHeader.vue 內

const adaptRecipeData = computed(() => {
  const m = props.modelValue;
  return {
    recipe_id: m.id || m.recipe_id,
    title: m.adapt_title || m.title || '未命名改編',

    // ✨ 這裡改為只認 adapt_description
    // 這樣你在輸入框打字時，小卡才會跟著動
    adaptation_note: m.adapt_description || '',

    coverImg: m.image || m.coverImg || m.recipe_image_url,
    author: m.author || { author_name: 'Recimo User', author_image: '' },
    likes: m.likes || 0,
    keyChangeTag: m.keyChangeTag || ''
  };
});

const handleCoverUpload = (e) => {
  const file = e.target.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = (evt) => updateField('coverImg', evt.target.result);
  reader.readAsDataURL(file);
};

// watch(
//   () => props.modelValue.steps,
//   (newSteps) => {
//     if (!props.isEditing) return; // 只有編輯模式才自動計算
    
//     const newSum = newSteps?.reduce((sum, s) => sum + (Number(s.time) || 0), 0) || 0;
    
//     // 如果用戶還沒手動輸入時間，或者手動輸入為 0，則自動帶入加總
//     if (!props.modelValue.totalTime || props.modelValue.totalTime === 0) {
//       updateField('totalTime', newSum);
//     }
//   },
//   { deep: true }
// );
watch(
  () => props.modelValue.steps,
  (newSteps) => {
    if (!props.isEditing) return;

    const newSum = newSteps?.reduce((sum, s) => sum + (Number(s.time) || 0), 0) || 0;

    // ✨ 修正點：加上數值判斷，避免數值沒變卻一直 emit 新物件
    if (newSum !== props.modelValue.totalTime) {
      // 如果用戶沒輸入或為0，才自動填入
      if (!props.modelValue.totalTime || props.modelValue.totalTime === 0) {
        updateField('totalTime', newSum);
      }
    }
  },
  { deep: true }
);
</script>

<template>
  <section class="recipe-card-container">
    <input ref="fileInput" type="file" class="hidden-input" accept="image/*" @change="handleCoverUpload" />

    <template v-if="isAdaptMode">
      <div class="adapt-card-section">
        <div class="adapt-card-wrapper" :style="{ cursor: isEditing ? 'pointer' : 'default' }">
          <AdaptRecipeCard :recipe="adaptRecipeData" :readonly="!isEditing" @upload-image="handleUploadClick" />
        </div>
        <BaseBtn title="查看原始食譜詳情" variant="outline" :width="320" @click="goToOriginal" class="back-original-btn" />
      </div>
    </template>

    <template v-else>
      <div class="cover-section" :class="{ 'has-image': modelValue.coverImg }"
        :style="{ backgroundImage: modelValue.coverImg ? `url(${modelValue.coverImg})` : '' }"
        @click="isEditing && fileInput.click()">
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
    </template>

    <div class="info-section">
      <div class="row-title">
        <template v-if="isAdaptMode">
          <div class="title-with-tag">
            <h2 class="title-display zh-h2-bold">{{ modelValue.original_title || modelValue.title || '未命名食譜' }}</h2>
            <span class="adapt-tag p-p3">改編自此食譜</span>
          </div>
        </template>
        <template v-else>
          <input v-if="isEditing" :value="modelValue.title" @input="updateField('title', $event.target.value)"
            class="title-input zh-h3" placeholder="請輸入標題..." maxlength="30" />
          <h2 v-else class="title-display zh-h2-bold">{{ modelValue.title || '未命名食譜' }}</h2>
        </template>
      </div>

      <div v-if="isAdaptMode && isEditing" class="row-adapt-inputs">
        <div class="input-container full-width">
          <input :value="modelValue.adapt_title" @input="updateField('adapt_title', $event.target.value)"
            class="form-input p-p1" :class="{ 'is-success': modelValue.adapt_title }" placeholder="請輸入改編版本標題 (例：低脂版)"
            maxlength="20" />
          <span class="char-counter p-p3">{{ modelValue.adapt_title?.length || 0 }}/20</span>
        </div>

        <div class="input-container full-width">
          <textarea class="form-input adaptation-textarea p-p1" :value="modelValue.adapt_description"
            @input="updateField('adapt_description', $event.target.value)" placeholder="說明改編了什麼..."
            maxlength="60"></textarea>
          <span class="char-counter p-p3">{{ modelValue.adapt_description?.length || 0 }}/60</span>
        </div>
      </div>

      <div class="row-meta p-p2">
        <div class="meta-item">
          <span class="label">製作時間：</span>
          <template v-if="isEditing">
            <input type="number" class="inline-input" :value="modelValue.totalTime"
              @input="updateField('totalTime', Number($event.target.value))" :placeholder="autoTotalTime" />
            <span class="unit">分鐘</span>
            <small v-if="modelValue.totalTime == 0 && autoTotalTime > 0" style="color: #999; margin-left: 4px;">
              (自動加總: {{ autoTotalTime }})
            </small>
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
        <div v-if="!isAdaptMode" class="meta-item">
          <span class="label">份量：</span>
          <template v-if="isEditing">
            <input type="number" class="inline-input servings-input" :value="modelValue.servings"
              @input="updateField('servings', Number($event.target.value))" placeholder="2" min="1" max="20" />
            <span class="unit">人份</span>
          </template>
          <span v-else class="value">{{ modelValue.servings || 0 }} 人份</span>
        </div>
      </div>

      <div class="row-tags">
        <div class="tags-wrapper">
          <div class="tag-item" v-for="tag in modelValue.tags" :key="tag.tag_id">
            <span class="tag-text p-p3"># {{ tag.tag_name }}</span>
            <button v-if="isEditing" class="tag-delete-btn" @click="removeTag(tag.tag_id)">
              <span>×</span>
            </button>
          </div>
          <button v-if="isEditing" class="add-tag-btn p-p3" @click="$emit('open-tag-modal')">
            <i class="bi bi-plus-lg"></i>
            <span>新增標籤</span>
          </button>
          <span v-if="!isEditing && (!modelValue.tags || modelValue.tags.length === 0)" class="no-tag-hint p-p3">
            尚未設定標籤
          </span>
        </div>
      </div>

      <div class="row-description">
        <textarea v-if="isEditing" :value="modelValue.description"
          @input="updateField('description', $event.target.value)" class="desc-textarea p-p2"
          placeholder="請輸入詳細說明..."></textarea>
      </div>
    </div>
  </section>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

// 新增標籤樣式
.row-tags {
  padding: 0 16px;
  margin: 4px 0 8px 0;

  .tags-wrapper {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    align-items: center;
  }

  .tag-item {
    display: flex;
    align-items: center;
    background-color: $primary-color-100;
    color: $primary-color-800;
    padding: 4px 10px;
    border-radius: 100px;

    .tag-delete-btn {
      appearance: none;
      background: transparent !important;
      border: none;
      padding: 0;
      margin: 0 0 0 6px;
      outline: none;
      box-shadow: none;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 16px;
      height: 16px;
      color: #ff8e8e;
      cursor: pointer;
      font-size: 18px;
      font-weight: 200;
      line-height: 1;
      transition: color 0.2s, transform 0.2s;

      &:hover {
        color: red;
        background: transparent !important;
      }

      &:active {
        transform: scale(0.9);
      }
    }
  }

  .add-tag-btn {
    display: flex;
    align-items: center;
    gap: 4px;
    background: transparent;
    color: $primary-color-700;
    border: 1px dashed $primary-color-400;
    padding: 4px 12px;
    border-radius: 100px;
    cursor: pointer;

    &:hover {
      background: $primary-color-100;
    }
  }

  .no-tag-hint {
    color: $neutral-color-400;
    font-style: italic;
  }
}

.adapt-card-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 100%;

  @media (min-width: 768px) {
    width: 320px;
    align-self: stretch;
    justify-content: space-between;
  }
}

.back-original-btn {
  width: 100%;
  margin-top: 16px;

  @media (min-width: 768px) {
    width: 320px;
    margin-top: 0;
  }
}

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
    align-items: stretch;
  }
}

.info-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-width: 0;
}

.title-with-tag {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 4px;

  .adapt-tag {
    background: $primary-color-100;
    color: $primary-color-700;
    padding: 2px 8px;
    border-radius: 4px;
    border: 1px solid $primary-color-100;
    white-space: nowrap;
  }
}

.hidden-input {
  display: none;
}

// ✨ 改編輸入框樣式
.row-adapt-inputs {
  display: flex;
  flex-direction: column;
  gap: 12px;
  width: 100%;
  padding: 16px;
  background-color: $neutral-color-100;
  border-radius: 12px;
  border: 1px solid $neutral-color-100;

  .input-container.full-width {
    width: 100%;
    position: relative; // 為了右下角計數器

    .char-counter {
      position: absolute;
      right: 12px;
      bottom: 8px;
      color: $neutral-color-400;
      pointer-events: none;
      background: rgba(255, 255, 255, 0.7);
      padding: 0 4px;
      border-radius: 4px;
    }

    .form-input {
      width: 100%;
      border-color: $neutral-color-400;
      padding-right: 50px; // 避開計數器
    }

    .adaptation-textarea {
      min-height: 100px; // 拉高框體
      resize: none;
      overflow: hidden; // 不要卷軸
      display: block;
      font-family: inherit;
      line-height: 1.5;
    }
  }
}

.form-input {
  border-radius: 8px;
  padding: 8px 12px;
  border: 1px solid $neutral-color-400;
  outline: none;
  transition: all 0.2s;
  background-color: $neutral-color-white;

  &.is-success {
    border-color: $primary-color-400;
  }

  &:focus {
    border-color: $primary-color-700;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  }
}

.adapt-card-wrapper {
  position: relative;
  flex-shrink: 0;
  width: 100%;
  border-radius: 8px;
  overflow: hidden;
}

.cover-section {
  position: relative;
  border: 2px dashed $neutral-color-400;
  width: 100%;
  height: 220px;
  background: $neutral-color-100;
  border-radius: 8px;
  background-size: cover;
  background-position: center;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;

  &.has-image {
    border-style: solid;
  }

  .upload-placeholder {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;

    .placeholder-content {
      display: flex;
      flex-direction: column;
      align-items: center;
      color: $neutral-color-400;

      .plus-icon {
        font-size: 48px;
        line-height: 1;
        margin-bottom: 4px;
        display: block;
      }
    }
  }

  .change-hint {
    position: absolute;
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    background: rgba(0, 0, 0, 0.4);
    color: $neutral-color-white;
    opacity: 0;
    transition: opacity 0.2s;
    border-radius: 6px;
  }

  &:hover .change-hint {
    opacity: 1;
  }

  @media (min-width: 768px) {
    width: 320px;
  }
}

.row-title .title-input {
  width: 100%;
  border: none;
  outline: none;
  border-bottom: 1px solid $neutral-color-100;
  background: transparent;
}

.row-title .title-display {
  color: $primary-color-800;
  margin: 0;
}

.row-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 24px;
  align-items: center;
  color: $neutral-color-800;
  padding: 0 16px;
  margin-top: 4px;

  .meta-item {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .inline-input {
    border: none;
    border-bottom: 1px solid $neutral-color-400;
    width: 50px;
    text-align: center;
    outline: none;
    padding: 0 4px;
    background: transparent;

    // 專門給份量輸入框的微調（如果需要的話）
      &.servings-input {
        width: 40px;
      }
    }
    
    .unit {
      color: $neutral-color-800;
      // margin-left: 4px;
    }
    
    .value {
      color: $primary-color-800;
      font-weight: 500;
    
  }

  .stars-group {
    display: flex;
    gap: 6px;

    .star {
      font-size: 22px;
      color: $neutral-color-400;
      line-height: 1;
    }

    &.is-editing .star {
      cursor: pointer;

      &:hover {
        transform: scale(1.1);
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
  border-radius: 10px;

  &.editing-border {
    border: 1px dashed $primary-color-700;
    background: $neutral-color-white;
  }

  &.is-adapt {
    min-height: 140px;

    .desc-textarea {
      height: 110px;
    }
  }

  .desc-textarea {
    width: 100%;
    height: 70px;
    border: none;
    resize: none;
    outline: none;
    background: transparent;
  }
}
</style>