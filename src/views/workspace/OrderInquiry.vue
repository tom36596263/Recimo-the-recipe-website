<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import OrderCard from '@/components/mall/OrderCard.vue'; // 建議變數名稱改大寫開頭
import { publicApi } from '@/utils/publicApi';

// 資料容器
const ordersData = ref([]);
const currentPage = ref(1);
const pageSize = 2; // 設定每頁顯示幾筆

// 日期與標籤狀態
const selectedDate = ref(''); // 綁定日期輸入框
const activeTag = ref('全部訂單');

// 1. 讀取資料
onMounted(() => {
  // 修正拼字 maill -> mall
  publicApi.get('data/mall/orders.json')
    .then(res => {
      ordersData.value = res.data;
    })
    .catch(err => {
      console.error('讀取 JSON 失敗', err);
    });
});

// --- 標籤設定 ---
const tags = [
  { text: '全部訂單', width: '138px' },
  { text: '已確認訂單', width: '138px' },
  { text: '已出貨訂單', width: '138px' },
  { text: '已完成訂單', width: '138px' },
  { text: '已取消訂單', width: '138px' }
];

// 狀態對照表 (請確保 JSON 裡的 status 數字與這裡對應)
const statusMapping = {
  "新訂單": 0,  //對應資料庫:訂購成功
  '已確認訂單': 1,//對應資料庫:訂單確認
  '已出貨訂單': 2,//對應資料庫:出貨
  '已完成訂單': 3,//對應資料庫:送達
  '已取消訂單': -1//對應資料庫:取消
};

// --- 2. 核心篩選邏輯 (同時篩選：標籤 + 日期) ---
const filteredProducts = computed(() => {
  let result = ordersData.value;

  // A. 先過濾狀態
  if (activeTag.value !== '全部訂單') {
    const targetStatus = statusMapping[activeTag.value];
    result = result.filter((item) => item.status === targetStatus);
  }

  // B. 再過濾日期 (假設 JSON 裡的 date 格式是 "YYYY-MM-DD")
  if (selectedDate.value) {
    result = result.filter(item => {
      return item.date === selectedDate.value;
    });
  }

  return result;
});

// --- 3. 頁碼計算 (依據篩選後的資料) ---
const totalPages = computed(() => {
  if (filteredProducts.value.length === 0) return 0;
  return Math.ceil(filteredProducts.value.length / pageSize);
});

// --- 4. 分頁裁切 (給 HTML 顯示用) ---
const paginatedOrders = computed(() => {
  const startIndex = (currentPage.value - 1) * pageSize;
  const endIndex = startIndex + pageSize;
  return filteredProducts.value.slice(startIndex, endIndex);
});

// --- 事件處理 ---
const selectTag = (tagName) => {
  activeTag.value = tagName;
  currentPage.value = 1; // 切換標籤時重置回第一頁
}

const setPage = (page) => {
  currentPage.value = page;
  window.scrollTo({ top: 0, behavior: 'smooth' }); // 換頁時滾動到頂部
};

// 監聽日期變動，也要重置頁碼
watch(selectedDate, () => {
  currentPage.value = 1;
});

// 顯示日曆 (透過 ref 操作 DOM)
const dateInput = ref(null);
const openCalender = () => {
  if (dateInput.value && dateInput.value.showPicker) {
    dateInput.value.showPicker();
  } else {
    dateInput.value.focus();
  }
}

// 取消訂單 (模擬前端刪除)
const onCancel = (orderId) => {
  //在 ordersData 中找到這筆訂單的索引位置
  const targetIndex = ordersData.value.findIndex(order => order.id === orderId);
  if (targetIndex !== -1) {
    ordersData.value[targetIndex].status = -1;
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
              <button v-if="selectedDate" @click="selectedDate = ''" class="clear-date-btn">×</button>
            </div>

            <div class="tag">
              <BaseTag v-for="item in tags" :key="item.text" :text="item.text" :width="130" :show-icon="false"
                :variant="activeTag === item.text ? 'primary' : 'action'" @click="selectTag(item.text)"></BaseTag>
            </div>
          </div>

          <div v-if="paginatedOrders.length === 0" class="no-data">
            目前沒有符合條件的訂單
          </div>
          <OrderCard v-else v-for="order in paginatedOrders" :key="order.id" :order="order" @cancel-order="onCancel" />
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

  /* 選取 .tag 這個容器底下，所有第一層的子元素，不管它是什麼標籤。 */
}

/* calender */
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
</style>
