<script setup>
import { ref, onMounted, computed } from 'vue';
import card from '@/components/mall/ProductCard.vue';
import axios from 'axios';

//取資料
const baseURL = import.meta.env.BASE_URL;
const productList = ref([]);

// --- 新增這段邏輯 ---
const randomProducts = computed(() => {
  if (productList.value.length === 0) return [];
  const shuffled = [...productList.value].sort(() => 0.5 - Math.random());

  // 這裡只取 3 筆，給上方的熱銷區用
  return shuffled.slice(0, 3);
});
// ------------------

const listCount = computed(() => {
  return productList.value.length;
});
const noData = computed(() => productList.value.length === 0);

const fetchData = () => {
  axios
    .get('/data/mall/products.json')
    .then((response) => {
      console.log('抓到的資料：', response.data);
      productList.value = response.data;
    })
    .catch((error) => {
      console.error('讀取 JSON 失敗，請檢查路徑是否正確', error);
    });
};

onMounted(() => {
  fetchData();
});

//tag標籤
const activeTag = ref('ALL'); //預設
// 2. 定義標籤的資料
const tags = [
  { text: 'ALL', width: '62px' },
  { text: '低卡健身系列', width: '138px' },
  { text: '日韓風味系列', width: '138px' },
  { text: '歐美西式系列', width: '138px' },
  { text: '台式家常系列', width: '138px' }
];
//觸發
const selectTag = (tagName) => {
  activeTag.value = tagName;
};

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
        <div v-for="item in productList" :key="item.id" class="col-3 col-md-12">
          <card :item="item" />
        </div>
      </div>
    </div>

    <!-- 頁碼 -->
    <div class="pagination">
      <a href="#" class="page-link active">1</a>
      <a href="#" class="page-link">2</a>
      <a href="#" class="page-link">3</a>
      <a href="#" class="page-link">4</a>
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
  justify-content: center;
}

.product-card {
  margin-bottom: 13px;
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
