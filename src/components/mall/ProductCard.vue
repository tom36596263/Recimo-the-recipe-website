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
            <div class="product-card__action">
                <p class="en-h2-bold product-card__price">{{ item.price }}</p>
                <BaseBtn title="加入購物車" variant="solid" @click="addToCart" :width="110" :height="30" />
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
    padding: 15px;
}

.product-card img {
    width: 100%;
    display: block;
}

.product-card__action {
    display: flex;
    justify-content: space-between;
}
</style>