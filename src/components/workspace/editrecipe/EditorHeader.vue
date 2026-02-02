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

const updateField = (field, value) => {
  // 1. 產生一個乾淨的拷貝
  const nextData = { ...props.modelValue };

  // 2. 執行欄位更新
  nextData[field] = value;

  // 3. ✨ 核心修正：實名制隔離
  if (field === 'adapt_description') {
    nextData.description = props.modelValue.description;
    nextData.clean_description = props.modelValue.description;
  }

  if (field === 'description') {
    nextData.clean_description = value;
  }

  emit('update:modelValue', nextData);
};

const removeTag = (tagId) => {
  const updatedTags = props.modelValue.tags.filter(t => t.tag_id !== tagId);
  updateField('tags', updatedTags);
};

const setDifficulty = (val) => {
  if (props.isEditing) updateField('difficulty', val);
};

// --- EditorHeader.vue ---

// 1. 修改自動計算屬性 (確保它是即時的)
const autoTotalTime = computed(() => {
  if (!props.modelValue.steps || props.modelValue.steps.length === 0) return 0;
  return props.modelValue.steps.reduce((sum, step) => sum + (Number(step.time) || 0), 0);
});

// EditorHeader.vue

const displayTime = computed(() => {
  // 如果自動加總有值，就優先顯示自動加總
  // 這樣能確保即使資料庫裡有舊的、錯誤的時間數值，也會被目前的步驟時間覆蓋
  if (autoTotalTime.value > 0) {
    return autoTotalTime.value;
  }
  // 如果步驟都沒填時間，才看手動輸入的值
  return Number(props.modelValue.totalTime) || 0;
});

// EditorHeader.vue 內的 adaptRecipeData
const adaptRecipeData = computed(() => {1
  const m = props.modelValue;

  return {
    ...m,
    title: m.adapt_title || m.title || '未命名改編',
    summary: m.adapt_description || '',
    description: m.adapt_description || '',
    recipe_descreption: m.description || '暫無詳細說明',
    recipe_id: m.parent_recipe_id || m.recipe_id,
    coverImg: m.adaptation_image_url || m.coverImg,
    adaptation_title: m.adapt_title,
    adaptation_note: m.adapt_description
  };
});

const handleCoverUpload = (e) => {
  const file = e.target.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = (evt) => updateField('coverImg', evt.target.result);
  reader.readAsDataURL(file);
};
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
            class="form-input p-p1" :class="{ 'is-success': modelValue.adapt_title }" placeholder="請輸入改編版本標題 (例：低脂版)" />
        </div>
        <div class="input-container full-width">
          <input :value="modelValue.adapt_description" @input="updateField('adapt_description', $event.target.value)"
            class="form-input p-p1" :class="{ 'is-success': modelValue.adapt_description }" placeholder="說明改編了什麼？" />
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
      </div>

      <div class="row-tags">
        <div class="tags-wrapper">
          <div class="tag-item" v-for="tag in modelValue.tags" :key="tag.tag_id">
            <span class="tag-text p-p3">#  {{ tag.tag_name }}</span>
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

      <div class="row-description" :class="{ 'editing-border': isEditing, 'is-adapt': isAdaptMode }">
        <textarea v-if="isEditing" :value="modelValue.description"
          @input="updateField('description', $event.target.value)" class="desc-textarea p-p2" placeholder="請輸入說明..."
          maxlength="200"></textarea>
        <p v-else class="desc-display p-p2">{{ modelValue.description || '暫無簡介' }}</p>
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

        /* 1. 徹底消除按鈕預設樣式 */
        appearance: none;
        background: transparent !important; // 強制透明，殺掉那個灰色圓形
        border: none;
        padding: 0;
        margin: 0 0 0 6px;
        outline: none;
        box-shadow: none;
    
        /* 2. 完美置中佈局 */
        display: inline-flex;
        align-items: center; // 垂直置中
        justify-content: center; // 水平置中
        width: 16px;
        height: 16px;
    
        /* 3. 叉叉樣式 */
        color: #ff8e8e;
        cursor: pointer;
        font-size: 18px; // 控制叉叉大小
        font-weight: 200; // 讓叉叉細一點，更簡約
        line-height: 1; // 避免行高撐開導致不置中
    
        transition: color 0.2s, transform 0.2s;
    
        span {
          display: block;
          line-height: 1;
          // 有時候乘號字體偏下，可以用這行微調 (視你的字體而定)
          // transform: translateY(1px);
        }
    
        &:hover {
          color: red;
          background: transparent !important;
          // transform: scale(1.2); // 滑過稍微放大，增加回饋感
        }
    
        &:active {
          transform: scale(0.9); // 點擊縮小感
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
    align-self: stretch; // 確保容器高度與右側 info-section 同步
    justify-content: space-between; // 標籤變多時，自動把按鈕推向底部
  }
}

.back-original-btn {
  width: 100%;
  margin-top: 16px;

  @media (min-width: 768px) {
    width: 320px;
    margin-top: 0; // 改由 space-between 控制對齊
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
    align-items: stretch; // 關鍵：確保左右兩邊等高
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

    .form-input {
      width: 100%;
      border-color: $neutral-color-400;
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
      justify-content: center;
      text-align: center;
      color: $neutral-color-400;

      .plus-icon {
        font-size: 48px;
        line-height: 1;
        margin-bottom: 4px;
        display: block;
      }

      .label {
        margin: 0;
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

/* ✨ 關鍵修改位置 */
.row-meta {
  display: flex;
  flex-wrap: wrap; // 防止手機版塞不下
  gap: 24px;
  align-items: center;
  color: $neutral-color-800;
  padding: 0 16px;
  margin-top: 4px;

  .meta-item {
    display: flex;
    align-items: center;
    gap: 8px; // 文字與內容的間距
  }

  .inline-input {
    border: none;
    border-bottom: 1px solid $neutral-color-400;
    width: 50px;
    text-align: center;
    outline: none;
    padding: 0 4px;
  }

  .stars-group {
    display: flex;
    gap: 6px; // 星號之間的間距

    .star {
      font-size: 22px; // 稍微放大的星星更好按
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