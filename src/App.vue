<script setup>
import { computed } from 'vue';
import { useRoute } from 'vue-router';
import DefaultLayout from '@/layouts/DefaultLayout.vue'; // 官網版面
import WorkspaceLayout from '@/layouts/WorkspaceLayout.vue'; // 工作區版面
import GlobalModalManager from '@/GlobalModalManager.vue';

const route = useRoute();

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
