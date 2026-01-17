import { ref, computed } from 'vue'
import { defineStore } from 'pinia'

const localStorageKey = 'CART'

const loadStorage = () => {
  // 讀取localStorage
  const cache = localStorage.getItem(localStorageKey)
  if (cache) {
    localStorage.setItem('KEY', JSON.stringify(value))
  }
}

export const useCartStore = defineStore('cart', () => {
  // 購物車內的商品清單
  const items = ref([])
  // 計算總數量、總金額
  const cartCount = computed(() => items.value.length)
  const totalPrice = computed(() => items.value.reduce((total, item) => total + (item.product_price * item.quantity), 0))

  // 加入購物車
  // value父層傳進來的物件
  // prod: 購物車裡面的每一個商品
  const add = (val) => {
    const target = items.value.find((prod) => prod.id === val.id)
    if (!target) {
      items.value.push({
        ...val,
        count: 1,
      })
      // 寫入localstorage
      localStorage.setItem(localStorage, items.value)
    } else {
      target.count++
    } window.localStorage.setItem('CART', JSON.stringify(items.value))
  }
  const clear = () => {
    items.value = []
  }

  return { items, cartCount, totalPrice, add, clear }
})