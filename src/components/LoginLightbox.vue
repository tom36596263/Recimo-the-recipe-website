<script setup>
// setup: 這是 Vue 3 的語法糖，讓你不用寫 export default {}，且能直接使用變數和函式，開發效率最高。
// 所有的變數、函式、或是從 JSON 引入的資料都寫在script裡面。
import { ref, onMounted } from 'vue';

// ==========================================
// 翻頁效果
// ==========================================

// 使用組長規範的 is 前綴命名布林值
const isRegister = ref(false);
const isVisible = ref(true);

// 切換翻頁狀態的函式

const handleToggleMode = () => {
  isRegister.value = !isRegister.value;
};

// 關閉燈箱
const handleClose = () => {
  isVisible.value = false;
};

// ==========================================
// 驗證碼
// ==========================================

// 定義綁定的變數，對應到 template 裡的 ref="canvasRef"
const canvasRef = ref(null);
const loginForm = ref({
  captchaInput: '' // 用 v-model 綁定輸入框，不要用 getElementById
});

let currentCaptcha = '';

// 產生亂數輔助函式
function rand(min, max) {
  return Math.floor(Math.random() * (max - min) + min);
}

// 產生驗證碼的主函式
const generateCaptcha = () => {
  // 關鍵：必須透過 .value 拿到 canvas 實體
  const canvas = canvasRef.value;
  if (!canvas) return; // 如果還沒畫好就跳過，防止報錯

  const ctx = canvas.getContext('2d');
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789';
  let code = '';

  // 清空畫布
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.fillStyle = '#f2f2f2';
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  // 繪製文字
  for (let i = 0; i < 4; i++) {
    const char = chars.charAt(Math.floor(Math.random() * chars.length));
    code += char;
    ctx.font = 'bold 24px Arial';
    ctx.fillStyle = `rgb(${rand(0, 150)}, ${rand(0, 150)}, ${rand(0, 150)})`;
    const x = 10 + i * 25;
    const y = 28;
    const angle = (rand(-20, 20) * Math.PI) / 180;
    ctx.save();
    ctx.translate(x, y);
    ctx.rotate(angle);
    ctx.fillText(char, 0, 0);
    ctx.restore();
  }

  // 干擾線
  for (let i = 0; i < 5; i++) {
    ctx.strokeStyle = `rgba(${rand(0, 255)}, ${rand(0, 255)}, ${rand(
      0,
      255
    )}, 0.5)`;
    ctx.beginPath();
    ctx.moveTo(rand(0, canvas.width), rand(0, canvas.height));
    ctx.lineTo(rand(0, canvas.width), rand(0, canvas.height));
    ctx.stroke();
  }

  currentCaptcha = code.toLowerCase();
};

// 驗證按鈕的函式
const handleVerify = () => {
  const input = loginForm.value.captchaInput.toLowerCase();
  if (input === currentCaptcha) {
    alert('驗證成功！');
  } else {
    alert('驗證碼錯誤，請重試。');
    generateCaptcha();
    loginForm.value.captchaInput = ''; // 清空輸入框
  }
};

// 生命週期：當畫面掛載完成後，才執行畫圖
onMounted(() => {
  generateCaptcha();
});

// ==========================================
// 不要原生的input提示
// ==========================================
const emailInput = ref(null);

onMounted(() => {
  const el = emailInput.value;
  if (!el) return;

  // 1. 當驗證失敗時觸發
  el.oninvalid = function (e) {
    e.target.setCustomValidity(""); // 先清空舊的訊息
    if (!e.target.validity.valid) {
      // 在這裡輸入你想顯示的自訂文字
      e.target.setCustomValidity("*必須包含「@」符號");
    }
  };

  // 2. 當使用者正在輸入時，必須把錯誤清掉，否則表單會一直判定為無效而無法送出
  el.oninput = function (e) {
    e.target.setCustomValidity("");
  };
});
</script>

<template>
  <!-- 燈箱灰色遮罩.auth-modal 負責定位和 3D 環境，.auth-modal__overlay 負責顏色 -->
  <div class="auth-modal" v-if="isVisible">
    <div class="auth-modal__overlay" @click="handleClose"></div>

    <!-- :class="{ 'book--flipped': isRegister }"：這是 Vue 的動態語法。當 isRegister 變成 true 時，這本書會被加上一個 book--flipped 的標籤。 -->
    <!-- 連動動畫：在 CSS 裡，我們寫了 .book--flipped & { transform: rotateY(-180deg); }。意思是只要標籤一出現，內部的封面頁就會執行「向左翻 180 度」的動作。 -->
    <div class="book" :class="{ 'book--flipped': isRegister }">
      <!-- 左底層 (.book__base--left)：固定在左邊，永遠不動。 -->
      <div class="book__base book__base--left">
        <!-- ==========================================
              會員登入
        ========================================== -->
        <button @click="handleClose">x</button>
        <div>
          <h1 class="auth-form__title">會員登入</h1>
          <div class="auth-form">
            <form novalidate>
              <label for="email">電子信箱</label>
              <input ref="emailInput" type="email" class="form-input" placeholder="請輸入您的電子信箱" required />
              <p class="input-message">請輸入正確的信箱格式</p>
            </form>
            <form>
              <div>
                <label for="password">密碼</label>
                <a href="#">忘記密碼</a>
              </div>
              <input type="password" class="form-input" placeholder="請輸入密碼" />
            </form>
            <form>
              <div class="auth-form__group">
                <label class="auth-form__label">驗證碼</label>
                <div class="auth-form__captcha-row">
                  <input type="text" class="form-input auth-form__input auth-form__input--captcha" placeholder="請輸入驗證碼"
                    v-model="loginForm.captchaInput" />
                  <canvas ref="canvasRef" width="120" height="40" class="auth-form__captcha-canvas"
                    @click="generateCaptcha"></canvas>
                  <button type="button" class="auth-form__refresh-btn" @click="generateCaptcha">
                    換一張
                  </button>
                </div>
              </div>
            </form>
            <button>登入</button>
            <p>更多登入方式</p>
            <div>
              <a href="#"><img src="https://picsum.photos/40/40/?random=10" /></a>
              <a href="#"><img src="https://picsum.photos/40/40/?random=10" /></a>
              <a href="#"><img src="https://picsum.photos/40/40/?random=10" /></a>
            </div>
          </div>
        </div>
      </div>

      <!-- 右底層 (.book__base--right)：固定在右邊，永遠不動。 -->
      <div class="book__base book__base--right">
        <!-- ==========================================
              會員註冊
        ========================================== -->
        <div class="auth-form">
          <button @click="handleClose">x</button>
          <div>
            <h1 class="auth-form__title">會員註冊</h1>
            <div class="auth-form">
              <form>
                <label for="text">姓名</label>
                <input type="text" class="form-input" placeholder="請輸入您的姓名" />
              </form>
              <form>
                <label for="email">電子信箱</label>
                <input type="email" class="form-input" placeholder="請輸入您的電子信箱" />
              </form>
              <form>
                <label for="password">密碼</label>
                <input type="password" class="form-input" placeholder="請輸入密碼" />
              </form>
              <form>
                <div>
                  <label for="password">確認密碼</label>
                </div>
                <input type="password" class="form-input" placeholder="請再輸入一次密碼" />
              </form>
              <button>註冊</button>
            </div>
          </div>
        </div>
      </div>

      <!-- 活動翻頁層 (.book__cover)：這是關鍵！它寬度只有書本的一半（50%），初始位置在右邊。 -->
      <div class="book__cover">
        <div class="book__face book__face--front">
          <!-- ==========================================
              前往會員註冊
          ========================================== -->
          <div class="auth-hero__content">
            <img src="https://picsum.photos/174/50/?random=10" />
            <div>
              <h3>還不是會員嗎？</h3>
              <h4>快來一起加入Recimo吧~</h4>
              <button @click="handleToggleMode">前往註冊</button>
            </div>
          </div>
        </div>

        <div class="book__face book__face--back">
          <!-- ==========================================
              前往會員登入
          ========================================== -->
          <div class="auth-info">
            <img src="https://picsum.photos/174/50/?random=10" />

            <div>
              <h3>歡迎回來Recimo</h3>
              <h4>如果已經有會員就直接登入吧~</h4>
              <button @click="handleToggleMode">前往登入</button>
            </div>
          </div>
        </div>
      </div>

      <!-- 書脊：書本的轉軸和裝飾，還能起到遮醜與強化立體感的作用 -->
      <div class="book__spine"></div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
//  lang="scss": 告訴 Vue 這裡要用 Scss 編譯
//  scoped: 確保這裡寫的 CSS 只會影響目前這個頁面，不會「跑去污染」到其他頁面的樣式。

// ==========================================
// input
// ==========================================
// @import '@/assets/scss/abstracts/_color.scss';
// @import '@/assets/scss/components-scss/_input.scss';


// .form-input {
//   // 直接呼叫設定的基礎樣式（裡面已經包含 transition 和 focus 邏輯了）
//   @include input-style();

//   // 2. 針對「驗證碼輸入框」微調寬度
//   &--captcha {
//     flex: 1;
//   }

//   // 3. 處理 Focus 狀態 (如果你想讓燈箱的 Focus 顏色跟預設不同)
//   &:focus {
//     // 這裡會覆蓋 Mixin 裡的預設值，改成你想要的顏色
//     border-color: $primary-color-800;
//     box-shadow: 0 0 0 3px rgba($primary-color-800, 0.1);
//   }
// }

// // 4. 處理錯誤狀態 (這也是組長寫好的 mixin)
// .form-input.is-error {
//   @include input-status($secondary-color-danger-700);
// }

// ========================================== 
// 書
// ==========================================
// 1. 遮罩與容器層
.auth-modal {
  position: fixed;
  inset: 0;
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: rgba(0, 0, 0, 0.5);

  // 賦予整個空間 3D 深度感，數值越大透視越平緩

  perspective: 2000px;

  &__overlay {
    position: absolute;
    inset: 0;
  }
}

// 2. 書本主體

.book {
  position: relative;
  width: 900px;
  height: 550px;
  display: flex;
  // 確保子元素能在 3D 空間中運動
  transform-style: preserve-3d;
  transition: transform 0.6s ease;
  // 3. 底層固定頁面 (Left & Right)

  &__base {
    flex: 1;
    background-color: #fff;
    padding: 40px;
    border: 1px solid #e0e0e0;

    &--left {
      border-radius: 12px 0 0 12px;
    }

    &--right {
      border-radius: 0 12px 12px 0;
      background-color: #f9f9f9; // 稍微區隔底層顏色
    }
  }

  // 4. 活動翻頁層 (核心動畫零件)

  &__cover {
    position: absolute;
    right: 0;
    width: 50%;
    height: 100%;

    // 設定旋轉軸心在左側（即書脊位置）
    transform-origin: left center;
    transition: transform 0.8s cubic-bezier(0.4, 0, 0.2, 1);
    transform-style: preserve-3d;
    z-index: 5;

    // 翻轉狀態：當父層有 .book--flipped 時，這一頁轉 180 度
    .book--flipped & {
      transform: rotateY(-180deg);
    }
  }

  // 5. 翻頁的正反面

  &__face {
    position: absolute;
    inset: 0;

    // 翻到背面時隱藏另一面，防止文字鏡像重疊
    backface-visibility: hidden;
    border-radius: 0 12px 12px 0;
    overflow: hidden;

    &--front {
      z-index: 2;
      background-color: #fff;
    }

    &--back {
      // 背面預設就要先轉 180 度，這樣翻過來後才會是正的
      transform: rotateY(180deg);
      background-color: #fff;
      border-radius: 12px 0 0 12px; // 翻過來後變成了左頁
      border-right: 1px solid #ddd;
    }
  }

  // 6. 書脊裝飾 (中間的小圓圈標籤)

  &__spine {
    position: absolute;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -50%);
    width: 40px;
    height: 40px;
    background-color: #4a7c59; // 配合設計圖綠色
    border-radius: 50%;
    z-index: 10;
    pointer-events: none; // 避免擋住點擊事件

    &::after {
      content: '';
      position: absolute;
      left: 50%;
      height: 100%;
      width: 2px;
      background-color: rgba(0, 0, 0, 0.1);

      // 延伸成一條線的視覺感
      height: 550px;
      top: -255px;
    }
  }
}
</style>
