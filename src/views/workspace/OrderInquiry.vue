<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import OrderCard from '@/components/mall/OrderCard.vue';
import { publicApi } from '@/utils/publicApi';
import BaseModal from '@/components/BaseModal.vue';


// 資料容器
const ordersData = ref([]);
const currentPage = ref(1);
const pageSize = 2;

const activeTag = ref('全部訂單');
const selectedDate = ref('');

// 讀取資料
onMounted(async () => {
  try {
    //讀取剛結帳的訂單 (前端格式: id, date, status)
    const localOrders = JSON.parse(localStorage.getItem('mall_orders') || '[]');

    //讀取歷史訂單 (資料庫格式: ORDER_ID, CREATED, ORDER_STATUS)
    // 假設你的 json 檔案內容已經改成資料庫欄位名稱了
    const res = await publicApi.get('data/mall/orders.json');
    const jsonOrders = res.data || [];

    //合併資料
    ordersData.value = [...localOrders, ...jsonOrders];

  } catch (err) {
    console.error('讀取訂單失敗', err);
    const localOrders = JSON.parse(localStorage.getItem('mall_orders') || '[]');
    ordersData.value = localOrders;
  }
});

const tags = [
  { text: '全部訂單', width: '138px' },
  { text: '已確認訂單', width: '138px' },
  { text: '已出貨訂單', width: '138px' },
  { text: '已完成訂單', width: '138px' },
  { text: '已取消訂單', width: '138px' }
];

//狀態對照表 (維持不變，對應 0, 1, 2...)
const statusMapping = {
  "新訂單": 0,
  '已確認訂單': 1,
  '已出貨訂單': 2,
  '已完成訂單': 3,
  '已取消訂單': -1
};

//兼容資料庫與前端格式
const filteredProducts = computed(() => {
  let result = ordersData.value;

  // 過濾狀態
  if (activeTag.value !== '全部訂單') {
    const targetStatus = statusMapping[activeTag.value];

    result = result.filter((item) => {
      //優先抓 ORDER_STATUS，抓不到才抓 status
      const itemStatus = item.ORDER_STATUS !== undefined ? item.ORDER_STATUS : item.status;
      return itemStatus === targetStatus;
    });
  }

  //過濾日期
  if (selectedDate.value) {
    result = result.filter(item => {
      // 取得日期字串
      const rawDate = item.CREATED || item.date || '';

      // 格式處理：資料庫可能是 "2026-01-24 14:00:00"，我們只取前 10 碼 "2026-01-24"
      // 如果是前端存的 "2026-01-24" 也不會受影響
      const itemDate = String(rawDate).substring(0, 10);

      return itemDate === selectedDate.value;
    });
  }


  // 剛結帳完的訂單會在最上面
  result.sort((a, b) => {
    const dateA = new Date(a.CREATED || a.date);
    const dateB = new Date(b.CREATED || b.date);
    return dateB - dateA; // 降序
  });

  return result;
});

//頁碼計算 
const totalPages = computed(() => {
  if (filteredProducts.value.length === 0) return 0;
  return Math.ceil(filteredProducts.value.length / pageSize);
});

//分頁裁切
const paginatedOrders = computed(() => {
  const startIndex = (currentPage.value - 1) * pageSize;
  const endIndex = startIndex + pageSize;
  return filteredProducts.value.slice(startIndex, endIndex);
});

//事件處理
const selectTag = (tagName) => {
  activeTag.value = tagName;
  currentPage.value = 1;
}

const setPage = (page) => {
  currentPage.value = page;
  window.scrollTo({ top: 0, behavior: 'smooth' });
};

watch(selectedDate, () => {
  currentPage.value = 1;
});

const dateInput = ref(null);
const openCalender = () => {
  if (dateInput.value && dateInput.value.showPicker) {
    dateInput.value.showPicker();
  } else {
    dateInput.value.focus();
  }
}

//取消訂單邏輯
const showSuccessModal = ref(false);
const onCancel = (orderId) => {
  const targetIndex = ordersData.value.findIndex(order => {
    const currentId = order.ORDER_ID || order.id;
    return currentId === orderId;
  });

  if (targetIndex !== -1) {
    // 執行取消邏輯
    if (ordersData.value[targetIndex].ORDER_STATUS !== undefined) {
      ordersData.value[targetIndex].ORDER_STATUS = -1;
    } else {
      ordersData.value[targetIndex].status = -1;
    }

    // 更新本地存儲
    if (!ordersData.value[targetIndex].ORDER_ID) {
      const localOnly = ordersData.value.filter(o => !o.ORDER_ID);
      localStorage.setItem('mall_orders', JSON.stringify(localOnly));
    }

    // --- 重點：原本是 alert('訂單已成功取消')，現在改為開啟彈窗 ---
    showSuccessModal.value = true;
  }
}



</script>

<template>
  <div class="container">
    <div class="row">
      <div class="col-12">
        <div class="order-page">
          <div class="tag-container">
            <div class="mydate">
              <label for="mydate" @click="openCalender">
                <i class="fa-regular fa-calendar-days"></i> 訂購時間
              </label>
              <input type="date" id="mydate" ref="dateInput" v-model="selectedDate">
              <button v-if="selectedDate" @click="selectedDate = ''" class="clear-date-btn">x</button>
            </div>

            <div class="tag">
              <BaseTag v-for="item in tags" :key="item.text" :text="item.text" :width="130" :show-icon="false"
                :variant="activeTag === item.text ? 'primary' : 'action'" @click="selectTag(item.text)"></BaseTag>
            </div>
          </div>

          <div v-if="paginatedOrders.length === 0" class="no-data">
            目前沒有符合條件的訂單
          </div>

          <OrderCard v-else v-for="order in paginatedOrders" :key="order.ORDER_ID || order.id" :order="order"
            @cancel-order="onCancel" />
        </div>
      </div>
    </div>

    <div class="pagination" v-if="totalPages > 1">
      <button v-for="page in totalPages" :key="page" class="page-link" :class="{ active: currentPage === page }"
        @click="setPage(page)">
        {{ page }}
      </button>
    </div>
  </div>

  <div class="container">
    <BaseModal :is-open="showSuccessModal" type="success" icon-class="fa-solid fa-circle-check" title="訂單已成功取消"
      description="您的退款申請已在處理中，請留意後續通知。" @close="showSuccessModal = false">
      <template #actions>
      </template>
    </BaseModal>
  </div>
</template>

<style>
/* 你的 CSS 樣式保持原樣即可 */
.tag-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  margin-top: 24px;

  @media screen and (max-width:1200px) {
    flex-direction: column;
    align-items: flex-start;
    gap: 20px;
  }
}

.tag {
  display: flex;
  gap: 10px;

  @media screen and (max-width:1024px) {
    width: 100%;
    overflow-x: auto;
    overflow-y: hidden;
    -webkit-overflow-scrolling: touch;
    scrollbar-width: none;

    &::-webkit-scrollbar {
      display: none;
    }
  }

  >* {
    flex-shrink: 0;
  }
}

input[type=date] {
  height: 25px;
  cursor: pointer;
  margin-left: 5px;

  @media screen and (max-width:1024px) {
    height: 30px;
  }
}

.fa-calendar-days {
  cursor: pointer;
}

.mydate {
  display: flex;
  align-items: center;
}
</style>