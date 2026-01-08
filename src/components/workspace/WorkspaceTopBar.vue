<template>
    <header class="workspace-top-bar">
        <div class="container">
            <div class="row align-items-center justify-between">
                <div class="col-auto">
                    <div class="breadcrumb p2">首頁 / {{ route.name }}</div>
                </div>
                <div class="col-auto">
                    <div class="user-controls">
                        <input type="text" placeholder="搜尋食譜..." />
                        <span>Hi, Recimo</span>
                    </div>
                </div>
            </div>
        </div>
    </header>
</template>

<script setup>
import { useRoute } from 'vue-router';
const route = useRoute();
</script>

<style lang="scss" scoped>
.workspace-top-bar {
    height: 60px;
    // padding: 0 20px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: #fff;
    border-bottom: 1px solid #eee;
}
</style>