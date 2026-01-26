<script setup>
import { useRouter } from 'vue-router';
import LikeButton from '@/components/common/LikeButton.vue'

const props = defineProps({
    recipe: {
        type: Object,
        required: true
    },
    readonly: {
        type: Boolean,
        default: false
    }
});

const router = useRouter();

// ✨ 修正重點：在 readonly 模式下不執行跳轉，交由父組件決定行為
const goToDetail = () => {
    if (!props.readonly) {
        // 如果不是唯讀模式（例如在一般列表），則執行原本的跳轉邏輯
        const targetId = props.recipe.id || props.recipe.recipe_id;
        if (targetId) {
            router.push(`/workspace/recipe-detail/${targetId}`);
        }
    }
    // 當 readonly 為 true 時，這裡什麼都不做，點擊事件會向上冒泡給父層
};

const handleLikeChange = (val, recipe) => {
    console.log('讚數更新:', val);
};

// AdaptRecipeCard.vue 的 <script setup>
const emit = defineEmits(['upload-image']); // 👈 加入這行

const handleUploadImage = () => {
    emit('upload-image'); // 👈 觸發事件
};

</script>

<template>
    <div v-if="recipe" class="recipe-card-sm" :class="{ 'is-readonly': readonly }" @click="goToDetail">
        <header class="card-header" :style="{
            backgroundImage: recipe.coverImg ? `url(${recipe.coverImg})` : '',
            backgroundSize: 'cover',
            backgroundPosition: 'center'
        }">
            <div v-if="recipe.keyChangeTag" class="key-change-badge">
                <span class="badge-dot"></span>
                <span class="badge-text">{{ recipe.keyChangeTag }}</span>
            </div>

            <div v-if="!readonly" class="change-hint-overlay" @click.stop="handleUploadImage">
                <span class="p-p2">+ 更換成品照</span>
            </div>
        </header>

        <div class="card-body">
            <div class="input-group title-input">
                <input type="text" :value="recipe.title" placeholder="改編版本標題..." readonly>
            </div>
            <div class="input-group content-input" :class="{ 'has-tag': recipe.keyChangeTag }">
                <i-material-symbols-arrow-right-alt-rounded class="arrow-icon" />
                <input type="text" :value="recipe.description || recipe.adapt_title" placeholder="關鍵更改內容..." readonly>
            </div>
        </div>

        <footer>
            <div class="personal-info">
                <div class="personal-img" :style="{
                    backgroundImage: (recipe.author && typeof recipe.author === 'object' && recipe.author.author_image)
                        ? `url(${recipe.author.author_image})` : '',
                    backgroundSize: 'cover',
                    backgroundPosition: 'center'
                }"></div>
                <p class="p-p1">{{ (recipe.author && typeof recipe.author === 'object') ? recipe.author.author_name :
                    (recipe.author || 'Recimo User') }}</p>
                <div @click.prevent.stop>
                    <LikeButton :initial-likes="recipe.likes || 0"
                        @update:liked="(val) => handleLikeChange(val, recipe)" />
                </div>
            </div>
        </footer>
    </div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.recipe-card-sm {
    border: 1px solid $neutral-color-400;
    border-radius: 12px;
    overflow: hidden;
    background-color: $neutral-color-white;
    height: 100%;
    display: flex;
    flex-direction: column;
    transition: all 0.3s ease;
    position: relative;

    &.is-readonly {
        cursor: pointer;

        &:hover {
            transform: translateY(-8px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.08);
        }
    }

    .card-header {
        isolation: isolate;
        position: relative;
        height: 160px;
        background-color: $neutral-color-100;
        overflow: hidden;
    }

    /* ✨ 修正後的標籤：解決文字重疊 */
    .key-change-badge {
        position: absolute;
        top: 8px;
        left: 8px;
        // 💡 關鍵：給予右邊距，確保標籤不會貼到右邊邊界，且有空間折行
        max-width: calc(100% - 16px);
        z-index: 20;
        background: rgba($primary-color-700, 0.9);
        backdrop-filter: blur(4px);
        color: white;
        padding: 4px 10px;
        border-radius: 12px; // 稍微調方一點點，折行時比較好看
        display: flex; // 改用 flex
        align-items: flex-start; // 對齊頂部，適合多行
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
        pointer-events: none;

        .badge-dot {
            width: 6px;
            height: 6px;
            background-color: #52c41a;
            border-radius: 50%;
            margin-right: 6px;
            margin-top: 5px; // 微調圓點位置對齊第一行字
            flex-shrink: 0;
        }

        .badge-text {
            font-size: 11px;
            font-weight: 500;
            line-height: 1.5; // 💡 增加行高，防止文字重疊
            white-space: normal; // 允許自然換行
            word-break: break-all; // 避免長英文字母衝出去
            flex: 1;
        }
    }

    .change-hint-overlay {
        position: absolute;
        inset: 0;
        background: rgba(0, 0, 0, 0.4);
        color: white;
        display: flex;
        align-items: center;
        justify-content: center;
        opacity: 0;
        transition: opacity 0.2s;
        z-index: 10;
    }

    // 當 Hover 時，如果不是 readonly 狀態，標籤可以選擇稍微變淡或維持原樣
    // 這裡我們維持標籤顯示，但讓 overlay 不要蓋過它
    &:not(.is-readonly) .card-header:hover .change-hint-overlay {
        opacity: 1;
    }

    .card-body {
        padding: 12px 16px;
        flex-grow: 1;

        .input-group {
            display: flex;
            align-items: center;
            margin-bottom: 8px;

            input {
                width: 100%;
                border: none;
                outline: none;
                background: transparent;
                color: $neutral-color-700;
                padding: 4px 0;
            }
        }

        .title-input input {
            font-weight: 600;
            font-size: 16px;
        }

        .content-input {
            display: flex;
            align-items: center;

            .arrow-icon {
                font-size: 20px;
                margin-right: 6px;
                color: $primary-color-700;
                flex-shrink: 0;
            }

            input {
                font-size: 14px;
                color: $neutral-color-400;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }

            &.has-tag {
                opacity: 0.6;

                input {
                    font-size: 13px;
                    font-style: italic;
                }

                .arrow-icon {
                    color: $primary-color-400;
                    transform: scale(0.9);
                }
            }
        }
    }

    footer {
        padding: 0 16px 16px;

        .personal-info {
            display: flex;
            align-items: center;

            .p-p1 {
                font-size: 14px;
                margin-left: 8px;
                margin-right: auto;
                color: $neutral-color-400;
            }
        }

        .personal-img {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background-color: $neutral-color-100;
            border: 1px solid $neutral-color-400;
        }
    }
}
</style>