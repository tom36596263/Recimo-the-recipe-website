<script setup>
import { ref, defineProps, computed, getCurrentInstance } from 'vue';
import { useCartStore } from '@/stores/cartStore';
import BaseModal from '@/components/BaseModal.vue';

// icon
import IconDelete from '~icons/material-symbols/delete-outline';

// 接收父元件傳過來的商品資料
const props = defineProps({
    item: {
        type: Object,
        required: true,
        default: () => ({})
    }
});

const baseURL = import.meta.env.BASE_URL;
const { proxy } = getCurrentInstance();
const cartStore = useCartStore();


// 控制 Modal 顯示狀態的變數
const showDeleteModal = ref(false);
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

const handleRemove = () => {
    // 不再使用 confirm()，改為打開自定義 Modal
    showDeleteModal.value = true;
};

// 當在 Modal 點擊「確定刪除」時執行的函式
const confirmDelete = () => {
    const id = props.item.id || props.item.product_id;
    cartStore.removeItem(id);
    showDeleteModal.value = false; // 刪除後關閉視窗
};

// 計算小計
const subtotal = computed(() => {
    const price = Number(props.item.product_price || props.item.price || 0);
    const qty = props.item.count || props.item.qty || 0;
    return price * qty;
});

// ==========================================
// 圖片路徑處理
// ==========================================
const parseFile = (url) => {
    if (!url) return '';
    // 移除 public/ 前綴並結合 baseURL (或是您的 base)
    const cleanPath = url.replace(/^public\//, '').replace(/^\//, '');
    return `${import.meta.env.BASE_URL}${cleanPath}`;
};

const productImage = computed(() => {
    const images = props.item.product_image;

    // 如果是陣列，找封面圖或第一張
    if (Array.isArray(images) && images.length > 0) {
        const coverImage = images.find(img => img.is_cover) || images[0];
        return proxy.$parsePublicFile(coverImage.image_url);
    }

    if (typeof images === 'string') {
        return proxy.$parsePublicFile(images);
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
                    價格 : {{ item.product_price || item.price }} 元 / 包</p>

                <div class="action-row">
                    <p class="qty-label p-p1">數量</p>
                    <div class="quantity-control">
                        <button @click.stop.prevent="handleDecrement">−</button>
                        <input type="number p-p1" :value="item.count || item.qty" readonly />
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