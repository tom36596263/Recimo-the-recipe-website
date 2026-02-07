<script setup>
import { computed, ref } from 'vue';

const props = defineProps({
  order: {
    type: Object,
    required: true
  }
});

// 取得 ID (若無則隨機 6 碼)
const orderId = computed(() => {
  // 嘗試取得真實資料
  return props.order.order_id || props.order.ORDER_ID || props.order.id;

  // 如果有真實 ID，就用真實的
  if (realId) return realId;

  // 否則：隨機產生 6 碼數字 (100000 ~ 999999)
  // 加上 .toString() 確保格式統一為字串
  return Math.floor(100000 + Math.random() * 900000).toString();
});

// 取得日期
const orderDate = computed(() => {
  return props.order.created || props.order.CREATED || props.order.date || '剛剛';
});

// 取得物流 ID (若無或為"1"則隨機 7 碼)
const logisticsId = computed(() => {
  // 1. 優先找 PHP 給的小寫 logistics_id
  const dbVal = props.order.logistics_id ||
    props.order.LOGISTICS_ID ||
    props.order.trackingNo;

  //只要有值就顯示，不論長度（除非你真的想排除掉測試用的 "1"）
  if (dbVal !== undefined && dbVal !== null && dbVal !== '') {
    return dbVal;
  }

  //真的沒資料才隨機產生
  return Math.floor(1000000 + Math.random() * 9000000).toString();
});

// 取得收件人
const receiverName = computed(() => {
  // 增加對小寫 recipient_name 的判斷
  return props.order.recipient_name ||
    props.order.RECIPIENT_NAME ||
    props.order.receiver ||
    props.order.name ||
    '未知';
});

// 取得電話
const receiverPhone = computed(() => {
  // 增加對小寫 recipient_phone 的判斷
  return props.order.recipient_phone ||
    props.order.RECIPIENT_PHONE ||
    props.order.phone ||
    '未知';
});

const orderStatus = computed(() => {
  const s = (props.order.order_status !== undefined && props.order.order_status !== null)
    ? props.order.order_status
    : (props.order.ORDER_STATUS !== undefined ? props.order.ORDER_STATUS : props.order.status);

  return s !== undefined ? Number(s) : 0;
});

// 取得商品列表並標準化
const displayItems = computed(() => {
  const items = props.order.items || props.order.products || [];
  if (!Array.isArray(items)) return [];

  return items.map(item => {
    // 1. 取得單價
    const price = item.snapshot_price || item.SNAPSHOT_PRICE || item.product_price || item.price || 0;
    // 2. 取得數量
    const qty = item.quantity || item.QUANTITY || item.qty || 0;

    return {
      name: item.product_name || item.PRODUCT_NAME || item.name || '未知商品',
      qty: qty,
      //這裡修正：將單價乘以數量，得到該品項的總計
      price: price * qty
    };
  });
});

// 計算總金額
const totalAmount = computed(() => {
  // 優先讀取後端回傳的 total_amount，接著是其他可能的變數名
  const amount = props.order.total_amount ??
    props.order.TOTAL_AMOUNT ??
    props.order.totalAmount;

  if (amount !== undefined && amount !== null) return amount;

  // 如果後端沒給總金額，才用商品列表累加
  return displayItems.value.reduce((sum, item) => sum + Number(item.price), 0);
});

// 計算總數量
const totalQuantity = computed(() => {
  return displayItems.value.reduce((sum, item) => sum + Number(item.qty), 0);
});

// 取得付款方式 
// 取得付款方式 (修正版)
const paymentText = computed(() => {
  const methodRaw = props.order.payment_method ?? props.order.PAYMENT_METHOD;
  const payStatusRaw = props.order.payment_status ?? props.order.PAYMENT_STATUS;
  const currentStatus = orderStatus.value;

  if (methodRaw === undefined || methodRaw === null) return '未付款';

  const method = String(methodRaw); // '1' 信用卡, '2' 貨到付款
  const payStatus = Number(payStatusRaw); // 0 待付, 1 已付, 2 已退款

  const map = {
    '1': '信用卡付款',
    '2': '貨到付款'
  };

  const methodName = map[method] || `方式(${method})`;

  // 1. 如果資料庫已經明確標記為「已退款 (2)」
  if (payStatus === 2) {
    return `${methodName} (已退款)`;
  }

  // 2. 如果訂單已取消 (-1)
  if (currentStatus === -1) {
    // 信用卡 (1)：因為通常是先付款，所以顯示已退款（或由後端邏輯確保 payStatus 變為 2）
    if (method === '1') {
      return `${methodName} (已退款)`;
    }
    // 貨到付款 (2)：使用者沒付錢，顯示「已取消」或「無需付款」更準確
    return `${methodName} (已取消)`;
  }

  // 3. 正常流程判定
  // 貨到付款在「已送達 (3)」之前都算待付款；信用卡則看 payStatus
  const isPaid = (method === '1' && payStatus === 1) || (method === '2' && currentStatus >= 3);

  return isPaid ? `${methodName} (已付)` : `${methodName} (待付款)`;
});

console.log('收到訂單資料:', props.order);
const emit = defineEmits(['cancel-order']);

// 格式化 ID (超過 8 碼才截斷，現在隨機產生的 6/7 碼不會被截斷)
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

// 子層：確認取消按鈕動作
const handleConfirmCancel = (data) => {
  // 確保這裡傳出去的是真實的 orderId
  emit('cancel-order', orderId.value);
  showCancelModal.value = false;
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
            <span>物流編號：{{ formatShortId(logisticsId) }}</span>
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
/* 樣式保持不變 */
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