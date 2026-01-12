<script setup>
    import {computed} from 'vue'
    import {useRouter} from 'vue-router'
    import { ref, markRaw } from 'vue'
    import LogoBlack from '@/assets/images/site/Recimo-logo-Black.svg'
    
    // import IconForkSpoon from 'virtual:icons/material-symbols/Fork-Spoon-outline'
    // import IconSkillet from 'virtual:icons/material-symbols/Skillet-outline'
    // import IconHandMeal from 'virtual:icons/material-symbols/Hand-Meal-outline'
    // import IconTextPerson from 'virtual:icons/material-symbols/Text-Person-outline'
    // import IconShoppingCart from 'virtual:icons/material-symbols/Shopping-Cart-outline'
    // import IconAssignment from 'virtual:icons/material-symbols/Assignment-outline'

    // const pageicon = [
    //     markRaw(IconForkSpoon),
    //     markRaw(IconSkillet),
    //     markRaw(IconHandMeal),
    //     markRaw(IconTextPerson),
    //     markRaw(IconShoppingCart),
    //     markRaw(IconAssignment)
    // ];

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
    <aside class="sidebar">
        <div class="logo">
            <router-link to="/"><img :src="LogoBlack" alt=""></router-link>
        </div>
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
        .logo{
            img {
                width: 120px;
            }
        } 
    .workspace-nav {
        display: flex;
        flex-direction: column;
        gap: 6px;
        a {
            text-decoration: none;
            color: inherit;
            padding: 12px 0;
            transition: all 0.3s;
            &:hover { 
                color: $accent-color-700;
            }
            &.router-link-active {
                color: $primary-color-800;
                font-weight: bold;
                &:hover {
                    color: $accent-color-700;
                }
            }
        }
    }
    }
</style>