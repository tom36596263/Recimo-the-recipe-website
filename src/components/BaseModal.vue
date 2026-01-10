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
  <div
    class="modal-overlay"
    :class="{ active: isOpen }"
    @click.self="closeModal"
  >
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

<style lang="scss" scoped></style>
