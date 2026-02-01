<script setup>
import { ref, onMounted, computed, watch, onUnmounted, getCurrentInstance } from 'vue';
// 呼叫Api
import { phpApi, base } from '@/utils/publicApi.js';
import { useRouteName } from '@/composables/useRouteName';
import { useCartStore } from '@/stores/cartStore';
import ProductRmd from '@/components/mall/ProductRmd.vue';
// 用來執行動作
import { useRouter } from 'vue-router';
const router = useRouter();
// 引用彈窗
import BaseModal from '@/components/BaseModal.vue';

// ==========================================
// 點小圖秀大圖
// ==========================================
// 預設顯示第一張
const mainImage = ref('');
const activeImage = ref('');

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
const cartStore = useCartStore()

//定義控制 Modal 顯示的變數
const showSuccess = ref(false);
const addToCart = async () => {
  if (productInfo.value) {
    try {
      await cartStore.add(productInfo.value, count.value);
      showSuccess.value = true; // 開啟彈窗

      setTimeout(() => { showSuccess.value = false; }, 1500);

    } catch (error) {
      console.error("加入購物車出錯", error);
    }
  }
};

// ==========================================
// 直接購買
// ==========================================
const buynowshowSuccess = ref(false);
const buyNow = async () => {
  if (productInfo.value) {
    try {
      // 先執行 API 加入購物車
      await cartStore.add(productInfo.value, count.value);
      buynowshowSuccess.value = true; // 開啟彈窗

      setTimeout(() => {
        buynowshowSuccess.value = false; // 關閉彈窗
        router.push('/cart');            // 執行跳轉
      }, 2000);

    } catch (error) {
      // console.error("購買跳轉出錯", error);
    }
  }
};

// ==========================================
// 引入 useRoute 獲取網址 ID
// ==========================================
import { useRoute } from 'vue-router';
const route = useRoute();
const productId = computed(() => route.params.id); // 將 ID 改為 computed，確保網址變了它也跟著變

const productInfo = ref(null); // 儲存當前商品的所有資訊
const isNotFound = ref(false); // 用來記錄是否找不到商品
const { setDetailName } = useRouteName()

// 定義一個 Script 內部可用的轉換函式
const parseFile = (url) => {
  if (!url) return '';

  // 1. 清理傳入的 url
  const cleanPath = url.replace(/^public\//, '').replace(/^\/+/, '');

  // 2. 處理 base，確保它是純粹的域名+路徑，不帶結尾斜線
  let baseUrl = base.replace(/\/+$/, '');

  // 3. 手動拼接，確保中間只有一個斜線
  const finalUrl = `${baseUrl}/${cleanPath}`.trim();

  // 4. 強制檢查結果，如果開頭還是有 /http，就把它切掉
  // 有時候 Vue 綁定會因為 baseUrl 的格式自動加上斜線
  return finalUrl.startsWith('/') && finalUrl.includes('http')
    ? finalUrl.substring(1)
    : finalUrl;
};

const fetchData = async () => {
  try {
    isNotFound.value = false; // 每次重新抓取前先重設
    productInfo.value = null; // 確保每次切換時先清空
    // const response = await axios.get(`${base}data/mall/products.json`);
    const response = await phpApi.get('mall/user_products.php');

    const item = response.data.find(p => String(p.product_id) === String(productId.value));

    // document.title = `${item.product_name} | Recimo`;

    if (item) {
      productInfo.value = item;
      document.title = `${item.product_name} | Recimo`;

      // 圖片初始化：
      // 對應後端 JOIN 出來的陣列
      if (item.images && item.images.length > 0) {
        // 預設大圖顯示第一張，記得過濾路徑
        mainImage.value = parseFile(item.images[0]);
        activeImage.value = parseFile(item.images[0]);
      }

      // 數量重置
      count.value = 1;
      // 設定路由名稱（麵包屑或標題用）
      setDetailName(productInfo.value.product_name);

      // console.log("成功找到商品：", item.product_name);
    } else {
      // productInfo.value = null; // 確保清空舊資料
      isNotFound.value = true;
      document.title = `無此商品 | Recimo`;
      // console.warn("找不到該 ID 的商品資料");
    }
  } catch (error) {
    isNotFound.value = true;
    document.title = `載入失敗 | Recimo`;
    // console.error("抓取失敗", error);
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
  <div class="product-detail-wrapper">
    <section v-if="productInfo" class="product-detail-page container">
      <div class="product-detail__main-content row">
        <!-- ==========================================
            商品圖
      ========================================= -->
        <div class="col-7 col-md-12">
          <div class="product-gallery" :class="{ 'is-nav-hidden': isScrollingDown }">
            <div class="product-gallery__viewport">
              <img v-if="mainImage" :src="mainImage" :alt="productInfo.product_name">
            </div>

            <div class="row product-gallery__thumbs">
              <div v-for="(imgUrl, index) in productInfo.images" :key="index"
                class="product-gallery__item col-3 col-sm-4">

                <div class="product-gallery__thumb" :class="{ 'is-active': activeImage === parseFile(imgUrl) }"
                  @click="changeImage(parseFile(imgUrl))">

                  <img :src="parseFile(imgUrl)" :alt="productInfo.product_name">
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
                    <td>{{ productInfo.tags.product_kcal }}kcal</td>
                    <td>碳水化合物</td>
                    <td>{{ productInfo.tags.product_carbs }}g</td>
                  </tr>
                  <tr class="p-p1">
                    <td>總脂肪</td>
                    <td>{{ productInfo.tags.product_fat }}g</td>
                    <td>飽和脂肪</td>
                    <td>{{ productInfo.tags.product_saturated_fat }}g</td>
                  </tr>
                  <tr class="p-p1">
                    <td>蛋白質</td>
                    <td>{{ productInfo.tags.product_protein }}g</td>
                    <td>膳食纖維</td>
                    <td>{{ productInfo.tags.product_fiber }}g</td>
                  </tr>
                  <tr class="p-p1">
                    <td>鈉</td>
                    <td>{{ productInfo.tags.product_sodium }}mg</td>
                    <td>糖</td>
                    <td>{{ productInfo.tags.product_sugar }}g</td>
                  </tr>
                </tbody>
              </table>
              <p class="p-p2 nutrition-table__note">一人份的營養成分表示/一份250g</p>
            </div>
            <div class="product-detail__extra">
              <div class="product-detail__section">
                <h3 class="zh-h5-bold">食材內容：</h3>
                <p class="p-p1">{{ productInfo.tags.product_ingredients }}
                </p>
              </div>
              <div class="product-detail__section">
                <hr>
                <h3 class="zh-h5-bold">使用方法：</h3>
                <p class="p-p1">
                  {{ productInfo.tags.product_cooking_method }}
                </p>
                <hr>
              </div>
              <div class="product-detail__section">
                <h3 class="zh-h5-bold">保存期限：</h3>
                <p class="p-p1"> {{ productInfo.tags.product_storage_method }}</p>
                <hr>
              </div>
              <div class="product-detail__section">
                <h3 class="zh-h5-bold">貼心提醒：</h3>
                <p class="p-p1"> {{ productInfo.tags.product_reminder }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      <BaseModal :isOpen="showSuccess" type="success" iconClass="fa-solid fa-check"
        :title="`${count} 件【${productInfo.product_name}】\n已加入至購物車`" @close="showSuccess = false">
      </BaseModal>
      <BaseModal :isOpen="buynowshowSuccess" type="success" iconClass="fa-solid fa-check"
        :title="`${count} 件【${productInfo.product_name}】\n已加入購物車`" description="將為您跳轉至購物車頁面"
        @close="showSuccess = false">
      </BaseModal>
      <ProductRmd class="detail-recommend-section" />
    </section>

    <!-- ==========================================
            找不到商品
      ========================================= -->
    <section v-if="productInfo && !isNotFound" class="product-detail-page container">
    </section>

    <section v-else-if="isNotFound" class="not-found-section container">
      <div class="not-found-content">
        <h2 class="zh-h2">哎呀！找不到這項商品</h2>
        <p class="p-p1">這份好料可能已經下架，或者網址輸入錯誤了。</p>
        <BaseBtn title="回商城逛逛" variant="outline" @click="router.push('/mall')" :width="210" />
      </div>
    </section>

    <section v-else class="loading-section container">
      <div style="text-align: center; padding: 100px 0;">
        <p class="zh-h5">美味載入中...</p>
      </div>
    </section>
  </div>
</template>

<style lang="scss" scoped>
@use "sass:map";
@use "@/assets/scss/layouts/_grid.scss" as *;

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
  @media screen and (max-width: map.get($breakpoints, "md")) {
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

  @media screen and (max-width: map.get($breakpoints, "md")) {
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
  @media screen and (max-width: map.get($breakpoints, "lg")) {
    padding-left: 0;
  }

  @media screen and (max-width: map.get($breakpoints, "md")) {
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

  @media screen and (max-width: map.get($breakpoints, "lg")) {
    margin-top: 60px;
  }
}

// ==========================================
// 找不到商品
// ==========================================
.not-found-section {
  padding: 100px 0;
  text-align: center;

  .not-found-content {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;


    h2 {
      color: $primary-color-700;
    }

    p {
      color: $neutral-color-700;
      margin-bottom: 20px;
    }
  }
}
</style>
