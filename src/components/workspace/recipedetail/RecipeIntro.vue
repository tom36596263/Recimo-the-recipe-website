<script setup>
import { computed } from 'vue';

const props = defineProps({ 
    info: {
        type: Object,
        required: true
    }
    });

    // 產生星星陣列，用於區分實心與空心
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
        <i-material-symbols-favorite-outline-rounded />
        <div class="favorite-text">加收藏</div>
        </div>
    </div>

    <div class="info-bar mt-4">
        <div class="info-left">
        <span class="info-item p-p2">
            <i-material-symbols-alarm-outline-rounded class="info-icon" />
            <span class="label">製作時間：</span>
            <span class="value">{{ props.info.time }}</span>
        </span>
        
        <span class="divider">|</span>

        <span class="info-item p-p2">
            <span class="label">難易度：</span>
            <span class="stars-box">
            <span 
                v-for="(star, index) in starArray" 
                :key="index" 
                :class="['star', { 'active': star === '★' }]"
            >{{ star }}</span>
            </span>
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

    // --- 圖片容器 ---
    .image-box {
    position: relative; 
    border-radius: 10px;
    overflow: hidden;
    border: 2px solid $neutral-color-400; // 使用中性色 400
    aspect-ratio: 16 / 9;
    width: 100%;
    margin-bottom: 20px;

    .main-img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        object-position: center;
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
    background: $neutral-color-100; // 使用中性色 100
    .icon-image { color: $neutral-color-400; }
    }

    // --- 收藏按鈕 ---
    .badge-favorite {
    color: $neutral-color-white; // 使用中性色 white
    position: absolute;
    top: 20px;
    left: 20px;
    z-index: 10;
    letter-spacing: 5px;
    cursor: pointer;
    display: flex;
    align-items: center;      
    gap: 5px;
    transition: all 0.3s ease;
    &:hover {
        color: $primary-color-700; // 使用主色 700
        transform: scale(1.05);
    }
    }

    // --- 資訊列 ---
    .info-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 20px;

    .info-left {
        display: flex;
        align-items: center;
        gap: 12px;

        .info-item {
        display: flex;
        align-items: center;
        
        .info-icon {
            font-size: 1.4em;
            margin-right: 4px;
            color: $primary-color-700; 
        }

        .label {
            color: $neutral-color-700; 
        }

        .value {
            color: $neutral-color-black; // 使用中性色 black
            font-weight: 500;
        }
        }

        .divider {
        color: $neutral-color-400; // 使用中性色 400
        margin: 0 4px;
        }
    }

    @media screen and (max-width: 810px) {
        flex-direction: column;
        align-items: flex-start;
        .info-left { width: 100%; flex-wrap: wrap; }
        .info-right { width: 100%; :deep(.base-btn), button { width: 100% !important; } }
    }
    }

    // --- 星星樣式 ---
    .stars-box {
    display: inline-flex;
    align-items: center;
    gap: 2px;
    margin-left: 4px;

    .star {
        font-size: 22px;
        line-height: 1;
        color: $secondary-color-warning-700;
        }
    }

    // --- 簡介區塊 ---
    .recipe-description {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 120px;
    border-bottom: $primary-color-400 1px solid; // 使用主色 400
    border-top: $primary-color-100 8px solid;   // 使用主色 100
    margin: 20px 0;

    p {
        padding: 20px;
        line-height: 2.1;
        color: $neutral-color-800; // 使用中性色 800
    }
}
</style>