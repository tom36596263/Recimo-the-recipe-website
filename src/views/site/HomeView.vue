<script setup>
import Hero from '@/components/site/home/HeroSection.vue';
import About from '@/components/site/home/AboutSection.vue';
import AboutIcons from '@/components/site/home/AboutSectionIcons.vue';
import Service from '@/components/site/home/ServiceSection.vue';
import HotRecipe from '@/components/site/home/HotRecipeSection.vue';
import FindRecipe from '@/components/site/home/FindRecipeSection.vue';
import ProductRmd from '@/components/mall/ProductRmd.vue';
</script>

<template>
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
        <img :src="$parsePublicFile('img/remove-bg-ingredients/1.png')" alt="番茄" class="home-ingredient1">
        <img :src="$parsePublicFile('img/remove-bg-ingredients/15.png')" alt="檸檬" class="home-ingredient15">
        <img :src="$parsePublicFile('img/remove-bg-ingredients/20.png')" alt="花椰菜" class="home-ingredient20">
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
    <!-- <section class="container">
        <div class="row">
            <ProductRmd class="detail-recommend-section" />
        </div>
    </section> -->


</template>

<style lang="scss" scoped>
.hero {
    height: 100vh;
    flex-direction: column;
    overflow: hidden;
    background-image: url('@/assets/images/site/hero.png'); 
    background-size: cover;
    background-position: center center;

    .bg-layout {
        z-index: -1;
        position: absolute;
        top: 0;
        left: 0;
        height: 100vh;

        img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            object-position: center;
        }
    }
}

.home-ingredient1 {
    z-index: 20;
    position: absolute;
    top: 10vh;
    right: 60vw;
    width: 100px;
    animation: floating 3s ease-in-out infinite;
}

.home-ingredient15 {
    z-index: 20;
    position: absolute;
    top: 60%;
    right: 5vw;
    width: 140px;
    animation: floating 4s ease-in-out infinite;
    animation-delay: 1s;
}

.home-ingredient20 {
    z-index: 20;
    position: absolute;
    top: 70%;
    left: 10vw;
    width: 180px;
    animation: floating 4s ease-in-out infinite;
    animation-delay: 0.5s;
}

@keyframes floating {
    0% {
        transform: translateY(0px);
    }

    50% {
        transform: translateY(-20px);
    }

    100% {
        transform: translateY(0px);
    }
}

.about-section-bg {
    background-color: $primary-color-700;
    width: 100%;
    padding: 130px 0;
    position: relative;
    overflow: hidden;
}

.about-feature-bg {
    background-color: $primary-color-100;
    padding: 30px 0;
}

.service-section {
    padding: 60px 0;
}

.hot-recipe-bg {
    background-color: $neutral-color-100;
    padding: 80px 0;
}

.find-recipe-section {
    margin: 60px auto;
    padding: 50px;
    background-color: $primary-color-100;
    border-radius: $radius-base;
}

@media screen and (max-width: 810px) {
    .about-section-bg {
        padding: 80px 0 100px 0;

        .title-wrapper {
            margin-bottom: 30px;
        }
    }

    .home-ingredient1,
    .home-ingredient15,
    .home-ingredient20 {
        display: none;
    }

    .find-recipe-section {
        padding: 40px 30px;
    }
}
</style>