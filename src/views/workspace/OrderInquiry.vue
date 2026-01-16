<script setup>
import { ref } from 'vue';
// 模擬 API 拿到的資料 (Mock Data)
const orders = ref([
  {
    id: '111018',
    date: '114/11/03',
    trackingNo: '1211031',
    receiver: '王小花',
    phone: '0952875365',
    method: '宅配',
    payment: '貨到付款',
    status: 1, // 對應到 '訂單確認'
    items: [
      { name: '舒肥雞胸藜麥飯', qty: 1, price: 160 },
      { name: '豆腐漢堡排佐野菇', qty: 1, price: 150 }
    ]
  },
  {
    id: '111019',
    date: '114/11/04',
    trackingNo: '1211032',
    receiver: '李大明',
    phone: '0912345678',
    method: '超商取貨',
    payment: '已付款',
    status: 3, // 對應到 '送達'
    items: [{ name: '鮮蝦義大利麵', qty: 2, price: 220 }]
  },
  {
    id: '111019',
    date: '114/11/04',
    trackingNo: '1211032',
    receiver: '李大明',
    phone: '0912345678',
    method: '超商取貨',
    payment: '已付款',
    status: 3, // 對應到 '送達'
    items: [{ name: '鮮蝦義大利麵', qty: 2, price: 220 }]
  }
]);

const onCancel = (orderId) => {
  alert(`使用者點擊取消訂單: ${orderId}`);
  // 這裡可以呼叫後端 API 執行取消邏輯
};
</script>

<template>
  <div class="order-page">
    <h2>我的訂單</h2>
    <OrderCard
      v-for="order in orders"
      :key="order.id"
      :order="order"
      @cancel-order="onCancel"
    />
  </div>
</template>

<style>
/* .order-page {
  padding: 20px;
  padding-bottom: 80px;
  margin-bottom: 20px;
  height: calc(100vh - 200px);
  overflow-y: auto;
} */
</style>
