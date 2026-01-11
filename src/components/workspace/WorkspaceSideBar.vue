<script setup>
    import {computed} from 'vue';
    import {useRouter} from 'vue-router';

    const router = useRouter();

    // 自動篩選出 workspace 下有標題的路由
    const menuItems = computed(() => {
        const workspaceRoot = router.options.routes.find(r => r.path === '/workspace');

        if(!workspaceRoot || !workspaceRoot.children) return [];
        return workspaceRoot.children
        .filter(child => child.meta && child.meta.title)
        .map(child => ({
            path: child.path.startsWith('/') ? child.path : `/workspace/${child.path}`,
            title: child.meta.title,
            icon: child.meta.icon
        }))
    });

</script>
<template>
    <aside class="sidebar">
        <div class="logo">Recimo</div>
        <div class="workspace-nav">
            <router-link v-for="item in menuItems" 
            :key="item.path"
            :to="item.path"
            class="side-nav-item">
                <div class="icon-box">
                    <component :is="item.icon" />
                    <span class="label">{{ item.title }}</span>
                </div>
            </router-link>
        </div>
    </aside>
    
</template>
<style lang="scss" scoped>
    // 側邊欄固定寬度
    .sidebar {
        width: $sidebar-width;
        background: $primary-color-100;
        display: flex;
        text-decoration: none;;
        flex-direction: column;
        padding: 24px;

        .logo {
            font-size: 1.5rem;
            font-weight: bold;
            color: $primary-color-800;
            margin-bottom: 2rem;
        }
    }

    // 導覽連結樣式
    .workspace-nav {
        display: flex;
        flex-direction: column;
        gap: 12px;
        margin-top: 1rem;

        a {
            text-decoration: none;
            color: inherit;
            padding: 8px 12px;
            border-radius: 6px;
            transition: all 0.3s;

            &:hover {
                color: $accent-color-700;
            }

            &.router-link-active {
                color: $primary-color-800;
                // background: rgba($primary-color-800, 0.1);
                font-weight: bold;
                &:hover {
                    color: $accent-color-700;
                }
            }
        }
    }
</style>