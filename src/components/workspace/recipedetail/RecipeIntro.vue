<script setup>
import { computed } from 'vue';

const props = defineProps({
    info: {
        type: Object,
        required: true
    }
});

// 產生星星陣列
const starArray = computed(() => {
    const score = props.info.difficulty ?? 3;
    return Array.from({ length: 5 }, (_, i) => (i < score ? '★' : '☆'));
});
</script>

<template>
    <div class="recipe-intro-wrapper">
        <div class="image-box">
            <template v-if="props.info.image">
                <img :src="props.info.image" class="main-img" />
            </template>
            <div v-else class="placeholder-box">
                <div class="icon-image">
                    <svg viewBox="0 0 24 24" width="80" height="80" fill="currentColor">
                        <path
                            d="M21 19V5c0-1.1-.9-2-2-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2zM8.5 13.5l2.5 3.01L14.5 12l4.5 6H5l3.5-4.5z" />
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
                <div class="info-item">
                    <div class="label-row">
                        <i-material-symbols-alarm-outline-rounded class="info-icon" />
                        <span class="label p-p3">製作時間</span>
                    </div>
                    <span class="value p-p1">{{ props.info.time }}</span>
                </div>

                <span class="divider"></span>

                <div class="info-item">
                    <div class="label-row">
                        <span class="label p-p3">難易度</span>
                    </div>
                    <div class="stars-box">
                        <span v-for="(star, index) in starArray" :key="index"
                            :class="['star', { 'active': star === '★' }]">
                            {{ star }}
                        </span>
                    </div>
                </div>
            </div>

            <div class="info-right">
                <BaseBtn title="開始烹飪" class="cook-btn" />
            </div>
        </div>

        <article class="quote-box">
            <div class="recipe-description">
                <p class="p-p1">{{ props.info.description }}</p>
            </div>
        </article>
    </div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

// --- 圖片容器 ---
.image-box {
    position: relative;
    border-radius: 10px;
    overflow: hidden;
    border: 2px solid $neutral-color-400;
    aspect-ratio: 16 / 9;
    width: 100%;
    margin-bottom: 20px;

    .main-img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        display: block;
        transition: transform 0.6s ease;
    }

    &:hover .main-img {
        transform: scale(1.05);
    }
}

.placeholder-box {
    width: 100%;
    height: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    background: $neutral-color-100;

    .icon-image {
        color: $neutral-color-400;
    }
}

.badge-favorite {
    color: $neutral-color-white;
    position: absolute;
    top: 20px;
    left: 20px;
    z-index: 10;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 5px;
    transition: all 0.3s ease;

    &:hover {
        color: $primary-color-700;
        transform: scale(1.05);
    }
}

// --- 資訊列佈局 ---
.info-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 20px;
    margin-bottom: 20px;

    .info-left {
        display: flex;
        align-items: center;
        gap: 24px;

        .info-item {
            display: flex;
            flex-direction: column;
            gap: 4px;

            .label-row {
                display: flex;
                align-items: center;
                gap: 4px;
                color: $neutral-color-400;

                .info-icon {
                    font-size: 1.2em;
                    color: $primary-color-700;
                }
            }

            .value {
                color: $neutral-color-black;
                font-weight: 600;
            }
        }

        .divider {
            width: 1px;
            height: 30px;
            background-color: $neutral-color-100;
            flex-shrink: 0;
        }
    }

    .info-right {
        .cook-btn {
            width: 180px;
        }
    }

    // --- RWD 修正 ---
    @media screen and (max-width: 810px) {
        flex-direction: column;
        align-items: center; // 整體置中
        text-align: center; // 文字置中
        gap: 24px;

        .info-left {
            width: 100%;
            justify-content: space-evenly; // 讓製作時間與難易度在同一列平均分佈
            gap: 0;

            .info-item {
                align-items: center; // 標籤與數值在內部也置中
                flex: 1; // 讓兩個項目平分寬度

                .label-row {
                    justify-content: center; // 標籤內的圖標文字置中
                }
            }
        }

        .info-right {
            width: 100%;

            :deep(.base-btn),
            .cook-btn {
                width: 100% !important;
            }
        }
    }
}

// --- 星星樣式 ---
.stars-box {
    display: inline-flex;
    align-items: center;
    gap: 2px;

    .star {
        font-size: 25px;
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
    border-bottom: $primary-color-400 1px solid;
    border-top: $primary-color-100 8px solid;
    margin: 24px 0;

    p {
        padding: 20px;
        line-height: 2.1;
        color: $neutral-color-800;
    }
}
</style>