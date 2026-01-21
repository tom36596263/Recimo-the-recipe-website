<script setup>
import { useRouter } from 'vue-router';
import LikeButton from '@/components/common/LikeButton.vue'

const props = defineProps({
    recipe: {
        type: Object,
        required: true
    },
    // ✨ 新增：判斷是否為唯讀模式（總覽頁使用）
    readonly: {
        type: Boolean,
        default: false
    }
});

const router = useRouter();

// ✨ 點擊行為：唯讀模式下點擊卡片跳轉詳情頁
const goToDetail = () => {
    if (props.readonly) {
        const targetId = props.recipe.id || props.recipe.recipe_id;
        if (targetId) {
            router.push(`/workspace/recipe-detail/${targetId}`);
        }
    }
};

const handleLikeChange = (val, recipe) => {
    console.log('讚數更新:', val);
};
</script>

<template>
    <div v-if="recipe" class="recipe-card-sm" :class="{ 'is-readonly': readonly }" @click="goToDetail">

        <header class="card-header" :style="{
            backgroundImage: recipe.coverImg ? `url(${recipe.coverImg})` : '',
            backgroundSize: 'cover',
            backgroundPosition: 'center'
        }">
            <div v-if="!readonly" class="change-hint-overlay">
                <span class="p-p2">+ 更換成品照</span>
            </div>
        </header>

        <div class="card-body">
            <div class="input-group title-input">
                <input type="text" :value="recipe.title" placeholder="改編版本標題..." readonly>
            </div>

            <div class="input-group content-input">
                <i-material-symbols-arrow-right-alt-rounded class="arrow-icon" />
                <input type="text" :value="recipe.description || recipe.adapt_title" placeholder="關鍵更改內容..." readonly>
            </div>
        </div>

        <footer>
            <div class="personal-info">
                <div class="personal-img" :style="{
                    backgroundImage: (recipe.author && typeof recipe.author === 'object' && recipe.author.author_image)
                        ? `url(${recipe.author.author_image})`
                        : '',
                    backgroundSize: 'cover',
                    backgroundPosition: 'center'
                }">
                </div>
                <p class="p-p1">
                    {{ (recipe.author && typeof recipe.author === 'object') ? recipe.author.author_name : (recipe.author
                        || 'Recimo User') }}
                </p>
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

    // ✨ 唯讀模式下的樣式（總覽頁用）
    &.is-readonly {
        cursor: pointer;

        &:hover {
            transform: translateY(-8px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.08);
        }
    }

    .card-header {
        position: relative;
        height: 160px;
        background-color: $neutral-color-100;
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
    }

    // 只有非 readonly 時 hover 圖片才顯示文字
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
                cursor: default; // 總覽頁不可輸入
            }
        }

        .title-input input {
            font-weight: 600;
            font-size: 16px;
        }

        .content-input {
            .arrow-icon {
                font-size: 20px;
                margin-right: 6px;
                color: $primary-color-700;
            }

            input {
                font-size: 14px;
                color: $neutral-color-400;
            }
        }
    }

    footer {
        padding: 0 16px 16px;

        .personal-info {
            display: flex;
            align-items: center;
            justify-content: space-between;
            width: 100%;

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