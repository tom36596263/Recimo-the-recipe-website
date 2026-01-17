<script setup>
import { defineProps, computed, defineEmits } from 'vue';
import { useCartStore } from '@/stores/cartStore'

// 接收父元件傳過來的商品資料，item是資料傳送的「對口名稱」取的 (父子必須一致)，整段的意思是「各位父組件請注意！我是商品卡片，如果你要用我，請務必 (required) 給我一個物件型態 (Object) 的資料，並且請貼上 item 這個標籤交給我。」
const props = defineProps({
    item: {
        type: Object,
        required: true,
        default: () => ({}) // 增加預設空物件保護
    }
});

// ==========================================
// vue上課教：以後部屬比較不會有問題
// ==========================================
const baseURL = import.meta.env.BASE_URL

// ==========================================
// 加入購物車
// ==========================================
const cartStore = useCartStore()

const addToCart = () => {
    // 檢查點：先印出簡單的字串，確認按鈕有沒有被點到
    console.log("把商品", props.item.product_name, "加入購物車");

    cartStore.add({
        id: props.item.product_id,
        name: props.item.product_name,
        price: props.item.product_price,
    })
};

// ==========================================
// 計算圖片路徑 (修正版：確保對接子目錄)
// ==========================================
const getImageUrl = (url) => {
    if (!url) return '';

    // 1. 去除 JSON 裡可能帶有的 "public/" 字眼
    let cleanPath = url.replace(/^public\//, '');

    // 2. 確保 cleanPath 開頭沒有斜線 (避免跟 base 的結尾斜線重複產生 //)
    if (cleanPath.startsWith('/')) {
        cleanPath = cleanPath.substring(1);
    }

    // 3. 獲取當前環境的 Base URL
    // 此時你的 .env 應為 VITE_BASE=/cjd102/g2/recimo/
    const base = import.meta.env.BASE_URL;

    // 4. 確保 base 結尾有斜線後再拼接
    const safeBase = base.endsWith('/') ? base : `${base}/`;

    return `${safeBase}${cleanPath}`;
};

const productImage = computed(() => {
    const images = props.item.product_image;

    if (Array.isArray(images) && images.length > 0) {
        // 找到封面圖或是取第一張
        const coverImage = images.find(img => img.is_cover) || images[0];

        // 統一交給 getImageUrl 處理
        return getImageUrl(coverImage.image_url);
    }

    // 備用圖路徑同樣需經過 getImageUrl 或確保 base 拼接正確
    return `${baseURL}images/default-placeholder.png`;
});
// const productImage = computed(() => {
//     // 1. 根據你的 Console 顯示，圖片欄位是一個陣列 (Array)
//     const images = props.item.product_image;

//     if (Array.isArray(images) && images.length > 0) {
//         // 2. 找到 is_cover 為 true 的那一張，如果沒設定就找第一張
//         const coverImage = images.find(img => img.is_cover) || images[0];
//         let path = coverImage.image_url;

//         // 3. 重要修正：去掉路徑開頭的 "public/"
//         // 因為在 Vite 中，public 資料夾下的檔案，路徑應直接從 / 開始
//         if (path.startsWith('public/')) {
//             path = path.replace('public/', '');
//         }

//         // 4. 拼接 baseURL
//         const cleanBaseURL = baseURL.endsWith('/') ? baseURL : `${baseURL}/`;
//         const cleanPath = path.startsWith('/') ? path.substring(1) : path;

//         return `${cleanBaseURL}${cleanPath}`;
//     }

//     // 備用圖
//     return `${baseURL}images/default-placeholder.png`;
// });

</script>
<template>
    <router-link :to="`/mall/${item.product_id}`" class="product-card card-content">
        <img :src="productImage" :alt="item.product_name">

        <div class="product-card__content">
            <h4 class="p-p1 product-card__title">{{ item.product_name }}</h4>

            <div class="product-card__action">
                <p class="zh-h4-bold product-card__price">${{ item.product_price }}</p>

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