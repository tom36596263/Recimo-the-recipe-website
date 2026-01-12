<script setup>
import { computed } from 'vue';

const props = defineProps({
  // 文字內容
  text: {
    type: String,
    default: ''
  },
  // 模式：新增 'primary' 狀態
  variant: {
    type: String,
    default: 'label',
    // 1. 修改這裡：加入 'primary'
    validator: (value) => ['action', 'label', 'primary'].includes(value)
  },
  // 控制 Action 模式下是否顯示圖示
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

// 2. 修改這裡：判斷 class 的邏輯
const tagClass = computed(() => {
  // 如果是 label，回傳小標籤樣式
  if (props.variant === 'label') {
    return 'tag-label';
  }

  // 如果是 primary，回傳 'tag-action' (大標籤基底) 加上 'tag-primary' (變色)
  if (props.variant === 'primary') {
    return 'tag-action tag-primary';
  }

  // 預設 action 回傳大標籤樣式
  return 'tag-action';
});

const customStyle = computed(() => {
  if (!props.width) return {};
  const w = typeof props.width === 'number' ? `${props.width}px` : props.width;
  return { width: w };
});

const handleClick = (event) => {
  // 3. 修改這裡：只要不是 label (純展示用)，都允許點擊
  if (props.variant !== 'label') {
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
// 基礎設定 mixin 維持不變
@mixin tag-base($height, $font-size, $width, $padding-x, $radius: 4px) {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border: 1px solid $primary-color-100;
  border-radius: $radius;
  height: $height;
  font-size: $font-size;
  width: $width;
  padding: 0 $padding-x;
  background-color: $primary-color-100;
  color: $neutral-color-black;
  transition: all 0.2s ease;
  box-sizing: border-box;
}

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

  // Hover 效果 (針對還沒被選取的時候)
  &:hover {
    background-color: $primary-color-400;
    color: $neutral-color-white;
    border-color: $primary-color-400;
  }

  &:active {
    transform: scale(0.98);
  }

  .plus-sign {
    font-size: 14px; // 稍微調整一下大小比較好看
    margin-right: 4px;
  }
}

// ★ 新增：選取狀態 (Primary)
// 它是疊加在 .tag-action 之上的，所以會繼承高度 32px
.tag-primary {
  background-color: $primary-color-400; // 選取後的深色背景
  color: $neutral-color-white; // 白字
  border: 1px solid $primary-color-400; // 邊框同色，確保高度不會變

  // 選取狀態下，hover 維持原樣，不需要再變色
  &:hover {
    background-color: $primary-color-400;
    opacity: 0.9; // 稍微一點點變化提示即可
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
