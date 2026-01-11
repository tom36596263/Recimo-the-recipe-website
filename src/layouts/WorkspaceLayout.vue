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
            <router-view />
        </main>
    </div>
</template>

<style lang="scss" scoped>
    @import '@/assets/scss/layouts/workspace-layout';
</style>