<script setup>
import { computed, ref } from 'vue';

const props = defineProps({
  order: {
    type: Object,
    required: true
  }
});

// 取得 ID
const orderId = computed(() => {
  return props.order.ORDER_ID || props.order.id || '';
});

// 取得日期
const orderDate = computed(() => {
  return props.order.CREATED || props.order.date || '剛剛';
});

// 取得物流 ID
const logisticsId = computed(() => {
  return props.order.LOGISTICS_ID || props.order.trackingNo || null;
});

// 取得收件人
const receiverName = computed(() => {
  // 資料庫欄位
  if (props.order.RECIPIENT_NAME) return props.order.RECIPIENT_NAME;

  //結帳頁常見格式
  if (props.order.purchaser_info) {
    return props.order.purchaser_info.name || props.order.purchaser_info.receiver;
  }

  // 一般扁平格式
  return props.order.receiver || props.order.name || '未知';
});

// 取得電話
const receiverPhone = computed(() => {
  if (props.order.RECIPIENT_PHONE) return props.order.RECIPIENT_PHONE;
  if (props.order.purchaser_info) return props.order.purchaser_info.phone;
  return props.order.phone || '未知';
});

// 取得訂單狀態
// 預設為 0 (訂購成功)
const orderStatus = computed(() => {
  if (props.order.ORDER_STATUS !== undefined) return props.order.ORDER_STATUS;
  if (props.order.status !== undefined) return props.order.status;
  return 0;
});

// 取得商品列表並標準化
// 不管來源是 cart 還是 order_product，都轉成統一格式給 template 用
const displayItems = computed(() => {
  // 嘗試取得陣列來源
  const items = props.order.products || props.order.items || [];

  if (!Array.isArray(items)) return [];

  return items.map(item => ({
    // 優先找資料庫的 PRODUCT_NAME
    name: item.PRODUCT_NAME || item.name || item.product_name || '未知商品',

    // 優先找資料庫 QUANTITY，沒有就找 qty, count
    qty: item.QUANTITY || item.qty || item.count || item.quantity || 0,

    // 優先找資料庫 SNAPSHOT_PRICE，沒有就找 price
    price: item.SNAPSHOT_PRICE || item.product_price || item.price || 0
  }));
});

// 計算總金額
const totalAmount = computed(() => {
  if (props.order.TOTAL_AMOUNT !== undefined) return props.order.TOTAL_AMOUNT;
  if (props.order.totalAmount !== undefined) return props.order.totalAmount;

  return displayItems.value.reduce((sum, item) => sum + (item.price * item.qty), 0);
});

// 計算總數量
const totalQuantity = computed(() => {
  return displayItems.value.reduce((sum, item) => sum + item.qty, 0);
});

// 取得付款方式 
const paymentText = computed(() => {
  const methodRaw = props.order.PAYMENT_METHOD || props.order.paymentMethod || props.order.payment;
  if (!methodRaw) return '未付款';

  const method = String(methodRaw).toLowerCase().trim();
  const map = {
    'cod': '貨到付款',
    'card': '信用卡付款', 'credit': '信用卡付款', 'visa': '信用卡付款', 'master': '信用卡付款',
    'transfer': '銀行轉帳', 'atm': '銀行轉帳', 'bank': '銀行轉帳'
  };
  return map[method] || methodRaw;
});


const emit = defineEmits(['cancel-order']);

const formatShortId = (value) => {
  if (!value) return '';
  const str = String(value);
  return str.length > 8 ? str.slice(-8) : str;
};

const isCancellable = computed(() => {
  return orderStatus.value === 0 || orderStatus.value === 1;
});

const buttonText = computed(() => {
  if (orderStatus.value === -1) return '訂單已取消';
  if (!isCancellable.value) return '無法取消';
  return '取消訂單';
});

const statusSteps = ['訂購成功', '訂單確認', '出貨', '送達'];

const showCancelModal = ref(false);

const onCancel = () => {
  if (orderStatus.value === -1) return;
  showCancelModal.value = true;
};

const handleConfirmCancel = (data) => {
  console.log('取消訂單 ID:', orderId.value);
  showCancelModal.value = false;
  emit('cancel-order', orderId.value);
};
</script>

<template>
  <div class="order-card">
    <div class="card-header">
      <div class="info-group">
        <div class="info-row p-p1">
          <span>訂購日期：{{ orderDate }}</span>
          <div class="flex">
            <span>訂單編號：{{ formatShortId(orderId) }}</span>
            <span>物流編號：{{ logisticsId ? formatShortId(logisticsId) : '處理中' }}</span>
          </div>
        </div>
        <div class="info-row p-p1">
          <span>收件人：{{ receiverName }}</span>
          <span>手機號碼：{{ receiverPhone }}</span>
          <div class="flex">
            <span>配送方式：宅配</span>
            <span>付款狀態：{{ paymentText }}</span>
          </div>
        </div>
      </div>
      <BaseBtn class="btn-status" :title="buttonText" :disabled="!isCancellable" variant="outline" @click="onCancel" />
    </div>

    <div class="status-bar p-p1">
      <div v-for="(step, index) in statusSteps" :key="index" class="status-step"
        :class="{ active: index <= orderStatus }">
        <div class="bar"></div>
        <span class="label">{{ step }}</span>
      </div>
    </div>

    <div class="product-section">
      <div class="list-header">
        <span class="col-name p-p1">商品名</span>
        <span class="col-qty p-p1">數量</span>
        <span class="col-price p-p1">金額</span>
      </div>

      <ul class="product-list">
        <li v-for="(item, idx) in displayItems" :key="idx" class="product-item">
          <span class="col-name p-p1">{{ item.name }}</span>
          <span class="col-qty p-p1">{{ item.qty }}</span>
          <span class="col-price p-p1">{{ item.price }}</span>
        </li>
      </ul>
    </div>

    <div class="card-footer">
      <span class="summary-text p-p1">總數量：{{ totalQuantity }}</span>
      <span class="summary-text p-p1">總金額：${{ totalAmount }}</span>
    </div>
  </div>
  <CanceModal :is-open="showCancelModal" @close="showCancelModal = false" @submit="handleConfirmCancel" />
</template>

<style lang="scss" scoped>
/* 樣式部分完全不用動，維持你原本的即可 */
.order-card {
  background-color: $neutral-color-100;
  border-radius: $radius-base;
  padding: 24px;
  margin-bottom: 24px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  font-family: sans-serif;

  @media (max-width: 390px) {
    padding: 15px;
  }
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
  gap: 16px;

  @media (max-width: 1024px) {
    gap: 0px;
  }

  @media (max-width: 540px) {
    flex-direction: column;
    align-items: flex-start;
  }
}

.info-row {
  display: flex;
  margin-bottom: 15px;
  flex-wrap: wrap;
  gap: 30px;

  @media (max-width: 1024px) {
    flex-direction: column;
    gap: 0;
  }
}

.flex {
  display: flex;
  gap: 30px;

  @media (max-width: 430px) {
    flex-direction: column;
    gap: 0;
  }
}

.status-bar {
  display: flex;
  justify-content: space-between;
  margin: 20px 0;
  gap: 8px;
}

.status-step {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  opacity: 0.4;
}

.status-step .bar {
  width: 100%;
  height: 4px;
  background-color: $primary-color-400;
  margin-bottom: 8px;
  border-radius: 2px;
}

.status-step+.status-step .bar {
  margin-left: 4px;
}

.status-step.active {
  opacity: 1;
}

.status-step.active .bar {
  background-color: $primary-color-700;
}

.status-step .label {
  font-weight: 500;
}

.product-section {
  margin-bottom: 20px;
}

.list-header,
.product-item {
  display: flex;
  padding: 12px 16px;
  align-items: center;
}

.product-item {
  background-color: $neutral-color-white;
  margin-bottom: 8px;
  border-radius: 4px;
}

.col-name {
  flex: 3;
  text-align: left;
}

.col-qty {
  flex: 1;
  text-align: center;
}

.col-price {
  flex: 1;
  text-align: right;
}

.card-footer {
  display: flex;
  justify-content: flex-end;
  gap: 20px;
  padding-top: 10px;
  font-weight: 500;
}
</style>