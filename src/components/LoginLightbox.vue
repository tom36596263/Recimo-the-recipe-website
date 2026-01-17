<script setup>
import { ref, computed, onMounted } from 'vue';

// ==========================================
// input前端驗證
// ==========================================
import BaseInput from '@/components/login/BaseInput.vue'
const name = ref('')
const email = ref('')
const password = ref('')
const showPassword = ref(false)

// 追蹤每個欄位是否被觸碰
const touched = {
  name: ref(false),
  email: ref(false),
  password: ref(false)
}

// 訊息內容
const message = {
  name: computed(() => {
    // 如果還沒觸碰過，回傳空字串（不顯示提示）
    if (!touched.name.value) return ''
    // 觸碰過後，如果沒填才顯示必填提示
    if (!name.value) return '* 此欄為必填'
    return ''
  }),
  email: computed(() => {
    if (!touched.email.value) return ''
    if (!email.value) return '* 此欄為必填'
    if (!/^\S+@\S+\.\S+$/.test(email.value)) return '* email 格式錯誤'
    return ''
  }),
  password: computed(() => {
    if (!touched.password.value) return ''
    if (!password.value) return '* 此欄為必填'
    return ''
  })
}

// 驗證狀態
const status = {
  name: computed(() => {
    if (!touched.name.value) return ''
    if (!name.value) return 'error' // 觸碰過沒填
    return name.value ? 'success' : 'error'
  }),
  email: computed(() => {
    if (!touched.email.value) return ''
    if (!email.value) return 'error' // 觸碰過沒填
    if (!/^\S+@\S+\.\S+$/.test(email.value)) return 'error'
    return 'success'
  }),
  password: computed(() => {
    if (!touched.password.value) return ''
    if (!password.value) return 'error' // 觸碰過沒填
    return password.value ? 'success' : 'error'
  })
}
// enter會進下一個input
const emailRef = ref(null);
const passwordRef = ref(null);
const nameRef = ref(null);

// 建立一個通用跳轉函式
const focusNext = (nextRef) => {
  console.log('嘗試跳轉，目標 Ref:', nextRef.value);

  if (!nextRef || !nextRef.value) {
    console.error('找不到目標 Ref 物件');
    return;
  }

  // 1. 取得 DOM 根節點
  // Vue 元件通常在 .value.$el，原生 HTML 元素則直接在 .value
  const el = nextRef.value.$el || nextRef.value;

  // 2. 尋找 input 標籤 (支援自定義元件內部的 input)
  let inputElement = null;
  if (el.tagName === 'INPUT') {
    inputElement = el;
  } else {
    inputElement = el.querySelector('input');
  }

  if (inputElement) {
    // 延遲一點點時間確保 DOM 狀態正確 (非必填，但可增加穩定性)
    setTimeout(() => {
      inputElement.focus();
      console.log('Focus 成功！');
    }, 10);
  } else {
    console.warn('目標組件中真的找不到 input 標籤');
    // 如果是 captcha 抓不到 input，就嘗試直接執行登入
    if (nextRef === captchaRef) {
      handleLogin();
    }
  }
};
// ==========================================
// 驗證碼
// ==========================================

import CaptchaInput from '@/components/login/CaptchaInput.vue'
const loginForm = ref({
  captchaInput: ''
})
const captchaVerified = ref(false)

const onCaptchaVerified = (success) => {
  captchaVerified.value = success
  console.log('captchaVerified:', captchaVerified.value)
}

// ==========================================
// 登入按鈕
// ==========================================
const handleLogin = () => {
  // 標記所有欄位為已觸碰，觸發紅框提示
  touched.email.value = true
  touched.password.value = true

  // 驗證邏輯：email、password、驗證碼都必須正確
  if (
    !email.value ||
    !password.value ||
    !/^\S+@\S+\.\S+$/.test(email.value) ||
    !captchaVerified.value
  ) {
    alert('請填寫完整且正確的資料！')
    return
  }
  alert('跳出登入成功或失敗彈窗！')
}

// ==========================================
// 翻頁效果
// ==========================================
const isRegister = ref(false);
const isVisible = ref(true);

// 切換翻頁狀態的函式

const goToRegister = () => {
  isRegister.value = true;
  console.log('切換到註冊頁', isRegister.value);
};

const goToLogin = () => {
  isRegister.value = false;
  console.log('切換到登入頁', isRegister.value);
};

// 關閉燈箱
const handleClose = () => {
  isVisible.value = false;
};


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
          <h1 class="zh-h3 auth-form__title">會員登入</h1>
          <div class="auth-form">
            <BaseInput ref="emailRef" v-model="email" label="電子信箱" placeholder="請輸入您的電子信箱" :status="status.email.value"
              :message="message.email" @blur="touched.email.value = true" @enter-press="focusNext(passwordRef)"
              class="tight-gap" />
            <BaseInput ref="passwordRef" v-model="password" label="密碼" placeholder="請輸入密碼"
              :type="showPassword ? 'text' : 'password'" :status="status.password.value"
              :message="message.password.value" @blur="touched.password.value = true"
              @enter-press="focusNext(captchaRef)" class="tight-gap">
              <template #label-right>
                <a href="#" class="forgot-password-link">忘記密碼</a>
              </template>
              <template #suffix> <button type="button" @click="showPassword = !showPassword"> {{
                showPassword ? '🙈' : '👁️' }} </button> </template>
            </BaseInput>
            <CaptchaInput ref="captchaRef" v-model="loginForm.captchaInput" @verified="onCaptchaVerified"
              @enter-press="handleLogin" class="tight-gap" />
            <div class="login-options">
              <BaseBtn title=" 登入" variant="solid" @click="handleLogin" :width="244" :height="50" class="login-btn" />
              <p class="auth-form__divider">更多登入方式</p>
              <div class="social-login">
                <a href="#"><img src="@/assets/images/login/google.svg" /></a>
                <a href="#"><img src="@/assets/images/login/fb.svg" /></a>
                <a href="#"><img src="@/assets/images/login/line.svg" /></a>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 右底層 (.book__base--right)：固定在右邊，永遠不動。 -->
      <div class="book__base book__base--right">
        <!-- ==========================================
              會員註冊
        ========================================== -->
        <button @click="handleClose">x</button>
        <div>
          <h1 class="zh-h3 auth-form__title">會員註冊</h1>
          <div class="auth-form">
            <BaseInput v-model="name" label="姓名" placeholder="請輸入姓名" :status="status.name.value"
              :message="message.name.value" @blur="touched.name.value = true" class="tight-gap" />
            <BaseInput ref="emailRef" v-model="email" label="電子信箱" placeholder="請輸入您的電子信箱" :status="status.email.value"
              :message="message.email" @blur="touched.email.value = true" @enter-press="focusNext(passwordRef)"
              class="tight-gap" />
            <BaseInput ref="passwordRef" v-model="password" label="密碼" placeholder="請輸入密碼"
              :type="showPassword ? 'text' : 'password'" :status="status.password.value"
              :message="message.password.value" @blur="touched.password.value = true"
              @enter-press="focusNext(captchaRef)" class="tight-gap">
              <template #suffix> <button type="button" @click="showPassword = !showPassword"> {{
                showPassword ? '🙈' : '👁️' }} </button> </template>
            </BaseInput>
            <form>
              <div>
                <label for="password">確認密碼</label>
              </div>
              <input type="password" class="form-input" placeholder="請再輸入一次密碼" />
            </form>
            <BaseBtn title="註冊" variant="solid" @click="handleRegister" :width="244" :height="50" />
          </div>
        </div>
      </div>


      <!-- 活動翻頁層 (.book__cover)：這是關鍵！它寬度只有書本的一半（50%），初始位置在右邊。 -->
      <div class="book__cover">
        <div class="book__face book__face--front">
          <!-- ==========================================
              前往會員註冊
          ========================================== -->
          <div class="registration-invite">
            <img src="@/assets/images/site/Recimo-logo-black.svg" />
            <div class="registration-invite__content">
              <h3 class="zh-h2">還不是會員嗎？</h3>
              <h4 class="zh-h3">快來一起加入Recimo吧~</h4>
              <BaseBtn title="前往註冊" variant="solid" @click="goToRegister" :width="244" :height="50" />
            </div>
          </div>
        </div>

        <div class="book__face book__face--back">
          <!-- ==========================================
              前往會員登入
          ========================================== -->
          <div class="login-invite">
            <img src="@/assets/images/site/Recimo-logo-black.svg" />
            <div class="login-invite__content">
              <h3>歡迎回來Recimo</h3>
              <h4>如果已經有會員就直接登入吧~</h4>
              <BaseBtn title="前往登入" variant="solid" @click="goToLogin" :width="244" :height="50" />
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
.auth-form {
  border: 1px solid red;
  margin: 20px 0;
  display: flex;
  flex-direction: column; // 讓內容由上往下排
  align-items: center; // **關鍵：讓所有子元素水平置中**
  width: 100%; // 確保容器撐滿寬度
}

.login-btn {
  margin: 20px 0;
}

// ========================================== 
// input
// ==========================================
// 調整 label 與 input 的垂直距離
.base-input-container.tight-gap {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

//標題
.auth-form__title {
  text-align: center;
}

.tight-gap {
  margin: 10px 0;
}

// 忘記密碼
:deep(.label-bar) {
  display: flex;
  justify-content: space-between; // 讓標籤跟連結分開在左右兩頭
  align-items: center;
  width: 100%;
  margin-bottom: 4px; // 與 input 的距離
}

.forgot-password-link {
  font-size: 12px;
  color: #4a7c59; // 配合你的主色調
  text-decoration: none;
  transition: color 0.3s;

  &:hover {
    color: $accent-color-700;
    text-decoration: underline; // 移上去加下底線
  }
}

// 更多登入方式
.login-options {
  width: 100%;
  text-align: center;
}

.auth-form__divider {
  display: flex; // 使用 Flexbox
  align-items: center; // 垂直居中對齊文字與線條
  width: 100%; // 確保容器寬度足夠
  color: #888; // 文字顏色

  // 線條的共同樣式
  &::before,
  &::after {
    content: "";
    flex: 1; // 讓線條自動填滿剩餘空間
    height: 1px; // 線條高度
    background-color: #ddd; // 線條顏色
  }

  // 文字與線條之間的間距
  &::before {
    margin-right: 15px;
  }

  &::after {
    margin-left: 15px;
  }
}

.social-login {
  display: flex;
  align-items: center;
  justify-content: center;

  a {
    display: inline-block; // 確保 transform 在連結上生效
    transition: transform 0.3s ease; // 設定動畫時間與曲線

    &:hover {
      // 放大 1.15 倍
      transform: scale(1.15);

      // 增加一點陰影，讓它看起來像浮起來
      // filter: drop-shadow(0 4px 6px rgba(0,0,0,0.1));
    }

    &:active {
      // 點擊瞬間縮小回 0.95 倍，增加點擊回饋感
      transform: scale(0.95);
    }
  }
}

.social-login img {

  width: 40px;
  margin: 20px;

  // 放大 1.15 倍
  transform: scale(1.15);

  // 增加一點陰影，讓它看起來像浮起來
  filter: drop-shadow(0 4px 6px rgba(0, 0, 0, 0.1));
}

// ========================================== 
// input旁邊有圖片的那頁
// ==========================================
.registration-invite {
  background-image: url(@/assets/images/login/registration-invite-bg.jpg);
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  gap: 15px;
}

.login-invite {
  background-image: url(@/assets/images/login/login-invite-bg.jpg);
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  gap: 15px;
}

.registration-invite__content,
.login-invite__content {
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 20px;
  align-items: center;
}

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
  // height: 600px;
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
  }

  // 翻轉狀態：當父層有 .book--flipped 時，這一頁轉 180 度
  &.book--flipped {

    // 當 .book 同時擁有 .book--flipped 時，改變 cover 的狀態
    .book__cover {
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