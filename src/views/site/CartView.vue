<script setup>
//  setup: 這是 Vue 3 的語法糖，讓你不用寫 export default {}，且能直接使用變數和函式，開發效率最高。
// 所有的變數、函式、或是從 JSON 引入的資料都寫在script裡面。
import { ref, onMounted } from 'vue';
// 假設這是購物車目前的狀態 (通常來自 Pinia Store)
const cartItems = ref([
  { id: 'c1', productId: 1, quantity: 1 },
  { id: 'c2', productId: 15, quantity: 2 }
]);

const handleUpdateQty = ({ id, quantity }) => {
  // 注意：這裡邏輯要確認子元件傳回來的 id 是 productId 還是 cart item id
  const item = cartItems.value.find((i) => i.productId === id);
  if (item) item.quantity = quantity;
};

const handleRemoveItem = (prodId) => {
  cartItems.value = cartItems.value.filter((i) => i.productId !== prodId);
};
</script>

<template>
  <div class="cart-page">
    <h2>我的購物車</h2>
    <div class="container">
      <div class="row">
        <div class="col-12">
          <div class="cart-list">
            <CartItem
              v-for="item in cartItems"
              :key="item.id"
              :product-id="item.productId"
              :quantity="item.quantity"
              @update:quantity="handleUpdateQty"
              @remove="handleRemoveItem"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
//  lang="scss": 告訴 Vue 這裡要用 Scss 編譯
//  scoped: 確保這裡寫的 CSS 只會影響目前這個頁面，不會「跑去污染」到其他頁面的樣式。
</style>
