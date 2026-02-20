<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useFavoritesStore } from '@/stores/favoritesStore';
import { useAuthStore } from '@/stores/authStore';
import { useRouter } from 'vue-router'; //為了開始烹飪跳轉連結而引入的功能
// 導入開發好的燈箱組件
import AddToFolderModal from '@/components/workspace/recipedetail/modals/AddToFolderModal.vue';

const props = defineProps({
    info: {
        type: Object,
        required: true
    },
    // 用於原本的預覽模式判斷
    isPreview: {
        type: Boolean,
        default: false
    },
    // ✨ 新增：專門給「改編彈窗」使用的控制項
    // 當這個值為 true 時，收藏與開始烹飪按鈕會被隱藏
    hideActions: {
        type: Boolean,
        default: false
    }
});

// 1. 組件掛載時檢查資料
onMounted(() => {
    console.log('--- RecipeIntro 組件已掛載 ---');
    console.log('完整的 info 資料:', props.info);
    console.log('Tags 資料:', props.info.tags);
});

// 2. 監聽 info 的變化（防止非同步讀取資料延遲）
watch(() => props.info, (newVal) => {
    console.log('info 資料發生更新:', newVal);
    console.log('更新後的 Tags:', newVal?.tags);
}, { deep: true });



// 「開始烹飪」按飪跳轉邏輯
const router = useRouter(); //宣告 router 變數

// 建立點擊跳轉函式
const handleStartCooking = () => {
    if (props.info.id) {
        // 導向路徑：/workspace/guide/{id}
        router.push(`/workspace/guide/${props.info.id}`);
    } else {
        console.error('找不到食譜 ID，無法進入烹飪模式');
    }
};

// 控制燈箱顯隱的狀態

const showModal = ref(false);
const favoritesStore = useFavoritesStore();
const authStore = useAuthStore();
const isFavorited = computed(() => favoritesStore.isFavorited(props.info.id));


const toggleFavorite = () => {
    if (!isFavorited.value) {
        // 尚未收藏 → 開 modal
        showModal.value = true;
    } else {
        // 已收藏 → 開 modal 讓使用者選擇移動或取消
        showModal.value = true;
    }
};

// 產生星星陣列
const starArray = computed(() => {
    const score = props.info.difficulty ?? 3;
    return Array.from({ length: 5 }, (_, i) => (i < score ? '★' : '☆'));
});

// 處理燈箱確認提交後的邏輯
const onModalSubmit = (data) => {
    if (data && data.updated && authStore.user) {
        favoritesStore.refetchFavorites(authStore.user.user_id || authStore.user.id);
    }
};
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

            <div v-if="!props.isPreview && !props.hideActions" class="badge-favorite" :class="{ active: isFavorited }"
                @click="toggleFavorite">

                <i-material-symbols-favorite-outline-rounded v-if="!isFavorited" />
                <i-material-symbols-favorite-rounded v-else />
                <div class="favorite-text">
                    {{ isFavorited ? '已收藏' : '加收藏' }}
                </div>
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
                <BaseBtn v-if="!props.isPreview && !props.hideActions" title="開始烹飪" class="cook-btn"
                    @click="handleStartCooking" />
            </div>
        </div>



        <article class="quote-box">
            <div class="recipe-description">
                <div class="recipe-tags-container" v-if="props.info.tags && props.info.tags.length">
                    <span v-for="tag in props.info.tags" :key="tag.tag_id" class="recipe-tag">
                        {{ tag.tag_name }}
                    </span>
                </div>

                <p class="p-p1">{{ props.info.description }}</p>
            </div>
        </article>

        <AddToFolderModal v-if="!props.isPreview" v-model="showModal" @submit="onModalSubmit" />
    </div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

// --- 樣式部分完全沒動 ---
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
    color: $primary-color-700;
    position: absolute;
    top: 10px;
    left: 10px;
    z-index: 10;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 5px;
    transition: all 0.3s ease;
    padding: 6px 12px;
    border-radius: 20px;

    &:hover {
        color: $accent-color-700;
        transform: scale(1.05);
    }

    &.active {
        color: $secondary-color-danger-700;
    }
}

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
                color: $neutral-color-800;
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

    @media screen and (max-width: 810px) {
        flex-direction: column;
        align-items: center;
        text-align: center;
        gap: 24px;

        .info-left {
            width: 100%;
            justify-content: space-evenly;
            gap: 0;

            .info-item {
                align-items: center;
                flex: 1;

                .label-row {
                    justify-content: center;
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

.recipe-description {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    min-height: 120px;
    border-bottom: $primary-color-400 1px solid;
    border-top: $primary-color-100 8px solid;
    margin: 24px 0;
    padding: 32px 20px 24px 20px; // 使用較大的 padding 設定

    p {
        margin-top: 20px;
        line-height: 2;
        color: $neutral-color-800;
        letter-spacing: 0.5px;
        width: 100%;

        // ✨ 最關鍵的這一行：保留原始換行符號並允許自動換行
        white-space: pre-wrap;

        // ✨ 選配：如果你的文字包含很長的網址或無空格英文，可以加上這行防止破版
        word-break: break-word;
    }

    .recipe-tags-container {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;

        .recipe-tag {
            background-color: $neutral-color-100;
            color: $neutral-color-800;
            padding: 4px 14px;
            border-radius: 5px;
            font-size: 13px;
            border: 1px solid transparent;
            transition: 0.3s;
        }
    
}

    @media screen and (max-width: 810px) {
        gap: 8px;
    }
}
</style>