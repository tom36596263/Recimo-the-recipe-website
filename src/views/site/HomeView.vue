<script setup>
    import Hero from '@/components/site/home/HeroSection.vue';
    import About from '@/components/site/home/AboutSection.vue';
    import AboutIcons from '@/components/site/home/AboutSectionIcons.vue';
    import Service from '@/components/site/home/ServiceSection.vue';
    import HotRecipe from '@/components/site/home/HotRecipeSection.vue';
</script>

<template>
    <!-- <h1>首頁</h1> -->
    <header class="hero container">
        <div class="row">
            <Hero />
        </div>
    </header>
    <section class="about-section-bg">
        <div class="about-section container">
            <div class="row">
                <About />
            </div>
        </div>
    </section>
    <section class="about-feature-bg">
        <div class="container">
            <div class="row">
                <AboutIcons />
            </div>
        </div>
    </section>
    <section class="service-section container">
        <div class="row">
            <Service />
        </div>
    </section>
    <div class="hot-recipe-bg">
        <section class="hot-recipe-section container">
            <div class="row">
                <HotRecipe />
            </div>
        </section>
    </div>
    
    
</template>

<style lang="scss" scoped>
    .hero{
        width:100%;
        height: 100vh;
        padding-top: 80px;
        display: flex;
        flex-direction: column;
        justify-content: center;
        position: relative;
    }
    .about-section-bg{
        background-color: $primary-color-700;
        width:100%;
        padding:130px 0;
        position: relative;
        overflow: hidden;
        
    }
    .about-feature-bg{
        background-color: $primary-color-100;
        padding: 30px 0;        
    }
    .service-section{
        padding: 60px 0;
    }
    .hot-recipe-bg{
        background-color: $neutral-color-100;
        padding:80px 0;
    }
    @media screen and (max-width: 810px){
        .about-section-bg{
            padding:80px 0 100px 0;
            .title-wrapper{
                margin-bottom: 30px;
            }
        }
    }
</style>