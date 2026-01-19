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

    <div class="zh-h3">烹飪流程指南</div>


  

  <div 
    v-for="(step, index) in steps" 
    :key="index" 
    class="step-card"
  >
    <div class="step-group">
      
      <div class="step-image">
          <img v-if="step.image" :src="step.image" @error="(e) => console.log('圖片載入失敗，路徑為:', step.image)" alt="烹飪步驟圖" />
          <div v-else class="placeholder-box">
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


.zh-h3 {
  padding-top: 20px; 
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
  align-items: flex-start; 
}


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

.placeholder-box {
  width: 100%;
  height: 100%;
  border-radius: 10px;
  border: 2px dashed $neutral-color-400; 
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
    margin-bottom: 0; 
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