<script setup>
import { computed, ref } from 'vue';



// 1. 定義 Props：接收父層傳來的「單筆」訂單物件
const props = defineProps({
  order: {
    type: Object,
    required: true
  }
});

// 取得商品列表
const displayItems = computed(() => {
  return props.order.products || props.order.items || [];
});

// 取得收件人姓名 (判斷同訂購人或新增)
const receiverName = computed(() => {
  const info = props.order.purchaser_info;
  if (info) {
    // 如果是 'same' (同訂購人) 取 name，否則取 addname
    return info.shippingType === 'same' ? info.name : info.addname;
  }
  return props.order.receiver || '未知';
});

// 取得收件人電話
const receiverPhone = computed(() => {
  const info = props.order.purchaser_info;
  if (info) {
    return info.shippingType === 'same' ? info.phone : info.addphone;
  }
  return props.order.phone || '未知';
});

// 取得付款方式
const paymentText = computed(() => {
  const info = props.order.purchaser_info;

  // 1. 防呆：如果沒有 info 或 paymentMethod，回傳預設值
  if (!info || !info.paymentMethod) {
    return props.order.payment || '未付款'; // 嘗試抓外層 payment，真的沒有才回傳未付款
  }

  // 2. 轉成小寫並移除前後空白，避免 'Card' 或 ' card ' 導致對應失敗
  const method = String(info.paymentMethod).toLowerCase().trim();

  const map = {
    // 貨到付款
    'cod': '貨到付款',

    // 信用卡 (涵蓋常見的各種寫法)
    'card': '信用卡付款',
    'credit': '信用卡付款',
    'credit_card': '信用卡付款',
    'visa': '信用卡付款',
    'master': '信用卡付款',

    // 轉帳
    'transfer': '銀行轉帳',
    'atm': '銀行轉帳',
    'bank': '銀行轉帳'
  };

  // 3. 回傳對應中文，如果找不到，就直接顯示原本的英文代碼 (方便除錯)
  return map[method] || info.paymentMethod;
});


//定義 Emits：通知父層取消訂單
const emit = defineEmits(['cancel-order']);

const formatShortId = (value) => {
  if (!value) return '';
  const str = String(value);
  return str.length > 8 ? str.slice(-8) : str;
};

// 定義一個變數來判斷「是否可取消」
// 只有狀態為 0 (新訂單) 或 1 (已確認) 時回傳 true
const isCancellable = computed(() => {
  return props.order.status === 0 || props.order.status === 1;
});

// 定義按鈕顯示的文字
const buttonText = computed(() => {
  // 1. 已經取消的
  if (props.order.status === -1) {
    return '訂單已取消';
  }
  // 2. 還沒取消，但狀態已進展到無法取消 (已出貨、已完成)
  if (!isCancellable.value) {
    return '無法取消';
  }
  // 3. 可以取消 (新訂單、已確認)
  return '取消訂單';
});


// 狀態定義
const statusSteps = ['訂購成功', '訂單確認', '出貨', '送達'];

// 自動計算單筆訂單的總數量
const totalQuantity = computed(() => {
  if (!props.order.items || !Array.isArray(props.order.items)) return 0;
  return props.order.items.reduce((sum, item) => sum + item.qty, 0);
});

// 自動計算單筆訂單的總金額
const totalAmount = computed(() => {
  if (!props.order.items || !Array.isArray(props.order.items)) return 0;
  return props.order.items.reduce(
    (sum, item) => sum + item.price * item.qty,
    0
  );
});

// --- 控制彈窗的邏輯 ---
const showCancelModal = ref(false);
// 點擊「取消訂單」按鈕
const onCancel = () => {
  // 開啟彈窗
  if (props.order.status === -1) return;
  showCancelModal.value = true;
};


// 處理彈窗按下「送出」
const handleConfirmCancel = (data) => {
  console.log('正在取消訂單 ID:', props.order.id);
  console.log('取消原因:', data.reason);
  console.log('備註:', data.note);

  // 在這裡呼叫後端 API
  // await api.cancelOrder(...)

  // 關閉彈窗
  showCancelModal.value = false;
  alert('訂單取消申請已送出');

  emit('cancel-order', props.order.id);
};
</script>

<template>
  <div class="order-card">
    <div class="card-header">
      <div class="info-group">
        <div class="info-row p-p1">
          <span>訂購日期：{{ order.date }}</span>
          <div class="flex">
            <span>訂單編號：{{ formatShortId(order.id) }}</span>
            <span>物流編號：{{ order.trackingNo ? formatShortId(order.trackingNo) : '處理中' }}</span>
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
        :class="{ active: index <= order.status }">
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
          <span class="col-name p-p1">{{ item.product_name || item.name }}</span>
          <span class="col-qty p-p1">{{ item.count || item.qty || item.quantity }}</span>
          <span class="col-price p-p1">{{ item.product_price || item.price }}</span>
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
.order-card {
  background-color: $neutral-color-100;
  border-radius: $radius-base;
  padding: 24px;
  margin-bottom: 24px;
  /* 卡片與卡片之間的距離 */
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
    // flex-direction: column;
    // align-items: flex-end;
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



/* Status Bar */
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

/* Product List */
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
