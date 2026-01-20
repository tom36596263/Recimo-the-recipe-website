<script setup>
import { ref } from 'vue';
import AdaptRecipeCard from '@/components/workspace/modifyrecipe/AdaptRecipeCard.vue';

// 初始資料
const recipeForm = ref({
    title: '雲朵般口感 - 經典日式舒芙蕾鬆餅',
    description: '日式舒芙蕾鬆餅以其驚人的空氣感...',
    coverImg: 'https://picsum.photos/200/150', // 先給一張假圖測試
    originalAuthor: 'Recimo',
    likes: 100
});
</script>

<template>
    <div class="modify-recipe-page container">
        <header class="page-header">
            <h2 class="zh-h2">改編食譜編輯</h2>
        </header>

        <section class="adapt-card-section">
            <AdaptRecipeCard :recipe="recipeForm" />
        </section>

        <div class="hint-text">
            <p class="p-p2">* 您正在改編此食譜，下方的食材與步驟已為您預填完成。</p>
        </div>
    </div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.modify-recipe-page {
    padding: 40px 0;

    .page-header {
        margin-bottom: 30px;
        border-left: 4px solid $primary-color-700;
        padding-left: 16px;
    }

    .adapt-card-section {
        margin-bottom: 40px;
        display: flex;
        justify-content: center;
    }

    .hint-text {
        color: #999;
        text-align: center;
    }
}
</style>