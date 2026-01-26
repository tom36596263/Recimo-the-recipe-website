// 為了讓按鈕調用時最精簡，用一個 Composable
import { useAuthStore } from '@/stores/authStore';

export function useAuthGuard() {
    const authStore = useAuthStore();

    /**
     * @param {Function} action - 登入後要執行的函數
     */
    const runWithAuth = (action) => {
        if (authStore.isLoggedIn) {
            // 1. 已登入，直接執行
            action();
        } else {
            // 2. 未登入，先把要做的動作「存進 Pinia 的口袋」
            authStore.pendingAction = action;

            // 3. 改為直接開啟登入燈箱 (取代原本的小彈窗 openLoginAlert)
            authStore.openLoginAlert();
        }
    };

    return { runWithAuth };
}