<script setup>
import { computed } from 'vue';
import { useRouter } from 'vue-router'
const router = useRouter();

const props = defineProps({
    title: {
        type: String,
        default: '預設文字'
    },
  // 樣式：'solid' (實心) 或 'outline' (描邊)
    variant: {
        type: String,
        default: 'solid',
        validator: (value) => ['solid', 'outline'].includes(value)
    },
    // 高度尺寸：30, 40, 50
    height: {
        type: [String, Number],
        default: 40
    },
    // 是否禁用
    disabled: {
        type: Boolean,
        default: false
    },
    // 按鈕類型 (submit, button 等)
    type: {
        type: String,
        default: 'button'
    },
    width: {
        type: [String, Number],
        default: 'auto'
    },
    href: {
        type: String,
        default: '#'
    }
});

const emit = defineEmits(['click']);

// 動態計算 Class
const buttonClasses = computed(() => {
    return [
        'btn',
        `btn-${props.variant}`,
        `h-${props.height}`,
        { 'btn-disabled': props.disabled }
    ];
});

const handleClick = (event) => {
    if(props.disabled)return;
    if (props.href && props.href.startsWith('/')) {
        event.preventDefault();
        router.push(props.href); 
    } else {
        emit('click', event);
    }
};
const buttonStyle = computed(() => {
    const w = typeof props.width === 'number' ? `${props.width}px` : props.width;
    return {
        '--btn-width' : w
    };
});
</script>

<template>
    <component 
        :is="href && href !== '#' ? 'a' : 'button'"
        :href="href && href !== '#' ? href : undefined"
        :type="!href || href === '#' ? type : undefined"
        :class="buttonClasses"
        :style="buttonStyle" 
        :disabled="disabled"
        @click="handleClick"
    >
        {{ title }}
    </component>
</template>

<style lang="scss" scoped>
// 這裡貼上你提供的 SCSS 程式碼
.btn {
    display: inline-flex; 
    align-items: center;
    justify-content: center;
    width: var(--btn-width);
    padding: 0 24px;
    border-radius: $radius-base;
    border: 1px solid transparent;
    white-space: nowrap;
    cursor: pointer;
    text-decoration: none;
    transition: all 0.3s ease;

  // Sizes
    &.h-30 { height: 30px; font-size: 14px; }
    &.h-40 { height: 40px; font-size: 16px; }
    &.h-50 { height: 50px; font-size: 20px; }

  // Solid
    &.btn-solid {
        background-color: $primary-color-700;
        color: $neutral-color-white;
        border-color: $primary-color-700;
        &:hover:not(:disabled) {
        background-color: $accent-color-700;
        border-color: $accent-color-700;
        }
    }

  // Outline
    &.btn-outline {
        background-color: transparent;
        border-color: $primary-color-700;
        color: $primary-color-700;
        &:hover:not(:disabled) {
        border-color: $accent-color-700;
        color: $accent-color-700;
        background-color: $accent-color-100;
        }
    }

  // Disabled (整合進入原本的邏輯)
    &:disabled, &.btn-disabled {
        cursor: not-allowed;
        &.btn-outline, &.btn-solid {
        border-color: $neutral-color-400;
        color: $neutral-color-100;
        background-color: $neutral-color-400;
        }
    }
}
</style>