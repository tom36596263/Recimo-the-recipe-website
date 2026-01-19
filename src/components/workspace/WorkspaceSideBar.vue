<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import BaseBtn from '@/components/common/BaseBtn.vue'
import LogoBlack from '/img/site/Recimo-logo-black.svg'
import IconList from 'virtual:icons/material-symbols/List'
import IconAdd from 'virtual:icons/material-symbols/Add'

const router = useRouter();
const isMoreOpen = ref(false);

// 自動篩選出 workspace 下有標題的路由
const menuItems = computed(() => {
    const workspaceRoot = router.options.routes.find(r => r.path === '/workspace');
    if (!workspaceRoot || !workspaceRoot.children) return [];

    return workspaceRoot.children
        .filter(child => child.meta && child.meta.title)
        .map(child => ({
            path: child.path.startsWith('/') ? child.path : `/workspace/${child.path}`,
            title: child.meta.title,
            icon: child.meta.icon
        }));
});

const mobileFixedItems = computed(() => menuItems.value.slice(0, 3));
const mobileMoreItems = computed(() => menuItems.value.slice(3));

const toggleMore = () => isMoreOpen.value = !isMoreOpen.value;
const closeMore = () => isMoreOpen.value = false;

</script>
<template>
    <aside class="workspace-sidebar">
        <div class="logo">
            <router-link to="/"><img :src="LogoBlack" alt="Recimo Logo"></router-link>
        </div>
        <div class="workspace-nav">
            <router-link v-for="item in menuItems" :key="item.path" :to="item.path" class="side-nav-item">
                <div class="nav-content">
                    <component :is="item.icon" class="nav-icon" />
                    <span class="label">{{ item.title }}</span>
                </div>
            </router-link>
        </div>
        <BaseBtn title="登出" height="30" />
    </aside>

    <nav class="mobile-tabbar">
        <div class="btn-group">
            <router-link v-for="item in mobileFixedItems" :key="item.path" :to="item.path" class="tab-item">
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

    <div class="slide-up">
        <div v-if="isMoreOpen" class="more-menu-panel">
            <div class="panel-items">
                <router-link v-for="item in mobileMoreItems" :key="item.path" :to="item.path" class="panel-link"
                    @click="closeMore">
                    <span class="panel-text">{{ item.title }}</span>
                </router-link>
                <BaseBtn title="登出" height="30" />
            </div>
        </div>
    </div>
</template>
<style lang="scss" scoped>
.workspace-sidebar {
    width: $sidebar-width;
    background: $primary-color-100;
    display: flex;
    flex-direction: column;
    padding: 24px;

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

    .btn-group {
        position: fixed;
        bottom: 0;
        left: 0;
        width: 100%;
        height: 70px;
        background: $primary-color-700;
        display: flex;
        justify-content: space-around;
        align-items: center;
        z-index: 1000;

        .tab-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            color: white;
            text-decoration: none;

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

@media screen and (max-width: 810px) {
    .workspace-sidebar {
        display: none;
    }

    .mobile-tabbar {
        display: block;
    }
}
</style>