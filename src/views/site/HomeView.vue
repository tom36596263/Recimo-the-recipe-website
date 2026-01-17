<script setup>
    import Hero from '@/components/site/home/HeroSection.vue';
    import About from '@/components/site/home/AboutSection.vue';
    import AboutIcons from '@/components/site/home/AboutSectionIcons.vue';
    import Service from '@/components/site/home/ServiceSection.vue';
    import HotRecipe from '@/components/site/home/HotRecipeSection.vue';
    import FindRecipe from '@/components/site/home/FindRecipeSection.vue';
</script>

<template>
    <!-- <h1>首頁</h1> -->
    <div class="hero">
        <header class="container">
            <div class="row">
                <Hero />
            </div>
        </header>
    </div>
    
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

    <section class="find-recipe-section container">
        <div class="row">
            <FindRecipe />
        </div>
    </section>
    
    
</template>

<style lang="scss" scoped>
    .hero{
        height: 100vh;
        flex-direction: column;
        overflow: hidden;
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
    .find-recipe-section{
        margin: 60px auto;
        padding: 50px;
        background-color: $primary-color-100;
        border-radius: $radius-base;
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