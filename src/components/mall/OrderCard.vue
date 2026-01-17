<script setup>
import { computed, ref } from 'vue';

// 1. 定義 Props：接收父層傳來的「單筆」訂單物件
const props = defineProps({
  order: {
    type: Object,
    required: true
  }
});

// 2. 定義 Emits：通知父層取消訂單
const emit = defineEmits(['cancel-order']);

// 狀態定義
const statusSteps = ['訂購成功', '訂單確認', '出貨', '送達'];

// 自動計算單筆訂單的總數量
const totalQuantity = computed(() => {
  return props.order.items.reduce((sum, item) => sum + item.qty, 0);
});

// 自動計算單筆訂單的總金額
const totalAmount = computed(() => {
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

  // 重要：通知父層 (訂單列表) 更新畫面或是移除該筆訂單
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
            <span>訂單編號：{{ order.id }}</span>
            <span>物流編號：{{ order.trackingNo }}</span>
          </div>
        </div>
        <div class="info-row p-p1">
          <span>收件人：{{ order.receiver }}</span>
          <span>手機號碼：{{ order.phone }}</span>
          <div class="flex">
            <span>配送方式：{{ order.method }}</span>
            <span>付款狀態：{{ order.payment }}</span>
          </div>
        </div>
      </div>
      <BaseBtn title="取消訂單" variant="outline" @click="onCancel" />
    </div>
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
      <li v-for="(item, idx) in order.items" :key="idx" class="product-item">
        <span class="col-name p-p1">{{ item.name }}</span>
        <span class="col-qty p-p1">{{ item.qty }}</span>
        <span class="col-price p-p1">${{ item.price }}</span>
      </li>
    </ul>
  </div>

  <div class="card-footer">
    <span class="summary-text p-p1">總數量：{{ totalQuantity }}</span>
    <span class="summary-text p-p1">總金額：${{ totalAmount }}</span>
  </div>

  <CanceModal :is-open="showCancelModal" @close="showCancelModal = false" @submit="handleConfirmCancel" />
</template>

<style lang="scss" scoped>
/* 樣式與之前相同，針對卡片設計 */
.order-card {
  background-color: $neutral-color-100;
  border-radius: $radius-base;
  padding: 24px;
  margin-bottom: 24px;
  /* 卡片與卡片之間的距離 */
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  font-family: sans-serif;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;

  @media (max-width: 530px) {
    flex-direction: column;
    align-items: flex-end;
  }
}

.info-row {
  display: flex;
  gap: 15px;
  margin-bottom: 15px;
  flex-wrap: wrap;
}

.flex {
  display: flex;
  gap: 10px;

  @media (max-width: 430px) {
    flex-direction: column;
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
