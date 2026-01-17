<script setup>
import { computed } from 'vue'


const model = defineModel({ type: String, default: '' });

const props = defineProps({
    label: String,
    type: {
        type: String,
        default: 'text'
    },
    placeholder: String,
    // 狀態控制：'error', 'success', 或空值
    status: {
        type: String,
        default: ''
    },
    message: String, // 下方的提示文字
    maxWidth: {
        type: [String, Number],
        default: ''
    }
});

// 計算容器寬度
const containerStyle = computed(() => {
    if (!props.maxWidth) return {};
    const w = typeof props.maxWidth === 'number' ? `${props.maxWidth}px` : props.maxWidth;
    return { maxWidth: w };
});

// 根據 status 綁定 SCSS 中的類別
const inputClasses = computed(() => ({
    'form-input': true,
    'is-error': props.status === 'error',
    'is-success': props.status === 'success'
}));

const emit = defineEmits(['blur', 'enter-press'])

</script>

<template>
    <div class="base-input-container" :class="{
        'is-error': props.status === 'error',
        'is-success': props.status === 'success'
    }" :style="containerStyle">
        <div class="label-bar" v-if="label || $slots['label-right']">
            <label v-if="label" class="form-label">{{ label }}</label>
            <slot name="label-right"></slot>
        </div>

        <div class="input-field-wrapper">
            <input v-model="model" :type="type" :class="inputClasses" :placeholder="placeholder" @blur="emit('blur')"
                @keyup.enter.stop="$emit('enter-press')" />

            <div class="suffix-icon">
                <slot name="suffix"></slot>
            </div>
        </div>

        <div class="input-message" :class="{ 'show-message': message }">
            {{ message }}
        </div>
    </div>
</template>

<style lang="scss" scoped>
@import "@/assets/scss/abstracts/_mixins.scss";
@import "@/assets/scss/components-scss/_input.scss";

// ==========================================
// 表單的input程式碼上下層級不同無法用mixins.scss預設
// ==========================================
.base-input-container {
    width: 100%;

    .form-input {
        $border-color: $neutral-color-400; // 一開始黑框

    }

    .input-message {
        display: block;
    }

    &.is-error {

        // 變紅
        .form-input {
            border-color: $secondary-color-danger-700;
        }

        .input-message {
            visibility: visible;
            color: $secondary-color-danger-700;
        }
    }

    &.is-success {

        // 變綠
        .form-input {
            border-color: $secondary-color-success-700;
        }

        .input-message {
            visibility: visible;
            color: $secondary-color-success-700;
        }
    }
}

// ==========================================
// 如果有icon
// ==========================================
.input-field-wrapper {
    position: relative;
}

.suffix-icon {
    position: absolute;
    right: 12px;
    top: 50%;
    transform: translateY(-50%);
}
</style>