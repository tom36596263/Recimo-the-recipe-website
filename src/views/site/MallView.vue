<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import card from '@/components/mall/ProductCard.vue';
import axios from 'axios';
import { useRouter } from 'vue-router';

// --- 資料與狀態 ---
const baseURL = import.meta.env.BASE_URL;
const productList = ref([]);
const activeTag = ref('ALL'); // 目前選中的標籤
const currentPage = ref(1); // 目前在第幾頁
const pageSize = 8; // 一頁顯示幾筆 (4欄 x 2排 = 8筆)
const router = useRouter();

//進入商品詳情
const goToDetail = (id) => {
  router.push({
    //放進瀏覽器裡的陣列(瀏覽器的歷史紀錄)
    name: 'product-detail',
    params: { id: id } //左邊id:目標欄位,右邊id:實際內容
  });
};

// --- 標籤設定 ---
const tags = [
  { text: 'ALL', width: '62px' },
  { text: '低卡健身系列', width: '138px' },
  { text: '日韓風味系列', width: '138px' },
  { text: '歐美西式系列', width: '138px' },
  { text: '台式家常系列', width: '138px' }
];

// --- 核心邏輯步驟 1：先過濾資料 (Filter) ---
const filteredProducts = computed(() => {
  //經過篩選後的所有商品清單
  if (activeTag.value === 'ALL') {
    return productList.value;
  }
  // 注意：這裡假設你的 JSON 資料裡有一個屬性叫做 category (或 tag)
  // 且內容跟上面的 text 完全一樣 (例如 "低卡健身系列")
  return productList.value.filter((item) => item.category === activeTag.value);
});

// --- 核心邏輯步驟 2：計算總頁數 ---
const totalPages = computed(() => {
  return Math.ceil(filteredProducts.value.length / pageSize);
}); //Math.ceil 無條件進位

// --- 核心邏輯步驟 3：切分出當前頁面要顯示的資料 (Slice) ---
const displayedProducts = computed(() => {
  const startIndex = (currentPage.value - 1) * pageSize; //currentPage.value：目前在第幾頁。
  const endIndex = startIndex + pageSize;
  // 從過濾後的清單中，取出這一段
  return filteredProducts.value.slice(startIndex, endIndex);
});

// --- 其他 Computed ---
const randomProducts = computed(() => {
  if (productList.value.length === 0) return [];
  const shuffled = [...productList.value].sort(() => 0.5 - Math.random());
  return shuffled.slice(0, 3);
  //... 是「展開運算子 (Spread Operator)」。意思是把 productList 裡面的東西全部倒出來，放進一個新的 [] 裡面
  //sort(() => 0.5 - Math.random()) 是洗牌的概念
});

// --- 事件處理 ---
const fetchData = () => {
  axios
    .get('/data/mall/products.json')
    .then((response) => {
      //.then是抓到資料後做函視裡面的動作,response：這是 Axios 幫你打包好的一個包裹。
      // console.log('抓到的資料：', response.data);
      productList.value = response.data;
    })
    .catch((error) => {
      console.error('讀取 JSON 失敗', error);
    });
};

const selectTag = (tagName) => {
  activeTag.value = tagName;
  currentPage.value = 1; // 切換標籤時，要切回第一頁，不然使用者會迷路
};

const setPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page;
    // 建議：換頁後通常會把視窗滾動到商品區上方，體驗較好
    // window.scrollTo({ top: 500, behavior: 'smooth' });
  }
};

onMounted(() => {
  fetchData(); //當網頁畫面全部準備好（掛載完成）的那一瞬間，請幫我執行 fetchData 這個函式,fetchData 去倉庫搬貨，搬回來後更新了 productList.value。
});

// 模擬圖片資料 (您可以換成 API 取得的資料)
// 這裡將圖片分成 4 欄 (columns)
const columns = ref([
  [
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80',
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80',
    'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400&q=80'
  ],
  [
    'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=400&q=80',
    'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=400&q=80',
    'https://images.unsplash.com/photo-1467003909585-2f8a7270028d?w=400&q=80'
  ],
  [
    'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=400&q=80',
    'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&q=80',
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&q=80'
  ],
  [
    'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=80',
    'https://images.unsplash.com/photo-1493770348161-369560ae357d?w=400&q=80',
    'https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=400&q=80'
  ]
]);
</script>

<template>
  <!-- 麵包屑 -->
  <div class="bread">
    <a class="p-p1" href="HomeView.vue">首頁 </a>
    <span> / Recimo商城</span>
  </div>

  <!-- 標題 -->
  <div class="title">
    <h1 class="zh-h1-bold">Recimo商城</h1>
  </div>

  <!-- 本月熱銷 -->
  <section>
    <div class="hot-container">
      <div class="hot-title">
        <h2 class="zh-h2">本月熱銷</h2>
      </div>
      <div class="container">
        <div class="row mobile-scroll">
          <div
            v-for="item in randomProducts"
            :key="item.id"
            class="col-4 col-md-12"
            @click="goToDetail(item.id)"
          >
            <card :item="item" />
          </div>
        </div>
      </div>
    </div>
  </section>

  <div class="product-title">
    <h2 class="zh-h2">Recimo料理包</h2>
  </div>
  <!-- 標籤 -->
  <div class="tag">
    <BaseTag
      v-for="item in tags"
      :key="item.text"
      :text="item.text"
      :width="item.width"
      :show-icon="false"
      :variant="activeTag === item.text ? 'primary' : 'action'"
      @click="selectTag(item.text)"
    ></BaseTag>
  </div>
  <section>
    <!-- 商品 -->
    <div class="container">
      <div class="row mobile-scroll">
        <div
          v-if="displayedProducts.length === 0"
          class="col-12"
          style="text-align: center; padding: 40px"
        >
          目前沒有此分類的商品
        </div>
        <div
          v-for="item in displayedProducts"
          :key="item.id"
          class="col-3 col-md-12"
          @click="goToDetail(item.id)"
        >
          <card :item="item" />
        </div>
      </div>
    </div>

    <!-- 頁碼 -->
    <div class="pagination" v-if="totalPages > 1">
      <!-- <a
        href="#"
        class="page-link"
        @click.prevent="setPage(currentPage - 1)"
        :class="{ disabled: currentPage === 1 }"
      >
        &lt;
      </a> -->

      <a
        href="#"
        class="page-link"
        v-for="page in totalPages"
        :key="page"
        :class="{ active: currentPage === page }"
        @click.prevent="setPage(page)"
      >
        {{ page }}
      </a>
      <!-- 如果這顆按鈕代表的數字 (page) 等於你目前所在的頁碼 (currentPage)。 -->
      <!-- 加上 active 這個 class。這通常會讓按鈕變色（例如變成藍底白字），告訴使用者「你現在在這裡」。 -->
      <!-- <a
        href="#"
        class="page-link"
        @click.prevent="setPage(currentPage + 1)"
        :class="{ disabled: currentPage === totalPages }"
      >
        &gt;
      </a> -->
    </div>
  </section>

  <!-- 輪播圖 -->
  <div class="marquee-container">
    <div class="grid-wrapper">
      <div
        v-for="(colImages, index) in columns"
        :key="index"
        class="column"
        :class="index % 2 === 0 ? 'move-down' : 'move-up'"
      >
        <div class="track">
          <div v-for="(img, i) in colImages" :key="'a-' + i" class="img-item">
            <img :src="img" alt="food" />
          </div>
          <div v-for="(img, i) in colImages" :key="'b-' + i" class="img-item">
            <img :src="img" alt="food" />
          </div>
        </div>
      </div>
    </div>

    <div class="overlay-content">
      <div class="card">
        <h2 class="zh-h2-bold">Get your Recimo ID</h2>
        <p class="zh-h3">
          您需要 Recimo ID 才能購買 Recimo 提供的商品。<br />
          註冊完全免費。
        </p>
        <BaseBtn
          title="會員登入"
          href="/src/components/LoginLightbox.vue"
          :width="102"
        />
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
// 麵包屑
.bread {
  margin-top: 17px;
  margin-left: 40px;
}
.bread > a {
  text-decoration: none;
  color: $neutral-color-800;
}
.bread > span {
  color: $primary-color-400;
}
@media (max-width: 768px) {
  .bread {
    display: none;
  }
}

//標題
.title {
  display: flex;
  justify-content: center;
  margin-top: 48px;
}

//熱銷商品
.hot-container {
  background-color: blanchedalmond;
  margin-top: 45px;
  padding-bottom: 120px;
}
.hot-title {
  text-align: center;
  padding-top: 67px;
  margin-bottom: 57px;
}

//商品
.product-title {
  margin-top: 52px;
  text-align: center;
}

.tag {
  display: flex;
  gap: 14px;
  justify-content: end;
  margin-right: 45px;
  margin-bottom: 42px;
  margin-top: 51px;
}
.container {
  display: flex;
  justify-content: space-evenly;
}

.row {
  display: flex;
  justify-content: flex-start;
  border: 1px solid red;
}

.product-card {
  margin-bottom: 13px;
  cursor: pointer;
  border: 1px solid blue;
}

//頁碼
.pagination {
  margin-bottom: 60px;
}

//輪播圖
.marquee-container {
  position: relative;
  width: 100%;
  height: 600px;
  overflow: hidden;
  background: #f8f8f8;
}

.grid-wrapper {
  display: flex;
  gap: 8px; /* 欄位間距 */
  width: 120%; /* 稍微寬一點以避免邊緣空白，視情況調整 */
  height: 100%;
  margin-left: -10%; /* 置中修正 */
  transform: rotate(0deg); /* 如果想要傾斜效果可以在這裡改角度 */
}

.column {
  flex: 1;
  position: relative;
  height: 100%;
  overflow: hidden; /* 隱藏欄位外的圖片 */
}

.img-item {
  margin-bottom: 8px; /* 圖片垂直間距 */
  overflow: hidden;
  height: 280px; /* 固定高度，確保動畫計算準確 */
}

.img-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

/* 4. 動畫核心 */
/* 原理：Track 總高度是原本內容的 200% (因為複製了一份)。
   從 0% 移動到 -50% (或相反)，視覺上會剛好接回起點，形成無限循環。
*/

/* 往下移動的欄位 */
.move-down .track {
  animation: scroll-down 30s linear infinite;
}

/* 往上移動的欄位 */
.move-up .track {
  animation: scroll-up 30s linear infinite;
}

@keyframes scroll-up {
  0% {
    transform: translateY(0);
  }
  100% {
    transform: translateY(-50%);
  }
}

@keyframes scroll-down {
  0% {
    transform: translateY(-50%);
  } /* 從中間開始往回播 */
  100% {
    transform: translateY(0);
  }
}

/* 5. 中間遮罩樣式 (仿照您的截圖) */
.overlay-content {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 10;
  background: rgba(0, 0, 0, 0.2); /* 整體稍微變暗 */
}

.card {
  background: rgba(255, 255, 255, 0.85); /* 半透明白底 */
  backdrop-filter: blur(8px); /* 毛玻璃特效 */
  padding: 40px 60px;
  text-align: center;
  border-radius: 4px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
  max-width: 890px;
}
.card > h2 {
  margin-bottom: 10px;
}
.card > p {
  margin-bottom: 9px;
}
/* 6. RWD 響應式：手機版變成兩欄 */
@media (max-width: 768px) {
  .grid-wrapper {
    width: 100%;
    margin-left: 0;
  }
  /* 隱藏後兩欄，只留兩欄 */
  .column:nth-child(n + 3) {
    display: none;
  }
}
</style>
