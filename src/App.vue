<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import DefaultLayout from '@/layouts/DefaultLayout.vue'
import WorkspaceLayout from '@/layouts/WorkspaceLayout.vue'

const route = useRoute()

// 根據目前路由的 meta.layout 決定要顯示哪一個組件
const layoutComponent = computed(() => {
  if (route.meta.layout === 'workspace') {
    return WorkspaceLayout
  }
  // 預設（或標記為 default）時顯示官網版面
  return DefaultLayout
})

</script>

<template>
  <component :is="layoutComponent">
    <router-view />
  </component>

</template>

<style lang="scss">
/* 這裡可以放全站共用的基礎 CSS */
</style>