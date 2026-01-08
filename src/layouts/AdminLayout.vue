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
.admin {
  display: flex;
  width: 100%;
  height: 100vh;
  overflow: hidden;
}

.admin-sidebar {
  width: 250px;
  height: 100vh;
  flex-shrink: 0;
  background-color: #fff;
  border-right: 1px solid #e0e0e0;
  display: flex;
  flex-direction: column;

  &__logo {
    padding: 20px;
    text-align: center;
    border-bottom: 1px solid #e0e0e0;
    h2 {
      color: #4a6741;
      margin: 0;
      font-size: 1.2rem;
    }
  }

  &__nav {
    display: flex;
    flex-direction: column;
    padding: 10px 0;
    overflow-y: auto;
  }

  &__link {
    padding: 15px 25px;
    text-decoration: none;
    color: #555;
    transition: background 0.3s;
    &:hover {
      background-color: #ebf0eb;
    }
    &--active {
      background-color: #dceddc;
      color: #2d4029;
      font-weight: bold;
      border-left: 4px solid #4a6741;
    }
  }
}

.main-container {
  flex-grow: 1;
  height: 100vh;
  overflow-y: auto;
  background-color: #f9f9f9;
}

.page-content {
  padding: 30px;
}
</style>
