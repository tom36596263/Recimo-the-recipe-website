// stores/cartStore.js
import { defineStore } from 'pinia';

export const useCartStore = defineStore('cart', {
  state: () => ({
    cartList: [] // 存放購物車內容
  }),
  actions: {
    addToCart(product, qty = 1) {
      // 這裡寫邏輯：如果重複就加數量，沒重複就 push
      this.cartList.push({ ...product, qty });
      alert('已加入購物車！');
    }
  },
  getters: {
    cartCount: (state) => state.cartList.length // 計算購物車有幾件商品
  }
});
