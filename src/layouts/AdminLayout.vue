<script setup>
import { computed } from 'vue';
import { useRouter, useRoute } from 'vue-router';

const router = useRouter();
const route = useRoute();

// 篩選出 /admin 下所有的子路由，用來生成選單
const adminMenuItems = computed(() => {
  const adminRoute = router.options.routes.find((r) => r.path === '/admin');
  return adminRoute
    ? adminRoute.children.filter((child) => child.meta && child.meta.title)
    : [];
});

// 判斷是否為目前選中的頁面
const isActive = (path) => {
  return route.path === `/admin/${path}`;
};
</script>

<template>
  <div class="admin">
    <aside class="admin-sidebar">
      <div class="admin-sidebar__logo">
        <h2>Recimo 後台</h2>
      </div>
      <nav class="admin-sidebar__nav">
        <router-link
          v-for="item in adminMenuItems"
          :key="item.path"
          :to="`/admin/${item.path}`"
          class="admin-sidebar__link"
          :class="{ 'admin-sidebar__link--active': isActive(item.path) }"
        >
          {{ item.meta.title }}
        </router-link>
      </nav>
    </aside>

    <div class="main-container">
      <main class="page-content">
        <router-view />
      </main>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @import '@/assets/scss/layouts/admin-layout';
</style>
