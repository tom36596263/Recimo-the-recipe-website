import { ref, computed, watch } from 'vue'
import { defineStore } from 'pinia'
// 呼叫Api
import { phpApi } from '@/utils/publicApi.js';
// 引入權限檢查
import { useAuthStore } from '@/stores/authStore';


// ==========================================
// 加入購物車前置作業
// ==========================================
export const useCartStore = defineStore('cart', () => {
  const authStore = useAuthStore();
  const items = ref([]); // 預設空陣列，改由 API 載入

  // 從 localStorage 初始化本地購物車 (為了訪客)
  const initLocalCart = () => {
    if (!authStore.isLoggedIn) {
      const localData = localStorage.getItem('guest_cart');
      if (localData) {
        items.value = JSON.parse(localData);
      }
    }
  };
  initLocalCart();

  // 監聽登入狀態
  // 當 authStore.isLoggedIn 從 true 變 false 時，自動清空本地購物車
  // 合併訪客購物車到資料庫
  const mergeCart = async () => {
    const localData = localStorage.getItem('guest_cart');
    if (!localData) return;
    const guestItems = JSON.parse(localData);

    for (const item of guestItems) {
      try {
        await phpApi.post('mall/add_cartitem.php', {
          product_id: item.product_id || item.id,
          quantity: item.quantity || item.count || 1
        });
      } catch (e) {
        console.error("合併商品失敗:", item.product_id);
      }
    }
    localStorage.removeItem('guest_cart');
    await fetchCart();
  };

  // 然後才執行監聽
  watch(() => authStore.isLoggedIn, async (newVal) => {
    if (!newVal) {
      items.value = [];
      initLocalCart();
    } else {
      await mergeCart();
    }
  }, { immediate: true });

  // 計算商品總數量 (給 Navbar 小紅點使用)
  const totalCount = computed(() => {
    return items.value.reduce((total, item) => total + Number(item.quantity || 0), 0);
  });

  // 計算總金額
  const totalAmount = computed(() => {
    return items.value.reduce((total, item) => {
      const price = Number(item.product_price || 0);
      const q = Number(item.quantity || 0);
      return total + (price * q);
    }, 0);
  });

  // ==========================================
  // 獲取購物車內容
  // ==========================================
  // 初始化：從 API 獲取購物車
  const fetchCart = async () => {
    if (!authStore.isLoggedIn) return;
    try {
      const response = await phpApi.get('mall/get_cart.php', {
        withCredentials: true // 這行沒加，PHP 就拿不到 Session ID
      });
      if (response.data.status === 'success') {
        const rawData = response.data.data || [];

        items.value = rawData.map(item => {
          let imageUrl = '';
          try {
            // 1. 把 product_image 字串轉成真正的 JS 陣列
            const images = JSON.parse(item.product_image);
            // 2. 找到封面圖 (is_cover 為 true 的那張)
            const cover = images.find(img => img.is_cover) || images[0];
            imageUrl = cover ? cover.image_url : '';
          } catch (e) {
            console.error("解析圖片路徑失敗", e);
          }

          return {
            ...item,
            // 3. 把處理好的路徑覆蓋回去，並確保加上伺服器基礎路徑 (base)
            product_image: imageUrl
          };
        });
      }
    } catch (error) {
      console.error("載入購物車失敗", error);
    }
  };

  // ==========================================
  // 加入購物車
  // ==========================================
  const add = async (item, qty = 1) => {
    const productId = item.product_id || item.id;
    const index = items.value.findIndex(p => (p.product_id || p.id) === productId);

    if (index !== -1) {
      // 統一用 quantity
      items.value[index].quantity = Number(items.value[index].quantity || 0) + qty;
    } else {
      items.value.push({ ...item, product_id: productId, quantity: qty });
    }

    // 分流處理
    if (authStore.isLoggedIn) {
      // A. 已登入：同步到資料庫
      await phpApi.post('mall/add_cartitem.php', { product_id: productId, quantity: qty });
    } else {
      // B. 訪客：存入 localStorage
      localStorage.setItem('guest_cart', JSON.stringify(items.value));
    }
  };


  // ==========================================
  // 更新商品數量
  // ==========================================
  const updateQty = async (id, newQty) => {
    if (newQty < 1) return removeItem(id);

    const index = items.value.findIndex(i => (i.product_id === id || i.id === id));
    if (index !== -1) {
      const val = Number(newQty);
      // 強制替換物件確保反應性
      items.value[index] = { ...items.value[index], quantity: val };

      if (authStore.isLoggedIn) {
        try {
          await phpApi.post('mall/update_cartitem.php', { product_id: id, quantity: val });
        } catch (error) {
          console.error("API 更新數量失敗", error);
        }
      } else {
        localStorage.setItem('guest_cart', JSON.stringify(items.value));
      }
      items.value = [...items.value];
    }
  };

  // 增加
  const incrementQty = (id) => {
    const target = items.value.find(i => (i.product_id === id || i.id === id));
    if (target) updateQty(id, Number(target.quantity || 0) + 1);
  };

  // 減少
  const decrementQty = (id) => {
    const target = items.value.find(i => (i.product_id === id || i.id === id));
    if (target) updateQty(id, Number(target.quantity || 0) - 1);
  };

  // 移除商品
  const removeItem = async (id) => {
    items.value = items.value.filter(i => (i.product_id !== id && i.id !== id));
    if (authStore.isLoggedIn) {
      try {
        await phpApi.post('mall/delete_cartitem.php', { product_id: id });
      } catch (error) {
        console.error("伺服器刪除失敗", error);
      }
    } else {
      //  訪客同步到 localStorage
      localStorage.setItem('guest_cart', JSON.stringify(items.value));
    }
  };

  // ==========================================
  // 清空購物車
  // ==========================================
  const clear = (syncWithServer = true) => {
    items.value = []; // 本地先歸零

    // 只有當 syncWithServer 為 true 時，才去打後端 API
    if (syncWithServer && authStore.isLoggedIn) {
      phpApi.post('mall/clear_cart.php');
    }
  };

  return { items, totalCount, totalAmount, fetchCart, add, incrementQty, decrementQty, removeItem, clear, mergeCart, initLocalCart, fetchCart };
});