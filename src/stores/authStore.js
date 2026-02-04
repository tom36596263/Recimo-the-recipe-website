import { ref, computed } from 'vue';
import { defineStore } from 'pinia';

export const useAuthStore = defineStore('auth', () => {
    // ✅ 修改：將原本要去的地方存入 localStorage，避免重整後消失
    const pendingPath = ref(localStorage.getItem('pendingPath') || null);

    // ✅ 修改：存入目標路徑的方法
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

    // ✅ 新增：專門給 LINE 登入跳轉後的成功訊號
    const isLineLoginSuccess = ref(false);
    // ==========================================
    // 登入
    // ==========================================
    const login = (foundUser) => {
        // 這裡做一個簡單的轉換：如果後端給的是 avatar，我們就把它複製一份給 image
        const normalizedUser = {
            ...foundUser,
            image: foundUser.image || foundUser.avatar // 誰有值就用誰
        };

        // console.log('正規化後的資料:', normalizedUser);

        user.value = normalizedUser;
        localStorage.setItem('user', JSON.stringify(normalizedUser));

        if (pendingAction.value) {
            pendingAction.value();
            pendingAction.value = null;
        }
    };

    // ✅ 新增：觸發訊號的方法
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