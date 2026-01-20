<script setup>
import { useRouter } from 'vue-router';
import BaseTag from '@/components/common/BaseTag.vue';
import BaseBtn from '@/components/common/BaseBtn.vue';
import LikeButton from '@/components/common/LikeButton.vue';
import LogoBlack from '/img/site/Recimo-logo-black.svg';

/**
 * PlanRecipeCard.vue
 * 目的：在 RecipePicker 的搜尋清單中呈現與 RecipeCardSm 風格一致的食譜資訊。
 */
const props = defineProps({
    recipe: {
        type: Object,
        required: true
    }
});

const emit = defineEmits(['click']);

// 點擊卡片或按鈕時觸發新增邏輯
const handleAdd = () => {
    emit('click', props.recipe);
};


</script>

<template>
    <div class="recipe-card-lg" @click="handleAdd">
        <header class="card-header">
            <img :src="recipe.recipe_image_url" :alt="recipe.recipe_title">
        </header>

        <div class="card-body">
            <div class="title">
                <h4 class="zh-h4">{{ recipe.recipe_title }}</h4>

            </div>

            <div class="tag-group">
                <BaseTag :text="`${recipe.recipe_kcal_per_100g} kcal`" />
                <BaseTag :text="`${recipe.recipe_protein_per_100g}P`" />
                <BaseTag :text="`難度：${recipe.recipe_difficulty}`" />
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.recipe-card-lg {
    border: 1px solid $neutral-color-400;
    border-radius: $radius-base;
    overflow: hidden;
    background-color: $neutral-color-white;
    cursor: pointer;
    transition: .3s ease;

    .card-header {
        overflow: hidden;
        height: 220px;
        width: 100%;

        img {
            object-fit: cover;
            display: block;
            width: 100%;
            height: 100%;
            transition: .3s ease;

            &:hover {
                scale: 1.1; // 圖片縮放效果
            }
        }
    }

    .card-body {
        padding: 16px;

        .title {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 6px;
            color: $primary-color-700;

            h4 {
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
                margin: 0;
            }
        }

        .icon-group {
            display: flex;
            gap: 12px;
            color: $neutral-color-700;
        }

        .tag-group {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
        }
    }
}

// RWD，確保小螢幕下按鈕不跑版
@media screen and (max-width: 1300px) {
    .recipe-card-lg {
        footer {
            .btn {
                width: 85px;
            }
        }
    }
}
</style>