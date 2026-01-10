<script setup>
    import Navbar from '@/components/site/home/Navbar.vue';
/**
 * 暫時移除 handleLoginClick 邏輯，
 * 等待未來串接登入燈箱與 Pinia。
 */
</script>

<template>
    <div class="default-layout">
        <header class="site-header">
            <div class="container">
                <div class="row">
                    <Navbar /> 
                </div>
                
            </div>
            <div class="box"></div>
        </header>
        <main class="page-content">
            <div class="container">
                <div class="row">
                    <router-view />
                </div>
                
            </div>
            
        </main>

        <footer class="site-footer">
            <div class="container">
                <p>這裡是footer</p>
            </div>
        </footer>
    </div>
</template>

<style lang="scss" scoped>
    @import '@/assets/scss/layouts/default-layout';
    .box{
        width: 100px;
        height: 50px;
        background-color: $neutral-color-white;
        position: absolute;
        top: 30px;
        right: 0;
    }
</style>