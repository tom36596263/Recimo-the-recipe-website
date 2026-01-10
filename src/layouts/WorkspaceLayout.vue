<script setup>
    import { useRoute } from 'vue-router';
    import WorkspaceTopBar from '@/components/workspace/WorkspaceTopBar.vue';
    import WorkspaceSideBar from '@/components/workspace/WorkspaceSideBar.vue';

    const route = useRoute();
</script>

<template>
    <div class="workspace-layout">
        <WorkspaceSideBar />
        <!-- <aside class="sidebar">
            <div class="logo">Recimo</div>
            <nav class="workspace-nav">
                <router-link 
                to="/workspace/my-recipes" 
                class="side-nav-item">
                <i-material-symbols-fork-spoon />
                    我的食譜
                </router-link>
                <router-link 
                to="/workspace/lab" 
                class="side-nav-item">
                <i-material-symbols-Skillet-outline />
                    烹飪實驗室
                </router-link>
                <router-link 
                to="/workspace/plan" 
                class="side-nav-item">
                <i-material-symbols-Hand-Meal-outline />
                    備餐計畫
                </router-link>
                <router-link 
                to="/workspace/recipes" 
                class="side-nav-item">
                <i-material-symbols-Inbox-Text-Person-outline />
                    食譜總覽
                </router-link>
                <router-link 
                to="/mall" 
                class="side-nav-item">
                <i-material-symbols-Shopping-Cart-outline />
                Recimo商城</router-link>
                <router-link 
                to="/workspace/orders" 
                class="side-nav-item">
                <i-material-symbols-Assignment-outline />
                    訂單查詢
                </router-link>
            </nav>
        </aside> -->
        <main class="page-content">
            <WorkspaceTopBar v-if="!route.meta.hideTopBar" />
            <router-view />
        </main>
    </div>
</template>

<style lang="scss" scoped>
    @import '@/assets/scss/layouts/workspace-layout';
</style>