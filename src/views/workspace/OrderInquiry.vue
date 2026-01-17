<script setup>
import { ref, onMounted, computed } from 'vue';

// 1. 宣告一個響應式變數，初始值為空陣列
const ordersData = ref([]);
const currentPage = ref(1);
const onCancel = () => { }

// 2. 在 onMounted 生命週期中獲取資料
onMounted(async () => {
  try {
    // 注意：放在 public 資料夾的檔案，在瀏覽器讀取時路徑通常不需要包含 '/public'
    // 如果你的檔案在專案的 public/data/mall/orders.json，讀取路徑通常是：
    const response = await fetch('/data/mall/orders.json');

    if (!response.ok) {
      throw new Error('讀取訂單資料失敗');
    }

    // 將讀取到的 JSON 寫入變數
    ordersData.value = await response.json();

  } catch (error) {
    console.error('Error loading orders:', error);
  }
});
// import ordersData from '/public/data/mall/orders.json';


//標籤
// --- 標籤設定 ---
const activeTag = ref('全部訂單');
const tags = [
  { text: '全部訂單', width: '138px' },
  { text: '已確認訂單', width: '138px' },
  { text: '已出貨訂單', width: '138px' },
  { text: '已完成訂單', width: '138px' },
  { text: '已取消訂單', width: '138px' }
];

// 定義狀態對照表 (請依照你後端的定義調整數字)
const statusMapping = {
  "新訂單": 0,  //對應資料庫:訂購成功
  '已確認訂單': 1,//對應資料庫:訂單確認
  '已出貨訂單': 2,//對應資料庫:出貨
  '已完成訂單': 3,//對應資料庫:送達
  '已取消訂單': -1//對應資料庫:取消
};

// --- 篩選邏輯 ---
const filteredProducts = computed(() => {
  // 1. 如果選全部，回傳所有 ordersData
  if (activeTag.value === '全部訂單') {
    return ordersData.value;
  }
  // 翻譯中文標籤為數字
  const targetStatus = statusMapping[activeTag.value];

  // 進行數字比對
  return ordersData.value.filter((item) => item.status === targetStatus);
});

const selectTag = (tagName) => {
  activeTag.value = tagName;
  currentPage.value = 1;
}

//頁碼
const pageSize = 2; // 設定每頁顯示幾筆
// --- 1. 計算總頁數 (依據篩選後的資料量來算) ---
const totalPages = computed(() => {
  // 如果沒有資料，至少要有 1 頁或是隱藏，這裡用無條件進位
  return Math.ceil(filteredProducts.value.length / pageSize);
});
// --- 2. 製作當前頁面的資料 (這是最後要給 HTML 顯示用的) ---
const paginatedOrders = computed(() => {
  // 計算開始與結束的索引
  const startIndex = (currentPage.value - 1) * pageSize;
  const endIndex = startIndex + pageSize;

  // 從「篩選後」的結果中，切出這一頁要的資料
  return filteredProducts.value.slice(startIndex, endIndex);
});

// --- 3. 切換頁碼的函式 ---
const setPage = (page) => {
  currentPage.value = page;
  // (選用) 點擊換頁後，通常會想滾動回到列表頂端
  // document.querySelector('.order-page').scrollTop = 0; 
};

//顯示calender
const dateInput = ref(null);
const openCalender = () => {
  dateInput.value.showPicker();
}

//取消訂單
// const onCancel = (orderId) => {
//   alert(`使用者點擊取消訂單: ${orderId}`);
//   // 這裡可以呼叫後端 API 執行取消邏輯
// };



</script>

<template>
  <div class="container">
    <div class="row">
      <div class="col-12">
        <div class="order-page">
          <!-- 標籤 -->
          <div class="tag-container">
            <div class="mydate">
              <label for="mydate"><i class="fa-regular fa-calendar-days" @click="openCalender"></i>訂購時間</label>
              <input type="date" name="date" ref="dateInput">
            </div>

            <div class="tag">
              <BaseTag v-for="item in tags" :key="item.text" :text="item.text" :width="130" :show-icon="false"
                :variant="activeTag === item.text ? 'primary' : 'action'" @click="selectTag(item.text)"></BaseTag>
            </div>

          </div>

          <div v-if="paginatedOrders.length === 0" style="text-align: center; margin-top: 100px;">目前沒有訂單</div>
          <OrderCard v-for="order in paginatedOrders" :key="order.id" :order="order" @cancel-order="onCancel" />
        </div>
      </div>
    </div>
    <!-- 頁碼 -->
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
