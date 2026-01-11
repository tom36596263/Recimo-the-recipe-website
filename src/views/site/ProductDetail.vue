<script setup>
import { ref, onMounted, computed } from 'vue';
import productrmd from '@/components/mall/ProductRmd.vue';

// ==========================================
// vue上課教：以後部屬比較不會有問題
// ==========================================
const baseURL = import.meta.env.BASE_URL

// ==========================================
// 增減商品數量
// ==========================================
const count = ref(1); // 預設數量是 1

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
// axios：先把商品卡片引入json檔
// ==========================================
import axios from 'axios'
const productList = ref([])
// 快速計算陣列數量結果
const listCount = computed(() => {
  return productList.value.length
})
const noData = computed(() => productList.value.length === 0)
const fetchData = () => {
  axios
    .get('/data/mall/products.json')
    .then((response) => {
      // 檢查點：確保 response.data 真的是那 20 筆陣列
      console.log("抓到的資料：", response.data);
      productList.value = response.data;
    })
    .catch((error) => {
      console.error("讀取 JSON 失敗，請檢查路徑是否正確", error);
    });
};
onMounted(() => {
  fetchData()
})


</script>

<template>
  <section class="product-detail container">
    <div class="row">
      <!-- ==========================================
            商品圖
      ========================================= -->
      <div class="col-7 col-lg-12">
        <div class="product-detail__gallery">
          <div class="gallery__main">
            <!-- <img :src="img1"> -->

            <!-- <img :src="parseAssetsIcon('PROD-001_main.jpg')">
            <img src="/assets/images/mall/PROD-001_main.jpg"> -->
            <img :src="`${baseURL}public/img/mall/PROD-001_01.jpg`">
          </div>

          <div class="row">
            <div class="col-2 col-md-3 col-sm-4">
              <div class="gallery__thumb">
                <img :src="`${baseURL}public/img/mall/PROD-001_02.jpg`">
              </div>
            </div>
            <div class="col-2 col-md-3 col-sm-4">
              <div class="gallery__thumb">
                <img :src="`${baseURL}public/img/mall/PROD-001_03.jpg`">
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
          <h1 class="zh-h1">舒肥雞胸藜麥飯</h1>
          <hr />
          <p class="p-p1 product-detail__description">
            想吃得健康，又不想犧牲美味？我們的「舒肥雞胸藜麥飯」專為忙碌的現代人、健身族與體重管理者設計。採用低溫烹調技術鎖住肉汁，搭配超級食物大軍，讓你每一口都吃進飽足感與純淨營養。
          </p>
          <div class="product-detail__purchase">
            <p class="zh-h2 product-detail__price">$160</p>
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
            <div style="width: 260px">
              <button class="btn h-50 btn-solid">加入購物車</button>
            </div>
            <div style="width: 260px">
              <button class="btn h-50 btn-outline">直接購買</button>
            </div>
          </div>
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
                <td>250g</td>
                <td>碳水化合物</td>
                <td>42.0g</td>
              </tr>
              <tr class="p-p1">
                <td>總脂肪</td>
                <td>4.2g</td>
                <td>飽和脂肪</td>
                <td>0.8g</td>
              </tr>
              <tr class="p-p1">
                <td>蛋白質</td>
                <td>28.5g</td>
                <td>膳食纖維</td>
                <td>5.5g</td>
              </tr>
              <tr class="p-p1">
                <td>鈉</td>
                <td>420mg</td>
                <td>糖</td>
                <td>0.5g</td>
              </tr>
            </tbody>
          </table>
          <p class="p-p2 nutrition-table__note">一人份的營養成分表示/一份250g</p>
          <div class="product-detail__extra">
            <div class="product-detail__section">
              <h3 class="zh-h5">食材內容：</h3>
              <ol>
                <li class="p-p1">嚴選低溫舒肥嫩雞胸</li>
                <li class="p-p1">黃金兩色藜麥糙米飯(三色藜麥、優質糙米)</li>
                <li class="p-p1">
                  五彩均衡鮮蔬(青花菜、鮮甜紅蘿蔔 / 黃玉米筍、栗子地瓜 /
                  烤南瓜、毛豆仁)
                </li>
              </ol>
            </div>
            <div class="product-detail__section">
              <hr>
              <h3 class="zh-h5">使用方法：</h3>
              <ol>
                <li class="p-p1">微波加熱： 撕開包裝一角以800W 加熱約2-3分鐘。</li>
                <li class="p-p1">
                  隔水加熱：
                  整包放入熱水中浸泡5-8分鐘（不建議沸騰加熱以維持肉質嫩度）。
                </li>
                <li class="p-p1">電鍋加熱： 解凍後放入內鍋，外鍋加少許水，跳起即可。</li>
              </ol>
              <hr>
            </div>
            <div class="product-detail__section">
              <h3 class="zh-h5">保存期限：</h3>
              <p class="p-p1">冷凍保存 12 個月。</p>
              <hr>
            </div>
            <div class="product-detail__section">
              <h3 class="zh-h5">貼心提醒：</h3>
              <p class="p-p1">本產品含有穀類製品，過敏者請留意。</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <productrmd />
  </section>

</template>

<style lang="scss" scoped>
// ==========================================
// 商品圖
// ==========================================
.gallery__main {
  width: 100%;
  margin-bottom: 10px;
}

.gallery__main img {
  width: 100%;
  height: 560px;
  object-fit: cover; // 避免圖片在固定高度下被拉扁或擠壓
  display: block;

  @media screen and (max-width: 1320px) {
    height: 450px;
  }

  @media screen and (max-width: 810px) {
    height: 400px;
  }

  @media screen and (max-width: 390px) {
    height: 300px;
  }
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
  object-fit: cover; // 確保圖片不變形
  cursor: pointer;
}

.gallery__thumb img {
  width: 100%;
  display: block;
}

// ==========================================
// 商品介紹
// ==========================================
.product-detail__info {
  gap: 100px;
}

.product-detail__info h1 {
  text-align: center;
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

.product-detail__section ol {
  list-style-position: inside; // 讓數字乖乖待在容器內
  list-style-type: decimal;
  padding-left: 0;
}

.product-detail__description,
.product-detail__purchase,
.product-detail__section table {
  margin-bottom: 10px;
}

.product-detail__actions,
.nutrition-table__note {
  margin-bottom: 20px;
}
</style>
