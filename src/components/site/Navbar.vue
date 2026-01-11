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
        <div class="container">
            <div class="row">
                <div class="col-12 content">
                    <div class="logo">
                        <router-link to="/"><img src="@/assets/images/site/Recimo-logo-black.svg" alt=""></router-link>
                    </div>
                    <div class="link-group">
                        <router-link to="/search" class="search-btn p-p1">搜尋好料理</router-link>
                        <div class="page-link">
                            <router-link 
                            v-for="item in navItems" 
                            :key="item.path" 
                            :to="item.path"
                            class="p-p1">
                            {{ item.title }}
                            </router-link>
                            
                        </div>
                        <router-link to="/workspace" class="cart-btn">
                            <i-material-symbols-Shopping-Cart-outline />
                        </router-link>
                        <router-link to="/workspace" class="login-btn">
                            <i-material-symbols-Account-Circle-outline />
                        </router-link>
                    </div>
                    <div class="box"></div>
                </div>
            </div>
        </div>
        
        
    </nav>
</template>
<style lang="scss" scoped>
    .site-nav {
        .content{
            justify-content: space-between;
            display: flex;
            flex-direction: row;
        }
        
        .logo img {
            height: 80%;

        }
        .link-group{
            display:flex;
            gap: 16px;
            height: 50px;
            .search-btn{
                background-color: $accent-color-700;
                transition: .3s ease;
                height: 100%;
                align-items: center;
                display: flex;
                padding: 0 30px;
                border-radius: 50px;
                &:hover{
                    background-color: $accent-color-800;
                    color: $accent-color-100;
                }
            }
            .page-link{
                background-color: $primary-color-800;
                display: flex;
                gap: 24px;
                align-items: center;
                padding: 0 0 0 50px;
                border-radius: 50px 0 0 50px;
                margin-right:12px;
            }
        }
        a {
            text-decoration: none;
            color: $neutral-color-white;
            transition: color 0.3s;

            &:hover {
                color: $accent-color-700;
            }

            &.router-link-active:not(.login-btn) {
                color: $accent-color-400;
                &:hover {
                color: $accent-color-700;
            }
            }
        }

        .login-btn,
        .cart-btn {
            color: $neutral-color-white;
            font-size: 24px;
            text-decoration: none;
            display: flex;
            align-items: center;
            &:hover {
                color: $accent-color-400;
            }
        }
        .box{
            width: 1000px;
            height: 50px;
            background-color: $primary-color-800;
            position: absolute;
            top: 0;
            right: -500px;
            z-index: -1;
        }
    }
    @media screen and (max-width: 1000px){
        .site-nav{
            
        }
        
    }
</style>