<script setup>
import { ref, defineProps, computed, defineEmits, onMounted, onUnmounted } from 'vue';
import { useCartStore } from '@/stores/cartStore'
import ProductRmd from '@/components/mall/ProductRmd.vue';
import CartCard from '@/components/mall/CartCard.vue';
// 門禁守衛
import { useAuthGuard } from '@/composables/useAuthGuard';
const { runWithAuth } = useAuthGuard();
const cartStore = useCartStore()

// 計算總額
const totalAmount = computed(() => {
  return cartStore.items.reduce((total, item) => {
    return total + (item.product_price * (item.count || 0));
  }, 0);
});

// 前往結帳
const handleGoToCheckout = () => {
  runWithAuth(() => {
    // 只有在登入驗證通過後，才會執行這裡
    router.push('/checkout');
  });
};

// ==========================================
// nav淡出結帳預覽往上滑一點 nav出現回復
// ==========================================
const isScrollingDown = ref(false);
let lastScrollY = window.scrollY;

// 偵測往下滑或往上滑
const handleScroll = () => {
  const currentY = window.scrollY;
  isScrollingDown.value = currentY > lastScrollY;
  lastScrollY = currentY;
};
onMounted(() => {
  // 監聽滾動
  window.addEventListener('scroll', handleScroll);
});

onUnmounted(() => {
  // 清除監聽，避免 memory leak
  window.removeEventListener('scroll', handleScroll);
});
</script>

<template>
  <div class="container cart-page">
    <h2 class="zh-h2">購物車 Cart</h2>
    <hr class="divider">

    <div v-if="cartStore.items.length > 0" class="row">
      <div class="col-7 col-lg-12">
        <div class="cart-list">
          <CartCard v-for="item in cartStore.items" :key="item.product_id || item.id" :item="item" />
        </div>
        <router-link to="/mall">
          <BaseBtn title="前往Recimo商城" variant="outline" :width="210" />
        </router-link>
      </div>

      <div class="col-5 col-lg-12">
        <div class="summary-box" :class="{ 'is-nav-hidden': isScrollingDown }">
          <div class="summary-line">
            <span class="p-p1">小計：</span>
            <span class="amount p-p1">${{ cartStore.totalAmount }}</span>
          </div>
          <p class="shipping-note p-p1">運費 60 元，滿 1000 元免運</p>
          <BaseBtn title="前往結帳" width="100%" @click="handleGoToCheckout" />
        </div>
      </div>
    </div>

    <div v-else class="empty-state">
      <p>購物車目前沒有商品</p>
      <router-link to="/mall">
        <BaseBtn title="前往Recimo商城" variant="outline" :width="210" />
      </router-link>
    </div>

    <div class="recommend">
      <ProductRmd />
    </div>
  </div>
</template>

<style lang="scss" scoped>
.cart-page {
  padding-top: 30px;

  .divider {
    border: 0;
    border: 1px solid #B2B2B2;
    margin: 20px 0 40px;
  }
}

// 結帳預覽區塊
.summary-box {
  background-color: $neutral-color-100;
  padding: 40px 30px;
  border-radius: 4px;
  text-align: right;
  position: sticky;
  top: 100px;
  transition: top 0.3s ease;

  &.is-nav-hidden {
    top: 35px; // nav 隱藏時，大圖往上
  }

  @media (max-width: 1024px) {
    position: static;
  }

  .summary-line {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 1.1rem;
    font-weight: bold;
    margin-bottom: 10px;

    .amount {
      font-size: 1.3rem;
    }
  }

  .shipping-note {
    margin-bottom: 30px;
  }
}

// 空狀態與回商城按鈕
.empty-state {
  text-align: center;
  padding: 80px 0;

  p {
    font-size: 1.2rem;
    margin-bottom: 20px;
  }
}

.recommend {
  margin-top: 30px;
}

// 響應式微調 (小於 1024px 時結帳欄往下掉)
@media screen and (max-width: 1024px) {
  .summary-box {
    margin-top: 30px;
  }
}
</style>