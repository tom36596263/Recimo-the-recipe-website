<script setup>
//  setup: 這是 Vue 3 的語法糖，讓你不用寫 export default {}，且能直接使用變數和函式，開發效率最高。
// 所有的變數、函式、或是從 JSON 引入的資料都寫在script裡面。
import { ref, onMounted } from 'vue';
</script>

<template>
  <section class="product-detail">
    <div class="product-detail__gallery">
      <img src="https://picsum.photos/763/558/?random=10" />
      <img src="https://picsum.photos/146/95/?random=11" />
      <img src="https://picsum.photos/146/95/?random=12" />
    </div>
    <div class="product-detail__info">
      <h1>舒肥雞胸藜麥飯</h1>
      <hr />
      <p class="product-detail__description">
        想吃得健康，又不想犧牲美味？我們的「舒肥雞胸藜麥飯」專為忙碌的現代人、健身族與體重管理者設計。採用低溫烹調技術鎖住肉汁，搭配超級食物大軍，讓你每一口都吃進飽足感與純淨營養。
      </p>
      <p class="product-detail__price">$160</p>
      <div class="product-detail__options">
        <p class="product-detail__label">數量</p>
        <div class="product-detail__quantity-selector"></div>
      </div>
      <div class="product-detail__actions">
        <button>加入購物車</button>
        <button>直接購買</button>
      </div>
      <table>
        <tr>
          <th>項目</th>
          <th>每份含量</th>
          <th>項目</th>
          <th>每份含量</th>
        </tr>
        <tr>
          <td>熱量</td>
          <td>250g</td>
          <td>碳水化合物</td>
          <td>42.0g</td>
        </tr>
        <tr>
          <td>總脂肪</td>
          <td>4.2g</td>
          <td>飽和脂肪</td>
          <td>0.8g</td>
        </tr>
        <tr>
          <td>蛋白質</td>
          <td>28.5g</td>
          <td>膳食纖維</td>
          <td>5.5g</td>
        </tr>
        <tr>
          <td>鈉</td>
          <td>420mg</td>
          <td>糖</td>
          <td>0.5g</td>
        </tr>
      </table>
      <p class="nutrition-table__note">一人份的營養成分表示/一份250g</p>
      <div class="product-detail__extra">
        <div>
          <h3 class="product-detail__section">食材內容：</h3>
          <ol>
            <li>嚴選低溫舒肥嫩雞胸</li>
            <li>黃金兩色藜麥糙米飯(三色藜麥、優質糙米)</li>
            <li>
              五彩均衡鮮蔬(青花菜、鮮甜紅蘿蔔 / 黃玉米筍、栗子地瓜 /
              烤南瓜、毛豆仁)
            </li>
          </ol>
        </div>
        <div class="product-detail__section">
          <h3>使用方法：</h3>
          <ol>
            <li>微波加熱： 撕開包裝一角以800W 加熱約2-3分鐘。</li>
            <li>
              隔水加熱：
              整包放入熱水中浸泡5-8分鐘（不建議沸騰加熱以維持肉質嫩度）。
            </li>
            <li>電鍋加熱： 解凍後放入內鍋，外鍋加少許水，跳起即可。</li>
          </ol>
        </div>
        <div class="product-detail__section">
          <h3>保存期限：</h3>
          <p>冷凍保存 12 個月。</p>
        </div>
        <div class="product-detail__section">
          <h3>貼心提醒：</h3>
          <p>本產品含有穀類製品，過敏者請留意。</p>
        </div>
      </div>
    </div>
  </section>
  <section>
    <h2>推薦商品</h2>
    <div class="product-card">
      <img src="https://picsum.photos/282/211/?random=16" class=".product-card__img" />
      <div class="product-card__content">
        <h4 class="product-card__title">舒肥雞胸藜麥飯</h4>
        <p class="product-card__price">$160</p>
        <button>加入購物車</button>
      </div>
    </div>
    <div class="product-card">
      <img src="https://picsum.photos/282/211/?random=15" class=".product-card__img" />
      <div class="product-card__content">
        <h4 class="product-card__title">豆腐漢堡排佐野菇</h4>
        <p class="product-card__price">$150</p>
        <button>加入購物車</button>
      </div>
    </div>
    <div class="product-card">
      <img src="https://picsum.photos/282/211/?random=14" class=".product-card__img" />
      <div class="product-card__content">
        <h4 class="product-card__title">白酒蒜香蛤蜊麵</h4>
        <p class="product-card__price">$185</p>
        <button>加入購物車</button>
      </div>
    </div>
    <div class="product-card">
      <img src="https://picsum.photos/282/211/?random=13" class=".product-card__img" />
      <div class="product-card__content">
        <h4 class="product-card__title">麻婆豆腐燒</h4>
        <p class="product-card__price">$160</p>
        <button>加入購物車</button>
      </div>
    </div>
  </section>
</template>

<style lang="scss" scoped>
//  lang="scss": 告訴 Vue 這裡要用 Scss 編譯
//  scoped: 確保這裡寫的 CSS 只會影響目前這個頁面，不會「跑去污染」到其他頁面的樣式。
.product-detail {
  display: flex; // 啟動 Flex 佈局
  align-items: center; // 垂直置中
  justify-content: space-between; // 兩端對齊（中間留空）
}

h1 {
  font-size: 36px; //h2
  text-align: center;
}

.product-detail__description {
  font-size: 16px; //p1
}
</style>
