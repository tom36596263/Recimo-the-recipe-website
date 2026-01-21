// stores/authStore.js
import { defineStore } from 'pinia';
import { ref } from 'vue';

export const useAuthStore = defineStore('auth', () => {
    const isLoggedIn = ref(false);
    const isLoginAlertOpen = ref(false);
    const isLoginLightboxOpen = ref(false);

    // --- 新增：存放被攔截的動作 ---
    const pendingAction = ref(null);

    const login = () => {
        isLoggedIn.value = true; // 真正標記為已登入
        if (pendingAction.value) {
            console.log("執行續傳動作...");
            pendingAction.value(); // 執行之前被擋下的 buyNow
            pendingAction.value = null; // 執行完清空
        }
    };

    const openLoginLightbox = () => {
        isLoginAlertOpen.value = false;
        isLoginLightboxOpen.value = true;
    };

    return {
        isLoggedIn,
        isLoginAlertOpen,
        isLoginLightboxOpen,
        pendingAction, // 暴露給 guard 使用
        login,         // 暴露給 AuthModal 使用
        openLoginLightbox,
        openLoginAlert: () => isLoginAlertOpen.value = true,
        closeAll: () => {
            isLoginAlertOpen.value = false;
            isLoginLightboxOpen.value = false;
        }
    };
});



// // 這個 Store 負責管理登入狀態與控制「登入提醒燈箱」的開關。
// import { ref, computed } from 'vue'
// import { defineStore } from 'pinia'

// const USERS = [
//     { account: 'demo', password: '1234', token: 'fake_token_demo' },
//     { account: 'ingrid', password: '5678', token: 'fake_token_ingrid' },
// ]

// const localStorageKey = 'USER'
// export const useUserStore = defineStore('user', () => {
//     const errorMsg = ref('')
//     const token = ref('')
//     const isLogin = computed(() => token.value !== '')

//     const loadStorage = () => {
//         // 讀取localStorage
//         const cache = localStorage.getItem(localStorageKey)
//         if (cache) {
//             token.value = cache
//         }
//     }

//     const login = (accountValue, passwordValue) => {
//         // 先判斷
//         if (!accountValue || !passwordValue) {
//             errorMsg.value = '請輸入帳號或密碼'
//             return false
//         }
//         const result = USERS.find((user) => {
//             return user.account === accountValue && user.password === passwordValue
//         })
//         if (!result) {
//             errorMsg.value = '登入失敗'
//             return false
//         }
//         // 成功登入
//         token.value = result.token
//         localStorage.setItem(localStorageKey, result.token) // 再寫入localStorage

//         // 確保成功時 errorMsg 是空的（前面已經清過，這裡寫不寫都可以，但寫了更保險）
//         errorMsg.value = ''
//         return true // 回傳 true 代表登入順利
//     }
//     const logout = () => {
//         token.value = ''
//         localStorage.removeItem(localStorageKey)
//     }

//     loadStorage()
//     return { errorMsg, token, isLogin, login, logout }
// })

// import { defineStore } from 'pinia';
// import { ref } from 'vue';

// export const useAuthStore = defineStore('auth', () => {
//     // 登入狀態 (實際開發中建議從 Token 或 API 取得)
//     const isLoggedIn = ref(false);

//     // 控制「登入提示燈箱」的顯示
//     const isLoginAlertOpen = ref(false);

//     const openLoginAlert = () => {
//         isLoginAlertOpen.value = true;
//     };

//     const closeLoginAlert = () => {
//         isLoginAlertOpen.value = false;
//     };

//     return {
//         isLoggedIn,
//         isLoginAlertOpen,
//         openLoginAlert,
//         closeLoginAlert
//     };
// });
