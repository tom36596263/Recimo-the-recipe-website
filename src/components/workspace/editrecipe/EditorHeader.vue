<script setup>
import { computed, watch } from 'vue';
import AdaptRecipeCard from '@/components/workspace/modifyrecipe/AdaptRecipeCard.vue';
// 1. ✨ 修正：必須匯入 useRoute
import { useRouter, useRoute } from 'vue-router';

const router = useRouter();
const route = useRoute(); // 2. ✨ 修正：定義 route

const props = defineProps({
  modelValue: { type: Object, required: true },
  isEditing: { type: Boolean, default: false },
  isAdaptMode: { type: Boolean, default: false }
});

const emit = defineEmits(['update:modelValue']);

const goToOriginal = () => {
  // 1. 抓取 ID (優先從資料抓，沒有就從網址抓)
  const targetId =
    props.modelValue.recipe_id ||
    props.modelValue.id ||
    route.query.editId ||
    route.params.id;

  if (targetId) {
    // ✨ 修正：改為正確的工作區路徑
    console.log("✅ 準備跳轉至正確路徑:", `/workspace/recipe-detail/${targetId}`);
    router.push(`/workspace/recipe-detail/${targetId}`);
  } else {
    console.error("❌ 找不到 ID");
    alert("系統找不到原始食譜編號");
  }
};

// ...其餘 updateField, setDifficulty, computed 等維持不變
const updateField = (field, value) => {
  emit('update:modelValue', { ...props.modelValue, [field]: value });
};

const setDifficulty = (val) => {
  if (props.isEditing) updateField('difficulty', val);
};

const autoTotalTime = computed(() => {
  if (!props.modelValue.steps) return 0;
  return props.modelValue.steps.reduce((sum, step) => sum + (Number(step.time) || 0), 0);
});

const displayTime = computed(() => {
  const manualTime = Number(props.modelValue.totalTime);
  return manualTime > 0 ? manualTime : autoTotalTime.value;
});

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

const handleCoverUpload = (e) => {
  const file = e.target.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = (evt) => updateField('coverImg', evt.target.result);
  reader.readAsDataURL(file);
};

const adaptRecipeData = computed(() => {
  return {
    ...props.modelValue,
    title: props.modelValue.adapt_title || '',
    description: props.modelValue.adapt_description || ''
  };
});
</script>

<template>
  <section class="recipe-card-container">
    <input ref="fileInput" type="file" class="hidden-input" accept="image/*" @change="handleCoverUpload" />

    <template v-if="isAdaptMode">
      <div class="adapt-card-section">
        <div class="adapt-card-wrapper readonly-overlay">
          <AdaptRecipeCard :recipe="adaptRecipeData" />
        </div>
        <BaseBtn title="查看原始食譜詳情" variant="outline" :width="320" @click="goToOriginal"
          class="back-original-btn d-none-mobile" />
      </div>
    </template>

    <template v-else>
      <div class="cover-section" :class="{ 'has-image': modelValue.coverImg }"
        :style="{ backgroundImage: modelValue.coverImg ? `url(${modelValue.coverImg})` : '' }"
        @click="isEditing && $refs.fileInput.click()">
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
            <h2 class="title-display zh-h2-bold">{{ modelValue.original_title || modelValue.title || '原始食譜' }}</h2>
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
              @input="updateField('totalTime', $event.target.value)" :placeholder="autoTotalTime" />
            <span class="unit">分鐘</span>
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

      <div class="row-description" :class="{ 'editing-border': isEditing, 'is-adapt': isAdaptMode }">
        <textarea v-if="isEditing" :value="modelValue.description"
          @input="updateField('description', $event.target.value)" class="desc-textarea p-p2" placeholder="請輸入說明..."
          maxlength="200"></textarea>
        <p v-else class="desc-display p-p2">{{ modelValue.description || '暫無簡介' }}</p>
      </div>

      <BaseBtn v-if="isAdaptMode" title="查看原始食譜詳情" variant="outline" :width="100" @click="goToOriginal"
        class="back-original-btn d-only-mobile" />
    </div>
  </section>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.adapt-card-section {
  display: flex;
  flex-direction: column;
  gap: 16px;
  align-items: center;

  @media (min-width: 768px) {
    width: 320px;
  }
}

.back-original-btn {
  &.d-only-mobile {
    display: none;

    @media (max-width: 767px) {
      display: flex;
      width: 100% !important;
      margin-top: 24px;
    }
  }

  &.d-none-mobile {
    margin-top: 60px;

    @media (max-width: 767px) {
      display: none;
    }
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
  }
}

.info-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-width: 0;
}

/* 基礎樣式保持不變 */
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

  &.readonly-overlay {
    pointer-events: none;
    user-select: none;
    cursor: default;
  }
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
  gap: 30px;
  align-items: center;
  color: $neutral-color-800;
  padding: 0 16px;
  margin-top: 4px;

  .inline-input {
    border: none;
    border-bottom: 1px solid $neutral-color-400;
    width: 60px;
    text-align: center;
    outline: none;
  }

  .stars-group {
    display: flex;
    gap: 4px;

    .star {
      font-size: 20px;
      color: $neutral-color-400;
    }

    &.is-editing .star {
      cursor: pointer;
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