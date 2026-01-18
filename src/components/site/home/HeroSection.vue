<script setup>
    import CircleBtn from '@/components/common/CircleBtn.vue'

</script>
<template>
    <div class="hero-container">
        <div class="col-12">
            <div class="hero-title">
                <h2 class="zh-h2">你的食譜，由你重新定義</h2>
                <h1 class="zh-h1-bold">讓食譜隨你的靈感進化</h1>
                <h3 class="en-h2">Recipe Inspiration evolution</h3>
            </div>
            <p class="p-p1 hero-text">這裡沒有標準答案，只有你對美食的熱情<br>
                隨手記下每一次烹飪的小發現，看見每一天自己的成長<br>
                把煮飯變成最療癒的創作</p>
            <router-link to="/recipes"><CircleBtn title="尋找食譜" :type="isAltTheme ? 'white' : 'fedault'"/></router-link>
        </div>
        <div class="bg-layout">
            <img :src="$parsePublicFile('img/site/hero.png')" alt="hero-bg" >
        </div>
    </div>
    
    
</template>

<style lang="scss" scoped>
    .hero-container{
        display: flex;
        align-items: center;
        width: 100%;
        height: 100vh;
        
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
            z-index: -1;
            position: absolute;
            top: 0;
            left: 0;
            height: 100vh;
            .hero-img1 {
                width: 100%;
                height: 100%;
                object-fit: cover;
                object-position: center;
            }
        }
        
        
    }
        @media screen and (max-width: 810px) {
            .hero-img1 {
                object-position: 70% center; 
            }
        }
</style>