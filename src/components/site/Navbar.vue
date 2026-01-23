<script setup>
import { useRouter } from 'vue-router';
import { computed, ref, onMounted, onUnmounted } from 'vue';
import BaseBtn from '@/components/common/BaseBtn.vue'

const router = useRouter();
const isMenuOpen = ref(false);
const isVisible = ref(true);  //控制顯示隱藏
const lastScrollTop = ref(0);  //紀錄上次捲動位置

const toggleMenu = () => {
    isMenuOpen.value = !isMenuOpen.value;
};
//點擊後自動關閉
const closeMenu = () => {
    isMenuOpen.value = false;
}

//監聽滾動事件
const handleScroll = () => {
    const currentScrollTop = window.pageYOffset || document.documentElement.scrollTop;
    if (isMenuOpen.value) return;
    if (currentScrollTop > lastScrollTop.value && currentScrollTop > 100) {
        isVisible.value = false;
    } else {
        isVisible.value = true;
    }
    lastScrollTop.value = currentScrollTop <= 0 ? 0 : currentScrollTop;
}
onMounted(() => {
    window.addEventListener('scroll', handleScroll);
});
onUnmounted(() => {
    window.removeEventListener('scroll', handleScroll);
})

// 篩選出 Default 佈局下的子路由
const navItems = computed(() => {
    return router.getRoutes()
        .filter(route => route.meta?.layout === 'default' && route.meta?.showInMenu)
        .map(route => ({
            path: route.path,
            title: route.meta.title
        }));
});

</script>
<template>
    <nav class="site-nav" :class="{ 'nav--hidden': !isVisible }">
        <div class="container">
            <div class="row">
                <div class="col-12 content">
                    <div class="hb" :class="{ 'menu-open': isMenuOpen }" @click="toggleMenu">
                        <span></span>
                        <span></span>
                        <span></span>
                    </div>
                    <div class="logo">
                        <router-link to="/"><img :src="$parsePublicFile('img/site/Recimo-logo-black.svg')" alt="logo" ></router-link>
                    </div>
                    <div class="link-group">
                        <div class="page-link" :class="{ 'mobile-active': isMenuOpen }">
                            <router-link to="/search" class="search-btn" :class="{ 'mobile-active': isMenuOpen }" @click="closeMenu">
                                <p class=" p-p1 text">搜尋好料理</p>
                                <i class="fa-solid fa-magnifying-glass icon-search"></i>
                            </router-link>

                            <router-link 
                                v-for="item in navItems" 
                                :key="item.path" 
                                :to="item.path" 
                                class="p-p1"
                                @click="closeMenu"
                            >
                                {{ item.title }}
                            </router-link>

                            <div class="nav-icon-link">
                                <router-link to="/cart" class="cart-btn" @click="closeMenu">
                                    <span class="btn-text  p-p1">我的購物車</span>
                                    <i-material-symbols-Shopping-Cart-outline class="btn-icon" />
                                </router-link>

                                <router-link to="/workspace" class="login-btn" @click="closeMenu">
                                    <span class="btn-text p-p1">我的廚房</span>
                                    <i-material-symbols-Account-Circle-outline class="btn-icon" />
                                </router-link>
                            </div>
                            <div class="side-menu-only">
                                <router-link to="/">
                                    <img :src="$parsePublicFile('img/site/Recimo-logo-white.svg')" alt="logo" >
                                </router-link>

                                <BaseBtn title="登出" height="30" />
                            </div>

                        </div>
                    </div>
                    <div class="nav-box"></div>
                </div>
            </div>
        </div>
        <div class="overlay" :class="{ 'show': isMenuOpen }" @click="closeMenu"></div>

    </nav>
</template>

<style lang="scss" scoped>
.site-nav {
    transition: transform 0.4s ease, opacity .4s ease;
    position: sticky;
    top: 0;
    z-index: 100;

    &.nav--hidden {
        opacity: 0;
        pointer-events: none;
        transform: translateY(-100%);
    }

    .content {
        justify-content: space-between;
        display: flex;
        flex-direction: row;
        position: relative;
    }

    .logo img {
        height: 80%;
    }

    .link-group {
        display: flex;
        gap: 24px;
        height: 50px;
        position: relative;

        .search-btn {
            background-color: $accent-color-700;
            transition: .3s ease;
            height: 100%;
            align-items: center;
            display: flex;
            padding: 0 30px;
            border-radius: 50px;
            position: absolute;
            left: -160px;
            animation: searchPulse 2.4s ease-in-out infinite;

            &:hover {
                background-color: $accent-color-800;
                color: $accent-color-100;
            }
            .icon-search{
                display: none;
            }
        }

        .page-link {
            background-color: $primary-color-800;
            display: flex;
            gap: 16px;
            align-items: center;
            padding: 0 0 0 50px;
            border-radius: 50px 0 0 50px;
            margin-right:12px;

            .btn-text,
            .side-menu-only {
                display: none;
            }
            .nav-icon-link {
                display: flex;
                flex-direction: row;
                gap: 14px;
            }
        }
    }

    a {
        text-decoration: none;
        color: $neutral-color-white;
        transition: color 0.3s;

        &:hover {
            color: $accent-color-700;
        }

        &.router-link-active:not(.login-btn, .search-btn) {
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

    .nav-box {
        width: 1000px;
        height: 50px;
        background-color: $primary-color-800;
        position: absolute;
        top: 0;
        right: -500px;
        z-index: -1;
    }

    .hb {
        position: absolute;
        width: 45px;
        height: 45px;
        border-radius: 50%;
        background-color: rgba(255, 255, 255, 0.6);
        z-index: 10;
        display: none;
        transition: .3s ease;
        cursor: pointer;

        span {
            display: block;
            height: 2px;
            width: 60%;
            position: absolute;
            background-color: $neutral-color-800;
            opacity: 1;
            margin: auto;
            left: 0;
            right: 0;
            transition: transform 1s ease, top 1.3s ease, opacity 1s ease;
        }

        span:first-child {
            top: 12px;
            transform: rotate(0deg);
        }

        span:nth-child(2) {
            top: 21.5px;
            transform: rotate(0deg);
        }

        span:nth-child(3) {
            top: 31px;
            transform: rotate(0deg);
        }

        &.menu-open{
            span:first-child {
                top: 21.5px;
                transform: rotate(45deg);
            }
            span:nth-child(2) {
                opacity: 0;
            }
            span:nth-child(3) {
                top: 21.5px;
                transform: rotate(135deg);
            }
        }
    }
}

@media screen and (max-width: 1000px) {
    .site-nav {
        .link-group {

            .search-btn {
                left: -90px;
                .icon-search{
                    display: block;
                }
                .text{
                    display: none;
                }
            }
            .page-link{
                gap: 10px;
                padding: 0 0 0 35px;
            }
        }
        .logo img {
            height: 70%;
        }
        .nav-box {
            width: 800px;
        }
    
    }
    
}
@media screen and (max-width: 810px) {

    .site-nav {
        .link-group {
            display: block;
            .search-btn {
                position: static;
                margin-bottom: 20px;
                width: 100%;
                max-width: 160px;
                height: auto;
                .icon-search{
                    display: none;
                }
            }
            .page-link {
                position: fixed;
                top: 0;
                left: 0;
                width: 300px;
                height: 100vh;
                transform: translateX(-100%);
                transition: transform 0.4s ease;
                border-radius: 0;
                flex-direction: column;
                padding: 0;
                margin: 0;
                gap: 0px;
                z-index: 15;

                &.mobile-active {
                    transform: translateX(0);
                    padding: 80px 30px 30px;
                    flex-wrap: nowrap;
                    overflow-x: scroll;
                    white-space: nowrap;
                    &::-webkit-scrollbar {
                        display: none;
                    }
                    -ms-overflow-style: none;
                    scrollbar-width: none;

                    .p-p1,
                    .nav-icon-link a {
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        width: 100%;
                        height: 45px;
                    }
                    a.p-p1 {
                        flex-shrink: 0;
                    }

                    .nav-icon-link {
                        position: static;
                        flex-direction: column;
                        gap: 0px;
                        width: 100%;

                        .btn-text {
                            color: $neutral-color-white;
                            &:hover {
                                color: $accent-color-700;
                            }
                            .p-p1 {
                                display: block;
                                font-size: 1rem;
                            }
                        }

                        .btn-icon {
                            display: none;
                        }

                        .cart-btn,
                        .login-btn {
                            background-color: transparent;
                            width: 100%;
                        }
                    }

                    .side-menu-only {
                        display: flex;
                        margin-top: 80px;
                        flex-direction: column;

                        img {
                            margin-bottom: 20px;
                            width: 150px;
                        }
                    }
                }

                &:not(.mobile-active) {
                    .nav-icon-link {
                        position: fixed;
                        margin-top: 30px;
                        right: 10%;
                        display: flex;
                        flex-direction: row;
                        transform: translateX(94vw);
                        right: 0;
                        top: 0;
                    }
                }

                .p-p1 {
                    display: none;
                }
            }
        }

        .content {
            .logo img {
                display: inline-block;
                align-items: center;
                justify-content: center;
                position: absolute;
                left: 50%;
                top: 50%;
                transform: translate(-50%, -50%);
                height: 50px
            }
        }

        .hb {
            display: block;
            opacity: .8;
            height: 45px;
            width: 45px;
            z-index: 20;
        }
        .cart-btn,
        .login-btn {
            color: $neutral-color-800;
            width: 45px;
            height: 45px;
            background-color: rgba(255, 255, 255, 0.6);
            border-radius: 50%;
            justify-content: center;
            align-items: center;
            transition: .3s ease;

            &:hover {
                color: $primary-color-700;
            }
        }

    }

    .overlay {
        position: fixed;
        top: 0;
        left: 0;
        background-color: rgba(0, 0, 0, .7);
        width: 100vw;
        height: 100vh;
        opacity: 0;
        visibility: hidden;
        transition: all .4 ease;

        &.show {
            opacity: 1;
            visibility: visible;
        }
    }
    .nav-box {
        display: none;
    }
}
@keyframes searchPulse {
    0% {
        box-shadow: 0 0 0 0 rgba(255, 180, 0, 0.6);
        transform: scale(1);
    }
    50% {
        box-shadow: 0 0 0 8px rgba(255, 180, 0, 0);
        transform: scale(1.03);
    }
    100% {
        box-shadow: 0 0 0 0 rgba(255, 180, 0, 0);
        transform: scale(1);
    }
}
</style>