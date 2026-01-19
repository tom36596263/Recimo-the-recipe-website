<script setup>
import { ref, onMounted } from 'vue';

const stage = ref(1);
const isExpanded = ref(false);
const emit = defineEmits(['enter']);

onMounted(() => {
  // 2秒後從小標題切換到 Logo
    setTimeout(() => {
        stage.value = 2;
    }, 2000);
});

const handleStart = () => {
    if (stage.value >= 2) {
        isExpanded.value = true;
        // 等待圓形擴散動畫結束後，通知父組件進入主網頁
        setTimeout(() => {
        emit('enter');
        }, 1500);
    }
};
</script>
<template>
    <div :class="['loading-container', { 'is-expanded': isExpanded }]" @click="handleStart">
        <div class="expand-circle"></div>

        <div class="content-wrapper" v-if="!isExpanded">
        <transition name="fade">
            <p v-if="stage === 1" class="slogan">寫下關於味道的無限可能</p>
        </transition>

        <transition name="fade">
            <div v-if="stage >= 2" class="logo-box">
            <img :src="$parsePublicFile('img/site/Recimo-logo-black.svg')" alt="logo" class="main-logo">
            <p class="hint-text">Click to enter</p>
            </div>
        </transition>
        </div>
    </div>
</template>


<style lang="scss" scoped>
    .loading-container {
        position: fixed;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        background-color: #ffffff; // 初始背景色
        display: flex;
        justify-content: center;
        align-items: center;
        cursor: pointer;
        overflow: hidden;
        z-index: 9999;
        transition: opacity 0.5s ease; // 增加容器本身的淡出

        &.is-expanded {
            // 當展開完成後，讓整個 container 變透明，避免擋住下方的內容
            pointer-events: none; // 讓點擊穿透，防止動畫期間重複點擊
            
            .expand-circle {
            transform: translate(-50%, -50%) scale(500); // 確保大到完全覆蓋
            transition: transform 1.2s cubic-bezier(0.7, 0, 0.3, 1);
            }

            .content-wrapper {
            opacity: 0;
            filter: blur(10px); // 增加一點模糊感會更高級
            transition: all 0.5s ease;
            }
        }

        .content-wrapper {
            text-align: center;
            z-index: 2;
        }

        .slogan {
            font-size: 1.2rem;
            letter-spacing: 0.5em;
            color: #333;
        }

        .main-logo {
            width: 250px; // 根據你的圖片調整大小
            height: auto;
            display: block;
            margin-bottom: 20px;
        }

        .hint-text {
            font-size: 0.8rem;
            color: #999;
            letter-spacing: 2px;
            animation: pulse 2s infinite;
        }

        // 圓形展開元素
        .expand-circle {
            position: absolute;
            top: 50%;
            left: 50%;
            width: 10px;
            height: 10px;
            background-color: $primary-color-700; // 展開後的顏色，可根據品牌色調整
            border-radius: 50%;
            transform: translate(-50%, -50%) scale(0);
            transition: transform 0.8s cubic-bezier(0.4, 0, 0.2, 1);
            z-index: 1;
        }

        // 當觸發展開時
        &.is-expanded {
            .expand-circle {
            transform: translate(-50%, -50%) scale(300); // 大到覆蓋全螢幕
            }
            .content-wrapper {
            opacity: 0;
            transition: opacity 0.3s ease;
            }
        }
    }

    // Vue 內建過渡動畫
    .fade-enter-active, .fade-leave-active {
        transition: opacity 1s ease;
    }
    .fade-enter-from, .fade-leave-to {
        opacity: 0;
    }

    // 提示文字呼吸效果
    @keyframes pulse {
        0%, 100% { opacity: 0.4; }
        50% { opacity: 1; }
    }
</style>