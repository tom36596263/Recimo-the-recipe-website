<script setup>
    import heroImg from '@/assets/images/site/hero.png'
    import CircleBtn from '@/components/common/CircleBtn.vue'
</script>
<template>
    <header class="hero container">
        <div class="row">
            <div class="col-12">
                <div class="title">
                    <h2 class="zh-h2">你的食譜，由你重新定義</h2>
                    <h1 class="zh-h1-bold">讓食譜隨你的靈感進化</h1>
                    <h3 class="en-h2">Recipe Inspiration evolution</h3>
                </div>
                <p class="p-p1">這裡沒有標準答案，只有你對美食的熱情<br>
                    隨手記下每一次烹飪的小發現，看見每一天自己的成長<br>
                    把煮飯變成最療癒的創作</p>
                <CircleBtn title="尋找食譜" href="/recipes"/>
            </div>
            
        </div>
        <img :src="heroImg" />
    </header>
</template>
<style lang="scss" scoped>
    .hero{
        width:100%;
        height: 100vh;
        margin-top: -80px;
        padding-top: 80px;
        display: flex;
        flex-direction: column;
        justify-content: center;
        position: relative;
        top: 0;
        left: 0;
        .title{
            margin-bottom: 30px;
        }
        img{
            height: 100%;
            z-index: -1;
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            object-fit: cover;
        }
    }
</style>