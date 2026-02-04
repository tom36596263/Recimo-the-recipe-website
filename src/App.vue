<script setup>
import { computed, onMounted, watch, ref } from 'vue';
import { useRoute } from 'vue-router';
import DefaultLayout from '@/layouts/DefaultLayout.vue'; // 官網版面
import WorkspaceLayout from '@/layouts/WorkspaceLayout.vue'; // 工作區版面
import GlobalModalManager from '@/GlobalModalManager.vue';
// 引用 store
import { useAuthStore } from '@/stores/authStore';
import { useCartStore } from '@/stores/cartStore';
// 引用彈窗
import BaseModal from '@/components/BaseModal.vue';

const route = useRoute();
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
  // 原有的購物車檢查
  if (authStore.isLoggedIn) {
    await cartStore.fetchCart();
  }

  // 2. ✅ 檢查是否有 LINE 登入成功的訊號
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
