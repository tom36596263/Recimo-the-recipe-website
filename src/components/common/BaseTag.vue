<script setup>
import { computed } from 'vue';

const props = defineProps({
  // 文字內容
  text: {
    type: String,
    default: ''
  },
  // 模式：'action' 或 'label'
  variant: {
    type: String,
    default: 'label',
    validator: (value) => ['action', 'label'].includes(value)
  },
  // ★ 新增：控制 Action 模式下是否顯示圖示 (預設顯示)
  showIcon: {
    type: Boolean,
    default: true
  },
  // 寬度
  width: {
    type: [String, Number],
    default: 'auto'
  }
});

const emit = defineEmits(['click']);

const tagClass = computed(() => {
  return props.variant === 'action' ? 'tag-action' : 'tag-label';
});

const customStyle = computed(() => {
  if (!props.width) return {};
  const w = typeof props.width === 'number' ? `${props.width}px` : props.width;
  return { width: w };
});

const handleClick = (event) => {
  // 只有 action 模式才允許點擊觸發
  if (props.variant === 'action') {
    emit('click', event);
  }
};
</script>

<template>
  <div
    class="base-tag"
    :class="tagClass"
    :style="customStyle"
    @click="handleClick"
  >
    <i
      v-if="variant === 'action' && showIcon"
      class="fa-solid fa-plus plus-sign"
    ></i>

    <span class="tag-content">
      <template v-if="text">{{ text }}</template>
      <slot v-else></slot>
    </span>
  </div>
</template>

<style lang="scss" scoped>
@mixin tag-base($height, $font-size, $width, $padding-x, $radius: 4px) {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border: 1px solid $primary-color-100; // 範例邊框
  border-radius: $radius;
  height: $height;
  font-size: $font-size;
  width: $width;
  padding: 0 $padding-x;
  background-color: $primary-color-100;
  // 範例背景
  color: $neutral-color-black;
  transition: all 0.2s ease;
  box-sizing: border-box;
}
// -----------------------------------------------------------------------

// 1. 大型互動標籤 (高度 32px)
.tag-action {
  @include tag-base(
    $height: 32px,
    $font-size: 16px,
    $width: 100%,
    $padding-x: 8px
  );

  cursor: pointer;
  user-select: none;

  // Hover 效果
  &:hover {
    background-color: $primary-color-400;
    color: $neutral-color-white;
    border-color: $primary-color-400; // 通常 hover 會連邊框一起變
  }

  // 按壓效果
  &:active {
    transform: scale(0.98);
  }

  // 加號微調
  .plus-sign {
    font-weight: 300;
    font-size: 25px;
    font-weight: 500;
    margin-right: -2px;
    margin-left: -8px;
    transform: translateY(-1.5px); // 微調 icon 垂直置中
  }
}

// 2. 小型展示標籤 (高度 21px)
.tag-label {
  @include tag-base(
    $height: 21px,
    $font-size: 14px,
    $width: auto,
    $padding-x: 8px,
    $radius: 4px
  );

  cursor: default;
}
</style>
