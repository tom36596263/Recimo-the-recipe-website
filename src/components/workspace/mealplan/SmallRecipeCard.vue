<script setup>
/**
 * SmallRecipeCard.vue
 * 目的：在週計畫（週視圖）的格子內顯示極簡的食譜摘要。
 * 串接：由 DayColumn.vue 遍歷 items 後，將單一食譜的標題與熱量傳入。
 */
defineProps({
    // 食譜名稱 (來自 recipe_title)
    title: {
        type: String,
        default: '未命名食譜'
    },
    // 食譜熱量 (來自 recipe_kcal_per_100g)
    kcal: {
        type: [Number, String],
        default: 0
    }
});
</script>

<template>
    <div class="small-recipe-card">
        <div class="small-recipe-card__title" :title="title">
            {{ title }}
        </div>

        <div class="small-recipe-card__kcal">
            {{ kcal }} <span class="unit">kcal</span>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.small-recipe-card {
    display: flex;
    flex-direction: column;
    justify-content: center;
    width: 100%;
    padding: 4px 8px;
    margin-bottom: 2px;

    background-color: $neutral-color-white; // 使用純白背景與底層灰色區隔
    border: 1px solid $neutral-color-100;
    border-radius: 6px;

    box-shadow: 0 1px 3px rgba($neutral-color-black, 0.05); // 增加極輕微的陰影營造層次感
    transition: transform 0.2s ease;
    cursor: pointer;

    &__title {
        font-size: 0.8rem;
        font-weight: 500;
        color: $primary-color-800;
        text-align: left;
        line-height: 1.2;

        /* --- 處理文字過長 --- */
        white-space: nowrap; // 強制文字不換行
        overflow: hidden; // 隱藏超出容器的部分
        text-overflow: ellipsis; // 在末尾顯示 "..."
    }

    &__kcal {
        font-size: 0.7rem;
        color: $neutral-color-700; // 使用中性色灰色，避免干擾標題
        text-align: left;
        margin-top: 2px;

        .unit {
            font-size: 0.6rem;
            color: $neutral-color-400; // 單位顏色更淡
        }
    }
}
</style>