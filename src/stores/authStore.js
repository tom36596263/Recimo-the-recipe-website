import { ref, computed } from 'vue';
import { defineStore } from 'pinia';

export const useAuthStore = defineStore('auth', () => {
    // --- 登入狀態 ---
    // 初始化時檢查 localStorage
    const user = ref(JSON.parse(localStorage.getItem('user')) || null);
    const isLoggedIn = computed(() => !!user.value);

    // --- 彈窗控制狀態 ---
    const isLoginAlertOpen = ref(false);     // 「請先登入」的小彈窗
    const isLoginLightboxOpen = ref(false);  // 真正的登入註冊燈箱

    // --- 攔截動作紀錄 ---
    const pendingAction = ref(null);

    // --- Actions ---
    const login = (foundUser) => {
        user.value = foundUser;
        localStorage.setItem('user', JSON.stringify(foundUser));

        // 登入後如果有被擋下的動作，就執行它
        if (pendingAction.value) {
            pendingAction.value();
            pendingAction.value = null;
        }
    };

    const logout = () => {
        user.value = null;
        localStorage.removeItem('user');
    };

    const openLoginAlert = () => {
        isLoginAlertOpen.value = true;
    };

    const openLoginLightbox = () => {
        isLoginAlertOpen.value = false;
        isLoginLightboxOpen.value = true;
    };

    const closeAll = () => {
        isLoginAlertOpen.value = false;
        isLoginLightboxOpen.value = false;
    };

    return {
        user,
        isLoggedIn,
        isLoginAlertOpen,
        isLoginLightboxOpen,
        pendingAction,
        login,
        logout,
        openLoginAlert,
        openLoginLightbox,
        closeAll
    };
});

// export const useAuthStore = defineStore('auth', () => {
//     const isLoggedIn = ref(false);
//     const isLoginAlertOpen = ref(false);
//     const isLoginLightboxOpen = ref(false);

//     // --- 新增：存放被攔截的動作 ---
//     const pendingAction = ref(null);

//     const login = () => {
//         isLoggedIn.value = true; // 真正標記為已登入
//         if (pendingAction.value) {
//             console.log("執行續傳動作...");
//             pendingAction.value(); // 執行之前被擋下的 buyNow
//             pendingAction.value = null; // 執行完清空
//         }
//     };

//     const openLoginLightbox = () => {
//         isLoginAlertOpen.value = false;
//         isLoginLightboxOpen.value = true;
//     };

//     return {
//         isLoggedIn,
//         isLoginAlertOpen,
//         isLoginLightboxOpen,
//         pendingAction, // 暴露給 guard 使用
//         login,         // 暴露給 AuthModal 使用
//         openLoginLightbox,
//         openLoginAlert: () => isLoginAlertOpen.value = true,
//         closeAll: () => {
//             isLoginAlertOpen.value = false;
//             isLoginLightboxOpen.value = false;
//         }
//     };
// });
