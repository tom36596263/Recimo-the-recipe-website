<script setup>
import { defineProps, defineEmits } from 'vue';

// 定義外部傳入的參數 (Props)
const props = defineProps({
  // 控制開關
  isOpen: {
    type: Boolean,
    default: false
  },
  // 彈窗類型: 'danger', 'info', 'success' (對應 SCSS 的 class)
  type: {
    type: String,
    default: 'info',
    validator: (value) => ['danger', 'info', 'success'].includes(value)
  },
  // FontAwesome 圖示 class
  iconClass: {
    type: String,
    default: 'fa-solid fa-circle-info'
  },
  // 標題文字
  title: {
    type: String,
    default: ''
  },
  // 描述文字 (選填)
  description: {
    type: String,
    default: ''
  }
});

// 定義發出的事件
const emit = defineEmits(['close']);

// 關閉彈窗的方法
const closeModal = () => {
  emit('close');
};
</script>

<template>
  <div class="modal-overlay" :class="{ active: isOpen }" @click.self="closeModal">
    <div class="modal-card" :class="type">
      <button class="close-btn" @click="closeModal">
        <i class="fa-solid fa-xmark"></i>
      </button>

      <div class="icon-wrapper">
        <i :class="iconClass"></i>
      </div>

      <div class="text-content">
        <div class="zh-h4" v-if="title">{{ title }}</div>
        <p class="p-p3" v-if="description">{{ description }}</p>

        <slot name="content"></slot>
      </div>

      <div class="btn-group" v-if="$slots.actions">
        <slot name="actions"></slot>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
:deep(.text-content .zh-h4) {
  white-space: pre-line;
  /* 允許正常換行 */
  word-break: break-all;
  /* 遇到長英文或標點符號也會強制斷行 */
  text-align: center;
  /* 置中對齊比較美觀 */
  line-height: 1.4;
  /* 設定行高，折行後才不會太擠 */
}

:deep(.icon-wrapper) {
  display: flex;
  align-items: center;
  justify-content: center;

  /* 防止被 Flexbox 壓縮 */
  flex-shrink: 0;

  i {
    /* 確保圖示本身大小正確 */
    display: block;
  }
}

.modal-card.danger:not(:has(.btn-group)) {
  height: auto;
  min-height: 203px;
}
</style>
