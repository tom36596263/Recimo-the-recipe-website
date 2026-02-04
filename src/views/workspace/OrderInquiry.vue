<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import OrderCard from '@/components/mall/OrderCard.vue';
// import { publicApi } from '@/utils/publicApi';
import { phpApi } from '@/utils/publicApi';
import BaseModal from '@/components/BaseModal.vue';
import BaseTag from '@/components/common/BaseTag.vue';

// 資料容器
const ordersData = ref([]);
const currentPage = ref(1);
const pageSize = 5;
const activeTag = ref('全部訂單');
const selectedDate = ref('');
// const userInfo = JSON.parse(localStorage.getItem('user_info'));
// const userId = userInfo?.id || userInfo?.user_id || null;

// console.log("從 localStorage 抓到的原始資料:", userInfo);
// console.log("最終解析出的 userId:", userId);

// if (!userId) {
//   console.error("錯誤：抓不到使用者 ID，請重新登入！");
//   // 可以導向登入頁面
// }

// 讀取資料
const fetchOrders = async () => {
  const userData = localStorage.getItem('user');
  if (!userData) {
    console.error("找不到使用者登入資訊 (Key: 'user')");
    return;
  }
  const userInfo = JSON.parse(userData);
  //確保抓到 id (根據內容是小寫 id)
  const userId = userInfo?.id;

  if (!userId) {
    console.error("解析不出 userId，請檢查內容:", userInfo);
    return;
  }
  console.log("成功抓到當前登入者 ID:", userId);
  try {
    //抓取訂單清單
    const resList = await phpApi.get('mall/user_order_list.php', {
      params: { user_id: userId }
    });

    const list = Array.isArray(resList.data) ? resList.data : [];

    // 併發抓取每一筆的明細 (包含 items)
    const detailedOrders = await Promise.all(
      list.map(async (basicOrder) => {
        try {
          const oid = basicOrder.order_id || basicOrder.ORDER_ID;
          const resDetail = await phpApi.get('mall/user_order.php', {
            params: {
              id: oid,
              user_id: userId
            }
          });
          // PHP 回傳的結構通常是 { ..., items: [...] }
          return resDetail.data;
        } catch (e) {
          console.error(`訂單 ${basicOrder.order_id} 詳情讀取失敗`, e);
          return basicOrder;
        }
      })
    );

    ordersData.value = detailedOrders;

  } catch (err) {
    console.error('讀取訂單失敗', err);
  }
};

const handleVisibilityChange = () => {
  if (document.visibilityState === 'visible') {
    console.log('偵測到回到頁面，自動更新訂單狀態...');
    fetchOrders(); // 執行您原本抓取資料的函數
  }
};

onMounted(() => {
  fetchOrders();
  window.addEventListener('visibilitychange', handleVisibilityChange);
  // 額外保險：當視窗獲得焦點時也觸發
  window.addEventListener('focus', fetchOrders);
});

// 記得在組件卸載時移除監聽，避免記憶體洩漏
import { onUnmounted } from 'vue';
onUnmounted(() => {
  window.removeEventListener('visibilitychange', handleVisibilityChange);
  window.removeEventListener('focus', fetchOrders);
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
      const rawStatus = item.ORDER_STATUS ?? item.order_status ?? item.status;
      // 使用 == (雙等於) 或 Number() 強制轉型，確保 "1" 等於 1
      return Number(rawStatus) === targetStatus;
    });
  }

  //過濾日期
  if (selectedDate.value) {
    result = result.filter(item => {
      const rawDate = item.created || item.CREATED || '';
      return String(rawDate).substring(0, 10) === selectedDate.value;
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
const onCancel = async (orderId) => {
  // 【新增】在這裡定義 userId，否則第 181 行會報錯
  const userInfo = JSON.parse(localStorage.getItem('user'));
  const currentUserId = userInfo?.id || userInfo?.user_id;

  if (!currentUserId) {
    alert("無法取得使用者資訊，請重新登入");
    return;
  }

  console.log("發送取消請求 - UserID:", currentUserId, "OrderID:", orderId);

  try {
    const res = await phpApi.post('mall/cancel_order.php', {
      user_id: currentUserId, // 🌟 使用剛剛定義的變數
      order_id: orderId
    });

    if (res.data.success) {
      //後端成功後，更新本地資料狀態，讓畫面即時變化
      const targetIndex = ordersData.value.findIndex(order => {
        const currentId = order.order_id || order.ORDER_ID || order.id;
        return currentId === orderId;
      });

      if (targetIndex !== -1) {
        // 統一更新為 -1 (取消狀態)
        if (ordersData.value[targetIndex].order_status !== undefined) {
          ordersData.value[targetIndex].order_status = -1;
        } else if (ordersData.value[targetIndex].ORDER_STATUS !== undefined) {
          ordersData.value[targetIndex].ORDER_STATUS = -1;
        } else {
          ordersData.value[targetIndex].status = -1;
        }
      }

      //顯示成功彈窗
      showSuccessModal.value = true;
    }
  } catch (err) {
    // 這裡可以幫你抓出 PHP 噴出的真正錯誤訊息
    console.error('取消失敗回應:', err.response?.data);
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