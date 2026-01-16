<script setup>
import { computed } from 'vue';
import { useRoute } from 'vue-router';
import { useRouteName } from '@/composables/useRouteName'

const route = useRoute();
const { detailName } = useRouteName()

const breadcrumbs = computed(() => {
    const matched = route.matched;
    return matched
        .filter(item => item.meta && item.meta.breadcrumb)
        .map(item => ({
            name: item.meta.breadcrumb,
            path: item.path,
            isDynamic: !!item.meta.isDynamic,
        }));
})
</script>
<template>
    <nav v-if="breadcrumbs.length > 0" class="bread col-12">
        <router-link to="/">首頁</router-link>
        <span v-for="(crumb, index) in breadcrumbs" :key="index">
            <span class="separator"> / </span>
            <router-link 
            v-if="index < breadcrumbs.length-1" 
            :to="crumb.path"
            >
            {{ crumb.name }}
            </router-link>
            <span v-else>{{  crumb.isDynamic ? detailName : crumb.name }}</span>
        </span>
    </nav>
</template>
<style lang="scss" scoped>
.bread {
    margin: 120px 0 0 0;

    a {
        text-decoration: none;
        color: $neutral-color-800;

        &:hover {
            color: $accent-color-700;
        }
    }

    span {
        color: $primary-color-700;
    }
}
</style>