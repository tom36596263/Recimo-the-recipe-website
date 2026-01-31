<script setup>
import { ref, computed, onMounted, nextTick, watch } from 'vue';
import { publicApi } from '@/utils/publicApi';
import { base } from '@/utils/publicApi';

// 引用 Pinia Store (權限狀態管理)
import { useAuthStore } from '@/stores/authStore';
const authStore = useAuthStore();
// 引用彈窗
import BaseModal from '@/components/BaseModal.vue';
// 引用input
import BaseInput from '@/components/login/BaseInput.vue'
// 引用icon
import IconEyeOpen from '~icons/material-symbols/visibility-outline-rounded';
import IconEyeClose from '~icons/material-symbols/visibility-off-outline-rounded';
// 引用驗證碼
import CaptchaInput from '@/components/login/CaptchaInput.vue'
// 呼叫Api
import { phpApi } from '@/utils/publicApi.js';

import { useRouter } from 'vue-router';
const router = useRouter();

// 定義控制彈窗的變數
const showLoginSuccess = ref(false);
const showLoginFail = ref(false);
const showRegisterSuccess = ref(false);
const showRegisterFail = ref(false);
const loginErrorMessage = ref(''); // 用來存放後端回傳的錯誤原因
const registerErrorMessage = ref(''); // 用來存放後端回傳的錯誤原因

// ==========================================
// 登入.註冊前端驗證
// ==========================================
const loginData = ref({
  email: '',
  password: ''
});

const registerData = ref({
  name: '',
  email: '',
  password: '',
  confirmPassword: ''
});

// 追蹤每個欄位是否被觸碰
const touched = ref({
  login: { email: false, password: false },
  register: { name: false, email: false, password: false, confirmPassword: false }
});

// ==========================================
// 登入前端驗證訊息內容
// ==========================================
const loginMessage = computed(() => {
  const t = touched.value.login;
  const d = loginData.value;
  const errors = { email: '', password: '' };

  // Email 驗證
  if (t.email) {
    if (!d.email) errors.email = '* 此欄為必填';
    else if (!/^\S+@\S+\.\S+$/.test(d.email)) errors.email = '* email 格式錯誤';
  }

  // 密碼驗證
  if (t.password && !d.password) {
    errors.password = '* 此欄為必填';
  }

  return errors;
});

const loginStatus = computed(() => ({
  email: touched.value.login.email ? (loginMessage.value.email ? 'error' : 'success') : '',
  password: touched.value.login.password ? (loginMessage.value.password ? 'error' : 'success') : ''
}));

const captchaError = computed(() => {
  // 如果還沒碰過，不顯示錯誤
  if (!touched.value.login.captcha) return '';
  // 如果沒填
  if (!loginForm.value.captchaInput) return '* 此欄為必填';
  // 如果驗證沒通過
  if (!captchaVerified.value) return '* 驗證碼錯誤';
  return '';
});

const captchaStatus = computed(() => {
  if (!touched.value.login.captcha) return '';
  return captchaError.value ? 'error' : 'success';
});

// ==========================================
// 註冊前端驗證訊息內容
// ==========================================
const registerMessage = computed(() => {
  const t = touched.value.register;
  const d = registerData.value;
  const msg = { name: '', email: '', password: '', confirmPassword: '' };

  if (t.name && !d.name) msg.name = '* 此欄為必填';
  if (t.email) {
    if (!d.email) msg.email = '* 此欄為必填';
    else if (!/^\S+@\S+\.\S+$/.test(d.email)) msg.email = '* email 格式錯誤';
  }
  // 檢查密碼規則是否全過
  const isPasswordValid = Object.values(passwordRules.value).every(v => v);
  if (t.password && !isPasswordValid) {
    // 回傳一個帶空格的字串，這會讓 BaseInput 的 status 判定為 error (顯示紅框)
    // 但因為內容是空的，所以畫面上不會看到錯誤文字
    msg.password = ' ';
  }
  // 確認密碼驗證
  if (t.confirmPassword) {
    if (!d.confirmPassword) msg.confirmPassword = '* 此欄為必填';
    else if (d.confirmPassword !== d.password) msg.confirmPassword = '* 兩次密碼不一致';
  }
  return msg;
});

// 眼睛連動與不連動
const showLoginPassword = ref(false);
const showRegisterPassword = ref(false);

// 驗證狀態
const registerStatus = computed(() => {
  const msg = registerMessage.value;
  const t = touched.value.register;
  return {
    name: t.name ? (msg.name ? 'error' : 'success') : '',
    email: t.email ? (msg.email ? 'error' : 'success') : '',
    password: t.password ? (msg.password ? 'error' : 'success') : '',
    confirmPassword: t.confirmPassword ? (msg.confirmPassword ? 'error' : 'success') : ''
  };
});

// ==========================================
// enter會進下一個input(尚未成功)
// ==========================================
const loginEmailRef = ref(null);
const loginPasswordRef = ref(null);
const captchaRef = ref(null);

const regNameRef = ref(null);
const regEmailRef = ref(null);
const regPasswordRef = ref(null);
const regConfirmPasswordRef = ref(null);

// 建立一個通用跳轉函式

const focusInput = async (targetRef) => {
  await nextTick();

  const instance = targetRef?.value;
  if (!instance) return;

  if (typeof instance.focus === 'function') {
    instance.focus();
    return;
  }

  const el = instance.$el || instance;
  el?.querySelector?.('input')?.focus();
};

// ==========================================
// 驗證碼
// ==========================================
const loginForm = ref({
  captchaInput: ''
})
const captchaVerified = ref(false)

const onCaptchaVerified = (success) => {
  captchaVerified.value = success
  // console.log('captchaVerified:', captchaVerified.value)
}

// ==========================================
// 登入按鈕邏輯
// ==========================================
const handleLogin = async () => {
  // 觸發所有欄位的 touched 狀態，錯誤由紅字顯示
  touched.value.login.email = true;
  touched.value.login.password = true;
  touched.value.login.captcha = true;

  // 檢查所有前端驗證是否通過
  const hasLoginError = loginMessage.value.email || loginMessage.value.password;

  // 如果有帳密錯誤，或者驗證碼沒過，直接攔截（不跳彈窗）
  if (hasLoginError || !captchaVerified.value) {
    // console.log('前端驗證未通過，攔截登入');
    return;
  }

  // 只有前端全過，才會跑到這裡執行 API
  try {
    // 改用 POST 發送到 PHP
    const response = await phpApi.post('auth/login.php', {
      email: loginData.value.email,
      password: loginData.value.password
    });

    const result = response.data;
    // console.log('PHP 回傳：', result.user);

    // 判斷 PHP 回傳的狀態 (對應PHP的 status)
    if (result.status === 'success') {
      // 登入成功：使用 PHP 回傳的真實資料 (result.user)
      authStore.login(result.user);

      // 先叫出成功小彈窗再關掉登入大書本
      showLoginSuccess.value = true;
      isVisible.value = false;


      // 延遲後跳轉
      setTimeout(() => {
        showLoginSuccess.value = false;
        emit('close');
        handleClose();

        if (authStore.pendingAction) {
          router.push('/');
        }
      }, 1500);

    } else {
      // 登入失敗：顯示失敗彈窗
      // console.log('PHP 回傳的錯誤訊息：', result.message);
      // 接收 PHP 回傳的 message (例如：帳號不存在、密碼錯誤)
      loginErrorMessage.value = result.message;
      showLoginFail.value = true;
    }
  } catch (error) {
    // console.error('API 連線失敗:', error);
    alert('伺服器連線異常');
  }
};

// 重置登入表單
const captchaKey = ref(0);
const resetLoginForm = () => {
  // 1. 清空輸入資料
  loginData.value = {
    email: '',
    password: ''
  };

  // 2. 清空驗證碼輸入 (如果有需要)
  loginForm.value.captchaInput = '';

  // 3. 重置「已觸碰」狀態，這樣錯誤訊息（紅字）才會消失
  touched.value.login = {
    email: false,
    password: false
  };

  // 4. 重置驗證碼成功狀態
  captchaVerified.value = false;
  captchaKey.value += 1;
};

// ==========================================
// 註冊按鈕邏輯
// ==========================================
const handleRegister = async () => {
  // 觸發所有欄位的 touched 狀態，錯誤由紅字顯示
  touched.value.register = {
    name: true,
    email: true,
    password: true,
    confirmPassword: true
  };

  // 檢查前端是否有錯誤 (密碼規則或格式)
  const allRulesMet = Object.values(passwordRules.value).every(val => val === true);
  const hasError = Object.values(registerMessage.value).some(msg => msg !== '' && msg !== ' ');

  // 如果前端驗證沒過，直接 return (此時畫面上會有紅字提示，不需要額外彈窗)
  if (!allRulesMet || hasError) return;

  try {
    // 改用 POST 發送到 PHP API
    const response = await phpApi.post('auth/register.php', registerData.value);
    const result = response.data;

    if (result.status === 'success') {
      showRegisterSuccess.value = true;
      setTimeout(() => {
        showRegisterSuccess.value = false;
        goToLogin();
      }, 1500);
    } else {
      // 註冊失敗：顯示失敗彈窗
      // 接收 PHP 回傳的 message (例如：此電子信箱尚未註冊)
      registerErrorMessage.value = result.message;
      showRegisterFail.value = true;
    }
  } catch (error) {
    // console.error('API 連線失敗:', error);
    alert('伺服器連線異常');
  }
};

// 重置註冊表單的函式
const resetRegisterForm = () => {
  registerData.value = {
    name: '',
    email: '',
    password: '',
    confirmPassword: ''
  };
  // 同時重置錯誤狀態，否則翻回來會看到滿片紅字
  touched.value.register = {
    name: false,
    email: false,
    password: false,
    confirmPassword: false
  };
};

// 密碼規定檢查
const passwordRules = computed(() => {
  const pwd = registerData.value.password;
  return {
    length: pwd.length >= 8,                       // 至少 8 個字元
    hasUpper: /[A-Z]/.test(pwd),                  // 含一大寫字母
    hasLower: /[a-z]/.test(pwd),                  // 含一小寫字母
  };
});
// ==========================================
// 翻頁效果與自動清空
// ==========================================
const isRegister = ref(false);
const isVisible = ref(true);

// 核心監聽：只要頁面一切換，就清空「對方」的資料
watch(isRegister, (newVal) => {
  if (newVal) {
    // 切換到註冊 -> 清空登入表單
    resetLoginForm();
  } else {
    // 切換到登入 -> 清空註冊表單
    resetRegisterForm();
  }
});

// 切換翻頁狀態的函式
const goToRegister = () => {
  isRegister.value = true;
  // console.log('切換到註冊頁', isRegister.value);
};

const goToLogin = () => {
  isRegister.value = false;
  // console.log('切換到登入頁', isRegister.value);
};

// ==========================================
// 關閉燈箱
// ==========================================
const emit = defineEmits(['close']);
const handleClose = () => {
  // console.log('Close button clicked'); // 如果沒印出來，代表按鈕沒點到
  emit('close'); // 通知 GlobalModalManager 把 Pinia 的狀態關掉
};

// ==========================================
// 登入成功彈窗
// ==========================================
const currentUserName = computed(() => {
  return authStore.user?.name;
});
</script>

<template>
  <!-- 燈箱灰色遮罩.auth-modal 負責定位和 3D 環境，.auth-modal__overlay 負責顏色 -->
  <div class="auth-modal" v-if="isVisible">
    <div class="auth-modal__overlay" @click="handleClose"></div>


    <!-- :class="{ 'book--flipped': isRegister }"：Vue 的動態語法。當 isRegister 變成 true 時，這本書會被加上一個 book--flipped 的標籤。 -->
    <!-- 連動動畫：在 CSS 裡，寫了 .book--flipped & { transform: rotateY(-180deg); }。意思是只要標籤一出現，內部的封面頁就會執行「向左翻 180 度」的動作。 -->


    <div class="container">
      <div class="row">
        <div class="book" :class="{ 'book--flipped': isRegister }">


          <!-- 左底層 (.book__base--left)：固定在左邊，永遠不動。 -->
          <div class="book__base book__base--left">

            <button class="close-btn" @click="handleClose">
              <i class="fa-solid fa-xmark"></i>
            </button>
            <!-- ==========================================
                        會員登入
                  ========================================== -->
            <div class="login-section">
              <h1 class="zh-h3 auth-form__title">會員登入</h1>
              <div class="auth-form">
                <BaseInput ref="loginEmailRef" v-model="loginData.email" label="電子信箱" placeholder="請輸入電子信箱"
                  :status="loginStatus.email" :message="loginMessage.email" @blur="touched.login.email = true"
                  @enter-press="focusInput(loginPasswordRef)" class="tight-gap" />
                <BaseInput ref="loginPasswordRef" v-model="loginData.password" label="密碼" placeholder="請輸入密碼"
                  :type="showLoginPassword ? 'text' : 'password'" :status="loginStatus.password"
                  :message="loginMessage.password" @blur="touched.login.password = true"
                  @enter-press="focusInput(captchaRef)" class="tight-gap">
                  <!-- <template #label-right>
                          <a href="#" class="forgot-password-link">忘記密碼</a>
                        </template> -->
                  <template #suffix>
                    <button type="button" @click="showLoginPassword = !showLoginPassword" class="icon-btn"
                      tabindex="-1">
                      <IconEyeClose v-if="showLoginPassword" />
                      <IconEyeOpen v-else />
                    </button>
                  </template>
                </BaseInput>
                <CaptchaInput :key="captchaKey" ref="captchaRef" v-model="loginForm.captchaInput"
                  @verified="onCaptchaVerified" @enter-press="handleLogin" class="tight-gap" />
                <div class="login-options">
                  <BaseBtn title=" 登入" variant="solid" @click="handleLogin" :width="244" :height="50"
                    class="login-btn" />
                  <p class="auth-form__divider">更多登入方式</p>
                  <div class="social-login">
                    <a href="#"><img src="@/assets/images/login/google.svg" /></a>
                    <a href="#"><img src="@/assets/images/login/fb.svg" /></a>
                    <a href="#"><img src="@/assets/images/login/line.svg" /></a>
                  </div>
                  <p class="mobile-switch-text" @click="isRegister = true">還不是會員嗎？快前往註冊吧~</p>
                </div>
              </div>
            </div>
          </div>


          <!-- 右底層 (.book__base--right)：固定在右邊，永遠不動。 -->
          <div class="book__base book__base--right">
            <!-- ==========================================
                        會員註冊
                  ========================================== -->
            <div class="register-section">
              <h1 class="zh-h3 auth-form__title">會員註冊</h1>
              <div class="auth-form">
                <BaseInput ref="regNameRef" v-model="registerData.name" label="姓名" placeholder="請輸入姓名"
                  :status="registerStatus.name" :message="registerMessage.name" @blur="touched.register.name = true"
                  @enter-press="focusInput(regEmailRef)" class="tight-gap" />
                <BaseInput ref="regEmailRef" v-model="registerData.email" label="電子信箱" placeholder="請輸入電子信箱"
                  :status="registerStatus.email" :message="registerMessage.email" @blur="touched.register.email = true"
                  @enter-press="focusInput(regPasswordRef)" class="tight-gap" />
                <BaseInput ref="regPasswordRef" v-model="registerData.password" label="密碼" placeholder="請輸入密碼"
                  :type="showRegisterPassword ? 'text' : 'password'" :status="registerStatus.password"
                  :message="registerMessage.password" @blur="touched.register.password = true"
                  @enter-press="focusInput(regConfirmPasswordRef)" class="tight-gap">
                  <template #suffix>
                    <button type="button" @click="showRegisterPassword = !showRegisterPassword" class="icon-btn"
                      tabindex="-1">
                      <IconEyeClose v-if="showRegisterPassword" />
                      <IconEyeOpen v-else />
                    </button>
                  </template>
                </BaseInput>

                <div class="password-requirements">
                  <p class="requirements-title p-p3">密碼規定：</p>
                  <ul>
                    <li class="p-p3" :class="{ 'met': passwordRules.length }">
                      <i
                        :class="passwordRules.length ? 'fa-solid fa-circle-check' : 'fa-solid fa-circle-exclamation'"></i>
                      至少含八個字元
                    </li>
                    <li class="p-p3" :class="{ 'met': passwordRules.hasUpper }">
                      <i
                        :class="passwordRules.hasUpper ? 'fa-solid fa-circle-check' : 'fa-solid fa-circle-exclamation'"></i>
                      含一大寫英文字母
                    </li>
                    <li class="p-p3" :class="{ 'met': passwordRules.hasLower }">
                      <i
                        :class="passwordRules.hasLower ? 'fa-solid fa-circle-check' : 'fa-solid fa-circle-exclamation'"></i>
                      含一小寫英文字母
                    </li>
                  </ul>
                </div>
                <BaseInput ref="regConfirmPasswordRef" v-model="registerData.confirmPassword" label="確認密碼"
                  placeholder="請再輸入一次密碼" :type="showRegisterPassword ? 'text' : 'password'"
                  :status="registerStatus.confirmPassword" :message="registerMessage.confirmPassword"
                  @blur="touched.register.confirmPassword = true" @enter-press="handleRegister" class="tight-gap" />
                <BaseBtn title="註冊" variant="solid" @click="handleRegister" :width="244" :height="50" />
                <p class="mobile-switch-text" @click="isRegister = false">已有帳號嗎？前往登入吧~</p>
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
                <img :src="`${base}img/site/Recimo-logo-black.svg`" />
                <div class="registration-invite__content">
                  <h3 class="zh-h3">還不是會員嗎？</h3>
                  <h4 class="zh-h4">快來一起加入Recimo吧~</h4>
                  <BaseBtn title="前往註冊" variant="outline" @click="goToRegister" :width="244" :height="50"
                    class="basebtn" />
                </div>
              </div>
            </div>
            <div class="book__face book__face--back">
              <!-- ==========================================
                        前往會員登入
                    ========================================== -->
              <div class="login-invite">
                <img src="/img/site/Recimo-logo-black.svg" />
                <div class="login-invite__content">
                  <h3 class="zh-h3">歡迎回來Recimo</h3>
                  <h4 class="zh-h4">如果已經有會員就直接登入吧~</h4>
                  <BaseBtn title="前往登入" variant="outline" @click="goToLogin" :width="244" :height="50"
                    class="basebtn" />
                </div>
              </div>
            </div>
          </div>


          <!-- 書脊：書本的轉軸和裝飾，還能起到遮醜與強化立體感的作用 -->
          <div class="book__spine"></div>
        </div>
      </div>
    </div>

  </div>
  <BaseModal :isOpen="showLoginSuccess" type="success" iconClass="fa-solid fa-check" title="登入成功"
    :description="`${currentUserName}，歡迎回來Recimo~`" @close="showLoginSuccess = false" />

  <BaseModal :isOpen="showLoginFail" type="danger" iconClass="fa-solid fa-exclamation" title="登入失敗"
    :description="loginErrorMessage" @close="showLoginFail = false">
    <template #actions>
      <button class="btn-solid" @click="showLoginFail = false; resetLoginForm()">重新登入</button>
      <!-- <button class="btn-outline" @click="/* 導向忘記密碼邏輯 */">忘記密碼</button> -->
    </template>
  </BaseModal>

  <BaseModal :isOpen="showRegisterSuccess" type="success" iconClass="fa-solid fa-user-plus" title="註冊成功"
    description="歡迎加入Recimo~將為您跳轉至登入畫面" @close="showRegisterSuccess = false">
  </BaseModal>

  <BaseModal :isOpen="showRegisterFail" type="danger" title="註冊失敗" iconClass="fa-solid fa-exclamation"
    :description="registerErrorMessage" @close="showRegisterFail = false">
    <template #actions>
      <button class="btn-solid" @click="showRegisterFail = false">返回修改</button>
    </template>
  </BaseModal>
</template>

<style lang="scss" scoped>
.close-btn {
  position: absolute;
  top: 20px;
  right: 20px;
  background: transparent;
  border: none;
  font-size: 24px;
  color: #ccc;
  cursor: pointer;
  z-index: 20;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: 50%;

  &:hover {
    color: $accent-color-700;
    background-color: rgba(0, 0, 0, 0.05);
    transform: rotate(90deg);
  }
}

.auth-form {
  // margin: 20px 0;
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
  margin: 5px 0;
}

//標題
.auth-form__title {
  text-align: center;
  margin: 10px 0;
}

// 忘記密碼
:deep(.label-bar) {
  display: flex;
  justify-content: space-between; // 讓標籤跟連結分開在左右兩頭
  align-items: center;
  width: 100%;
}

.forgot-password-link {
  font-size: 12px;
  color: #4a7c59;
  text-decoration: none;
  transition: color 0.3s;

  &:hover {
    color: $accent-color-700;
    text-decoration: underline; // 移上去加下底線
  }
}

.icon-btn {
  background: transparent;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  color: $primary-color-700;
  transition: color 0.2s ease;

  svg {
    width: 28px;
    height: 28px;
  }

  &:hover {
    color: $accent-color-700;
  }

  &:focus {
    outline: none; // 去除按鈕預設藍框
  }
}

// 更多登入方式
.login-options {
  width: 100%;
  text-align: center;
}

.auth-form__divider {
  display: flex;
  align-items: center; // 垂直居中對齊文字與線條
  width: 100%; // 確保容器寬度足夠
  color: $neutral-color-700;

  // 線條的共同樣式
  &::before,
  &::after {
    content: "";
    flex: 1; // 讓線條自動填滿剩餘空間
    height: 1px; // 線條高度
    background-color: $neutral-color-400;
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
      transform: scale(1.15);

      // 增加一點陰影，讓它看起來像浮起來
      filter: drop-shadow(0 4px 6px rgba(0, 0, 0, 0.1));
    }

    &:active {
      // 點擊瞬間縮小回 0.6 倍，增加點擊回饋感
      transform: scale(0.6);
    }
  }
}

.social-login img {
  width: 40px;
  margin: 15px 20px 10px 20px;

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
  gap: 10px;
  align-items: center;

  .basebtn {
    margin-top: 10px;
  }
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
  background-color: $primary-color-700;
  border: 20px solid $primary-color-700;
  border-radius: 12px;
  position: relative;
  display: flex;
  margin: auto;
  width: 850px;
  // max-height: 95vh;
  // 確保子元素能在 3D 空間中運動
  transform-style: preserve-3d;
  transition: transform 0.6s ease;
  // 3. 底層固定頁面 (Left & Right)

  &__base {
    flex: 1;
    background-color: #fff;
    padding: 30px;
    border: 1px solid #e0e0e0;

    display: flex;
    flex-direction: column; // 讓標題與表單由上往下排
    justify-content: center; // 垂直置中

    @media screen and (max-width: 1024px) {
      padding: 20px;
    }

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

  // 6. 書脊裝飾
  &__spine {
    &::after {
      content: '';
      position: absolute;
      left: 50%;
      height: 100%;
      width: 2px;
      background-color: rgba(0, 0, 0, 0.1);

      // 延伸成一條線的視覺感
      // height: 550px;
      top: -255px;
    }
  }
}

.book__face--back {
  pointer-events: auto; // 確保背面元素可點擊
  z-index: 10; // 稍微提高一點點
}

// 手機版切換文字樣式
.mobile-switch-text {
  display: none; // 桌機版隱藏
  margin-top: 20px;
  color: $primary-color-700;
  text-decoration: underline;
  cursor: pointer;
  font-size: 14px;
}

@media screen and (max-width: 810px) {
  .close-btn {
    display: none;
  }

  .auth-modal {
    overflow-x: hidden;
    perspective: none;
  }

  .container {
    max-width: 100% !important;
    padding: 0;
  }

  .book {
    display: block !important; // 手機版改回 block，不再用 200% 寬度
    width: 370px !important;
    border: 15px solid $primary-color-700;
    margin: auto;
    transform: none !important; // 取消位移動畫

    &__base {
      width: 100% !important;
      padding: 20px;
      box-sizing: border-box;
      background-color: #fff;
      border-radius: 12px !important;

      // --- 根據父層類別控制顯示 ---
      &--left {

        // 當書本被翻轉（處於註冊狀態）時，隱藏左側登入頁
        .book--flipped & {
          display: none !important;
        }
      }

      &--right {
        // 預設隱藏右側註冊頁
        display: none !important;

        // 當書本被翻轉時，顯示右側註冊頁
        .book--flipped & {
          display: flex !important;
        }
      }
    }

    // 隱藏桌機版 3D 組件
    &__cover,
    &__spine,
    &__face {
      display: none !important;
    }
  }

  .mobile-switch-text {
    display: block !important;
  }

  .social-login img {
    width: 30px;
    margin: 20px 20px 0 20px;
  }

  .login-btn {
    margin: 10px 0;
  }

  .btn.h-50 {
    height: 40px;
    width: 100%;
  }

  .book__cover {
    display: none !important;
    pointer-events: none; // 徹底防禦
  }
}

/* 確保彈窗在燈箱之上 */
:deep(.modal-overlay) {
  z-index: 1100;
  /* 比 auth-modal 的 1000 更高 */
}

.password-requirements {
  width: 100%;
  margin-top: -10px; // 稍微往上靠攏 input
  margin-bottom: 5px;
  padding-left: 5px;

  .requirements-title {
    color: $neutral-color-700;
  }

  li {
    display: flex;
    align-items: center;
    color: #ff5252; // 預設紅色（未通過）
    transition: color 0.3s ease;

    i {
      font-size: 12px;
    }

    &.met {
      color: #4caf50; // 通過後變綠色
    }
  }
}
</style>