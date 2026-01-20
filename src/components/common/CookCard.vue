<script setup>
import { defineProps, defineEmits } from 'vue';

// 定義可以從外部傳入的資料 (Props)
const props = defineProps({
    name: {
        type: String,
        required: true,
        default: ''
    },
    calories: {
        type: [Number, String],
        required: true,
        default: ''
    },
    fat: {
        type: [Number, String],
        required: true,
        default: ''
    },
    imageSrc: {
        type: String,
        default: '' // 預設圖片路徑或留空
    }
});

// 定義事件，當點擊 + 按鈕時通知父元件
const emit = defineEmits(['add-to-cart']);

const handleAddClick = () => {
    emit('add-ingredient'); // 發送訊號給父層
};
</script>

<template>
    <article class="ingredient-card">
        <div class="info-section">
            <h3 class="title p-p2">{{ name }}</h3>
            <p class="unit-label p-p3">每100g：</p>
            <div class="nutrition-data">
                <p class="p-p3">熱量：{{ calories }}kcal</p>
                <p class="p-p3">脂肪：{{ fat }}g</p>
            </div>
        </div>

        <div class="image-wrapper">
            <img :src="imageSrc" :alt="name" class="product-img" />
        </div>

        <button class="add-btn" @click.stop="handleAddClick" aria-label="加入食材">
            <span class="plus-icon">+</span>
        </button>
    </article>
</template>

<style lang="scss" scoped>
.ingredient-card {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px;
    background-color: $neutral-color-white;
    border-radius: 12px;
    position: relative;
    width: 270px;
    height: 94px;
    margin-bottom: 6px;
    cursor: pointer;
}

.info-section {
    flex: 1;
    padding-right: 10px;
    display: flex;
    flex-direction: column;
    justify-content: center;

    .title {
        color: $primary-color-700;
    }
}

.image-wrapper {
    width: 90px;
    height: 70px;
    background-color: $neutral-color-400;
    border-radius: $radius-base;
    overflow: hidden;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 30px;


    .product-img {
        width: 100%;
        height: 100%;
        object-fit: cover; // 確保圖片填滿且不變形
        display: block;
    }
}

.add-btn {
    position: absolute;
    bottom: 0px;
    right: 0px; // 根據設計圖，按鈕似乎浮在右下角
    width: 24px;
    height: 24px;
    background-color: $primary-color-400;
    border: none;
    border-radius: 10px 0 10px 0;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: transform 0.1s, background-color 0.2s;

    &:hover {
        background-color: $accent-color-700;
    }

    &:active {
        transform: scale(0.95);
    }

    .plus-icon {
        font-size: 20px;
        font-weight: 400;
        color: $neutral-color-800;
        line-height: 1;
    }
}
</style>