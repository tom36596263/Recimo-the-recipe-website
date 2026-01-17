<script setup>
import { ref, computed, onMounted } from 'vue';
import productsData from '../../../public/data/mall/products.json';

const props = defineProps({
  productId: {
    type: Number,
    required: true
  },
  quantity: {
    type: Number,
    default: 1
  }
});

// 結帳頁面通常不需要 emit 修改數量，所以刪除 emits

const product = ref(null);

onMounted(() => {
  if (Array.isArray(productsData)) {
    const found = productsData.find((p) => p.id === props.productId);
    if (found) {
      product.value = found;
    }
  }
});

const subtotal = computed(() => {
  if (!product.value) return 0;
  return Number(product.value.price) * props.quantity;
});


</script>

<template>
  <div class="product-card" v-if="product">
    <div class="image-wrapper">
      <img :src="product.images[0]" :alt="product.product_name" />
    </div>

    <div class="content">
      <div class="info">
        <p class="title p-p1">{{ product.product_name }}</p>
        <p class="price-unit p-p1">
          價格 : {{ product.price }}元/包
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
