<script setup>
    import {computed} from 'vue'
    import {useRouter} from 'vue-router'
    import BaseBtn from '@/components/common/BaseBtn.vue'
    import LogoBlack from '@/assets/images/site/Recimo-logo-Black.svg'

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
        }));
    });

</script>
<template>
    <aside class="workspace-sidebar">
        <div class="logo">
            <router-link to="/"><img :src="LogoBlack" alt="Recimo Logo"></router-link>
        </div>
        <div class="workspace-nav">
            <router-link v-for="item in menuItems" 
            :key="item.path"
            :to="item.path"
            class="side-nav-item">
                <div class="nav-content">
                    <component :is="item.icon" class="nav-icon"/>
                    <span class="label">{{ item.title }}</span>
                </div>
            </router-link>
        </div>
        <BaseBtn title="登出" height="30" />
    </aside>
    
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
                .nav-content{
                    display: flex;
                    align-items: center;
                    overflow: hidden;
                }
                .nav-icon{
                    width: 0;
                    height: 24px;
                    opacity: 0;
                    font-size: 24px; // 確保 icon 有大小
                    transition: all 0.3s ease;
                    white-space: nowrap;
                }
                &:hover { 
                    color: $accent-color-700;
                    .nav-icon{
                        width: 24px;
                        height: 24px;
                        opacity: 1;
                        margin-right: 8px;
                    }
                }
                &.router-link-active {
                    color: $primary-color-700;
                    .nav-icon{
                        width: 24px;
                        height: 24px;
                        opacity: 1;
                        margin-right: 8px;
                    }
                    &:hover {
                        color: $accent-color-700;
                        .nav-icon{
                            color: $accent-color-700;
                        }
                    }
                }
            }
        }
    }
    @media screen and (max-width: 810px){
        .workspace-sidebar{
            display: none;
        }
    }
</style>