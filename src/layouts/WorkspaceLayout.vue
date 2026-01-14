<script setup>
    import { useRoute } from 'vue-router';
    import LogoBlack from '@/assets/images/site/Recimo-logo-Black.svg'
    import WorkspaceTopBar from '@/components/workspace/WorkspaceTopBar.vue';
    import WorkspaceSideBar from '@/components/workspace/WorkspaceSideBar.vue';

    const route = useRoute();
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
                    <div class="workspace-top-bar">
                        <WorkspaceTopBar v-if="!route.meta.hideTopBar" />
                    </div>
                </div>
            </header>
            <section class="container">
                <div class="row">
                    <div class="breadcrumb p2">
                        <router-link to="/">首頁</router-link> / <span class="title-active">{{ route.meta.title }}</span>
                    </div>
                </div>
            </section>
            
            <router-view />
        </main>
    </div>
</template>

<style lang="scss" scoped>
    @import '@/assets/scss/layouts/workspace-layout';
    .topbar-logo img{
        display: none;
        height: 35px;
    }
    .workspace-layout {
        display: flex;
        height: 100vh;
        overflow: hidden;
        .workspace-top-bar {
            width: 100%;
            // padding: 20px; 
            margin: 20px auto;
            border-radius: $radius-base;
            background-color: $primary-color-100;
            display: flex;
        }
    }
    .breadcrumb{
        .title-active {
            color: $primary-color-700;
            font-weight: 500;
        }
        a{
            text-decoration: none;
            color: $neutral-color-800;
            transition: .3s ease;
            &:hover{
                color: $accent-color-700;
            }
        }
    }
    @media screen and (max-width: 810px){
        .topbar-logo{
            width: 100%;
            display: flex;
            justify-content: center;
            margin-bottom: 20px;
            img{
                display: block;
                width: 120px;
                margin-top: 20px;
            }
        } 
    }
</style>