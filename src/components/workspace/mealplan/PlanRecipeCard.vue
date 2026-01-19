<script setup>
/**
 * PlanRecipeCard.vue
 * 目的：在 RecipePicker 的搜尋清單中呈現完整的食譜資訊。
 * 串接：接收來自 RecipePicker 的 recipe 物件，點擊時將該物件傳回父層。
 */
const props = defineProps({
    // 接收單一食譜的完整物件 (對應 recipes.json 的資料結構)
    recipe: {
        type: Object,
        required: true
    }
});

// 定義點擊事件，讓 RecipePicker 接收後執行新增逻辑
const emit = defineEmits(['click']);
</script>

<template>
    <div class="plan-recipe-card" @click="emit('click', recipe)">

        <div class="plan-recipe-card__image-box">
            <img :src="recipe.recipe_image_url" :alt="recipe.recipe_title" class="recipe-img" />

            <div class="difficulty-tag">
                難易度：
                <i-material-symbols-star />
                {{ recipe.recipe_difficulty }}
            </div>
        </div>

        <div class="plan-recipe-card__content">

            <div class="nutrition-tags">
                <span class="tag tag--kcal">{{ recipe.recipe_kcal_per_100g }} kcal</span>
                <span class="tag tag--pro">{{ recipe.recipe_protein_per_100g }}P</span>
            </div>

            <h4 class="recipe-title">{{ recipe.recipe_title }}</h4>

            <p class="recipe-desc">{{ recipe.recipe_descreption }}</p>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.plan-recipe-card {
    display: flex;
    flex-direction: column;
    background-color: $neutral-color-white;
    border: 1px solid $neutral-color-100;
    border-radius: 12px;
    overflow: hidden; // 確保圖片圓角生效
    cursor: pointer;
    transition: all 0.3s ease; // 平滑的動畫過渡
    height: 100%;

    // --- 互動效果：滑鼠懸停時上浮並產生陰影 ---
    &:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 16px rgba($neutral-color-black, 0.08);
        border-color: $primary-color-400;

        .recipe-title {
            color: $primary-color-700; // 標題顏色同步變化
        }
    }

    // --- 1. 圖片區域樣式 ---
    &__image-box {
        position: relative;
        width: 100%;
        height: 140px;
        background-color: $neutral-color-100;

        .recipe-img {
            width: 100%;
            height: 100%;
            object-fit: cover; // 核心：裁切圖片以填滿容器而不變形
        }

        .difficulty-tag {
            position: absolute;
            top: 8px;
            right: 8px;
            display: flex;
            align-items: center;
            gap: 2px;
            background-color: rgba($neutral-color-black, 0.6);
            color: $neutral-color-white;
            padding: 2px 8px;
            border-radius: 20px;
            font-size: 0.7rem;
            backdrop-filter: blur(2px); // 背景模糊，增加質感
        }
    }

    // --- 2. 內容文字區域樣式 ---
    &__content {
        padding: 12px;
        display: flex;
        flex-direction: column;
        gap: 8px;
        flex-grow: 1;

        .nutrition-tags {
            display: flex;
            gap: 6px;

            .tag {
                font-size: 0.7rem;
                font-weight: bold;
                padding: 2px 8px;
                border-radius: 4px;

                &--kcal {
                    background-color: $primary-color-100;
                    color: $primary-color-800;
                }

                &--pro {
                    background-color: $accent-color-100;
                    color: $accent-color-800;
                }
            }
        }

        .recipe-title {
            font-size: 1rem;
            font-weight: bold;
            color: $neutral-color-black;
            margin: 0;
            transition: color 0.2s;
        }

        .recipe-desc {
            font-size: 0.8rem;
            color: $neutral-color-700;
            line-height: 1.4;
            margin: 0;

            /* --- 多行文字截斷邏輯 --- */
            display: -webkit-box;
            -webkit-line-clamp: 2; // 限制最多兩行
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
        }
    }
}
</style>