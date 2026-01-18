<script setup>
import { ref, onMounted, computed, watch, onUnmounted } from 'vue';
// import axios from 'axios';
import { publicApi, base } from '@/utils/publicApi.js';
import { defineStore } from 'pinia'
import { useRouteName } from '@/composables/useRouteName'
import { useCartStore } from '@/stores/cartStore'
import ProductRmd from '@/components/mall/ProductRmd.vue';
// 門禁守衛
import { useAuthGuard } from '@/composables/useAuthGuard';
const { runWithAuth } = useAuthGuard();
// ==========================================
// vue上課教：以後部屬比較不會有問題(資料放public的話)
// ==========================================
// const baseurl = import.meta.env.BASE_URL

// ==========================================
// 點小圖秀大圖
// ==========================================
const productImages = [
  `${base}img/mall/PROD-001_01.jpg`,
  `${base}img/mall/PROD-001_02.jpg`,
  `${base}img/mall/PROD-001_03.jpg`
];

// 預設顯示第一張
const mainImage = ref(productImages[0]);
const activeImage = ref(productImages[0]);

const changeImage = (imgSrc) => {
  mainImage.value = imgSrc;
  activeImage.value = imgSrc; // 讓點擊的小圖變色
};

// ==========================================
// 增減商品數量
// ==========================================
const count = ref(1); // 預設數量是 1

// ==========================================
// 加入購物車
// ==========================================
// 按鈕動作定義 (避免 Template 報錯)

const cartStore = useCartStore()
const addToCart = () => {
  // 詳情頁的資料在 productInfo 裡
  if (productInfo.value) {
    console.log("把商品", productInfo.value.product_name, "數量", count.value, "加入購物車");
  }
};

const buyNow = () => {
  runWithAuth(() => {
    // 「確定登入後」才執行
    if (productInfo.value) {
      console.log("直接購買商品", productInfo.value.product_name, "數量", count.value);
    }
  });
};

// ==========================================
// 引入 useRoute 獲取網址 ID
// ==========================================
import { useRoute } from 'vue-router';
const route = useRoute();
const productId = computed(() => route.params.id); // 將 ID 改為 computed，確保網址變了它也跟著變

const productInfo = ref(null); // 儲存當前商品的所有資訊
const { setDetailName } = useRouteName()

const fetchData = async () => {
  try {
    // const response = await axios.get(`${base}data/mall/products.json`);
    const response = await publicApi.get(`data/mall/products.json`);

    // 1. 修改這裡：將 p.id 改為 p.product_id
    // 並使用 String() 確保兩邊型別一致（字串對字串）
    const item = response.data.find(p => String(p.product_id) === String(productId.value));

    if (item) {
      productInfo.value = item;

      // 2. 修正圖片初始化：
      // 確保使用 item.product_image 並透過 getImageUrl 處理路徑
      if (item.product_image && item.product_image.length > 0) {
        // 取得第一張圖的路徑
        const firstImg = getImageUrl(item.product_image[0].image_url);
        mainImage.value = firstImg;
        activeImage.value = firstImg;
      }

      // 數量重置
      count.value = 1;
      // 設定路由名稱（麵包屑或標題用）
      setDetailName(productInfo.value.product_name);

      console.log("成功找到商品：", item.product_name);
    } else {
      console.warn("找不到該 ID 的商品資料，請確認 JSON 中的 product_id 值");
    }
  } catch (error) {
    console.error("抓取失敗", error);
  }
};

// 監聽 ID，當從推薦商品點擊進入不同 ID 時，重新抓資料
watch(
  () => productId.value,
  () => {
    fetchData()
  },
  {
    immediate: true,
  },
);

onMounted(() => {
  fetchData();
});

// 新增一個處理路徑的 function
// const getImageUrl = (url) => {
//   if (!url) return '';
//   const cleanPath = url.replace(/^public\//, '');
//   // return `${base}${cleanPath}`;
//   return `publicApi${cleanPath}`;
// };
const getImageUrl = (url) => {
  if (!url) return '';
  // 假設 JSON 裡的路徑是 "public/img/prod.jpg"
  const cleanPath = url.replace(/^public\//, '');
  // 修正：直接回傳相對路徑或加上基礎路徑
  return `${base}${cleanPath}`;
};

// ==========================================
// nav淡出商品圖往上滑一點 nav出現商品圖回復
// ==========================================
const isScrollingDown = ref(false);
let lastScrollY = window.scrollY;

// 偵測往下滑或往上滑
const handleScroll = () => {
  const currentY = window.scrollY;
  isScrollingDown.value = currentY > lastScrollY;
  lastScrollY = currentY;
};

onMounted(() => {
  // 先抓商品資料
  fetchData();

  // 監聽滾動
  window.addEventListener('scroll', handleScroll);
});

onUnmounted(() => {
  // 清除監聽，避免 memory leak
  window.removeEventListener('scroll', handleScroll);
});
</script>

<template>

  <section v-if="productInfo" class="product-detail-page container">
    <div class="product-detail__main-content row">
      <!-- ==========================================
            商品圖
      ========================================= -->
      <div class="col-7 col-md-12">
        <div class="product-gallery" :class="{ 'is-nav-hidden': isScrollingDown }">
          <div class="product-gallery__viewport">
            <img :src="mainImage">
          </div>

          <div class="row product-gallery__thumbs">
            <div v-for="(imgObj, index) in productInfo.product_image" :key="index"
              class="product-gallery__item col-3 col-sm-4">
              <div class="product-gallery__thumb"
                :class="{ 'is-active': activeImage === getImageUrl(imgObj.image_url) }"
                @click="changeImage(getImageUrl(imgObj.image_url))">
                <img :src="getImageUrl(imgObj.image_url)" :alt="productInfo.product_name">
              </div>
            </div>
          </div>
        </div>
      </div>
      <!-- ==========================================
            商品介紹
      ========================================= -->
      <div class="col-5 col-md-12">
        <div class="product-detail__info">
          <h1 class="zh-h2">{{ productInfo.product_name }}</h1>
          <hr />
          <p class="p-p1 product-detail__description">
            {{ productInfo.product_description }}
          </p>
          <div class="product-detail__purchase">
            <p class="zh-h2-bold product-detail__price">${{ productInfo.product_price }}</p>
            <div class="quantity-selector-box">
              <p class="p-p1">數量</p>
              <div class="quantity-selector-control">
                <button @click="count--" :disabled="count <= 1">−</button>
                <input v-model="count" readonly />
                <button @click="count++">+</button>
              </div>
            </div>
          </div>
          <div class="product-detail__actions">
            <BaseBtn title="加入購物車" variant="solid" @click="addToCart" :width="260" :height="50" />
            <BaseBtn title="直接購買" variant="outline" @click="buyNow" :width="260" :height="50" />
          </div>
          <div class="table-wrap">
            <table>
              <tbody>
                <tr class="p-p1-bold">
                  <th class="col-3">項目</th>
                  <th class="col-3">每份含量</th>
                  <th class="col-3">項目</th>
                  <th class="col-3">每份含量</th>
                </tr>
                <tr class="p-p1">
                  <td>熱量</td>
                  <td>{{ productInfo.product_kal }}</td>
                  <td>碳水化合物</td>
                  <td>{{ productInfo.product_carbs }}</td>
                </tr>
                <tr class="p-p1">
                  <td>總脂肪</td>
                  <td>{{ productInfo.product_fat }}</td>
                  <td>飽和脂肪</td>
                  <td>{{ productInfo.product_staturated_fat }}</td>
                </tr>
                <tr class="p-p1">
                  <td>蛋白質</td>
                  <td>{{ productInfo.product_protein }}</td>
                  <td>膳食纖維</td>
                  <td>{{ productInfo.product_fiber }}</td>
                </tr>
                <tr class="p-p1">
                  <td>鈉</td>
                  <td>{{ productInfo.product_sodium }}</td>
                  <td>糖</td>
                  <td>{{ productInfo.product_sugar }}</td>
                </tr>
              </tbody>
            </table>
            <p class="p-p2 nutrition-table__note">一人份的營養成分表示/一份250g</p>
          </div>
          <div class="product-detail__extra">
            <div class="product-detail__section">
              <h3 class="zh-h5-bold">食材內容：</h3>
              <p class="p-p1">{{ productInfo.product_ingredients }}
              </p>
            </div>
            <div class="product-detail__section">
              <hr>
              <h3 class="zh-h5-bold">使用方法：</h3>
              <p class="p-p1">
                {{ productInfo.product_cooking_method }}
              </p>
              <hr>
            </div>
            <div class="product-detail__section">
              <h3 class="zh-h5-bold">保存期限：</h3>
              <p class="p-p1"> {{ productInfo.product_storage_method }}</p>
              <hr>
            </div>
            <div class="product-detail__section">
              <h3 class="zh-h5-bold">貼心提醒：</h3>
              <p class="p-p1"> {{ productInfo.product_reminder }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <ProductRmd class="detail-recommend-section" />
  </section>

</template>

<style lang="scss" scoped>
@import "@/assets/scss/layouts/_grid.scss";

.product-detail-page {
  margin-top: 20px;
}

// ==========================================
// 商品圖
// ==========================================
.product-gallery {
  position: sticky; //左邊商品圖固定
  top: 100px; // 避開 Navbar 高度
  transition: top 0.3s ease;

  &.is-nav-hidden {
    top: 35px; // nav 隱藏時，大圖往上
  }

  // 在平板/手機版（堆疊狀態）時取消固定
  @media screen and (max-width: map-get($breakpoints, "md")) {
    position: static;
  }
}

.product-gallery__viewport {
  width: 100%;
  aspect-ratio: 4 / 3;
  // height: 65vh;
  margin-bottom: 15px;
  // 設定一個最小與最大極限，防止在超大或超小螢幕破圖
  min-height: 360px;
  max-height: 460px;
  overflow: hidden;
  border-radius: 10px;

  @media screen and (max-width: map-get($breakpoints, "md")) {
    height: 430px; // 手機版回到原本設定的高度
    max-height: none;
  }
}

.product-gallery__viewport img {
  width: 100%;
  height: 100%;
  object-fit: cover; // 避免圖片在固定高度下被拉扁或擠壓
  object-position: center;
}

//因為 row 預設是 flex-start（靠左），當你的小圖數量加起來不足 12 欄（例如只有 3 張 col-3，總共才 9 欄）時，右邊會留白
.product-gallery__thumbs {
  justify-content: center;
}

.product-gallery__thumb {
  aspect-ratio: 4 / 3;
  cursor: pointer;
  border-radius: 10px;
  border: 2px solid transparent; // 預設透明邊框，防止抖動
  overflow: hidden; // 隱藏超出部分
  object-fit: cover; // 確保圖片不變形
  transition: all 0.5s ease;

  // 當外層 div 有 is-active 時變色
  &.is-active {
    border-color: $accent-color-700;
    // 使用 box-shadow 可以讓選中感更強烈且不影響尺寸
    box-shadow: 0 0 3px rgba($accent-color-700, 0.3);

    img {
      opacity: 0.6; // 讓選中的圖稍微變淡，使用者看更清楚
    }
  }

  &:not(.is-active):hover {
    border-color: $accent-color-400;
  }
}

.product-gallery__thumb img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

// ==========================================
// 商品介紹
// ==========================================
.product-detail__info>* {
  margin-bottom: 20px;
}

.product-detail__info {
  padding-left: 20px; // 增加與左側圖片的間距

  // 當螢幕變小時（變成上下堆疊），把間距拿掉，改為增加上方間距
  @media screen and (max-width: map-get($breakpoints, "lg")) {
    padding-left: 0;
  }

  @media screen and (max-width: map-get($breakpoints, "md")) {
    margin-top: 30px;
  }
}

.product-detail__info h1 {
  text-align: center;
}

.product-detail__price {
  align-self: center;
}

.product-detail__purchase {
  display: flex;
  justify-content: space-between;
}

.quantity-selector-box {
  display: flex;
  align-items: center; // 文字與按鈕水平對齊
  gap: 15px; // 文字與按鈕的距離

  .quantity-selector-control {
    display: flex;
    background-color: $primary-color-100;
    border-radius: 10px;
    overflow: hidden; // 讓按鈕不會超出圓角邊界

    button,
    input {
      border: none;
      background: none;
      height: 40px;
      width: 40px;
      text-align: center;
    }

    button {
      cursor: pointer;
      font-size: 20px;

      &:hover {
        background: $accent-color-100;
      }
    }

    input {
      width: 50px; // 讓數字輸入框寬一點
      font-size: 16px;
    }
  }
}

.product-detail__actions {
  display: flex;
  gap: 10px;
  justify-content: center;

  @media screen and (max-width: 1200px) {
    justify-content: end;
  }
}

table {
  text-align: center;
  width: 100%;
  border-collapse: separate; // 一定要用 separate，圓角才會生效
  border-spacing: 0;
  border: 1px solid #757575;
  border-radius: 10px;
  overflow: hidden; // 確保內層的儲存格不會超出圓角邊界
  border-spacing: 0;
  margin-top: 50px;
}

tr :nth-child(2) {
  border-right: 1px solid #757575;
}

th {
  background-color: $primary-color-100;
  height: 40px;
  vertical-align: middle;
  background-clip: padding-box; // 解決背景色蓋住邊框的問題
  white-space: nowrap; // 強制不換行
}

td {
  height: 35px;
  vertical-align: middle;
  white-space: nowrap; // 強制不換行
}

.nutrition-table__note {
  text-align: right;
}

.product-detail__section>* {
  margin-bottom: 10px;
}

.product-detail__section p {
  white-space: pre-line; // 讓json 的 \n 生效
}

// ==========================================
// 推薦商品
// ==========================================
.detail-recommend-section {
  margin-top: 100px;

  @media screen and (max-width: map-get($breakpoints, "lg")) {
    margin-top: 60px;
  }
}
</style>
