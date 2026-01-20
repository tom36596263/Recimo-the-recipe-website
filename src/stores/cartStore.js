import { ref, computed, watch } from 'vue'
import { defineStore } from 'pinia'

export const useCartStore = defineStore('cart', () => {
  // 初始化：從 LocalStorage 讀取資料
  const items = ref(JSON.parse(localStorage.getItem('CART_DATA')) || [])

  // 計算總金額
  const totalAmount = computed(() => {
    return items.value.reduce((total, item) => {
      // 兼容 count 或 qty 欄位
      const quantity = item.count || item.qty || 0
      const price = item.product_price || item.price || 0
      return total + (price * quantity)
    }, 0)
  })

  // 監聽 items 變化並寫入 LocalStorage
  watch(items, (newVal) => {
    localStorage.setItem('CART_DATA', JSON.stringify(newVal))
  }, { deep: true })

  // --- Actions ---

  // 1. 加入購物車 (給推薦商品 ProductCard 使用)
  // 1. 加入購物車 (相容 ProductCard 預設加1，也相容詳情頁傳入指定數量)
  const add = (val, qty = 1) => { // 新增第二個參數 qty
    const productId = val.product_id || val.id;

    if (!productId) {
      console.error("加入購物車失敗：商品資料缺少 ID", val);
      return;
    }

    const target = items.value.find((prod) => {
      const targetId = prod.product_id || prod.id;
      return targetId === productId;
    });

    if (!target) {
      // 如果是新商品，推入陣列
      items.value.push({
        ...val,
        product_id: productId,
        count: qty, // 使用傳入的數量
        product_price: Number(val.product_price || val.price || 0)
      });
    } else {
      // 如果已存在，累加傳入的數量
      if (target.count !== undefined) {
        target.count += qty; // 累加 qty 而不是 ++
      } else {
        target.count = (target.qty || 0) + qty;
      }
    }

    console.log('當前購物車內容:', items.value);
  };

  // 2. 增加數量 (給購物車清單 CartCard 使用)
  const incrementQty = (id) => {
    const target = items.value.find(i => (i.id === id || i.product_id === id))
    if (target) {
      if (target.count !== undefined) target.count++
      else target.qty++
    }
  }

  // 3. 減少數量 (給購物車清單 CartCard 使用)
  const decrementQty = (id) => {
    const target = items.value.find(i => (i.id === id || i.product_id === id))
    if (target) {
      const currentQty = target.count || target.qty || 1
      if (currentQty > 1) {
        if (target.count !== undefined) target.count--
        else target.qty--
      } else {
        removeItem(id) // 減到 0 時移除
      }
    }
  }

  // 4. 移除商品
  const removeItem = (id) => {
    items.value = items.value.filter(i => (i.id !== id && i.product_id !== id))
  }

  // 5. 清空購物車
  const clear = () => {
    items.value = []
  }

  return {
    items,
    totalAmount,
    add,
    incrementQty,
    decrementQty,
    removeItem,
    clear
  }
})