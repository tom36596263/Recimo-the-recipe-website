<script setup>
import { defineProps } from 'vue';

// 接收父元件傳過來的商品資料
const props = defineProps({
    item: {
        type: Object,
        required: true
    }
});

// ==========================================
// vue上課教：以後部屬比較不會有問題
// ==========================================
const baseURL = import.meta.env.BASE_URL

</script>
<template>
    <div class="product-card">
        <img :src="baseURL + item.images[0]">
        <div class="product-card__content">
            <h4 class="p-p1 product-card__title">{{ item.product_name }}</h4>
            <p class="en-h2-bold product-card__price">{{ item.price }}</p>
            <div class="inline" style="width: 109px">
                <button class="btn h-30 btn-solid">加入購物車</button>
            </div>
        </div>
    </div>
</template>
<style lang="scss" scoped>
.product-card {
    width: 100%; // 預設撐滿格子
    max-width: 315px; // 【重點】設定它的最大上限
    background-color: #fff;
    border: 1px solid $primary-color-700;
    border-radius: 10px;
    padding: 10px;
}

.product-card img {
    width: 100%;
    display: block;
}

.product-card p>div {
    display: inline;
}
</style>