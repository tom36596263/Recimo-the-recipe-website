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

// Demo 模式不跳轉，但保留結構
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
                <span class="p-p2">改編成果照</span>
            </div>
        </header>

        <div class="card-body">
            <div class="input-group title-input">
                <input type="text" :value="recipe.title" placeholder="改編版本標題..." readonly>
            </div>

            <div class="input-group content-input">
                <i-material-symbols-arrow-right-alt-rounded class="arrow-icon" />
                <input type="text" :value="recipe.description" placeholder="關鍵更改內容..." readonly>
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

.readonly-card-effect {
    transition: all 0.4s cubic-bezier(0.165, 0.84, 0.44, 1);

    &:hover {
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
    }
}

.recipe-card-sm {
    border: 1px solid $neutral-color-400;
    border-radius: 12px;
    overflow: hidden;
    background-color: $neutral-color-white;
    height: 100%;
    display: flex;
    flex-direction: column;

    .card-header {
        position: relative;
        height: 160px;
        background-color: $neutral-color-100;
    }

    .change-hint-overlay {
        position: absolute;
        inset: 0;
        background: rgba(0, 0, 0, 0.2);
        color: white;
        display: flex;
        align-items: center;
        justify-content: center;
        opacity: 0;
        transition: opacity 0.3s;
    }

    &:hover .change-hint-overlay {
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
                cursor: default;
            }
        }

        .title-input input {
            font-weight: 600;
            font-size: 16px;
            color: $neutral-color-800;
        }

        .content-input {
            .arrow-icon {
                font-size: 20px;
                margin-right: 6px;
                color: $primary-color-700; // 箭頭用主色標註
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
            width: 100%;
            justify-content: space-between;

            .p-p1 {
                font-size: 14px;
                color: $neutral-color-400;
                margin-right: auto;
                margin-left: 8px;
            }
        }

        .personal-img {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            border: 1px solid $neutral-color-100;
            background-color: $neutral-color-100;
        }
    }
}
</style>