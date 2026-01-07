<script setup>
// 引入你架構中定義的後台組件
import AdminSidebar from '@/components/admin/AdminSidebar.vue';
// 假設你有一個頂部列來顯示「主要管理員」
import WorkspaceTopBar from '@/components/workspace/WorkspaceTopBar.vue';
</script>

<template>
  <div class="admin-container">
    <AdminSidebar class="admin-sidebar" />

    <main class="admin-main">
      <header class="admin-header">
        <WorkspaceTopBar />
      </header>

      <section class="admin-view-content">
        <router-view />
      </section>
    </main>
  </div>
</template>

<style lang="scss" scoped>
// 使用標準 SCSS 進行佈局
.admin-container {
  display: flex;
  width: 100%;
  height: 100vh;
  overflow: hidden;
}

.admin-sidebar {
  width: 240px; // 側邊欄寬度
  height: 100%;
  flex-shrink: 0;
  background-color: #f4f7f4; // 參考圖片的淺綠背景色
  border-right: 1px solid #e0e0e0;
}

.admin-main {
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  height: 100%;
  background-color: #ffffff;
}

.admin-header {
  height: 60px;
  width: 100%;
  border-bottom: 1px solid #eeeeee;
}

.admin-view-content {
  flex-grow: 1;
  padding: 30px;
  overflow-y: auto; // 如果內容太長則顯示捲軸
}
</style>