<template>
    <div class="default-layout">
        <header class="site-header">
            <div class="container">
                <div class="logo">
                    <router-link to="/">Recimo</router-link>
                </div>
                <nav class="site-nav">
                    <router-link to="/">首頁</router-link>
                    <router-link to="/about">關於Recimo</router-link>
                    <router-link to="/recipes">食譜總覽</router-link>
                    <router-link to="/mall">Recimo商城</router-link>
                    <router-link to="/benefits">會員權益</router-link>
                    <router-link to="/cart">購物車</router-link>

                    <router-link to="/workspace" class="login-btn">進入工作區</router-link>
                </nav>
            </div>
        </header>

        <main class="main-content">
            <router-view />
        </main>

        <footer class="site-footer">
            <div class="container">
                <p>這裡是footer</p>
            </div>
        </footer>
    </div>
</template>

<script setup>
/**
 * 暫時移除 handleLoginClick 邏輯，
 * 等待未來串接登入燈箱與 Pinia。
 */
</script>

<style lang="scss" scoped>
    @import '@/assets/scss/layouts/default-layout';
</style>