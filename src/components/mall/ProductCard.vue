<script setup>
import { ref, defineProps } from 'vue';
import { useCartStore } from '@/stores/cartStore';
const cartStore = useCartStore()
// 引用彈窗
import BaseModal from '@/components/BaseModal.vue';

// ==========================================
// 接收父元件傳過來的商品資料
// ==========================================
const props = defineProps({
    item: {
        type: Object,
        required: true,
        default: () => ({}) // 增加預設空物件保護
    }
});

// ==========================================
// 加入購物車
// ==========================================
// 定義控制 Modal 顯示的變數
const showSuccess = ref(false);

const addToCart = () => {
    // 確認按鈕有沒有被點到
    // console.log("把商品", props.item.product_name, "加入購物車");

    cartStore.add(props.item);

    // alert(`「${props.item.product_name}」已加入購物車~`);
    showSuccess.value = true;
    setTimeout(() => { showSuccess.value = false; }, 1500);
};
</script>
<template>
    <router-link :to="`/mall/${item.product_id}`" class="product-card card-content">
        <img :src="$parsePublicFile(item.image_url)" :alt="item.product_name">

        <div class="product-card__content">
            <h4 class="p-p1 product-card__title">{{ item.product_name }}</h4>

            <div class="product-card__action">
                <p class="zh-h4-bold product-card__price">${{ item.product_price }}</p>

                <span @click.prevent.stop>
                    <BaseBtn title="加入購物車" variant="solid" @click.stop.prevent="addToCart" :width="110" :height="30"
                        class="cart-btn" />
                </span>

            </div>
        </div>

    </router-link>
    <!-- 解決CSS 層級 (z-index) 與 容器溢出 (overflow) 的問題，利用 Vue 的 <Teleport> 功能，將 Modal 抽離到 <body> 層級 -->
    <Teleport to="body">
        <BaseModal :isOpen="showSuccess" type="success" iconClass="fa-solid fa-check"
            :title="`已將【${item.product_name}】\n加入購物車`" @close="showSuccess = false">
        </BaseModal>
    </Teleport>
</template>
<style lang="scss" scoped>
@use "sass:map";
@use "@/assets/scss/layouts/_grid.scss" as *;

.product-card {
    display: block; // 讓 a 標籤像 div 一樣撐開
    text-decoration: none;
    color: inherit; // 繼承文字顏色，避免變成藍色
    width: 100%;
    background-color: $neutral-color-white;
    border: 1px solid $primary-color-700;
    border-radius: 10px;
    padding: 15px;
    transition: transform 0.3s ease, box-shadow 0.3s ease;

    &:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
        transition: transform 0.5s ease;
    }
}

@media screen and (max-width: map.get($breakpoints, "lg")) {
    .product-card {
        &:hover {
            transform: none; // 強制取消位移
        }
    }
}

// 確保圖片與內容不受 a 標籤影響
.product-card img {
    width: 100%;
    display: block;
    border-radius: 10px;
}

.product-card__content {
    margin-top: 10px;
}

.product-card__action {
    display: flex;
    justify-content: space-between;
    align-items: center;

    span {
        display: inline-flex; // 讓 span 包住按鈕且不影響排版
    }
}

.product-card__content h4 {
    white-space: nowrap; // 強制不換行
    overflow: hidden; // 隱藏超出部分
    text-overflow: ellipsis; // 超出部分顯示 "..."
    width: 100%; // 確保寬度受限於父容器
}
</style>