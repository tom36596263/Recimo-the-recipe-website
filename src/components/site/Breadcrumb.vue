<script setup>
    import { computed } from 'vue';
    import { useRoute } from 'vue-router';

    const route = useRoute();

    const breadcrumbs = computed(() => {
        const matched = route.matched;
        return matched
        .filter(item => item.meta && item.meta.breadcrumb)
        .map(item => ({
            name: item.meta.breadcrumb,
            path: item.path
        }));
    })
</script>
<template>
    <nav v-if="breadcrumbs.length > 0" class="bread col-12">
        <router-link to="/">首頁</router-link>
        <span v-for="(crumb, index) in breadcrumbs" :key="index">
            <span class="separator"> / </span>
            <span v-if="index === breadcrumbs.length-1">{{ crumb.name }}</span>
            <span v-else>{{ crumb.name || '載入中...' }}</span>
        </span>
    </nav>
</template>
<style lang="scss" scoped>
    .bread {
        margin: 120px 0 0 0;
        a {
            text-decoration: none;
            color: $neutral-color-800;
            &:hover { color: $accent-color-700; }
        }
        span {
            color: $primary-color-700;
        }
    }
</style>