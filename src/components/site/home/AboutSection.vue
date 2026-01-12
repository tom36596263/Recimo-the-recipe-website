<script setup>
    import { ref, markRaw } from 'vue'
    import CircleBtn from '@/components/common/CircleBtn.vue'
    import IconWandStars from '~icons/material-symbols/Wand-Stars-outline';
    import IconLocalFireDepartment from '~icons/material-symbols/Local-Fire-Department-outline';
    import IconInboxTextPerson from '~icons/material-symbols/Inbox-Text-Person-outline';
    import IconHistoryEdu from '~icons/material-symbols/History-Edu-outline';

    const features = ref([
        { icon: markRaw(IconWandStars), text: '將官方食譜進化為<br>您的私房秘笈' },
        { icon: markRaw(IconLocalFireDepartment), text: '透過熱量計算<br>為您做有效的健康管理' },
        { icon: markRaw(IconInboxTextPerson), text: '告別選擇困難<br>輕鬆找尋合適的食譜' },
        { icon: markRaw(IconHistoryEdu), text: '食譜搭配份量換算功能<br>客製化自己的菜餚' }
    ]);

    const marqueeItems = 6;
</script>
<template>
    <section class="about-section-bg">
        <div class="about-section container">
            <div class="row">
                <div class="col-5 col-md-12 title-wrapper">
                    <h2 class="zh-h2 vertical-text">記錄下</h2>
                    <h2 class="zh-h2 vertical-text vertical-text__hightlight">每一道美味的誕生</h2>
                </div>
                <div class="col-5 col-md-12">
                    <span class="en-h3">ABOUT US</span>
                    <h3 class="zh-h3 title">關於我們</h3>
                    
                    <p class="p-p1 detail">我們深信，食譜不應是死板的教科書，而是隨靈感與季節演進的動態紀錄。在 Recimo，我們鼓勵你發揮創意打破規則。</p>
                    <p class="p-p1 detail">這是一個極度自由的平台，讓你在烹飪時能隨手記下多加的一匙香料、烹飪後的體悟，或是為心愛的人所做的微調。拿起你的數位筆尖，讓我們一起 ，打造專屬於你的美味百科。</p>
                    <CircleBtn title="了解更多" type="white" href="/about" class="more-btn"/>
                </div>
            </div>
            
        </div>
        <div class="bg-decoration-text">
            <div class="marquee-content">
                <span v-for="n in marqueeItems" :key="n">About Recimo</span>
            </div>
            
        </div>
    </section>
    <section class="about-feature-bg">
        <div class="container">
            <div class="row about-feature">
                <div v-for="item in features" :key="item.text" class="col-3 col-lg-6 about-feature-item">
                    <div class="icon-circle">
                        <component :is="item.icon" />
                    </div>
                    <p class="p-p1" v-html="item.text"></p>
                </div>
            </div>
        </div>
    </section>
    
</template>

<style lang="scss" scoped>
    @mixin flex-center($direction: row){
        display: flex;
        flex-direction: $direction;
        align-items: center;
        justify-content: center;
    }
    .about-section-bg{
        background-color: $primary-color-700;
        width:100%;
        padding:130px 0;
        position: relative;
        overflow: hidden;
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
    .about-feature-bg{
        background-color: $primary-color-100;
        padding: 30px 0;
        .about-feature{
            &-item{
                @include flex-center(column);
                text-align: center;
                margin: 30px 0;
                gap: 1rem;
            }
            .icon-circle{
                @include flex-center;
                width: 70px;
                height: 70px; 
                background-color: $neutral-color-white;
                border-radius: $radius-pill;
                font-size: 32px;
                color: $primary-color-700;
                transition: transform 0.3s ease;
                &:hover{
                    transform: scale(1.1);
                }
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
    @media screen and (max-width: 810px){
        .about-section-bg{
            padding:80px 0 100px 0;
            .title-wrapper{
                margin-bottom: 30px;
            }
        }
        
    }
</style>