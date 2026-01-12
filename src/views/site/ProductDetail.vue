<script setup>
import { ref, onMounted, computed } from 'vue';
import ProductRmd from '@/components/mall/ProductRmd.vue';
import axios from 'axios';

// ==========================================
// vue上課教：以後部屬比較不會有問題
// ==========================================
const baseURL = import.meta.env.BASE_URL

// ==========================================
// 點小圖秀大圖
// ==========================================
const productImages = [
  `${baseURL}img/mall/PROD-001_01.jpg`,
  `${baseURL}img/mall/PROD-001_02.jpg`,
  `${baseURL}img/mall/PROD-001_03.jpg`
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
const addToCart = () => {
  // 詳情頁的資料在 productInfo 裡
  if (productInfo.value) {
    console.log("把商品", productInfo.value.product_name, "數量", count.value, "加入購物車");
  }
};

const buyNow = () => {
  if (productInfo.value) {
    console.log("直接購買商品", productInfo.value.product_name, "數量", count.value);
  }
};

// ==========================================
// 加入購物車pina
// ==========================================
// import { useCartStore } from '@/stores/cartStore';
// const cartStore = useCartStore();

// const product = { id: 1, name: '舒肥雞胸', price: 160 }; // 假資料

// const addCart = () => {
//   cartStore.addToCart(product, 1);
// };

// ==========================================
// 引入 useRoute 獲取網址 ID
// ==========================================
import { useRoute } from 'vue-router';
const route = useRoute();
const productId = computed(() => route.params.id); // 將 ID 改為 computed，確保網址變了它也跟著變

const productInfo = ref(null); // 儲存當前商品的所有資訊

const fetchData = async () => {
  try {
    const response = await axios.get(`${baseURL}data/mall/products.json`);
    // 從 20 筆資料中，找 ID 跟網址一樣的那一筆
    const item = response.data.find(p => p.id === Number(productId.value));

    if (item) {
      productInfo.value = item;
      // 拿到資料後，初始化大圖為圖片陣列的第一張
      const firstImg = `${baseURL}${item.images[0]}`;
      mainImage.value = firstImg;
      activeImage.value = firstImg;
      // 切換商品時，數量重置為 1
      count.value = 1;
    }
  } catch (error) {
    console.error("抓取失敗", error);
  }
};
import { watch } from 'vue';

// 監聽 ID，當從推薦商品點擊進入不同 ID 時，重新抓資料
watch(() => productId.value, () => {
  fetchData();
});

onMounted(() => {
  fetchData();
});

</script>

<template>

  <section v-if="productInfo" class="product-detail container">
    <div class="row">

      <!-- ==========================================
            商品圖
      ========================================= -->
      <div class="col-7 col-lg-12">

        <div class="product-detail__gallery">
          <nav class="breadcrumb">
            <ul class="breadcrumb__list">
              <li><router-link to="/" class="p-p1">首頁</router-link></li>
              <li><router-link to="/mall" class="p-p1">Recimo商城</router-link></li>
              <li class="active p-p1">{{ productInfo?.product_name }}</li>
            </ul>
          </nav>
          <div class="gallery__main">
            <img :src="mainImage" id="gallery-preview-img">
          </div>

          <div class="row">
            <div v-for="(img, index) in productInfo.images" :key="index" class="col-2 col-md-3 col-sm-4">
              <div class="gallery__thumb" :class="{ 'is-active': activeImage === `${baseURL}${img}` }"
                @click="changeImage(`${baseURL}${img}`)">
                <img :src="`${baseURL}${img}`" :alt="productInfo.product_name">
              </div>
            </div>
          </div>
        </div>
      </div>
      <!-- ==========================================
            商品介紹
      ========================================= -->
      <div class="col-5 col-lg-12">
        <div class="product-detail__info">
          <h1 class="zh-h1">{{ productInfo.product_name }}</h1>
          <hr />
          <p class="p-p1 product-detail__description">
            {{ productInfo.description }}
          </p>
          <div class="product-detail__purchase">
            <p class="zh-h2-bold product-detail__price">${{ productInfo.price }}</p>
            <div class="quantity-selector-box">
              <p class="p-p1">數量</p>
              <div class="quantity-selector-control">
                <button @click="count > 1 ? count-- : null">−</button>
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
            <table class="col-12">
              <tbody>
                <tr class="p-p1-bold">
                  <th class="col-3">項目</th>
                  <th class="col-3">每份含量</th>
                  <th class="col-3">項目</th>
                  <th class="col-3">每份含量</th>
                </tr>
                <tr class="p-p1">
                  <td>熱量</td>
                  <td>{{ productInfo.calories }}</td>
                  <td>碳水化合物</td>
                  <td>{{ productInfo.carbohydrates }}</td>
                </tr>
                <tr class="p-p1">
                  <td>總脂肪</td>
                  <td>{{ productInfo.total_fat }}</td>
                  <td>飽和脂肪</td>
                  <td>{{ productInfo.dietary_fiber }}</td>
                </tr>
                <tr class="p-p1">
                  <td>蛋白質</td>
                  <td>{{ productInfo.protein }}</td>
                  <td>膳食纖維</td>
                  <td>{{ productInfo.saturated_fat }}</td>
                </tr>
                <tr class="p-p1">
                  <td>鈉</td>
                  <td>{{ productInfo.sodium }}</td>
                  <td>糖</td>
                  <td>{{ productInfo.sugar }}</td>
                </tr>
              </tbody>
            </table>
            <p class="p-p2 nutrition-table__note">一人份的營養成分表示/一份250g</p>
          </div>
          <div class="product-detail__extra">
            <div class="product-detail__section">
              <h3 class="zh-h5-bold">食材內容：</h3>
              <p class="p-p1">{{ productInfo.ingredients }}
              </p>
            </div>
            <div class="product-detail__section">
              <hr>
              <h3 class="zh-h5-bold">使用方法：</h3>
              <p class="p-p1">
                {{ productInfo.instructions }}
              </p>
              <hr>
            </div>
            <div class="product-detail__section">
              <h3 class="zh-h5-bold">保存期限：</h3>
              <p class="p-p1"> {{ productInfo.shelf_life }}</p>
              <hr>
            </div>
            <div class="product-detail__section">
              <h3 class="zh-h5-bold">貼心提醒：</h3>
              <p class="p-p1"> {{ productInfo.note }}</p>
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


// ==========================================
// 商品圖
// ==========================================
.product-detail__gallery {
  position: sticky; //左邊商品圖固定
  top: 100px; // 避開 Navbar 高度

  // 在平板/手機版（堆疊狀態）時取消固定
  @media screen and (max-width: map-get($breakpoints, "lg")) {
    position: static;
  }
}

.gallery__main {
  width: 100%;
  height: 65vh;
  margin-bottom: 15px;
  // 設定一個最小與最大極限，防止在超大或超小螢幕破圖
  min-height: 350px;
  max-height: 560px;

  @media screen and (max-width: map-get($breakpoints, "lg")) {
    height: 430px; // 手機版回到你原本設定的高度
    max-height: none;
  }
}

.gallery__main img {
  width: 100%;
  height: 100%;
  object-fit: cover; // 避免圖片在固定高度下被拉扁或擠壓
  display: block;
  border-radius: 10px;
  overflow: hidden; // 隱藏超出部分
}

.row {
  // 抵銷最左與最右的間距，讓它跟大圖切齊
  margin-left: -5px;
  margin-right: -5px;

  [class*="col-"] {
    // 設定左右各 5px，加起來中間就是 10px
    padding-left: 5px;
    padding-right: 5px;
  }
}

.gallery__thumb {
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

.gallery__thumb img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

// ==========================================
// 商品介紹
// ==========================================
.product-detail__info>* {
  margin-bottom: 25px;
}

.product-detail__info {
  padding-left: 40px; // 增加與左側圖片的間距

  // 當螢幕變小時（變成上下堆疊），把間距拿掉，改為增加上方間距
  @media screen and (max-width: map-get($breakpoints, "lg")) {
    padding-left: 0;
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
}

tr :nth-child(2) {
  border-right: 1px solid #757575;
}

th {
  background-color: $primary-color-100;
  height: 40px;
  vertical-align: middle;
  background-clip: padding-box; // 解決背景色蓋住邊框的問題
}

td {
  height: 35px;
  vertical-align: middle;
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

// ==========================================
// 麵包屑
// ==========================================
.breadcrumb {
  padding-bottom: 10px;

  .breadcrumb__list {
    display: flex;
    color: black;

    .active {
      color: $primary-color-800;
    }

    li {
      display: flex;
      align-items: center;

      // 製作中間的分隔斜線
      &:not(:last-child)::after {
        content: "/";
        margin: 0 10px;
      }

      a {
        text-decoration: none;
        color: inherit;

        &:hover {
          color: $accent-color-700;
        }
      }
    }
  }
}
</style>
