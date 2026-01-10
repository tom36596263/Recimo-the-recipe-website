<script setup>
    import { useRouter } from 'vue-router';
import { computed } from 'vue';

const router = useRouter();

// 篩選出 Default 佈局下的子路由
const navItems = computed(() => {
  // 直接拿取所有路由，篩選出 layout 為 default 且 meta.showInMenu 為 true 的項目
    return router.getRoutes()
    .filter(route => route.meta?.layout === 'default' && route.meta?.showInMenu)
    .map(route => ({
        path: route.path,
        title: route.meta.title
    }));
});
</script>
<template>
    <nav class="site-nav">
        <div class="logo">
            <router-link to="/"><img src="@/assets/images/site/Recimo-logo-black.svg" alt=""></router-link>
        </div>
        <div class="link-group">
            <router-link to="/search" class="search">搜尋好料理</router-link>
            <div class="page-link">
                <router-link 
                v-for="item in navItems" 
                :key="item.path" 
                :to="item.path"
                class="p-p1">
                {{ item.title }}
                </router-link>
                <router-link to="/workspace" class="cart-btn">
                <i-material-symbols-Shopping-Cart-outline />
                </router-link>
                <router-link to="/workspace" class="login-btn">
                <i-material-symbols-Account-Circle-outline />
                </router-link>
            </div>
        </div>
    </nav>
</template>
<style lang="scss" scoped>
    .site-nav {
    .logo img {
        width: 120px;
    }
    height: 50px;
    width:100%;
    justify-content: space-between;
    position: sticky;
    z-index: 100;
    display: flex;
    align-items: center;
    margin-top: 30px;
    
    .link-group{
        display:flex;
        gap: 16px;
        height: 50px;
        .search{
            background-color: $accent-color-700;
            color: $neutral-color-white;
            height: 100%;
            align-items: center;
            display: flex;
            padding: 0 30px;
            border-radius: 50px;
        }
        .page-link{
            background-color: $neutral-color-white;
            display: flex;
            gap: 24px;
            align-items: center;
            padding: 0 0 0 50px;
            border-radius: 50px 0 0 50px;
        }
    }
    a {
        text-decoration: none;
        color: $neutral-color-800;
        transition: color 0.3s;

        &:hover {
            color: $primary-color-700;
        }

        &.router-link-active:not(.login-btn) {
            color: $primary-color-800;
        }
    }

    .login-btn,
    .cart-btn {
        color: $primary-color-700;
        font-size: 24px;
        text-decoration: none;
        display: flex;
        align-items: center;
        &:hover {
            color: $primary-color-800;
        }
    }
}
</style>