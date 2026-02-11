<script setup>
import { ref, defineProps, computed, getCurrentInstance } from 'vue';
import { useCartStore } from '@/stores/cartStore';
// 引用彈窗
import BaseModal from '@/components/BaseModal.vue';
// icon
import IconDelete from '~icons/material-symbols/delete-outline';
// 圖片路徑
import { parsePublicFile } from '@/utils/parseFile';

// ==========================================
// 接收父元件傳過來的商品資料
// ==========================================
const props = defineProps({
    item: {
        type: Object,
        required: true,
        default: () => ({})
    }
});

const { proxy } = getCurrentInstance();
const cartStore = useCartStore();

// ==========================================
// 邏輯處理：串接 Pinia Store
// ==========================================
// 提取 ID (確保支援不同來源的資料結構)
const productId = computed(() => props.item.product_id || props.item.id);

// ==========================================
// 商品邏輯
// ==========================================
// 建立一個格式化工具
const formatPrice = (val) => {
    const num = Number(val || 0);
    return new Intl.NumberFormat('zh-TW', { maximumFractionDigits: 0 }).format(num);
};

const displayQty = computed(() => {
    return Number(props.item.quantity || 0);
});

// 增加數量
const handleIncrement = () => {
    // 這裡 cartStore.incrementQty 會去呼叫 updateQty，
    // updateQty 內部已經寫好了：登入就打 API，沒登入就存 LocalStorage
    cartStore.incrementQty(productId.value);
};

// 減少數量
const handleDecrement = async () => {
    const currentQty = Number(props.item.quantity || 0);
    if (currentQty > 1) {
        // 自動處理同步邏輯
        await cartStore.decrementQty(productId.value);
    } else {
        // 數量為 1 再點減號，觸發刪除彈窗
        handleRemove();
    }
};

// 刪除商品
const showDeleteModal = ref(false);
const handleRemove = () => {
    showDeleteModal.value = true;
};

// 當在 Modal 點擊「確定刪除」時執行的函式
const confirmDelete = async () => {
    // 這裡會執行 removeItem，內含 API (delete_cartitem.php) 或 LocalStorage 同步
    await cartStore.removeItem(productId.value);
    showDeleteModal.value = false;
};

// 計算小計
const subtotal = computed(() => {
    const price = Number(props.item.product_price || 0);
    const qty = Number(props.item.quantity || 0);
    return formatPrice(price * qty);
});

// ==========================================
// 圖片路徑處理
// ==========================================
const productImage = computed(() => {
    const imgUrl = props.item.product_image || props.item.image_url;

    if (imgUrl) {
        let finalPath = proxy.$parsePublicFile(imgUrl);

        return finalPath;
    }
    return `${import.meta.env.BASE_URL}images/default-placeholder.png`;
});
</script>

<template>
    <div class="product-card">
        <router-link :to="`/mall/${item.id || item.product_id}`" class="image-wrapper">
            <img :src="productImage" :alt="item.product_name || item.name || '商品圖片'" />
        </router-link>

        <div class="content">
            <div class="info-group">
                <p class="title zh-h5-bold">{{ item.product_name || item.name }}</p>
                <p class="price-unit p-p1">
                    價格 : {{ formatPrice(item.product_price) }} 元 / 包</p>

                <div class="action-row">
                    <p class="qty-label p-p1">數量</p>
                    <div class="quantity-control">
                        <button @click.stop.prevent="handleDecrement">−</button>
                        <input type="text" class="p-p1" :value="displayQty" readonly />
                        <button @click.stop.prevent="handleIncrement">+</button>
                    </div>
                    <button class="delete-btn" @click.stop.prevent="handleRemove">
                        <component :is="IconDelete" class="icon" />
                    </button>
                </div>
            </div>

            <div class="subtotal-area">
                <span class="subtotal-val p-p1">${{ subtotal }}</span>
            </div>
        </div>
        <BaseModal :isOpen="showDeleteModal" type="info" iconClass="fa-regular fa-trash-can"
            :title="`確定要從購物車中移除「${item.product_name || item.name}」嗎？`" @close="showDeleteModal = false">
            <template #actions>
                <button class="btn-solid" @click="confirmDelete">確定刪除</button>
                <button class="btn-outline" @click="showDeleteModal = false">取消</button>
            </template>
        </BaseModal>
    </div>
</template>

<style lang="scss" scoped>
.product-card {
    display: flex;
    border: 1px solid $primary-color-700;
    border-radius: 10px;
    padding: 20px;
    margin-bottom: 20px;
    align-items: center;
    gap: 20px;
    width: 100%;
}

.image-wrapper {
    width: 220px;
    height: 170px;
    flex-shrink: 0; // 無論空間再怎麼擠，都不壓縮
    border-radius: 10px;
    overflow: hidden;

    img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
}

.content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex: 1;
}

.info-group .title {
    margin-bottom: 5px;
}

.price-unit {
    margin-bottom: 10px;
}

.action-row {
    display: flex;
    align-items: center;
    gap: 10px;
    white-space: nowrap;

    .quantity-control {
        display: flex;
        background-color: $primary-color-100;
        border-radius: 10px;
        overflow: hidden; // 讓按鈕不會超出圓角邊界

        button,
        input {
            border: none;
            background: none;
            height: 40px;
            width: 40px;
            text-align: center;
        }

        button {
            cursor: pointer;
            font-size: 20px;

            &:hover {
                background: $accent-color-100;
            }
        }

        input {
            width: 50px; // 讓數字輸入框寬一點
            font-size: 16px;
        }
    }

    .delete-btn {
        background: none;
        border: none;
        cursor: pointer;
        color: $primary-color-700;
        font-size: 1.2rem;

        &:hover {
            color: $accent-color-700;
        }
    }
}

.subtotal-area {
    .subtotal-val {
        font-size: 1.2rem;
        font-weight: bold;
        color: #333;
    }
}

@media (max-width: 810px) {
    .product-card {
        padding: 15px;
        gap: 10px;
    }

    .image-wrapper {
        width: 150px;
        height: auto;
    }

    .action-row {
        gap: 5px;
    }
}

@media (max-width: 430px) {
    .product-card {
        flex-direction: column;
        align-items: center;
        padding: 20px;
        gap: 20px;
    }

    .image-wrapper {
        width: 100%;
        height: auto;
    }

    .content {
        width: 100%;
        flex-direction: column;
        align-items: flex-start;
    }

    .action-row {
        margin-left: auto;
    }

    .subtotal-area {
        align-self: flex-end;
        display: inline;
    }
}
</style>