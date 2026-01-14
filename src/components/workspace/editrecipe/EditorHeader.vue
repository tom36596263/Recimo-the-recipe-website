<script setup>
import { computed } from 'vue';

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

const handleCoverUpload = (e) => {
  const file = e.target.files[0];
  if (!file) return;

  const reader = new FileReader();
  reader.onload = (evt) => updateField('coverImg', evt.target.result);
  reader.readAsDataURL(file);
};

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
  <section class="header-card">

    <!-- 封面 -->
    <div
      class="cover-container"
      :style="{ backgroundImage: modelValue.coverImg ? `url(${modelValue.coverImg})` : '' }"
      @click="isEditing && $refs.fileInput.click()"
    >
      <input
        ref="fileInput"
        type="file"
        class="hidden-input"
        @change="handleCoverUpload"
      />

      <div v-if="!modelValue.coverImg" class="placeholder">
        <template v-if="isEditing">
          <p class="p-p1">+</p>
          <p class="p-p1">上傳封面</p>
        </template>
        <i v-else class="fa-solid fa-image fa-3x"></i>
      </div>
    </div>

    <!-- 右側資訊 -->
    <div class="info-container">

      <!-- 標題 -->
      <div class="title-area">
        <input
          v-if="isEditing"
          v-model="modelValue.title"
          class="title-input zh-h3-bold"
          placeholder="食譜名稱"
        />

        <div v-else class="title-display zh-h3-bold">
          {{ modelValue.title || '未命名食譜' }}
        </div>
      </div>

      <!-- 統計 -->
      <div class="stats-bar">
        <div class="stat-item">
          <p class="label p-p3">總烹飪時間</p>
          <div class="value time">
            <span class="num">{{ displayTime }}</span> 分鐘
          </div>
        </div>

        <div class="stat-item">
          <p class="label p-p3">難易度</p>
          <div class="stars">
            <span
              v-for="n in 5"
              :key="n"
              class="star"
              :class="{ active: n <= modelValue.difficulty }"
              @click="setDifficulty(n)"
            >
              ★
            </span>
          </div>
        </div>
      </div>

      <!-- 簡介 -->
      <div class="desc-area">
        <textarea
          v-if="isEditing"
          v-model="modelValue.description"
          class="desc-input p-p2"
          placeholder="輸入食譜簡介..."
        ></textarea>

        <p v-else class="desc-display p-p2">
          {{ modelValue.description || '暫無簡介' }}
        </p>
      </div>

    </div>
  </section>
</template>

<style lang="scss">

.header-card {
  background: $neutral-color-white;
  border-radius: 10px;
  padding: 30px;
  border: 1.5px solid $primary-color-700;
  display: flex;
  flex-direction: column;
  gap: 30px;

  @media (min-width: 768px) {
    flex-direction: row;
  }
}

.cover-container {
  width: 100%;
  height: 200px;
  background: $neutral-color-100;
  border: 2px dashed $neutral-color-400;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  background-size: cover;
  background-position: center;

  @media (min-width: 768px) {
    width: 260px;
    height: 210px;
    flex-shrink: 0;
  }

  .hidden-input {
    display: none;
  }

  .placeholder {
    text-align: center;
    color: $neutral-color-400;
  }
}

.info-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.title-input {
  width: 100%;
  border: none;
  outline: none;
  background: transparent;
  font: inherit;
}

.stats-bar {
  display: flex;
  gap: 40px;
  padding: 15px 0;
  border-top: 2px solid $neutral-color-100;
  border-bottom: 2px solid $neutral-color-100;
}

.stat-item {
  .label {
    color: $neutral-color-400;
    margin-bottom: 5px;
    display: block;
  }

  .value.time {
    color: $primary-color-700;
    

    .num {
      font-size: 22px;
      font-weight: 600;

    }
  }

  .stars .star {
    font-size: 20px;
    color: $neutral-color-400;
    cursor: pointer;

    &.active {
      color: $secondary-color-warning-700;
    }
  }
}

.desc-area {
  .desc-input,
  .desc-display {
    width: 100%;
    border: none;
    outline: none;
    background: transparent;
    line-height: 1.6;
    font: inherit;
  }

  .desc-input {
    height: 70px;
    resize: none;
  }
}
</style>
