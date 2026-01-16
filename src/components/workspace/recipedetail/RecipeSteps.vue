<script setup>
const props = defineProps({
  steps: {
    type: Array,
    required: true,
    default: () => []
  }
});
</script>

<template>
<div class="step-container">
  <!-- <div class="step-header-content"> -->
    <div class="zh-h3">烹飪流程指南</div>

  <!-- <div class="info-right">
      <BaseBtn title="開始烹飪" class="cook-btn" />
    </div> -->
  <!-- </div> -->
  

  <div 
    v-for="(step, index) in steps" 
    :key="index" 
    class="step-card"
  >
    <div class="step-group">
      
      <div class="step-image">
        <img 
          v-if="step.image && step.image !== ''"
          :src="step.image" 
          alt="烹飪步驟圖" 
        />
        <div v-else class="placeholder-box">
          <div class="icon-image">
            <svg viewBox="0 0 24 24" width="40" height="40" fill="currentColor">
              <path d="M21 19V5c0-1.1-.9-2-2-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2zM8.5 13.5l2.5 3.01L14.5 12l4.5 6H5l3.5-4.5z"/>
            </svg>
          </div>
        </div>
      </div>

      <div class="step-content">
        <div class="step-title-group">
          <div class="step-tag">
            <span class="step-text">Step</span>
            <span class="index">{{ index + 1 }}</span>
          </div>
          <div class="zh-h5">{{ step.title }}</div>
        </div>
        <p class="p-p2">{{ step.content }}</p>
      </div>

    </div>
  </div>
</div>
</template>

<style lang="scss" scoped>
@import "@/assets/scss/abstracts/_color.scss";

// .step-header-content {
//   display: flex;
//   justify-content: space-between;
//   align-items: center;
// }
.zh-h3 {
  padding-top: 20px; // 稍微縮減頂部間距
  padding-bottom: 20px;
}

.step-card {
  margin-bottom: 24px;
}

.step-group {
  border: 1px solid $primary-color-700;
  padding: 20px;
  border-radius: 12px;
  display: flex;
  gap: 20px;
  height: auto;
  align-items: flex-start; // 讓內容對齊頂部
}

/* 圖片與佔位框共同樣式 */
.step-image {
  width: 140px;
  height: 140px;
  flex-shrink: 0;

  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    border-radius: 10px;
  }
}

/* 虛線佔位框 */
.placeholder-box {
  width: 100%;
  height: 100%;
  border-radius: 10px;
  border: 2px dashed $neutral-color-400; // 核心：虛線邊框
  background-color: $neutral-color-100;
  display: flex;
  justify-content: center;
  align-items: center;
  color: $neutral-color-400;

  .icon-image {
    opacity: 0.4;
  }
}

.step-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  
  p {
    margin-top: 12px;
    line-height: 1.8;
    margin-bottom: 0; // 移除底部預設間距縮減高度
  }
}

.step-title-group {
  display: flex;
  align-items: center;
  gap: 12px;
}

.step-tag {
  background-color: $primary-color-100;
  color: $primary-color-700;
  border-radius: 10px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  width: 48px;
  height: 48px;
  flex-shrink: 0;

  .step-text {
    font-size: 10px;
    line-height: 1;
    text-transform: uppercase;
  }
  .index {
    font-weight: bold;
    line-height: 1.1;
  }
}
</style>