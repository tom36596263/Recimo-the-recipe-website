<script setup>
    import { ref, onMounted, onUnmounted } from 'vue'
    import heroImg1 from '@/assets/images/site/hero.png'
    import heroImg2 from '@/assets/images/site/hero-2.png'
    import CircleBtn from '@/components/common/CircleBtn.vue'

    const isAltTheme = ref(false); //第一張true 第二張false
    let timer = null

    const startTimer = () => {
        if(window.innerWidth > 810 && !timer){
            timer = setInterval(() => {
                isAltTheme.value = !isAltTheme.value
            }, 4000)
        }
    }
    const stopTimer = () => {
        if(timer){
            clearInterval(timer)
            timer = null
        }
    }
    const handleResize = () => {
        if(window.innerWidth <= 810){
            isAltTheme.value = false
            stopTimer()
        }else{
            startTimer()
        }
    }
    onMounted(() => {
        startTimer()
        window.addEventListener("resize", handleResize);
    })
    onUnmounted(() => {
        if(timer) clearInterval(timer)
        window.removeEventListener("resize", handleResize);
    })
</script>
<template>
    <div class="hero-container" :class="{ 'is-alt-theme': isAltTheme }">
        <div class="col-12">
            <div class="hero-title">
                <h2 class="zh-h2">你的食譜，由你重新定義</h2>
                <h1 class="zh-h1-bold">讓食譜隨你的靈感進化</h1>
                <h3 class="en-h2">Recipe Inspiration evolution</h3>
            </div>
            <p class="p-p1 hero-text">這裡沒有標準答案，只有你對美食的熱情<br>
                隨手記下每一次烹飪的小發現，看見每一天自己的成長<br>
                把煮飯變成最療癒的創作</p>
            <CircleBtn title="尋找食譜" href="/recipes" :type="isAltTheme ? 'white' : 'fedault'"/>
        </div>
        <div class="bg-layout">
            <img :src="heroImg1" class="hero-img1"/>
            <img :src="heroImg2" class="hero-img2"/>
        </div>
    </div>
    
    
</template>

<style lang="scss" scoped>
    .hero-container{
        display: flex;
        align-items: center;
        
        .hero-title{
            margin-bottom: 30px;
            .zh-h2{
                margin-bottom: 4px;
                color: $primary-color-800;
            }
            .zh-h1-bold{
                margin-bottom: 10px;
                color: $primary-color-800;
            }
        }
        .hero-text{
            margin-bottom: 40px;
        }
        .bg-layout{
            transition: opacity 3s ease;
            z-index: -1;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            position: absolute;
            transition: height 1s ease;
        }
        .hero-img1{
            opacity: 1;
            z-index: -3;
            object-fit: cover;
        }
        .hero-img2{
            opacity: 0;
            height: 0;
            z-index: -5;
        }
        &.is-alt-theme{
            .zh-h2{
                color: $neutral-color-white;
            }
            .zh-h1-bold{
                color: $neutral-color-white;
            }
            color: $neutral-color-white;
            .hero-img1 { 
                opacity: 0;
                height: 0; 
            }
            .hero-img2 { 
                opacity: 1;
                height: auto; }
        }
    }
    @media screen and (max-width: 810px){
        .hero-title{
            .zh-h2, .zh-h1-bold {
                color: $primary-color-800;
            }
        }
        .hero-text{
            color: $neutral-color-800
        }
        .hero-img1{
            height: auto;
            opacity:1;
        }
        .hero-img2{
            height: 0; 
            opacity: 0;
        }
        
    }
        
</style>