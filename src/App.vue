<script setup>
import { computed, onMounted, watch } from 'vue';
import { useRoute } from 'vue-router';
import DefaultLayout from '@/layouts/DefaultLayout.vue'; // 官網版面
import WorkspaceLayout from '@/layouts/WorkspaceLayout.vue'; // 工作區版面
import GlobalModalManager from '@/GlobalModalManager.vue';
// 引用 store
import { useAuthStore } from '@/stores/authStore';
import { useCartStore } from '@/stores/cartStore';

const route = useRoute();
const authStore = useAuthStore();
const cartStore = useCartStore();

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
  if (authStore.isLoggedIn) {
    await cartStore.fetchCart();
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
</template>

<style lang="scss">
/* 全站共用基礎 CSS */
</style>
