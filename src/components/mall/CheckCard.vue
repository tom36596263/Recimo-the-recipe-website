<script setup>
import { computed } from 'vue';

// 1. 接收父層傳來的資料
const props = defineProps({
  productName: {
    type: String,
    default: ''
  },
  quantity: {
    type: Number,
    default: 0
  },
  price: {
    type: Number,
    default: 0
  },
  image: {
    type: String,
    default: ''
  }
});

// 2. 計算小計 (單價 * 數量)
// 直接使用 props.price 和 props.quantity 計算
const subtotal = computed(() => {
  return props.price * props.quantity;
});


const cleanImage = computed(() => {
  if (props.image && props.image.startsWith('public/')) {
    return props.image.replace('public/', '/');
  }
  return props.image;
});

</script>

<template>
  <div class="product-card">
    <div class="image-wrapper">
      <img :src="cleanImage" :alt="productName" />
    </div>

    <div class="content">
      <div class="info">
        <p class="title p-p1">{{ productName }}</p>
        <p class="price-unit p-p1">
          價格 : {{ price }}元/包
        </p>
      </div>

      <div class="action-area">
        <p class="qty-text p-p1">數量 : {{ quantity }}</p>
        <p class="subtotal-text p-p1">小計 : ${{ subtotal }}</p>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
/* 共用結構樣式 */
.product-card {
  display: flex;
  border: 1px solid $primary-color-700;
  border-radius: $radius-base;
  padding: 16px;
  margin-bottom: 16px;
  align-items: center;
  gap: 16px;
  width: 100%;
  box-sizing: border-box;

  @media (max-width: 1024px) {
    flex-direction: column;
    align-items: flex-start;
    padding: 12px;
    gap: 12px;
  }
}

.image-wrapper {
  width: 250px;
  flex-shrink: 0;
  overflow: hidden;

  @media (max-width: 1024px) {
    width: 100%;
  }

  img {
    width: 100%;
    // height: 100%;
    border-radius: $radius-base;
    // object-position: center;
    object-fit: cover;

    @media (max-width: 768px) {
      width: 280px;
    }
  }
}

.content {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  width: 100%;
  // max-width: 300px;

  @media (min-width: 769px) {
    height: auto;
  }
}

/* CheckoutItem 專屬樣式 */
.action-area {
  display: flex;
  flex-direction: column; // 結帳頁垂直排列
  align-items: flex-start;
  margin-top: auto;
  gap: 8px;

  .subtotal-text {
    font-weight: bold;
  }
}
</style>
