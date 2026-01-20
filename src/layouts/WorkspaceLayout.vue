<script setup>
import { computed } from 'vue';
import { useRoute } from 'vue-router';
import LogoBlack from '/img/site/Recimo-logo-black.svg'
import WorkspaceTopBar from '@/components/workspace/WorkspaceTopBar.vue';
import WorkspaceSideBar from '@/components/workspace/WorkspaceSideBar.vue';

const route = useRoute();

// 計算麵包屑
const breadcrumbs = computed(() => {
    const crumbs = [{ name: '首頁', path: '/' }];
    
    // 我的食譜的子頁面
    const myRecipesSubPages = ['recent-recipes', 'my-favorites', 'personal-recipes'];
    
    if (myRecipesSubPages.includes(route.name)) {
        crumbs.push({ name: '我的食譜', path: '/workspace/my-recipes' });
        crumbs.push({ name: route.meta.title, path: null });
    } else {
        crumbs.push({ name: route.meta.title, path: null });
    }
    
    return crumbs;
});
</script>

<template>
    <div class="workspace-layout">
        <WorkspaceSideBar />

        <main class="page-content">
            <header class="container">
                <div class="row">
                    <div class="topbar-logo">
                        <router-link to="/"><img :src="LogoBlack" alt="Recimo Logo"></router-link>
                    </div>
                    <WorkspaceTopBar v-if="!route.meta.hideTopBar" />
                </div>
            </header>
            <section class="container">
                <div class="row">
                    <div class="breadcrumb p2">
                        <template v-for="(crumb, index) in breadcrumbs" :key="index">
                            <router-link v-if="crumb.path" :to="crumb.path">{{ crumb.name }}</router-link>
                            <span v-else class="title-active">{{ crumb.name }}</span>
                            <span v-if="index < breadcrumbs.length - 1"> / </span>
                        </template>
                    </div>
                </div>
            </section>

            <router-view />
        </main>
    </div>
</template>

<style lang="scss" scoped>
@use '@/assets/scss/layouts/workspace-layout' as *;

.topbar-logo img {
    display: none;
    height: 35px;
}

.workspace-layout {
    display: flex;
    height: 100vh;
    overflow: hidden;

    .page-content {
        // padding-bottom: 80px;
        margin-bottom: 20px;
        overflow-y: auto;
    }
}

.breadcrumb {
    .title-active {
        color: $primary-color-700;
        font-weight: 500;
    }

    a {
        text-decoration: none;
        color: $neutral-color-800;
        transition: .3s ease;

        &:hover {
            color: $accent-color-700;
        }
    }
}

@media screen and (max-width: 810px) {
    .topbar-logo {
        width: 100%;
        display: flex;
        justify-content: center;
        margin-bottom: 20px;

        img {
            display: block;
            width: 120px;
            margin-top: 20px;
        }
    }
}
</style>