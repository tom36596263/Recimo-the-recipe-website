<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import card from '@/components/mall/ProductCard.vue';
import axios from 'axios';
import { publicApi } from '@/utils/publicApi';
import { useRouter, useRoute } from 'vue-router';
import PageBtn from '@/components/common/PageBtn.vue'

// --- Swiper 相關設定 (請用這段取代舊的) ---
import { Swiper, SwiperSlide } from 'swiper/vue';
import 'swiper/css';
import 'swiper/css/pagination';
import 'swiper/css/free-mode'; // 記得加上這個樣式

// 關鍵修正：把 Pagination 和 FreeMode 寫在同一行
import { Pagination, FreeMode } from 'swiper/modules';

//會員登入
import { useAuthGuard } from '@/composables/useAuthGuard';

const { runWithAuth } = useAuthGuard();
const handleFollow = () => {
  runWithAuth(() => {
    // 這裡放「確定登入後」才要做的 API 動作
    console.log("已登入，執行關注 API");
  });
};

// 註冊模組：也寫在一起
const modules = [Pagination, FreeMode];
// --- 新增：Swiper RWD 斷點設定 ---
const swiperBreakpoints = {
  // 當螢幕寬度 >= 0px (手機)
  0: {
    slidesPerView: 1.3,
    spaceBetween: 15
  },
  // 當螢幕寬度 >= 768px (平板)
  768: {
    slidesPerView: 3, // 平板顯示 3 張完整，露出第 4 張一點點
    spaceBetween: 20
  }
};

// --- 資料與狀態 ---
const baseURL = import.meta.env.BASE_URL;
const productList = ref([]);
const activeTag = ref('全部'); // 目前選中的標籤
const currentPage = ref(1); // 目前在第幾頁
const pageSize = 8; // 一頁顯示幾筆 (4欄 x 2排 = 8筆)
const router = useRouter();
const route = useRoute();

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
  { text: '全部', width: '62px' },
  { text: '低卡健身系列', width: '138px' },
  { text: '日韓風味系列', width: '138px' },
  { text: '歐美西式系列', width: '138px' },
  { text: '台式家常系列', width: '138px' }
];

// --- 核心邏輯步驟 1：先過濾資料 (Filter) ---
const filteredProducts = computed(() => {
  //經過篩選後的所有商品清單
  if (activeTag.value === '全部') {
    return productList.value;
  }
  // 注意：這裡假設你的 JSON 資料裡有一個屬性叫做 category (或 tag)
  // 且內容跟上面的 text 完全一樣 (例如 "低卡健身系列")
  return productList.value.filter((item) => item.product_category === activeTag.value);
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
  return shuffled.slice(0, 4);
  //... 是「展開運算子 (Spread Operator)」。意思是把 productList 裡面的東西全部倒出來，放進一個新的 [] 裡面
  //sort(() => 0.5 - Math.random()) 是洗牌的概念
});

// --- 事件處理 ---
const fetchData = () => {
  publicApi
    .get('data/mall/products.json')
    .then((response) => {
      //.then是抓到資料後做函視裡面的動作,response：這是 Axios 幫你打包好的一個包裹。
      // console.log('抓到的資料：', response.data);
      productList.value = response.data;
    })
    .catch((error) => {
      console.error('讀取 JSON 失敗', error);
    });
};
const handlePageChange = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page;
  }
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

const getImg = (name) => {
  return new URL(`../../assets/images/mall/${name}`, import.meta.url).href;
};

// 2. 修改 columns 資料，使用 getImg 包住檔名
const columns = ref([
  // 第一欄
  [
    getImg('food1.png'), // 替換成你的圖片檔名
    getImg('food2.png'),
    getImg('food3.png')
  ],
  // 第二欄
  [getImg('food4.png'), getImg('food5.jpg'), getImg('food6.jpg')],
  // 第三欄
  [getImg('food7.jpg'), getImg('food8.jpg'), getImg('food9.png')],
  // 第四欄
  [getImg('food10.png'), getImg('food11.png'), getImg('food3.png')]
]);
</script>

<template>
  <div v-if="!route.params.id" class="mall">
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
          <div class="row desktop-view">
            <div v-for="item in randomProducts" :key="item.id" class="col-3 col-md-12" @click="goToDetail(item.id)">
              <card :item="item" />
            </div>
          </div>
          <div class="mobile-view swiper-container-custom">
            <swiper :breakpoints="swiperBreakpoints" :modules="modules" class="mySwiper">
              <swiper-slide v-for="item in randomProducts" :key="item.id" @click="goToDetail(item.id)">
                <card :item="item" />
              </swiper-slide>
            </swiper>
          </div>
        </div>
      </div>
    </section>

    <div class="product-title">
      <h2 class="zh-h2">Recimo料理包</h2>
    </div>
    <!-- 標籤 -->
    <div class="tag-wrapper">
      <div class="tag">
        <BaseTag v-for="item in tags" :key="item.text" :text="item.text" :width="item.width" :show-icon="false"
          :variant="activeTag === item.text ? 'primary' : 'action'" @click="selectTag(item.text)"></BaseTag>
      </div>

      <div class="tag-swiper">
        <swiper :slidesPerView="'auto'" :spaceBetween="14" :freeMode="true" :modules="modules" class="mySwiper">
          <swiper-slide v-for="item in tags" :key="item.text" class="tag-slide">
            <BaseTag :text="item.text" :width="item.width" :show-icon="false"
              :variant="activeTag === item.text ? 'primary' : 'action'" @click="selectTag(item.text)"></BaseTag>
          </swiper-slide>
        </swiper>
      </div>
    </div>

    <section>
      <!-- 商品 -->
      <div class="container">
        <div class="row desktop-view">
          <div v-if="displayedProducts.length === 0" class="col-12 col-lg-6" style="text-align: center; padding: 40px">
            目前沒有此分類的商品
          </div>
          <div v-for="item in displayedProducts" :key="item.id" class="col-3 col-lg-6" @click="goToDetail(item.id)">
            <card :item="item" />
          </div>
        </div>
        <div class="mobile-view swiper-container-custom" v-if="displayedProducts.length > 0">
          <swiper :breakpoints="swiperBreakpoints" :modules="modules" class="mySwiper">
            <swiper-slide v-for="item in displayedProducts" :key="item.id" @click="goToDetail(item.id)">
              <card :item="item" />
            </swiper-slide>
          </swiper>
        </div>
      </div>

      <PageBtn :currentPage="currentPage" :totalPages="totalPages" @update:page="handlePageChange" />
    </section>

    <!-- 輪播圖 -->
    <div class="marquee-container">
      <div class="grid-wrapper">
        <div v-for="(colImages, index) in columns" :key="index" class="column"
          :class="index % 2 === 0 ? 'move-down' : 'move-up'">
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
          <BaseBtn title="會員登入" :width="102" @click="handleFollow" />
        </div>
      </div>
    </div>
  </div>

  <router-view v-else></router-view>
  <!-- 如果網址有 ID（代表選了商品），就把商品詳情頁『嵌』在這個位置顯示；如果沒有 ID，就顯示原本的商城列表 -->
</template>

<style lang="scss" scoped>
.mall {

  // 麵包屑
  .bread {
    margin-top: 17px;
    margin-left: 40px;
  }

  .bread>a {
    text-decoration: none;
    color: $neutral-color-800;
  }

  .bread>span {
    color: $primary-color-400;
  }

  @media (max-width: 1024px) {
    .bread {
      display: none;
    }
  }

  //標題
  .title {
    display: flex;
    justify-content: center;
    margin-top: 48px;

    @media (max-width: 1024px) {
      margin-top: 60px;
    }
  }

  //熱銷商品
  .hot-container {
    background-image: url(../../assets/images/mall/hotback.png);
    background-repeat: no-repeat;
    background-size: cover;
    background-position: center top;
    margin-top: 45px;
    padding-bottom: 120px;


    @media (max-width: 768px) {
      background-image: url(../../assets/images/mall/phonehotback.png);
      background-size: cover;
      background-position: center;
    }
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

  // 手機版 Tag Swiper 特別設定
  .tag-slide {
    // 關鍵！設定 width: auto，Swiper 才會依照內容寬度排列，不會一張佔滿畫面
    width: auto;
  }

  .tag-swiper {
    display: none;
    /* 平板跟桌機都不要看到它 */
  }

  // RWD 斷點設定 (維持跟您商品列表一樣的 1024px)
  @media (max-width: 768px) {
    .tag {
      display: none;
    }

    // 調整手機版 Tag Swiper 的間距
    .tag-swiper {
      display: block;
      /* 手機版打開 */
      margin-top: 30px;
      margin-bottom: 15px;
      padding-left: 15px; // 左邊留白，滑動體驗較好
    }
  }

  .container {
    display: flex;
    justify-content: space-evenly;
    margin-bottom: 30px;
  }

  .row {
    display: flex;
    flex-wrap: wrap; // 必加：確保商品多時會換行，不會全部擠在同一排
    justify-content: flex-start; // 靠左對齊
    width: 100%; // 必加：不管裡面有幾個商品，這一排都要佔滿整個 container
  }

  .product-card {
    margin-bottom: 13px;
    cursor: pointer;
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
    gap: 8px;
    /* 欄位間距 */
    width: 120%;
    /* 稍微寬一點以避免邊緣空白，視情況調整 */
    height: 100%;
    margin-left: -10%;
    /* 置中修正 */
    transform: rotate(0deg);
    /* 如果想要傾斜效果可以在這裡改角度 */
  }

  .column {
    flex: 1;
    position: relative;
    height: 100%;
    overflow: hidden;
    /* 隱藏欄位外的圖片 */
  }

  .img-item {
    margin-bottom: 8px;
    /* 圖片垂直間距 */
    overflow: hidden;
    height: 280px;
    /* 固定高度，確保動畫計算準確 */
  }

  .img-item img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
  }

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
    }

    /* 從中間開始往回播 */
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
    background: rgba(0, 0, 0, 0.2);
    /* 整體稍微變暗 */
  }

  .card {
    background: rgba(255, 255, 255, 0.85);
    /* 半透明白底 */
    backdrop-filter: blur(8px);
    /* 毛玻璃特效 */
    padding: 40px 60px;
    text-align: center;
    border-radius: $radius-base;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
    max-width: 890px;
  }

  .card>h2 {
    margin-bottom: 10px;
  }

  .card>p {
    margin-bottom: 15px;
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

  // 桌機版狀態
  .desktop-view {
    display: flex;
    flex-wrap: wrap;
    width: 100%;
  }


  .mobile-view {
    display: none;
  }

  @media (max-width: 1024px) {

    .desktop-view {
      display: none
    }


    .mobile-view {
      display: block;
      width: 100%;
      overflow: hidden;
    }

    // 調整 Swiper 樣式
    .swiper {
      padding-bottom: 20px;
      // padding-right: 40px; // 讓右邊露出下一張
    }

    .swiper-slide {
      height: auto;
    }
  }
}
</style>
