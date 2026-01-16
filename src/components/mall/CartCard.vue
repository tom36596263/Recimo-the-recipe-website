<!-- <script setup>
import { defineProps, computed } from 'vue';
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
// vue上課教：以後部屬比較不會有問題(資料放public的話)
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
        product_id: props.item.product_id,
        product_name: props.item.product_name,
        product_price: props.item.product_price,
        product_image: props.item.product_image
    })
};

// 增加
const handleIncrement = () => {
    // 確保使用正確的 ID 欄位
    const id = props.props.item.id;
    cartStore.incrementQty(id);
};

// 減少
const handleDecrement = () => {
    const id = props.item.id;
    // 如果數量大於 1 才執行減少，或是交給 store 判斷
    if ((props.item.qty || props.item.count) > 1) {
        cartStore.decrementQty(id);
    } else {
        // 如果剩 1 個還點減，通常會詢問是否刪除
        if (confirm("是否移除此商品？")) {
            cartStore.removeItem(id);
        }
    }
};

// 刪除
const handleRemove = () => {
    const id = props.item.product_id || props.item.id;
    if (confirm(`確定要刪除 ${props.item.product_name || props.item.name} 嗎？`)) {
        cartStore.removeItem(id);
    }
};

// ==========================================
// 計算圖片路徑 (增加安全性)
// ==========================================
const productImage = computed(() => {
    // 1. 根據你的 Console 顯示，圖片欄位是一個陣列 (Array)
    const images = props.item.product_image;

    if (Array.isArray(images) && images.length > 0) {
        // 2. 找到 is_cover 為 true 的那一張，如果沒設定就找第一張
        const coverImage = images.find(img => img.is_cover) || images[0];
        let path = coverImage.image_url;

        // 3. 重要修正：去掉路徑開頭的 "public/"
        // 因為在 Vite 中，public 資料夾下的檔案，路徑應直接從 / 開始
        if (path.startsWith('public/')) {
            path = path.replace('public/', '');
        }

        // 4. 拼接 baseURL
        const cleanBaseURL = baseURL.endsWith('/') ? baseURL : `${baseURL}/`;
        const cleanPath = path.startsWith('/') ? path.substring(1) : path;

        return `${cleanBaseURL}${cleanPath}`;
    }

    // 備用圖
    return `${baseURL}images/default-placeholder.png`;
});
</script>
<template>
    <router-link :to="`/mall/${item.id}`" class="product-card card-content">
        <div class="cart-card">
            <img :src="productImage" :alt="item.name" class="cart-card__img">

            <div class="cart-card__info">
                <h4>{{ item.name }}</h4>
                <p class="price">${{ item.price }}</p>

                <div class="quantity-control">
                    <button @click.stop.prevent="handleDecrement">-</button>
                    <span>{{ item.count || item.qty }}</span>
                    <button @click.stop.prevent="handleIncrement">+</button>
                </div>

                <p class="subtotal">小計：${{ item.price * (item.count || item.qty) }}</p>

                <button @click.stop.prevent="handleRemove" class="del-btn">
                    刪除
                </button>
            </div>
        </div>

    </router-link>

</template>
<style lang="scss" scoped>
@import "@/assets/scss/layouts/_grid.scss";

.cart-card {
    display: flex;
    gap: 20px;
    padding: 15px;
    border-bottom: 1px solid #eee;

    &__img {
        width: 100px;
        height: 100px;
        object-fit: cover;
        border-radius: 8px;
    }
}
</style> -->
<script setup>
import { defineProps, computed } from 'vue';
import { useCartStore } from '@/stores/cartStore';

// 接收父元件傳過來的商品資料
const props = defineProps({
    item: {
        type: Object,
        required: true,
        default: () => ({})
    }
});

const baseURL = import.meta.env.BASE_URL;
const cartStore = useCartStore();

// ==========================================
// 邏輯處理：串接 Pinia Store
// ==========================================

// 增加數量
const handleIncrement = () => {
    // 優先取 item.id，若無則取 product_id
    const id = props.item.id || props.item.product_id;
    cartStore.incrementQty(id);
};

// 減少數量
const handleDecrement = () => {
    const id = props.item.id || props.item.product_id;
    const currentQty = props.item.count || props.item.qty || 1;

    if (currentQty > 1) {
        cartStore.decrementQty(id);
    } else {
        handleRemove(); // 數量為 1 時點減號觸發刪除
    }
};

// 刪除商品
const handleRemove = () => {
    const id = props.item.id || props.item.product_id;
    const name = props.item.product_name || props.item.name;
    if (confirm(`確定要從購物車中移除「${name}」嗎？`)) {
        cartStore.removeItem(id);
    }
};

// 計算小計
const subtotal = computed(() => {
    const price = Number(props.item.product_price || props.item.price || 0);
    const qty = props.item.count || props.item.qty || 0;
    return price * qty;
});

// 判斷單位 (沿用原本 getUnit 邏輯)
const unit = computed(() => {
    const name = props.item.product_name || props.item.name || '';
    if (!name) return '個';
    return name.includes('飯') ? '個' : '包';
});

// ==========================================
// 圖片路徑處理
// ==========================================
const productImage = computed(() => {
    const images = props.item.product_image;

    if (Array.isArray(images) && images.length > 0) {
        const coverImage = images.find(img => img.is_cover) || images[0];
        let path = coverImage.image_url;

        if (path.startsWith('public/')) {
            path = path.replace('public/', '');
        }

        const cleanBaseURL = baseURL.endsWith('/') ? baseURL : `${baseURL}/`;
        const cleanPath = path.startsWith('/') ? path.substring(1) : path;
        return `${cleanBaseURL}${cleanPath}`;
    }

    // 如果傳進來的是單一字串路徑 (相容舊格式)
    if (typeof props.item.product_image === 'string') {
        return props.item.product_image;
    }

    return `${baseURL}images/default-placeholder.png`;
});
</script>

<template>
    <router-link :to="`/mall/${item.id || item.product_id}`" class="product-card">
        <div class="image-wrapper">
            <img :src="productImage" :alt="item.product_name || item.name" />
        </div>

        <div class="content">
            <div class="info">
                <p class="title p-p1">{{ item.product_name || item.name }}</p>
                <p class="price-unit p-p1">
                    價格 : {{ item.product_price || item.price }} 元 / {{ unit }}
                </p>
            </div>

            <div class="action-area">
                <div class="quantity-control">
                    <button @click.stop.prevent="handleDecrement" :disabled="(item.count || item.qty) <= 1 && false">
                        −
                    </button>
                    <input type="number" :value="item.count || item.qty" readonly />
                    <button @click.stop.prevent="handleIncrement">+</button>
                </div>

                <button class="delete-btn" @click.stop.prevent="handleRemove">
                    <i class="icon-trash">🗑️</i>
                </button>

                <div class="subtotal p-p1">${{ subtotal }}</div>
            </div>
        </div>
    </router-link>
</template>

<style lang="scss" scoped>
// 引入你設定好的 Grid 變數
@import "@/assets/scss/layouts/_grid.scss";

.product-card {
    display: flex;
    background: #fff;
    border: 1px solid #c4d6c4;
    border-radius: 8px;
    padding: 15px;
    margin-bottom: 16px;
    align-items: center;
    gap: 20px;
    width: 100%;
    box-sizing: border-box;
    max-width: 800px; // 稍微放寬以符合購物車列表感
    text-decoration: none; // 去除連結底線
    color: inherit;
    transition: background 0.3s;

    &:hover {
        background: #fcfdfc;
    }

    @media (max-width: 768px) {
        flex-direction: column;
        align-items: flex-start;
        padding: 12px;
        gap: 12px;
    }
}

.image-wrapper {
    width: 200px;
    height: 120px;
    flex-shrink: 0;
    border-radius: 8px;
    overflow: hidden;
    background: #f5f5f5;

    img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    @media (max-width: 768px) {
        width: 100%;
        height: 180px;
    }
}

.content {
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    flex: 1;
    width: 100%;
}

.info {
    .title {
        font-weight: bold;
        margin-bottom: 5px;
    }

    .price-unit {
        color: #666;
        font-size: 0.9rem;
    }
}

.action-area {
    display: flex;
    align-items: center;
    margin-top: 15px;
    gap: 15px;

    .quantity-control {
        display: flex;
        align-items: center;
        background: #e8f3e8;
        border-radius: 4px;
        overflow: hidden;

        button {
            background: none;
            border: none;
            width: 36px;
            height: 36px;
            cursor: pointer;
            font-size: 18px;
            color: #4a674a;

            &:hover {
                background: #d7ead7;
            }

            &:disabled {
                opacity: 0.3;
                cursor: not-allowed;
            }
        }

        input {
            width: 40px;
            text-align: center;
            border: none;
            background: transparent;
            font-size: 16px;
            outline: none;

            &::-webkit-inner-spin-button {
                -webkit-appearance: none;
            }
        }
    }

    .delete-btn {
        background: none;
        border: none;
        cursor: pointer;
        font-size: 1.2rem;
        color: #888;
        transition: color 0.2s;

        &:hover {
            color: #ff4d4f;
        }
    }

    .subtotal {
        font-weight: bold;
        margin-left: auto;
        color: #2c3e50;
        font-size: 1.1rem;
    }
}
</style>