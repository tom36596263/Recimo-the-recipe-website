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
            // 姓名對接
            name: foundUser.name || foundUser.user_name || '新朋友',
            user_name: foundUser.user_name || foundUser.name || '新朋友', // 確保兩個 key 都有值

            // 圖片對接
            image: foundUser.image || foundUser.user_url || foundUser.avatar || null,

            // ★ 新增：電話與地址的正規化 (防止 undefined)
            user_phone: foundUser.user_phone || foundUser.phone || '',
            user_address: foundUser.user_address || foundUser.address || ''
        };

        // console.log('正規化後的完整資料:', normalizedUser);

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
    // 更新使用者資訊
    // ==========================================
    const updateUserInfo = (newData) => {
        if (!user.value) {
            // console.warn('❌ user.value 不存在，無法更新');
            return;
        }

        // 建立新物件
        const updatedUser = {
            ...user.value,
            ...newData
        };

        // 特別處理 name 欄位
        if (newData.user_name || newData.name) {
            updatedUser.name = newData.user_name || newData.name || user.value.name;
            updatedUser.user_name = newData.user_name || newData.name || user.value.user_name;
        }

        // 特別處理 image/avatar 欄位
        if (newData.user_url || newData.image || newData.avatar) {
            const newImage = newData.user_url || newData.image || newData.avatar;
            updatedUser.image = newImage;
            updatedUser.user_url = newImage;
            updatedUser.avatar = newImage;
        }

        // 處理電話與地址 (確保更新時也能吃到不同命名)
        if (newData.user_phone !== undefined || newData.phone !== undefined) {
            updatedUser.user_phone = newData.user_phone || newData.phone || '';
        }
        if (newData.user_address !== undefined || newData.address !== undefined) {
            updatedUser.user_address = newData.user_address || newData.address || '';
        }

        // 重新賦值
        user.value = updatedUser;

        // 同步到 localStorage
        localStorage.setItem('user', JSON.stringify(updatedUser));
    };

    // ==========================================
    // 頭像 URL 計算屬性
    // ==========================================
    const avatarUrl = computed(() => {
        if (!user.value) return null;
        return user.value.image || user.value.user_url || user.value.avatar || null;
    });

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
        avatarUrl,
        triggerLineSuccess,
        login,
        logout,
        updateUserInfo,
        openLoginAlert,
        openLoginLightbox,
        closeAll
    };
});