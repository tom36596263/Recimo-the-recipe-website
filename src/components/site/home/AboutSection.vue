<script setup>
    import CircleBtn from '@/components/common/CircleBtn.vue';

    const marqueeItems = 6;
</script>

<template>
    <div class="col-5 col-md-12 title-wrapper">
        <h2 class="zh-h2 vertical-text">記錄下</h2>
        <h2 class="zh-h2 vertical-text vertical-text__hightlight">每一道美味的誕生</h2>
    </div>

    <div class="col-5 col-md-12">
        <span class="en-h3">ABOUT US</span>
        <h3 class="zh-h3 title">關於我們</h3>
        <p class="p-p1 detail">我們深信，食譜不應是死板的教科書，而是隨靈感與季節演進的動態紀錄。在 Recimo，我們鼓勵你發揮創意打破規則。</p>
        <p class="p-p1 detail">這是一個極度自由的平台，讓你在烹飪時能隨手記下多加的一匙香料、烹飪後的體悟，或是為心愛的人所做的微調。拿起你的數位筆尖，讓我們一起 ，打造專屬於你的美味百科。</p>
        <router-link to="/about">
            <CircleBtn title="了解更多" type="white" class="more-btn"/>
        </router-link>
    </div>

    <div class="bg-decoration-text">
        <div class="marquee-content">
            <span v-for="n in marqueeItems" :key="n">About Recimo</span>
        </div>
    </div>
    
</template>

<style lang="scss" scoped>
    @mixin flex-center($direction: row){
        display: flex;
        flex-direction: $direction;
        align-items: center;
        justify-content: center;
    }
    .about-section-bg{
        .title-wrapper{
            display: flex;
            justify-content: center;
        }
        .vertical-text{
            writing-mode: vertical-lr;
            letter-spacing: 0.5rem;
            margin-right: 10px;
            color: $accent-color-100;
            &__hightlight{
                transform: translateY(2rem);
            }
        }
        .more-btn{
            margin-top: 20px;
        }
        .en-h3{
            color: $primary-color-400;
            margin-bottom: 4px;
            display: flex;
        }
        .title{
            color: $neutral-color-white;
            margin-bottom: 30px;
            display: flex;
        }
        .detail{
            color: $neutral-color-white;
            margin-bottom: 10px;
        }
        .bg-decoration-text{
            position: absolute;
            bottom: -20px;
            font-size: 6rem;
            font-family: $font-family-en;
            font-weight: bold;
            color: $primary-color-400;
            opacity: .2;
            overflow: hidden;
            white-space: nowrap;
            pointer-events: none;
            animation: marquee-scroll 80s linear infinite;
            .marquee-content{
                gap: 2rem;
                display:flex;
            }
        }
    }
    @keyframes marquee-scroll{
        0%{
            transform: translateX(0);
        }100%{
            transform: translateX(-50%);
        }
    }
</style>