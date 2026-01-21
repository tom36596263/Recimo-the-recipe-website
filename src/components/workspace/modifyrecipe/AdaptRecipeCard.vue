<script setup>
import { useRouter } from 'vue-router';
import LikeButton from '@/components/common/LikeButton.vue'

const props = defineProps({
    recipe: {
        type: Object,
        required: true
    }
});

const router = useRouter();

const goToDetail = () => {
    console.log('Demo 模式：已停用跳轉', props.recipe.id);
};

const handleLikeChange = (val, recipe) => {
    console.log('讚數更新:', val);
};
</script>

<template>
    <div v-if="recipe" class="recipe-card-sm readonly-card-effect">
        <header class="card-header" :style="{
            backgroundImage: recipe.coverImg ? `url(${recipe.coverImg})` : '',
            backgroundSize: 'cover',
            backgroundPosition: 'center'
        }">
            <div class="change-hint-overlay">
                <span class="p-p2">+ 更換成品照</span>
            </div>
        </header>

        <div class="card-body">
            <div class="input-group title-input">
                <input type="text" :value="recipe.title || ''" placeholder="改編版本標題..." readonly>
            </div>

            <div class="input-group content-input">
                <i-material-symbols-arrow-right-alt-rounded class="arrow-icon" />
                <input type="text" :value="recipe.description || ''" placeholder="關鍵更改內容..." readonly>
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
                        || 'Recimo') }}
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

.readonly-card-effect {
    transition: all 0.4s cubic-bezier(0.165, 0.84, 0.44, 1);

    &:hover {
        // ✨ 修改：移除 transform: scale(1.03)，只保留投影感
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
    }
}

.recipe-card-sm {
    border: 1px solid $neutral-color-400;
    border-radius: $radius-base;
    overflow: hidden;
    background-color: $neutral-color-white;
    cursor: default;

    .card-header {
        position: relative;
        overflow: hidden;
        height: 150px;
        width: 100%;
        background-color: $neutral-color-100;

        &:hover {
            .change-hint-overlay {
                opacity: 1;
            }
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
        transition: opacity 0.2s ease-in-out;
        pointer-events: none;
    }

    .card-body {
        padding: 12px 16px;

        .input-group {
            display: flex;
            align-items: center;
            margin-bottom: 8px;

            input {
                width: 100%;
                border: none;
                outline: none;
                background: transparent;
                font-size: 14px;
                color: $neutral-color-700;
                padding: 4px 0;

                &::placeholder {
                    color: $neutral-color-400;
                }

                &:focus {
                    border-bottom: 1px solid $primary-color-400;
                }
            }
        }

        .title-input input {
            font-weight: 500;
            font-size: 16px;
        }

        .content-input .arrow-icon {
            font-size: 20px;
            margin-right: 4px;
            color: $neutral-color-800;
        }
    }

    footer {
        padding: 0 16px 16px 16px;
        justify-content: space-between;
        display: flex;

        .personal-info {
            display: flex;
            align-items: center;

            .p-p1 {
                margin-right: 6px;
            }
        }

        .personal-img {
            width: 24px;
            height: 24px;
            margin-right: 8px;
            border-radius: $radius-pill;
            border: 1px solid $neutral-color-700;
            overflow: hidden;
            display: flex;
            justify-content: center;
            background-color: $neutral-color-100;
        }
    }
}
</style>