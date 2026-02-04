import { ref, computed } from 'vue';
import { defineStore } from 'pinia';

export const useAuthStore = defineStore('auth', () => {
    // 將原本要去的地方存入 localStorage，避免重整後消失
    const pendingPath = ref(localStorage.getItem('pendingPath') || null);

    // 存入目標路徑的方法
    const setPendingPath = (path) => {
        pendingPath.value = path;
        localStorage.setItem('pendingPath', path);
    };
    // ==========================================
    // 登入狀態
    // ==========================================
    // 初始化時檢查 localStorage
    const user = ref(JSON.parse(localStorage.getItem('user')) || null);
    // 統一的 userId 計算屬性
    const userId = computed(() => {
        if (!user.value) return null;
        // 同時相容兩種命名方式
        return user.value.id || user.value.user_id;
    });
    const isLoggedIn = computed(() => !!user.value);

    // 彈窗控制狀態
    const isLoginAlertOpen = ref(false);     // 「請先登入」的小彈窗
    const isLoginLightboxOpen = ref(false);  // 真正的登入註冊燈箱

    // 攔截動作紀錄
    const pendingAction = ref(null);

    // 專門給 LINE 登入跳轉後的成功訊號
    const isLineLoginSuccess = ref(false);
    // ==========================================
    // 登入
    // ==========================================
    const login = (foundUser) => {
        // 在這裡把後端各式各樣的欄位名，統一轉成前端要用的 key
        const normalizedUser = {
            ...foundUser,
            // 姓名對接：優先用 name，再來是 user_name，都沒就空字串
            name: foundUser.name || foundUser.user_name || '新朋友',

            // 圖片對接：相容 image, avatar, 還有你 PHP 寫的 user_url
            image: foundUser.image || foundUser.user_url || foundUser.avatar || null
        };

        console.log('正規化後的完整資料:', normalizedUser);

        user.value = normalizedUser;
        localStorage.setItem('user', JSON.stringify(normalizedUser));

        if (pendingAction.value) {
            pendingAction.value();
            pendingAction.value = null;
        }
    };

    // 觸發訊號的方法
    const triggerLineSuccess = () => {
        isLineLoginSuccess.value = true;
    };

    // 門禁守衛彈窗
    const openLoginAlert = () => {
        isLoginAlertOpen.value = true;
    };

    // 開啟登入燈箱
    const openLoginLightbox = () => {
        isLoginAlertOpen.value = false;
        isLoginLightboxOpen.value = true;
    };

    // 關閉
    const closeAll = () => {
        isLoginAlertOpen.value = false;
        isLoginLightboxOpen.value = false;
    };

    // ==========================================
    // 登出
    // ==========================================
    const logout = () => {
        user.value = null;
        localStorage.removeItem('user');
    };

    return {
        user,
        userId,
        isLoggedIn,
        isLoginAlertOpen,
        isLoginLightboxOpen,
        pendingAction,
        isLineLoginSuccess,
        pendingPath,
        triggerLineSuccess,
        login,
        logout,
        openLoginAlert,
        openLoginLightbox,
        closeAll
    };
});