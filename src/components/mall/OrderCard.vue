<script setup>
import { computed } from 'vue';

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

const handleCancel = () => {
  emit('cancel-order', props.order.id);
};
</script>

<template>
  <div class="order-card">
    <div class="card-header">
      <div class="info-group">
        <div class="info-row p-p1">
          <span>訂購日期：{{ order.date }}</span>
          <span>訂單編號：{{ order.id }}</span>
          <span>物流編號：{{ order.trackingNo }}</span>
        </div>
        <div class="info-row p-p1">
          <span>收件人：{{ order.receiver }}</span>
          <span>手機號碼：{{ order.phone }}</span>
          <span>配送方式：{{ order.method }}</span>
          <span>付款狀態：{{ order.payment }}</span>
        </div>
      </div>
      <BaseBtn title="取消訂單" variant="outline" @click="handleDelete" />
    </div>

    <div class="status-bar p-p1">
      <div
        v-for="(step, index) in statusSteps"
        :key="index"
        class="status-step"
        :class="{ active: index <= order.status }"
      >
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
  </div>
</template>

<style scoped>
/* 樣式與之前相同，針對卡片設計 */
.order-card {
  background-color: #fff;
  border-radius: 8px;
  padding: 24px;
  margin-bottom: 24px; /* 卡片與卡片之間的距離 */
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  font-family: sans-serif;
  color: #333;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
}

.info-row {
  display: flex;
  gap: 24px;
  margin-bottom: 12px;
  font-size: 14px;
  color: #333;
  flex-wrap: wrap;
}

/* Status Bar */
.status-bar {
  display: flex;
  justify-content: space-between;
  margin: 30px 0;
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
  background-color: #ddd;
  margin-bottom: 8px;
  border-radius: 2px;
}

.status-step + .status-step .bar {
  margin-left: 4px;
}

.status-step.active {
  opacity: 1;
  color: #2c3e50;
}

.status-step.active .bar {
  background-color: #68b684;
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

.list-header {
  color: #666;
  border-bottom: 2px solid #68b684; /* 綠色底線 */
  margin-bottom: 10px;
}

.product-item {
  background-color: #fcfcfc;
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
