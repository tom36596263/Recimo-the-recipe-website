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
                            首頁 / <span class="title-active">{{ route.meta.title }}</span>
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
    .breadcrumb{
        .title-active {
            color: $primary-color-700;
            font-weight: 500;
        }
    }
</style>