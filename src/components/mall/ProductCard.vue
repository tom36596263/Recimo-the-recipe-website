<script setup>
// 可以不寫這行 import（因為它是全域編譯巨集），但手動寫出來能讓程式碼更嚴謹、更好讀
import { defineProps, computed } from 'vue';

// 接收父元件傳過來的商品資料，item是資料傳送的「對口名稱」取的 (父子必須一致)，整段的意思是「各位父組件請注意！我是商品卡片，如果你要用我，請務必 (required) 給我一個物件型態 (Object) 的資料，並且請貼上 item 這個標籤交給我。」
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

// ==========================================
// 加入購物車
// ==========================================
const emit = defineEmits(['add-to-cart', 'click']);

const addToCart = () => {
    // 檢查點：先印出簡單的字串，確認按鈕有沒有被點到
    console.log("把商品", props.item.product_name, "加入購物車");

    // 傳送事件給父組件
    emit('add-to-cart', props.item);
};

// ==========================================
// 計算圖片路徑 (增加安全性)
// ==========================================
const productImage = computed(() => {
    // 檢查是否有圖片資料
    if (props.item.images && props.item.images.length > 0) {
        return `${baseURL}${props.item.images[0]}`;
    }
    // 回傳一張預設的佔位圖
    return `${baseURL}images/default-placeholder.png`;
});
</script>
<template>
    <router-link :to="`/mall/${item.id}`" class="product-card card-content">
        <img :src="productImage" :alt="item.product_name">

        <div class="product-card__content">
            <h4 class="p-p1 product-card__title">{{ item.product_name }}</h4>

            <div class="product-card__action">
                <p class="zh-h4-bold product-card__price">${{ item.price }}</p>

                <span @click.prevent.stop>
                    <BaseBtn title="加入購物車" variant="solid" @click="addToCart" :width="110" :height="30"
                        class="cart-btn" />
                </span>

            </div>
        </div>
    </router-link>
</template>
<style lang="scss" scoped>
@import "@/assets/scss/layouts/_grid.scss";

.product-card {
    display: block; // 讓 a 標籤像 div 一樣撐開
    text-decoration: none; // 去掉超連結底線
    color: inherit; // 繼承文字顏色，避免變成藍色
    width: 100%;
    max-width: 315px;
    background-color: $neutral-color-white;
    border: 1px solid $primary-color-700;
    border-radius: 10px;
    padding: 15px;
    transition: transform 0.3s ease, box-shadow 0.3s ease;

    &:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);

    }
}

@media screen and (max-width: map-get($breakpoints, "lg")) {
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