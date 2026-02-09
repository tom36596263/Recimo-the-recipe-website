<script setup>
import { computed, onMounted, watch, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import DefaultLayout from '@/layouts/DefaultLayout.vue'; // 官網版面
import WorkspaceLayout from '@/layouts/WorkspaceLayout.vue'; // 工作區版面
import GlobalModalManager from '@/GlobalModalManager.vue';
// 引用 store
import { useAuthStore } from '@/stores/authStore';
import { useCartStore } from '@/stores/cartStore';
// 引用彈窗
import BaseModal from '@/components/BaseModal.vue';
// 呼叫Api
import { phpApi } from '@/utils/publicApi.js';

const route = useRoute();
const router = useRouter();
const authStore = useAuthStore();
const cartStore = useCartStore();

// 控制 Line 登入成功的彈窗變數
const showLineSuccess = ref(false);

/**
 * 根據路由的 meta.layout 切換版面
 * 現在只剩兩種：workspace 或預設的 default
 */
const layoutComponent = computed(() => {
  if (route.meta.layout === 'workspace') {
    return WorkspaceLayout;
  }
  // 如果不是 workspace，就統一使用官網版面
  return DefaultLayout;
});

onMounted(async () => {
  // 偵測網址是否有 LINE 回傳的 code
  const urlParams = new URLSearchParams(window.location.search);
  const code = urlParams.get('code');

  if (code) {
    try {
      // 呼叫後端 API 換取資料
      const res = await phpApi.post('auth/line-login.php', { code });

      if (res.data && res.data.status === 'success') {
        // 執行 store 的登入動作
        authStore.login(res.data.user);

        // 彈出成功視窗
        showLineSuccess.value = true;

        // 清除網址上的參數（code），讓網址變乾淨
        // 這樣重新整理頁面時，就不會重複觸發 API
        window.history.replaceState({}, document.title, window.location.pathname);

        // 如果當初有紀錄想去的地方，就跳轉過去
        const pendingPath = localStorage.getItem('pendingPath');
        if (pendingPath) {
          localStorage.removeItem('pendingPath');

          // 如果存的路徑已經包含了正式環境的子目錄，我們只需要跳轉到「該子目錄之後」的路徑
          const base = '/cjd102/g2/recimo/';
          let targetPath = pendingPath;

          if (pendingPath.startsWith(base)) {
            // 舉例：把 /cjd102/g2/recimo/workspace 變成 /workspace
            targetPath = pendingPath.replace(base, '/');
          }

          // 確保路徑不會變成空的或雙斜線
          targetPath = targetPath.startsWith('/') ? targetPath : '/' + targetPath;

          router.push(targetPath);
        }

        // 延遲自動關閉彈窗
        setTimeout(() => {
          showLineSuccess.value = false;
        }, 2000);
      }
    } catch (error) {
      console.error('LINE 登入驗證失敗:', error);
    }
  }
  // 原有的購物車檢查
  if (authStore.isLoggedIn) {
    await cartStore.fetchCart();
  }

  // 檢查是否有手動存入的成功訊號
  if (localStorage.getItem('line_login_success') === 'true') {
    showLineSuccess.value = true;
    localStorage.removeItem('line_login_success'); // 顯示後立刻刪除，避免重複彈出

    // 延遲自動關閉
    setTimeout(() => {
      showLineSuccess.value = false;
    }, 1500);
  }
});

watch(() => authStore.isLoggedIn, async (newVal) => {
  if (newVal) {
    await cartStore.fetchCart();
  }
}, { immediate: true }); // immediate 確保一進來就檢查一次
</script>

<template>
  <!-- <component :is="layoutComponent"> -->
  <router-view />
  <!-- </component> -->
  <GlobalModalManager />
  <!-- Line登入成功 -->
  <BaseModal :isOpen="showLineSuccess" type="success" iconClass="fa-solid fa-check" title="登入成功"
    :description="`${authStore.user?.name}，歡迎回來Recimo~`" @close="showLineSuccess = false" />
</template>

<style lang="scss">
/* 全站共用基礎 CSS */
</style>
