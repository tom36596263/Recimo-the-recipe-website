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

// 處理按讚（目前僅為 UI 展示）
const handleLikeChange = (val, recipe) => {
    console.log(`${recipe.recipe_title} Liked: ${val}`);
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
                <div class="icon-group">
                    <i-material-symbols-Favorite-outline />
                </div>
            </div>

            <div class="tag">
                <BaseTag :text="`${recipe.recipe_kcal_per_100g} kcal`" />
                <BaseTag :text="`${recipe.recipe_protein_per_100g}P`" />
                <BaseTag :text="`難度：${recipe.recipe_difficulty}`" />
            </div>
        </div>

        <footer>
            <div class="personal-info">
                <div class="personal-img">
                    <img :src="LogoBlack" alt="Recimo Logo">
                </div>
                <p class="p-p1">Recimo</p>
                <LikeButton :initial-likes="recipe.recipe_likes || 0"
                    @update:liked="(val) => handleLikeChange(val, recipe)" />
            </div>

            <div class="btn-group">
                <BaseBtn title="加入計畫" variant="solid" height="30" @click.stop="handleAdd" class="btn" />
            </div>
        </footer>
    </div>
</template>

<style lang="scss" scoped>
// 完全複用 RecipeCardSm.vue 的樣式邏輯
.recipe-card-lg {
    border: 1px solid $neutral-color-400;
    border-radius: $radius-base;
    overflow: hidden;
    background-color: $neutral-color-white;
    cursor: pointer;
    transition: .3s ease;

    &:hover {
        box-shadow: 0 8px 16px rgba($neutral-color-black, 0.08);
        border-color: $primary-color-400;
    }

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
                // 處理標題過長
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

        .tag {
            display: flex;
            gap: 6px;
            flex-wrap: wrap; // 避免標籤過多破版
        }
    }

    footer {
        padding: 0 16px 16px 16px;
        justify-content: space-between;
        display: flex;
        align-items: center;

        .btn-group {
            display: flex;
            gap: 8px;
        }

        .personal-info {
            display: flex;
            align-items: center;

            .p-p1 {
                margin-right: 6px;
                color: $neutral-color-800;
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
            align-items: center;

            img {
                width: 16px; // 配合 Recimo logo 大小
            }
        }
    }
}

// 響應式調整，確保小螢幕下按鈕不跑版
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