<template>
    <div class="workspace-layout">
        <aside class="sidebar">
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
    @import '@/assets/scss/layouts/workspace-layout';
// .workspace-layout {
//     display: flex;
//     height: 100vh;
// }

// .sidebar {
//     width: 250px;
//     background: #f8f9fa;
//     display: flex;
//     flex-direction: column;
//     padding: 20px;
// }

// .workspace-nav {
//     display: flex;
//     flex-direction: column;
//     gap: 15px;
//     margin-top: 30px;

//     a {
//         text-decoration: none;
//         color: #666;
//     }

//     .router-link-active {
//         color: $primary-color-800;
//         font-weight: bold;
//     }
// }



// .page-content {
//     flex: 1;
//     padding: 20px;
//     overflow-y: auto;
// }
</style>