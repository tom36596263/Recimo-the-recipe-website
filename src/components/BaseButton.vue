<script setup>
import { computed } from 'vue';

const props = defineProps({
    title: {
        type: String,
        default: '預設文字'
    },
    // type 用於切換樣式，例如 'default' 或 'white'
    type: {
        type: String,
        default: 'default' 
    },
    // 增加 href 或 to，讓元件更像真正的按鈕/連結
    href: {
        type: String,
        default: '#'
    }
});

// 根據 type 自動判斷樣式 class
const buttonClass = computed(() => {
    return {
        'btn-recipe': true,
        'mode-white': props.type === 'white',
        // 如果未來有其他樣式可以繼續擴充
    };
});
</script>

<template>
    <div :class="buttonClass">
        <a :href="href">{{ title }}</a>
        <div class="icon-circle">
        <i class="fa-solid fa-arrow-right"></i>
        </div>
    </div>
</template>

<style lang="scss" scoped>
// 這裡放你原本的 SCSS 內容
.btn-recipe {
    display: flex;
    align-items: center;
    justify-content: center;
    width: $btn-width-full; // 確保你的全域變數已匯入
    height: 76px;
    font-size: 20px;
    text-decoration: none;
    letter-spacing: 1px;
    cursor: pointer;
    transition: all 0.3s ease;

    a {
        z-index: 1;
        color: inherit; // 讓 a 繼承外層顏色
        text-decoration: none;
    }

    .icon-circle {
        width: 76px;
        height: 76px;
        border-radius: $radius-pill;
        margin-left: -18px;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: color 0.3s ease;

        i {
        transition: transform 0.3s ease;
        }
    }

    &:hover {
        .icon-circle i {
        transform: translateX(5px);
        }
    }

    // --- 樣式 A: 預設綠色 ---
    &:not(.mode-white) {
        color: $primary-color-700;
        .icon-circle {
        background-color: $neutral-color-white;
        color: $primary-color-700;
        }
        &:hover {
        color: $accent-color-700;
        .icon-circle { color: $accent-color-700; }
        }
    }

    // --- 樣式 B: 白色半透明 (Mode White) ---
    &.mode-white {
        color: $neutral-color-white;
        .icon-circle {
        background-color: rgba($primary-color-400, 0.5);
        color: $neutral-color-white;
        }
        &:hover {
        color: $accent-color-700;
        .icon-circle { color: $accent-color-700; }
        }
    }
}
</style>