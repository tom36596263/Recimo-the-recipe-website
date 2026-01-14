<script setup>
import { computed } from 'vue';

const props = defineProps({
info: {
    type: Object,
    required: true
}
});

const starArray = computed(() => {
const score = props.info.difficulty ?? 3;
return Array.from({ length: 5 }, (_, i) => (i < score ? '★' : '☆'));
});
</script>

<template>
<div class="image-box">
    <template v-if="props.info.image">
    <img :src="props.info.image" class="main-img" />
    </template>

    <div v-else class="placeholder-box">
    <div class="icon-image">
        <svg viewBox="0 0 24 24" width="80" height="80" fill="currentColor">
        <path d="M21 19V5c0-1.1-.9-2-2-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2zM8.5 13.5l2.5 3.01L14.5 12l4.5 6H5l3.5-4.5z" />
        </svg>
    </div>
    </div>

    <div class="badge-favorite">
<!-- <i-material-symbols-heart /> -->

        加收藏</div>
</div>



<div class="info-bar mt-4">
    <div class="info-left">
    <span class="info-item p-p2">🕒 製作時間：{{ props.info.time }}</span>
    <span class="info-item p-p2">⭐ 難易度：
        <span class="stars-text">{{ starArray.join('') }}</span>
    </span>
    </div>
    <div class="info-right">
    <BaseBtn title="開始烹飪" :width="180" />
    </div>
</div>

<article class="quote-box">
    <div class="recipe-description">
    <p class="p-p1">{{ props.info.description }}</p>
    </div>
</article>


</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.image-box {
    position: relative; // 必須開啟，收藏按鈕才找得到家
    border-radius: 10px;
    overflow: hidden;
    border: 2px solid $neutral-color-400; // 這是你的框
    // height: 350px;
    aspect-ratio: 16 / 9;
    width: 100%;
    margin-bottom: 20px;

.main-img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    object-position: center;// 確保裁切時是以中心點為主
    display: block;
    transition: transform 0.6s ease;
}
&:hover .main-img { transform: scale(1.05); }
}

.placeholder-box {
    width: 100%;
    height: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    background: $neutral-color-100;

&::before {
    content: '';
    position: absolute;
    top: 15px; left: 15px; right: 15px; bottom: 15px;
    // border: 2px dashed #adc6e8;
    border-radius: 12px;
}

.icon-image { color: $neutral-color-400; }
}

.badge-favorite {
    position: absolute;
    top: 20px;
    left: 20px;
    z-index: 10;
    background: rgba(255, 255, 255, 0.85);
    backdrop-filter: blur(4px);
    padding: 8px 20px;
    border-radius: 99px;
    font-size: 14px;
    cursor: pointer;
    border: 1px solid rgba(0,0,0,0.1);
}

.recipe-description {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 120px;
    border-bottom: $primary-color-400 1px solid;
    border-top: $primary-color-100 8px solid;
    margin: 20px 0;

p {
    padding: 20px;
    line-height: 2.1;
}
}

.info-bar {

    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 20px; // 增加元素間的間距

    // --- 手機版調整 (針對小螢幕) ---
    @media screen and (max-width: 810px) {
        flex-direction: column;    // 改為上下排列
        align-items: flex-start;  // 讓時間與難易度靠左對齊
        
        .info-right {
            width: 100%;          // 讓右側容器佔滿 100%
            
            // 強制讓 BaseBtn 組件佔滿整行
            :deep(.base-btn),     // 如果 BaseBtn 有這個 class
            button {
                width: 100% !important; 
                max-width: none !important; // 取消寬度限制
            }
        }
    }
}

.stars-text {
    color: #10B981;
    letter-spacing: 2px;
}

</style>