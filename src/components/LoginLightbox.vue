<script setup>
import { ref, computed, nextTick, watch, onUnmounted, onMounted } from 'vue';
// 引用 Pinia Store (權限狀態管理)
import { useAuthStore } from '@/stores/authStore';
const authStore = useAuthStore();
import { useCartStore } from '@/stores/cartStore';
const cartStore = useCartStore();
import LogoBlack from '@/assets/images/site/Recimo-logo-black.svg'
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
import { phpApi, base } from '@/utils/publicApi.js';
// 用來執行動作
import { useRouter } from 'vue-router';
const router = useRouter();
// 第三方登入(GOOGLE)
import { useTokenClient } from "vue3-google-signin";

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
// 登入：前端驗證訊息內容
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

// ==========================================
// 註冊：前端驗證訊息內容
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
// 登入：送出邏輯
// ==========================================
// 忘記密碼
const handleForgotPassword = async () => {
  forgotTouched.value = true;
  if (forgotEmailMessage.value) return;

  try {
    const response = await phpApi.post('auth/forgot-password.php', {
      email: forgotEmail.value
    });

    if (response.data.status === 'success') {
      alert('重設密碼信件已發送至您的信箱');
      resetForgotForm();
    } else {
      alert(response.data.message || '發送失敗');
    }
  } catch (error) {
    alert('伺服器連線異常，請稍後再試');
  }
};
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

      // 立刻去後端抓該使用者的購物車
      // 用 await，確保購物車資料抓完後再進行後續動作
      await cartStore.fetchCart();

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
    alert('伺服器連線異常，請稍後再試');
  }
};

// 重置登入表單
const captchaKey = ref(0);
const resetLoginForm = () => {
  forgotStep.value = 0;
  // 1. 清空輸入資料
  loginData.value = {
    email: '',
    password: ''
  };

  // 2. 清空驗證碼輸入
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
// 註冊：送出邏輯
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
    alert('伺服器連線異常，請稍後再試');
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

// 只要頁面一切換，就清空「對方」的資料
watch(isRegister, (newVal) => {
  // 無論切到哪，都先把忘記密碼的進度歸零並清空資料
  forgotStep.value = 0;
  forgotData.value = { email: '', code: '', password: '', confirmPassword: '' };
  forgotTouched.value = false;
  if (interval) clearInterval(interval); // 停止倒數計時器
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

// ==========================================
// Google 登入成功後的處理函式
// ==========================================
// 初始化 Google 登入觸發器
const { login } = useTokenClient({
  onSuccess: (response) => {
    handleGoogleSuccess(response);
  },
  onError: (error) => {
    // console.error("Google Login Failed", error);
  },
  // 明確宣告 scope
  scope: 'openid email profile',
});

// 接收 token
const handleGoogleSuccess = async (response) => {
  console.log('Google Response:', response); // 檢查有沒有 response.access_token
  try {
    // 發送 access_token 到後端
    const res = await phpApi.post('auth/google-login.php', {
      access_token: response.access_token
    });

    const result = res.data;

    if (result.status === 'success') {
      // 登入成功：更新 Pinia 狀態
      authStore.login(result.user);

      // 處理購物車同步
      await cartStore.fetchCart();

      // UI 反饋
      showLoginSuccess.value = true;
      isVisible.value = false;

      setTimeout(() => {
        showLoginSuccess.value = false;
        emit('close');
        handleClose();
        if (authStore.pendingAction) {
          router.push('/');
        }
      }, 1500);
    } else {
      // 登入失敗處理
      loginErrorMessage.value = result.message || 'Google 登入失敗';
      showLoginFail.value = true;
    }
  } catch (error) {
    // console.error('Google API Error:', error);
    alert('伺服器連線異常，請稍後再試');
  }
};

// ==========================================
// LINE 登入跳轉函式
// ==========================================
const handleLineLogin = () => {
  // 不管目前在哪，登入成功後一律指定去 workspace
  // 存入的路徑，App.vue 會拿去判斷
  localStorage.setItem('pendingPath', '/workspace');

  const clientID = '2009040716';

  // 判斷當前是否在正式環境
  const isProd = window.location.hostname === 'tibamef2e.com';

  // 正式環境的 Redirect URI (LINE 授權後會跳回首頁)
  const redirectUri = isProd
    ? encodeURIComponent('https://tibamef2e.com/cjd102/g2/recimo/')
    : encodeURIComponent(window.location.origin + '/');

  const state = Math.random().toString(36).substring(7);
  window.location.href = `https://access.line.me/oauth2/v2.1/authorize?response_type=code&client_id=${clientID}&redirect_uri=${redirectUri}&state=${state}&scope=profile%20openid%20email`;
};
// ==========================================
// Facebook 登入處理
// ==========================================
const handleFBLogin = () => {
  window.FB.login(function (response) {
    if (response.authResponse) {
      const accessToken = response.authResponse.accessToken;
      // console.log('FB 登入成功，拿到 Token:', accessToken);

      // 直接呼叫你下面寫好的那個 async 函式
      sendFBTokenToBackend(accessToken);
    }
  }, { scope: 'email,public_profile' });
};

const sendFBTokenToBackend = async (accessToken) => {
  try {
    // phpApi 會自動補上 http://localhost/你的專案路徑/api/
    const res = await phpApi.post('auth/facebook-login.php', {
      access_token: accessToken
    });

    const result = res.data;

    if (result.status === 'success') {
      const formattedUser = {
        ...result.user,
        name: result.user.user_name,  // 將 user_name 對應到 name
        image: result.user.user_url   // 將 user_url 對應到 image
      };

      // console.log('格式化後的用戶資料：', formattedUser);
      authStore.login(result.user);
      await cartStore.fetchCart();

      showLoginSuccess.value = true;
      isVisible.value = false;

      setTimeout(() => {
        showLoginSuccess.value = false;
        emit('close');
        handleClose();
      }, 1500);
    } else {
      loginErrorMessage.value = result.message || 'Facebook 登入失敗';
      showLoginFail.value = true;
    }
  } catch (error) {
    // console.error('FB API Error:', error);
    alert('FB 伺服器連線異常，請稍後再試');
  }
};

// ==========================================
// 忘記密碼
// ==========================================
// 宣告所有彈窗相關的狀態 (ref)
const isModalOpen = ref(false);
const modalConfig = ref({
  type: 'info',
  iconClass: 'fa-solid fa-exclamation',
  title: '',
  description: ''
});

// 定義彈窗工具函式
// 確保它在所有 API 函式之前被定義
const showAlert = (title, description = '', type = 'info', icon = 'fa-solid fa-exclamation') => {
  modalConfig.value = {
    title,
    description,
    type,
    iconClass: icon,
  };
  isModalOpen.value = true;
};

// 定義其他資料狀態
const forgotData = ref({
  email: '',
  code: '',
  password: '',
  confirmPassword: ''
});
// 控制是否顯示忘記密碼介面
const isForgotPassword = ref(false);
const forgotEmail = ref('');
const forgotTouched = ref(false);

// 重設密碼的眼睛切換邏輯
const showForgotPwd = ref(false);

// 驗證 Email 格式
const forgotEmailMessage = computed(() => {
  if (!forgotTouched.value) return '';
  if (!forgotEmail.value) return '* 此欄為必填';
  if (!/^\S+@\S+\.\S+$/.test(forgotEmail.value)) return '* email 格式錯誤';
  return '';
});

const forgotEmailStatus = computed(() =>
  forgotTouched.value ? (forgotEmailMessage.value ? 'error' : 'success') : ''
);

// 重置忘記密碼表單
const resetForgotForm = () => {
  isForgotPassword.value = false;
  forgotEmail.value = '';
  forgotTouched.value = false;
};

// 密碼重設
// 忘記密碼流程控制：0 (登入), 1 (填 Email), 2 (填驗證碼), 3 (設新密碼)
const forgotStep = ref(0);

// 驗證碼倒數計時
const timer = ref(0); // 剩餘秒數
let endTime = null;   // 預計結束的時間戳記
let interval = null;

const startTimer = () => {
  // 1. 強制清除舊的計時器，避免兩個 setInterval 同時執行
  if (interval) {
    clearInterval(interval);
    interval = null;
  }

  // 2. 設定新的結束時間 (150秒後)
  const duration = 150;
  endTime = Date.now() + duration * 1000;

  // 3. 立即存入 localStorage 覆蓋舊資料
  localStorage.setItem('reset_password_expiry', endTime);

  // 4. 先手動更新一次畫面，避免「跳秒」感
  timer.value = duration;

  // 5. 啟動計時
  interval = setInterval(() => {
    const now = Date.now();
    const remaining = Math.round((endTime - now) / 1000);

    if (remaining <= 0) {
      timer.value = 0;
      clearInterval(interval);
      interval = null;
      localStorage.removeItem('reset_password_expiry');
    } else {
      timer.value = remaining;
    }
  }, 1000);
};

// 在 onMounted 時檢查是否還有沒跑完的計時
onMounted(() => {
  const savedEndTime = localStorage.getItem('reset_password_expiry');
  if (savedEndTime) {
    const now = Date.now();
    const remaining = Math.round((savedEndTime - now) / 1000);
    if (remaining > 0) {
      endTime = parseInt(savedEndTime);
      startTimer(); // 自動重新啟動
    } else {
      localStorage.removeItem('reset_password_expiry');
    }
  }
});

onUnmounted(() => {
  if (interval) clearInterval(interval);
});

// 彈窗控制
const showForgotFail = ref(false);
const showResetSuccess = ref(false);

// 密碼規則 (複用註冊的規則邏輯)
const forgotPwdRules = computed(() => {
  const pwd = forgotData.value.password;
  return {
    length: pwd.length >= 8,
    hasUpper: /[A-Z]/.test(pwd),
    hasLower: /[a-z]/.test(pwd),
  };
});

const resetForgotEmailOnly = () => {
  forgotData.value.email = '';
  forgotTouched.value = false;
  loginErrorMessage.value = '';
};

// 步驟跳轉
// 步驟 1: 送出 Email
const sendForgotEmail = async () => {
  try {
    const res = await phpApi.post('auth/send-reset-code.php', {
      email: forgotData.value.email
    });

    if (res.data.status === 'success') {
      // 這裡加上自動填入，開發時方便
      if (res.data.debug_code) {
        forgotData.value.code = res.data.debug_code;
        console.log('【測試模式】自動填入驗證碼：', res.data.debug_code);
      }

      showAlert('驗證碼已寄出', '請至您的電子信箱收信', 'success', 'fa-solid fa-check');

      setTimeout(() => {
        isModalOpen.value = false;
        forgotStep.value = 2; // 跳轉到輸入驗證碼畫面
        startTimer();        // 開始倒數
      }, 2000);

    } else {
      showAlert('發送失敗', res.data.message, 'danger');
    }
  } catch (error) {
    // console.error('發送失敗：', error);
  }
};

// 返回上一步清空計時器
const handleBackToStep1 = () => {
  // 1. 回到填寫 Email 的步驟
  forgotStep.value = 1;

  // 2. 徹底停止並清除計時器
  if (interval) {
    clearInterval(interval);
    interval = null;
  }

  // 3. 重置相關狀態與暫存
  timer.value = 0;
  localStorage.removeItem('reset_password_expiry');
};

// 步驟 2: 驗證驗證碼
const verifyCode = async () => {
  if (!forgotData.value.code) {
    // alert('請輸入驗證碼');
    showAlert('請輸入驗證碼', '驗證碼欄位不能為空', 'danger', 'fa-solid fa-exclamation');
    return;
  }

  try {
    const res = await phpApi.post('auth/verify-reset-code.php', {
      email: forgotData.value.email,
      code: forgotData.value.code
    });

    if (res.data.status === 'success') {
      showAlert('驗證成功', '請設定您的新密碼', 'success', 'fa-solid fa-check');
      setTimeout(() => {
        isModalOpen.value = false;
        forgotStep.value = 3; // 2秒後關閉並跳轉到設定新密碼
      }, 2000);
    } else {
      // alert(res.data.message || '驗證碼錯誤或已失效');
      showAlert('驗證失敗', res.data.message || '驗證碼錯誤或已失效', 'danger', 'fa-solid fa-exclamation');
    }
  } catch (error) {
    alert('伺服器連線異常，請稍後再試');
  }
};

// 步驟 3: 更新密碼
const handleResetPassword = async () => {
  // 前端檢查
  if (!forgotPwdRules.value.length || !forgotPwdRules.value.hasUpper || !forgotPwdRules.value.hasLower) {
    // alert('新密碼格式不符規定');
    showAlert('格式不符', '新密碼格式不符規定，請檢查大小寫與長度', 'danger', 'fa-solid fa-exclamation');
    return;
  }
  if (forgotData.value.password !== forgotData.value.confirmPassword) {
    // alert('兩次密碼輸入不一致');
    showAlert('輸入不一致', '兩次密碼輸入不一致', 'danger', 'fa-solid fa-exclamation');
    return;
  }

  try {
    const res = await phpApi.post('auth/reset-password.php', {
      email: forgotData.value.email,
      new_password: forgotData.value.password
    });

    if (res.data.status === 'success') {
      // 顯示成功的彈窗 (或 Toast 提示)
      showResetSuccess.value = true;

      setTimeout(() => {
        closeResetSuccess();
      }, 2000);

    } else {
      // 這裡處理後端傳回的具體錯誤 (例如新舊密碼相同)
      // alert(res.data.message || '重設失敗，請重新嘗試');
      showAlert('重設失敗', res.data.message || '請重新嘗試', 'danger', 'fa-solid fa-exclamation');
    }
  } catch (error) {
    // 這裡處理網路錯誤或 PHP 崩潰導致的非法請求
    // alert('系統錯誤，請確認驗證狀態是否過期');
    showAlert('系統錯誤', '請確認驗證狀態是否過期', 'danger', 'fa-solid fa-exclamation');
    // console.error('Reset Error:', error);
  }
};

// ==========================================
// 重新發送驗證碼邏輯
// ==========================================
const isResending = ref(false); // 防止重複點擊

const resendCode = async () => {
  if (timer.value > 0 || isResending.value) return;

  isResending.value = true;
  try {
    const res = await phpApi.post('auth/send-reset-code.php', {
      email: forgotData.value.email
    });

    if (res.data.status === 'success') {
      // 更新驗證碼資料
      if (res.data.debug_code) {
        forgotData.value.code = res.data.debug_code; // 這裡一定要更新！
        console.log('【測試模式】新驗證碼：', res.data.debug_code);
      }

      showAlert('發送成功', '新驗證碼已寄出', 'success', 'fa-solid fa-check');
      startTimer();
    } else {
      showAlert('發送失敗', res.data.message, 'danger');
    }
  } catch (error) {
    showAlert('錯誤', '網路連線異常', 'danger');
  } finally {
    isResending.value = false;
  }
};

// 重設成功
const closeResetSuccess = () => {
  showResetSuccess.value = false;
  forgotStep.value = 0; // 回到登入頁
  isRegister.value = false; // 確保在登入頁面

  // 自動填好剛剛重設的 Email
  loginData.value.email = forgotData.value.email;

  // 清空忘記密碼的暫存資料
  forgotData.value = { email: '', code: '', password: '', confirmPassword: '' };
};
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
              <!-- 忘記密碼 -->
              <button class="close-btn" @click="handleClose">
                <i class="fa-solid fa-xmark"></i>
              </button>

              <div v-if="forgotStep > 0">
                <div v-if="forgotStep === 1">
                  <h1 class="zh-h3 auth-form__title" @click="forgotEmailStatus">忘記密碼</h1>
                  <div class="auth-form">
                    <BaseInput v-model="forgotData.email" label="電子信箱" placeholder="請輸入您的電子信箱" class="tight-gap"
                      :status="forgotEmailStatus" :message="forgotEmailMessage" />
                    <BaseBtn title="傳送驗證碼" variant="solid" @click="sendForgotEmail" :width="244" :height="50"
                      class="m-auto" />
                    <p class="mobile-switch-text" @click="forgotStep = 0">返回登入</p>
                  </div>
                </div>

                <div v-else-if="forgotStep === 2">
                  <h1 class="zh-h3 auth-form__title">忘記密碼</h1>
                  <div class="auth-form">
                    <p class="p-p3 text-center" style="margin-bottom: 15px;">
                      已發送驗證碼至<br>
                      <strong>{{ forgotData.email }}</strong>
                    </p>

                    <BaseInput v-model="forgotData.code" label="驗證碼" placeholder="請輸入驗證碼" class="tight-gap" />

                    <div class="resend-wrapper" style="align-self: flex-end; margin-top: 5px;">
                      <p v-if="timer > 0" class="p-p3" style="color: #e74c3c;">
                        驗證碼將於 {{ timer }} 秒後失效
                      </p>
                      <a v-else href="#" class="p-p3 resend-link" @click.prevent="resendCode">
                        {{ isResending ? '發送中...' : '重新發送驗證碼' }}
                      </a>
                    </div>

                    <div class="row w-100" style="gap: 10px; justify-content: center; margin-top: 20px;">
                      <BaseBtn title="返回上一步" variant="outline" @click="handleBackToStep1" :width="120" />
                      <BaseBtn title="下一步" variant="solid" @click="verifyCode" :width="120" />
                    </div>

                    <router-link to="/benefits" @click="handleClose" class="p-p3 m-auto"
                      style="margin-top: 20px; text-decoration: underline; color: #666;">
                      嘗試多次仍無法收到驗證碼？可聯繫客服
                    </router-link>
                  </div>
                </div>

                <div v-else-if="forgotStep === 3">
                  <h1 class="zh-h3 auth-form__title">重設密碼</h1>
                  <div class="auth-form">
                    <BaseInput v-model="forgotData.password" :type="showForgotPwd ? 'text' : 'password'" label="新密碼"
                      class="tight-gap">
                      <template #suffix>
                        <button type="button" @click="showForgotPwd = !showForgotPwd" class="icon-btn">
                          <IconEyeClose v-if="showForgotPwd" />
                          <IconEyeOpen v-else />
                        </button>
                      </template>
                    </BaseInput>

                    <div class="password-requirements" style="width: 100%; margin-bottom: 10px;">
                      <ul>
                        <li class="p-p3" :class="{ 'met': forgotPwdRules.length }">
                          <i
                            :class="forgotPwdRules.length ? 'fa-solid fa-circle-check' : 'fa-solid fa-circle-exclamation'"></i>
                          至少含八個字元
                        </li>
                        <li class="p-p3" :class="{ 'met': forgotPwdRules.hasUpper }">
                          <i
                            :class="forgotPwdRules.hasUpper ? 'fa-solid fa-circle-check' : 'fa-solid fa-circle-exclamation'"></i>
                          含一大寫英文字母
                        </li>
                        <li class="p-p3" :class="{ 'met': forgotPwdRules.hasLower }">
                          <i
                            :class="forgotPwdRules.hasLower ? 'fa-solid fa-circle-check' : 'fa-solid fa-circle-exclamation'"></i>
                          含一小寫英文字母
                        </li>
                      </ul>
                    </div>

                    <BaseInput v-model="forgotData.confirmPassword" :type="showForgotPwd ? 'text' : 'password'"
                      label="確認密碼" class="tight-gap">
                      <template #suffix>
                        <button type="button" @click="showForgotPwd = !showForgotPwd" class="icon-btn">
                        </button>
                      </template>
                    </BaseInput>

                    <BaseBtn title="完成重設" variant="solid" @click="handleResetPassword" :width="244" :height="50"
                      class="m-auto" />
                  </div>
                </div>
              </div>

              <div v-else>
                <!-- 會員登入 -->
                <h1 class="zh-h3 auth-form__title">會員登入</h1>
                <form @submit.prevent="handleLogin">
                  <div class="auth-form">
                    <BaseInput ref="loginEmailRef" v-model="loginData.email" label="電子信箱" placeholder="請輸入電子信箱"
                      autocomplete="email" :status="loginStatus.email" :message="loginMessage.email"
                      @blur="touched.login.email = true" @enter-press="focusInput(loginPasswordRef)"
                      class="tight-gap" />
                    <BaseInput ref="loginPasswordRef" v-model="loginData.password" label="密碼" placeholder="請輸入密碼"
                      autocomplete="current-password" :type="showLoginPassword ? 'text' : 'password'"
                      :status="loginStatus.password" :message="loginMessage.password"
                      @blur="touched.login.password = true" @enter-press="focusInput(captchaRef)" class="tight-gap">
                      <template #label-right>
                        <a href="#" class="forgot-password-link" @click.prevent="forgotStep = 1">忘記密碼</a>
                      </template>
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
                        <img src="@/assets/images/login/google.svg" @click="login" alt="Google Login" />
                        <!-- <GoogleLogin :callback="handleGoogleSuccess" popup-type="CODE">
                      </GoogleLogin> -->
                        <img src="@/assets/images/login/fb.svg" @click="handleFBLogin" alt="FB Login" />
                        <img src="@/assets/images/login/line.svg" alt="Line Login" @click="handleLineLogin"
                          class="line-btn" />
                      </div>
                      <p class="mobile-switch-text" @click="isRegister = true">還不是會員嗎？快前往註冊吧~</p>
                    </div>
                  </div>
                </form>
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
              <form @submit.prevent="handleRegister">
                <div class="auth-form">
                  <BaseInput ref="regNameRef" v-model="registerData.name" label="姓名" placeholder="請輸入姓名"
                    autocomplete="username" :status="registerStatus.name" :message="registerMessage.name"
                    @blur="touched.register.name = true" @enter-press="focusInput(regEmailRef)" class="tight-gap" />
                  <BaseInput ref="regEmailRef" v-model="registerData.email" label="電子信箱" placeholder="請輸入電子信箱"
                    autocomplete="email" :status="registerStatus.email" :message="registerMessage.email"
                    @blur="touched.register.email = true" @enter-press="focusInput(regPasswordRef)" class="tight-gap" />
                  <BaseInput ref="regPasswordRef" v-model="registerData.password" label="密碼" placeholder="請輸入密碼"
                    autocomplete="new-password" :type="showRegisterPassword ? 'text' : 'password'"
                    :status="registerStatus.password" :message="registerMessage.password"
                    @blur="touched.register.password = true" @enter-press="focusInput(regConfirmPasswordRef)"
                    class="tight-gap">
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
                    placeholder="請再輸入一次密碼" autocomplete="new-password"
                    :type="showRegisterPassword ? 'text' : 'password'" :status="registerStatus.confirmPassword"
                    :message="registerMessage.confirmPassword" @blur="touched.register.confirmPassword = true"
                    @enter-press="handleRegister" class="tight-gap" />
                  <BaseBtn title="註冊" variant="solid" @click="handleRegister" :width="244" :height="50"
                    class="m-auto" />
                  <p class="mobile-switch-text" @click="isRegister = false">已有帳號嗎？前往登入吧~</p>
                </div>
              </form>
            </div>
          </div>


          <!-- 活動翻頁層 (.book__cover)：這是關鍵！它寬度只有書本的一半（50%），初始位置在右邊。 -->
          <div class="book__cover">
            <div class="book__face book__face--front">
              <!-- ==========================================
                        前往會員註冊
                    ========================================== -->
              <div class="registration-invite">
                <img :src="LogoBlack" alt="Recimo Logo">
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
                <img :src="LogoBlack" alt="Recimo Logo">
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
      <button class="btn-outline" @click="showLoginFail = false; forgotStep = 1">忘記密碼</button>
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

  <BaseModal :isOpen="showForgotFail" type="danger" title="失敗" description="此信箱尚未註冊" iconClass="fa-solid fa-exclamation"
    @close="showForgotFail = false">
    <template #actions>
      <button class="btn-solid" @click="showForgotFail = false; isRegister = true">前往註冊</button>
      <button class="btn-outline" @click="showForgotFail = false; resetForgotEmailOnly()">重新填寫信箱</button>
    </template>
  </BaseModal>

  <BaseModal :isOpen="showResetSuccess" type="success" iconClass="fa-solid fa-check" title="密碼重設成功"
    description="將為您跳轉至登入畫面" @close="showResetSuccess = false">
  </BaseModal>

  <BaseModal :isOpen="isModalOpen" :type="modalConfig.type" :title="modalConfig.title"
    :iconClass="modalConfig.iconClass" :description="modalConfig.description" @close="isModalOpen = false" />
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
}

:deep(.tight-gap) {
  margin-bottom: 10px !important;
  margin-top: 4px;

  /* 強制覆蓋組件內部的預設間距 */
  input {
    margin-top: 4px;
  }
}

//標題
.auth-form__title {
  text-align: center;
  margin: 20px 0;
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
  cursor: pointer;

  // 針對 Google 登入元件的包裝層
  // :deep(div[id^="google-login-button"]) {
  //   margin-right: 10px; // 讓它跟後面的 FB 按鈕保持距離
  // }

  img {
    width: 45px;
    height: 45px;
    margin: 15px 20px 0 20px;
    display: inline-block; // 確保 transform 在連結上生效
    transition: transform 0.3s ease; // 設定動畫時間與曲線

    &:hover {
      transform: scale(1.2);

      // 增加一點陰影，讓它看起來像浮起來
      filter: drop-shadow(0 4px 6px rgba(0, 0, 0, 0.1));
    }

    &:active {
      // 點擊瞬間縮小回 0.8 倍，增加點擊回饋感
      transform: scale(0.8);
    }
  }
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
  // 告訴瀏覽器此處滾動不需等待 JS
  touch-action: pan-y;
  // 當螢幕高度太小時，允許內部滾動
  overflow-y: auto;
  // 增加上下邊距，避免書本貼死螢幕邊緣
  padding: 20px 0;

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
      padding: 20px 30px;
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

    // 設定旋轉軸心在左側（書脊位置）
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
  text-align: center;
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
  margin-bottom: 10px;

  ul {
    list-style: none;
    padding: 0;

    li {
      color: $secondary-color-danger-700; // 預設灰色
      display: flex;
      align-items: center;
      gap: 5px;
      transition: color 0.3s ease;

      i {
        font-size: 12px;
      }

      &.met {
        color: $secondary-color-success-700; // 達成條件變綠色
      }
    }
  }
}

// 重新發送驗證碼
.resend-link {
  color: #3498db; // 使用品牌藍色
  text-decoration: underline;
  cursor: pointer;
  transition: color 0.2s ease;

  &:hover {
    color: #2980b9;
  }
}

// 如果正在發送中，讓它看起來不能點
.resend-link.loading {
  color: #999;
  pointer-events: none;
  text-decoration: none;
}

.text-center {
  text-align: center;
}

.m-auto {
  display: block; // 必須是 block 元素 margin auto 才會生效
  margin-left: auto;
  margin-right: auto;
  margin-top: 10px;
}
</style>