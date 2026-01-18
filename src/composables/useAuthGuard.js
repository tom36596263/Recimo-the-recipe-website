// 為了讓按鈕調用時最精簡，用一個 Composable
import { useAuthStore } from '@/stores/authStore';

export function useAuthGuard() {
    const authStore = useAuthStore();

    /**
     * @param {Function} action - 登入後要執行的函數
     */
    const runWithAuth = (action) => {
        if (authStore.isLoggedIn) {
            action();
        } else {
            authStore.openLoginAlert(); // 未登入，開啟 Pinia 裡的燈箱狀態
        }
    };

    return { runWithAuth };
}