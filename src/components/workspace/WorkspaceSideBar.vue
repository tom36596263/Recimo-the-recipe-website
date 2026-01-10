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
<style lang="scss" scoped></style>