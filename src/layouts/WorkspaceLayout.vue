<template>
    <div class="workspace-layout">
        <aside class="sidebar">
            <div class="logo">Recimo</div>
            <nav class="workspace-nav">
                <router-link to="/workspace/my-recipes">我的食譜</router-link>
                <router-link to="/workspace/lab">烹飪實驗室</router-link>
                <router-link to="/workspace/plan">備餐計畫</router-link>
                <router-link to="/workspace/recipes">食譜總覽</router-link>
                <router-link to="/mall">Recimo商城</router-link> <router-link to="/workspace/orders">訂單查詢</router-link>
            </nav>
        </aside>

        <div class="main-container">
            <WorkspaceTopBar v-if="!route.meta.hideTopBar" />

            <main class="page-content">
                <router-view />
            </main>
        </div>
    </div>
</template>

<script setup>
import { useRoute } from 'vue-router';
import WorkspaceTopBar from '@/components/workspace/WorkspaceTopBar.vue';

const route = useRoute();
</script>

<style lang="scss" scoped>
.workspace-layout {
    display: flex;
    height: 100vh;
}

.sidebar {
    width: 250px;
    background: #f8f9fa;
    display: flex;
    flex-direction: column;
    padding: 20px;
}

.workspace-nav {
    display: flex;
    flex-direction: column;
    gap: 15px;
    margin-top: 30px;

    a {
        text-decoration: none;
        color: #666;
    }

    .router-link-active {
        color: $primary-color;
        font-weight: bold;
    }
}

.main-container {
    flex: 1;
    display: flex;
    flex-direction: column;
}

.page-content {
    flex: 1;
    padding: 20px;
    overflow-y: auto;
}
</style>