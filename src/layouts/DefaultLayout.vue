<script setup>
    import Navbar from '@/components/site/Navbar.vue';
    import Breadcrumb from '@/components/site/Breadcrumb.vue';
    import Footer from '@/components/site/Footer.vue';
</script>

<template>
    <div class="default-layout">
        <header class="site-header">
            <Navbar />             
        </header>
        <main class="page-content">
            <div class="container">
                <div class="row">
                    <Breadcrumb />
                </div>
            </div>
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
        .site-header{
            position: fixed;
            top: 30px;
            left: 0;
            right: 0;
            z-index: 100;
        }
        .page-content{
            flex: 1;
            position: relative;
        }
    }
    

</style>