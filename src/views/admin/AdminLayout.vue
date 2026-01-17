<script>

</script>
<template>
    <div class="admin-layout">
        <aside class="sidebar">
            <RouterLink to="/admin">Dashboard</RouterLink>
            <RouterLink to="/admin/users">Users</RouterLink>
            <RouterLink to="/admin/settings">Settings</RouterLink>
        </aside>
        <main class="content">
            <RouterView /> <!-- ✅ 子路由會渲染在這裡 -->
        </main>
    </div>
    <div class="block"></div>
</template>
<style scoped>
.block {
    height: 1000px;
}
</style>
