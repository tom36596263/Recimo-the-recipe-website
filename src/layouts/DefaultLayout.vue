<script setup>
    import Navbar from '@/components/site/Navbar.vue';
    import Footer from '@/components/site/Footer.vue';
/**
 * 暫時移除 handleLoginClick 邏輯，
 * 等待未來串接登入燈箱與 Pinia。
 */
</script>

<template>
    <div class="default-layout">
        <header class="site-header">
            <Navbar />             
        </header>
        <main class="page-content">
            <router-view />            
        </main>

        <footer class="site-footer">
            <Footer />
        </footer>
    </div>
</template>

<style lang="scss" scoped>
    @import '@/assets/scss/layouts/default-layout';
    .default-layout{
        display: flex;
        flex-direction: column;
        min-height: 100vh;
        .site-header{
            position: sticky;
            top: 30px;
            z-index: 100;
        }
        .page-content{
            flex: 1;
            position: relative;
        }
    }
    

</style>