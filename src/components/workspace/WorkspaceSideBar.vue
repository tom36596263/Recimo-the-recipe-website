<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import LogoBlack from '@/assets/images/site/Recimo-logo-black.svg'
import BaseBtn from '@/components/common/BaseBtn.vue'
import IconList from 'virtual:icons/material-symbols/List'
import IconAdd from 'virtual:icons/material-symbols/Add'
// 引用 Pinia Store (權限狀態管理)
import { useAuthStore } from '@/stores/authStore';
// 引用彈窗
import BaseModal from '@/components/BaseModal.vue';

const isVisible = ref(true);
let lastScrollPosition = 0;

const handleScroll = (e) => {
    const currentScrollPosition = e.target.scrollTop;
    if (Math.abs(currentScrollPosition - lastScrollPosition) < 10) return;
    isVisible.value = currentScrollPosition < lastScrollPosition || currentScrollPosition <= 0;
    lastScrollPosition = currentScrollPosition;
}
defineExpose({ handleScroll });
// onMounted(() => {
//     document.querySelector('.page-content').addEventListener('scroll', handleScroll);
// });
onUnmounted(() => {
    window.removeEventListener('scroll', handleScroll);
})

const router = useRouter();
const authStore = useAuthStore();
const route = useRoute();
const isMoreOpen = ref(false);

// 自動篩選出 workspace 下有標題和圖標的路由
const menuItems = computed(() => {
    const workspaceRoot = router.options.routes.find(r => r.path === '/workspace');
    if (!workspaceRoot || !workspaceRoot.children) return [];

    return workspaceRoot.children
        .filter(child => child.meta && child.meta.title && child.meta.icon)
        .map(child => ({
            path: child.path.startsWith('/') ? child.path : `/workspace/${child.path}`,
            title: child.meta.title,
            icon: child.meta.icon
        }));
});

// 檢查路由是否激活（包含子路由）
const isActive = (itemPath) => {
    const currentPath = route.path;
    const normalizedItemPath = itemPath.replace(/\/$/, '');

    // 我的食譜的子頁面
    const myRecipesSubPages = ['/workspace/recent-recipes', '/workspace/my-favorites', '/workspace/personal-recipes'];

    // 如果當前在子頁面，且 itemPath 是我的食譜，則激活
    if (normalizedItemPath === '/workspace/my-recipes' && myRecipesSubPages.includes(currentPath)) {
        return true;
    }

    // 完全匹配
    return currentPath === normalizedItemPath;
};

const mobileFixedItems = computed(() => menuItems.value.slice(0, 3));
const mobileMoreItems = computed(() => menuItems.value.slice(3));

const toggleMore = () => isMoreOpen.value = !isMoreOpen.value;
const closeMore = () => isMoreOpen.value = false;

// ==========================================
// 登出
// ==========================================
const isLogoutModalOpen = ref(false);

const confirmLogout = () => {
    isLogoutModalOpen.value = true; // 先打開彈窗，不直接登出
};

const handleLogout = () => {
    // console.log('正在登出...');
    authStore.logout();   // 執行 Pinia 清除狀態
    isLogoutModalOpen.value = false; // 關閉彈窗

    if (isMoreOpen.value) {
        closeMore();
    }
    // closeMenu();       // 關閉手機版選單
    router.push('/');     // 跳轉回首頁
};

</script>
<template>
    <aside class="workspace-sidebar">
        <div class="logo">
            <router-link to="/"><img :src="LogoBlack" alt="Recimo Logo"></router-link>
        </div>
        <div class="workspace-nav">
            <router-link v-for="item in menuItems" :key="item.path" :to="item.path" class="side-nav-item"
                :class="{ 'router-link-active': isActive(item.path) }">
                <div class="nav-content">
                    <component :is="item.icon" class="nav-icon" />
                    <span class="label">{{ item.title }}</span>
                </div>
            </router-link>
        </div>
        <BaseBtn v-if="authStore.isLoggedIn" title="登出" height="30" @click="confirmLogout" class="logout-btn" />
    </aside>

    <nav class="mobile-tabbar" :class="{ 'tabber-hidden': !isVisible }">
        <div class="btn-group">
            <router-link v-for="item in mobileFixedItems" :key="item.path" :to="item.path" class="tab-item"
                :class="{ 'router-link-active': isActive(item.path) }">
                <component :is="item.icon" class="tab-icon" />
                <span class="tab-label p-p3">{{ item.title }}</span>
            </router-link>

            <router-link to="edit-recipe" class="tab-item add-btn">
                <IconAdd />
            </router-link>
            <div class="tab-item" @click="toggleMore" :class="{ 'active': isMoreOpen }">
                <IconList class="tab-btn" />
                <span class="tab-label p-p3">尋找更多</span>
            </div>
        </div>

    </nav>
    <BaseModal :isOpen="isLogoutModalOpen" type="info" iconClass="fa-solid fa-sign-out-alt" title="確定要登出嗎？"
        @close="isLogoutModalOpen = false">
        <template #actions>
            <BaseBtn title="取消" class="btn-outline" @click="isLogoutModalOpen = false" />
            <BaseBtn title="確定登出" class="btn-solid" @click="handleLogout" />
        </template>
    </BaseModal>
    <Transition name="slide">
        <div v-if="isMoreOpen" class="slide-up">
            <div class="overlay" @click="closeMore"></div>
            <div class="more-menu-panel">
                <div class="panel-header">
                    <router-link to="/">
                        <img :src="$parsePublicFile('img/site/Recimo-logo-white.svg')" alt="logo" class="logo">
                    </router-link>
                    <BaseBtn v-if="authStore.isLoggedIn" title="登出" height="30" @click="confirmLogout" />
                </div>
                <div class="panel-items">
                    <router-link v-for="item in mobileMoreItems" :key="item.path" :to="item.path" class="panel-link"
                        @click="closeMore">
                        <span class="p-p1">{{ item.title }}</span>
                    </router-link>
                    <router-link to="settings" class="panel-link">
                        <p class="p-p1">會員中心</p>
                    </router-link>
                </div>
            </div>
        </div>
    </Transition>

</template>
<style lang="scss" scoped>
.workspace-sidebar {
    width: $sidebar-width;
    background: $primary-color-100;
    display: flex;
    flex-direction: column;
    padding: 24px;

    .logout-btn {
        margin-top: 50px;
    }

    .logo {
        margin-bottom: 1rem;

        img {
            width: 120px;
        }
    }

    .workspace-nav {
        display: flex;
        flex-direction: column;

        .side-nav-item {
            text-decoration: none;
            color: inherit;
            padding: 12px 0;
            transition: all 0.3s;

            .nav-content {
                display: flex;
                align-items: center;
                overflow: hidden;
            }

            .nav-icon {
                width: 0;
                height: 24px;
                opacity: 0;
                font-size: 24px; // 確保 icon 有大小
                transition: all 0.3s ease;
                white-space: nowrap;
            }

            &:hover {
                color: $accent-color-700;

                .nav-icon {
                    width: 24px;
                    height: 24px;
                    opacity: 1;
                    margin-right: 8px;
                }
            }

            &.router-link-active {
                color: $primary-color-700;

                .nav-icon {
                    width: 24px;
                    height: 24px;
                    opacity: 1;
                    margin-right: 8px;
                }

                &:hover {
                    color: $accent-color-700;

                    .nav-icon {
                        color: $accent-color-700;
                    }
                }
            }
        }
    }
}

.mobile-tabbar {
    display: none;
    position: fixed; // 確保導航欄是固定的
    bottom: 0;
    left: 0;
    width: 100%;
    z-index: 1000;
    transition: transform 0.3s ease, opacity 0.3s ease;
    transform: translateY(0);
    opacity: 1;

    &.tabber-hidden {
        transform: translateY(100%);
        opacity: 0;
        pointer-events: none;
    }

    .btn-group {
        position: relative;
        width: 100%;
        height: 70px;
        background: $primary-color-700;
        display: flex;
        justify-content: space-around;
        align-items: center;

        .tab-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            color: white;
            text-decoration: none;
            cursor: pointer;

            &.router-link-active,
            &.active {
                opacity: 1;
            }

            .tab-icon {
                font-size: 24px;
                margin-bottom: 4px;
            }
        }

        .add-btn {
            width: 45px;
            height: 45px;
            background: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: $primary-color-700;
            font-size: 30px;
            position: absolute;
            top: -20px;
            border: 1px solid $primary-color-700;
        }

        .tab-btn {
            font-size: 24px;
        }
    }
}

.slide-up {
    display: none;
}

@media screen and (max-width: 810px) {
    .workspace-sidebar {
        display: none;
    }

    .mobile-tabbar,
    .slide-up {
        display: block;
    }
}

.slide-enter-active,
.slide-leave-active {
    transition: all 0.4s cubic-bezier(0.25, 1, 0.5, 1);

    .more-menu-panel {
        transition: transform 0.4s cubic-bezier(0.25, 1, 0.5, 1);
    }

    .overlay {
        transition: opacity 0.4s ease;
    }
}

.slide-enter-from,
.slide-leave-to {
    .more-menu-panel {
        transform: translateY(100%);
    }

    .overlay {
        opacity: 0;
    }
}

.slide-up {
    .more-menu-panel {
        position: fixed;
        width: 100%;
        display: flex;
        flex-direction: column;
        z-index: 10;
        bottom: 70px;

        .panel-header {
            background-color: $primary-color-700;
            width: 100%;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;

            .logo {
                height: 40px;
            }
        }

    }

    .panel-items {
        display: flex;
        flex-direction: column;
        background-color: $primary-color-100;
        text-align: center;

        .panel-link {
            padding: 20px;
            text-decoration: none;
            color: $neutral-color-black;
            transition: .3s ease;

            .p-p1 {
                padding-bottom: 20px;
            }

            &:hover {
                background-color: $accent-color-400;
            }
        }
    }
}

.overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background: rgba(0, 0, 0, 0.4);
    z-index: 3;
}
</style>