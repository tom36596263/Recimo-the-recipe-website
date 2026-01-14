<script setup>
    import { useRoute } from 'vue-router';
    import WorkspaceTopBar from '@/components/workspace/WorkspaceTopBar.vue';
    import WorkspaceSideBar from '@/components/workspace/WorkspaceSideBar.vue';

    const route = useRoute();
</script>

<template>
    <div class="workspace-layout">
        <WorkspaceSideBar />
        <main class="page-content">
            <WorkspaceTopBar v-if="!route.meta.hideTopBar" />

            <div class="container">
                <div class="row">
                    <div class="col-12">
                        <div class="breadcrumb p2">
                            <router-link to="/">首頁</router-link> / <span class="title-active">{{ route.meta.title }}</span>
                        </div>
                    </div>
                </div>
            </div>
            
            <router-view />
        </main>
    </div>
</template>

<style lang="scss" scoped>
    @import '@/assets/scss/layouts/workspace-layout';
    .workspace-layout {
            display: flex;
            height: 100vh;
            overflow: hidden;
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
</style>