<script setup>
    import CircleBtn from '@/components/common/CircleBtn.vue'
    import { onMounted, ref } from 'vue'

    const heroTitleH1 = ref(null)
    const heroTitleH2 = ref(null)
    const showOtherText = ref(false)

    const activeCursor = ref('h1')

    const typeText = (element, text, delay, callback) => {
        let i = 0
        element.textContent = ''
        setTimeout(() => {
            const typingInterval = setInterval(() => {
                if (i < text.length) {
                    element.textContent += text.charAt(i)
                    i++
                } else {
                    clearInterval(typingInterval)
                    if (callback) callback()
                }
            }, 100) // 打字速度
            element.style.visibility = 'visible' // 確保元素可見
        }, delay)
    }

onMounted(() => {
    const h1Text = "讓食譜隨你的靈感進化"
    const h2Text = "你的食譜，由你重新定義"

    typeText(heroTitleH1.value, h1Text, 100, () => {
        activeCursor.ref = 'h2'

        typeText(heroTitleH2.value, h2Text, 100, () => {
            activeCursor.value = null
            showOtherText.value = true
        })
    })
})
</script>
<template>
    <div class="hero-container">
        <div class="col-12">
            <div class="hero-title">
                <h2 class="zh-h2 typing" 
                    :class="{ 'show-cursor': activeCursor === 'h2' }" 
                    ref="heroTitleH2"></h2>
                <h1 class="zh-h1-bold typing" 
                    :class="{ 'show-cursor': activeCursor === 'h1' }" 
                    ref="heroTitleH1"></h1>
                <h3 class="en-h2" :class="{ 'fade-in': showOtherText }" ref="heroTitleH3">Recipe Inspiration evolution</h3>
            </div>

            <p class="p-p1 hero-text" :class="{ 'fade-in': showOtherText }" ref="heroText">這裡沒有標準答案，只有你對美食的熱情<br>
                隨手記下每一次烹飪的小發現，看見每一天自己的成長<br>
                把煮飯變成最療癒的創作</p>
            <router-link to="/recipes" class="circle-btn" :class="{ 'fade-in': showOtherText }"><CircleBtn title="尋找食譜" /></router-link>
        </div>
        <div class="bg-layout">
            <img :src="$parsePublicFile('img/site/hero.png')" alt="hero-bg" >
        </div>
        <p class="hint-text p-p1"><span class="dot"></span>SCROLL</p>
    </div>
    
    
</template>

<style lang="scss" scoped>
    @keyframes blink {
        0%, 100% { opacity: 1; }
        50% { opacity: 0; }
    }
    .hero-container{
        display: flex;
        align-items: center;
        width: 100%;
        height: 100vh;
        padding-top: 100px;
        // position: relative;
        .hero-title{
            margin-bottom: 30px;
            display: flex;
            flex-direction: column;
            .zh-h2{
                margin-bottom: 4px;
                color: $primary-color-800;
            }
            .zh-h1-bold{
                margin-bottom: 10px;
                color: $primary-color-800;
            }
            .en-h2{
                opacity: 0;
                transition: opacity 1s ease-in-out;
                &.fade-in {
                    opacity: 1;
                }
            }
            .typing {
                display: inline-block; // 讓光標緊跟在文字後
                min-height: 1.2em;
                visibility: hidden; // 初始隱藏，由 JS 開啟
                
                // 定義光標樣式
                &.show-cursor::after {
                    content: '|';
                    margin-left: 5px;
                    color: $primary-color-800;
                    animation: blink 1s infinite;
                    font-weight: normal;
                }
            }
        }
        .hero-text{
            margin-bottom: 40px;
            opacity: 0;
            transition: opacity 1s ease-in-out 0.5s; // 稍微延遲淡入
            &.fade-in {
                opacity: 1;
            }
        }
        .hint-text{
            position: absolute;
            top: 90vh;
            left: 50vw;
            animation: pulse 2s infinite;
        }
        .bg-layout{
            z-index: -1;
            position: absolute;
            top: 0;
            left: 0; 
            height: 100vh;
            img{
                width: 100%;
                height: 100%;
                object-fit: cover;
                object-position: center;
            }
        }
        .circle-btn{
            opacity: 0;
            transition: opacity 1s ease-in-out 1s; // 延遲更久
            
            &.fade-in {
                opacity: 1;
        }
        }
        
    }
    // animation: pulse 2s infinite;
    @keyframes pulse {
        0%, 100% { 
            opacity: 0.6; 
        }
        50% { 
            opacity: 1;
        }
    }
    @media screen and (max-width: 810px) {
        .hero-img1 {
            object-position: 70% center; 
        }
        .hero-container{
            padding-top: 50px;
        }
    }
</style>