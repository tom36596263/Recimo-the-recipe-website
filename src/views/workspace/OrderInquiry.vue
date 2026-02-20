<script setup>
import { ref, onMounted, onUnmounted, computed, watch } from 'vue';
import OrderCard from '@/components/mall/OrderCard.vue';
import { phpApi } from '@/utils/publicApi';
import BaseModal from '@/components/BaseModal.vue';
import BaseTag from '@/components/common/BaseTag.vue';

// 資料容器
const ordersData = ref([]);
const currentPage = ref(1);
const pageSize = 5;
const activeTag = ref('全部訂單');
const selectedDate = ref('');
const showSuccessModal = ref(false);

// 讀取資料 (核心函式)
const fetchOrders = async () => {
  const userData = localStorage.getItem('user');
  if (!userData) return;

  const userInfo = JSON.parse(userData);

  // 嘗試所有可能的欄位名稱
  const userId = userInfo?.id || userInfo?.user_id || userInfo?.data?.id || userInfo?.data?.user_id;

  if (!userId) {
    console.error("解析不出 userId，請檢查內容:", userInfo);
    return;
  }

  try {
    // 1. 抓取訂單清單
    const resList = await phpApi.get('mall/user_order_list.php', {
      params: { user_id: userId }
    });

    const list = Array.isArray(resList.data) ? resList.data : [];

    // 2. 併發抓取明細
    const detailedOrders = await Promise.all(
      list.map(async (basicOrder) => {
        try {
          // 相容大小寫
          const oid = basicOrder.order_id || basicOrder.ORDER_ID;
          const resDetail = await phpApi.get('mall/user_order.php', {
            params: {
              id: oid,
              user_id: userId
            }
          });
          return resDetail.data;
        } catch (e) {
          console.error(`訂單 ${basicOrder.order_id} 詳情失敗`, e);
          return basicOrder;
        }
      })
    );

    ordersData.value = detailedOrders;

  } catch (err) {
    console.error('讀取訂單失敗', err);
  }
};

// 監聽頁面可見性變化
const handleVisibilityChange = () => {
  if (document.visibilityState === 'visible') {
    // 當使用者切換分頁或是從綠界跳轉回來時，重新抓一次資料
    // 這裡原本寫 startPolling()，因為函式被刪了所以報錯，改成 fetchOrders()
    fetchOrders();
  }
};

onMounted(() => {
  // 進來頁面直接抓一次
  // 這裡原本寫 startPolling()，因為函式被刪了所以報錯，改成 fetchOrders()
  fetchOrders();

  window.addEventListener('visibilitychange', handleVisibilityChange);
});

onUnmounted(() => {
  window.removeEventListener('visibilitychange', handleVisibilityChange);
});

// --- 以下篩選與分頁邏輯保持不變 ---

const tags = [
  { text: '全部訂單', width: '138px' },
  { text: '已確認訂單', width: '138px' },
  { text: '已出貨訂單', width: '138px' },
  { text: '已完成訂單', width: '138px' },
  { text: '已取消訂單', width: '138px' }
];

const statusMapping = {
  "新訂單": 0,
  '已確認訂單': 1,
  '已出貨訂單': 2,
  '已完成訂單': 3,
  '已取消訂單': -1
};

const filteredProducts = computed(() => {
  let result = ordersData.value;

  if (activeTag.value !== '全部訂單') {
    const targetStatus = statusMapping[activeTag.value];
    result = result.filter((item) => {
      // 確保相容 PHP 回傳的各種 key 大小寫
      const rawStatus = item.ORDER_STATUS ?? item.order_status ?? item.status;
      return Number(rawStatus) === Number(targetStatus);
    });
  }

  if (selectedDate.value) {
    result = result.filter(item => {
      const rawDate = item.created || item.CREATED || '';
      return String(rawDate).substring(0, 10) === selectedDate.value;
    });
  }

  result.sort((a, b) => {
    const dateA = new Date(a.CREATED || a.created || a.date);
    const dateB = new Date(b.CREATED || b.created || b.date);
    return dateB - dateA;
  });

  return result;
});

const totalPages = computed(() => {
  if (filteredProducts.value.length === 0) return 0;
  return Math.ceil(filteredProducts.value.length / pageSize);
});

const paginatedOrders = computed(() => {
  const startIndex = (currentPage.value - 1) * pageSize;
  const endIndex = startIndex + pageSize;
  return filteredProducts.value.slice(startIndex, endIndex);
});

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

// 取消訂單
const onCancel = async (orderId) => {
  const userInfo = JSON.parse(localStorage.getItem('user'));
  const currentUserId = userInfo?.id || userInfo?.user_id;

  if (!currentUserId) {
    alert("無法取得使用者資訊，請重新登入");
    return;
  }

  try {
    const res = await phpApi.post('mall/cancel_order.php', {
      user_id: currentUserId,
      order_id: orderId
    });

    if (res.data.success) {
      // 成功後直接重抓一次資料，確保狀態同步
      fetchOrders();
      showSuccessModal.value = true;
    }
  } catch (err) {
    console.error('取消失敗:', err);
    alert('取消失敗，請稍後再試');
  }
};
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

.pagination {
  margin-bottom: 100px;
}
</style>