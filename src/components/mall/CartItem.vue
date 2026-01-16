<script setup>
import { ref, computed, watch, onMounted } from 'vue';
// ⚠️ 請確認你的 JSON 路徑
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

// 只需要這兩個事件，不需要 mode 了
const emit = defineEmits(['update:quantity', 'remove']);

const product = ref(null);
const currentQty = ref(props.quantity);

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
  return Number(product.value.price) * currentQty.value;
});

const updateQuantity = (change) => {
  const newQty = currentQty.value + change;
  if (newQty < 1) return;

  currentQty.value = newQty;
  emit('update:quantity', { id: props.productId, quantity: newQty });
};

const getUnit = (name) => {
  if (!name) return '個';
  return name.includes('飯') ? '個' : '包';
};

watch(
  () => props.quantity,
  (newVal) => (currentQty.value = newVal)
);
</script>

<template>
  <div class="product-list"></div>
  <div class="product-card" v-if="product">
    <div class="image-wrapper">
      <img :src="product.images[0]" :alt="product.product_name" />
    </div>

    <div class="content">
      <div class="info">
        <p class="title p-p1">{{ product.product_name }}</p>
        <p class="price-unit p-p1">
          價格 : {{ product.price }}元/{{ getUnit(product.product_name) }}
        </p>
      </div>

      <div class="action-area">
        <div class="quantity-control">
          <button @click="updateQuantity(-1)" :disabled="currentQty <= 1">
            −
          </button>
          <input type="number" v-model.number="currentQty" readonly />
          <button @click="updateQuantity(1)">+</button>
        </div>

        <button class="delete-btn" @click="$emit('remove', product.id)">
          <i class="icon-trash">🗑️</i>
        </button>

        <div class="subtotal p-p1">${{ subtotal }}</div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.product-card {
  display: flex;
  background: $neutral-color-white;
  border: 1px solid $primary-color-700;
  border-radius: $radius-base;
  padding: 10px;
  margin-bottom: 16px;
  align-items: center;
  gap: 16px;
  width: 100%;
  box-sizing: border-box;
  width: 100%; // 預設佔滿
  max-width: 600px;

  @media (max-width: 768px) {
    padding: 12px;
    gap: 12px;
    flex-direction: column;
  }
}

.image-wrapper {
  width: 250px;
  height: 150px;
  flex-shrink: 0;
  border-radius: $radius-base;
  overflow: hidden;

  img {
    width: 100%;
    height: 100%;
    object-position: center;
    object-fit: contain;
  }
}

.content {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  flex: 1;

  @media (min-width: 769px) {
    height: auto;
  }
}

/* CartItem 專屬樣式 */
.action-area {
  display: flex;
  align-items: center;
  margin-top: auto;
  justify-content: flex-start;
  gap: 15px;

  .quantity-control {
    display: flex;
    align-items: center;
    background: $primary-color-100;
    border-radius: $radius-base;
    padding: 2px;

    button {
      background: none;
      border: none;
      width: 40px;
      /* 修正原本 150px 太寬的問題 */
      height: 40px;
      cursor: pointer;
      font-size: 16px;

      &:disabled {
        opacity: 0.3;
      }
    }

    input {
      width: 40px;
      text-align: center;
      border: none;
      background: transparent;
      font-size: 16px;

      &::-webkit-inner-spin-button {
        -webkit-appearance: none;
      }
    }
  }

  .delete-btn {
    background: none;
    border: none;
    cursor: pointer;
    font-size: 18px;
  }

  .subtotal {
    font-weight: bold;
    margin-left: auto;
    /* 讓小計靠右或是依你設計 */
  }
}
</style>
