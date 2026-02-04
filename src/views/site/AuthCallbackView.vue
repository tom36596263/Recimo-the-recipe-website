<script setup>
import { onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { phpApi } from '@/utils/publicApi.js'; // 這是您常用的 API 工具
import { useAuthStore } from '@/stores/authStore';

const route = useRoute();
const router = useRouter();
const authStore = useAuthStore();

onMounted(async () => {
    // 1. 從 URL 取得 LINE 回傳的 code
    const code = route.query.code;

    // 獲取當初被守衛攔截時存下的目標頁面 (如有)
    const targetPath = localStorage.getItem('pendingPath');

    if (!code) {
        console.error('找不到 Code，跳轉回首頁');
        router.push('/');
        return;
    }

    try {
        // 2. 將 code 打給您的 PHP 後端
        // 注意：後續我們需要去寫這支 auth/line-login.php
        const res = await phpApi.post('auth/line-login.php', { code });
        console.log('PHP 原始回傳：', res.data);

        if (res.data && res.data.status === 'success') {
            // authStore.login(res.data.user);

            // localStorage.setItem('line_login_success', 'true');

            // // 💡 老師，改用這個方式回首頁，強制瀏覽器重整，App.vue 才會偵測到
            // window.location.href = '/';
            if (res.data && res.data.status === 'success') {
                authStore.login(res.data.user);

                // 1. 存入彈窗訊號
                localStorage.setItem('line_login_success', 'true');

                // 2. ✅ 關鍵：從 localStorage 讀取目的地
                const targetPath = localStorage.getItem('pendingPath');

                if (targetPath) {
                    console.log('有目的地，跳轉至：', targetPath);
                    // 跳轉前先清除紀錄
                    localStorage.removeItem('pendingPath');
                    // 執行跳轉
                    window.location.href = targetPath;
                } else {
                    console.log('沒目的地，回首頁');
                    window.location.href = '/';
                }
            }
        }
    } catch (error) {
        console.error('API 請求出錯:', error);
        alert('系統連線異常，請稍後再試');
        router.push('/');
    }
});
</script>

<template>
    <div class="callback-container">
        <div class="loader-box">
            <div class="spinner"></div>
            <p>LINE 驗證中，請稍候...</p>
        </div>
    </div>
</template>

<style scoped>
.callback-container {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 60vh;
    text-align: center;
}

.spinner {
    width: 40px;
    height: 40px;
    border: 4px solid #f3f3f3;
    border-top: 4px solid #00B900;
    /* LINE 的綠色 */
    border-radius: 50%;
    animation: spin 1s linear infinite;
    margin: 0 auto 1rem;
}

@keyframes spin {
    0% {
        transform: rotate(0deg);
    }

    100% {
        transform: rotate(360deg);
    }
}
</style>