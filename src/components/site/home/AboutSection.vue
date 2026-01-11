<script setup>
    
</script>
<template>
    <div class="about-section-bg">
        <div class="about-section container">
            <div class="row">
                <div class="col-5">
                    <p>記錄下</p>
                    <p>每一道美味的誕生</p>
                </div>
                <div class="col-5">
                    <h3 class="zh-h3">關於我們</h3>
                    <p class="p-p1">我們深信，食譜不應是死板的教科書，而是隨靈感與季節演進的動態紀錄。在 Recimo，我們鼓勵你發揮創意打破規則。</p>
                    <p class="p-p1">這是一個極度自由的平台，讓你在烹飪時能隨手記下多加的一匙香料、烹飪後的體悟，或是為心愛的人所做的微調。拿起你的數位筆尖，讓我們一起 ，打造專屬於你的美味百科。</p>
                    <CircleBtn title="了解更多" type="white" href="/about"/>
                </div>
            </div>
            
        </div>
        <div>
            <span>About Recimo</span>
            <span>About Recimo</span>
        </div>
    </div>
    <div class="about-feature-bg">
        <div class="container">
            <div class="row about-feature">
                <div class="col-3">
                    <div class="icon-circle">
                        <i-material-symbols-Wand-Stars-outline />
                    </div>
                    <p class="p-p1">將官方食譜進化為<br>您的私房秘笈</p>
                </div>
                <div class="col-3">
                    <div class="icon-circle">
                        <i-material-symbols-Local-Fire-Department-outline />
                    </div>
                    <p class="p-p1">透過熱量計算<br>為您做有效的健康管理</p>
                </div>
                <div class="col-3">
                    <div class="icon-circle">
                        <i-material-symbols-Inbox-Text-Person-outline />
                    </div>
                    <p class="p-p1">告別選擇困難<br>輕鬆找尋合適的食譜</p>
                </div>
                <div class="col-3">
                    <div class="icon-circle">
                        <i-material-symbols-History-Edu-outline />
                    </div>
                    <p class="p-p1">食譜搭配份量換算功能<br>客製化自己的菜餚</p>
                </div>
            </div>
        </div>
    </div>
    
</template>

<style lang="scss" scoped>
    .about-section-bg{
        background-color: $primary-color-700;
        width:100%;
        padding:200px 0;
        
    }
    .about-feature-bg{
        background-color: $primary-color-100;
        padding: 30px 0;
        .about-feature{
            .col-3{
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                text-align: center;
                gap: 1rem;
            }
            .icon-circle{
                width: 90px;
                height: 90px; 
                background-color: $neutral-color-white;
                border-radius: $radius-pill;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 40px;
                color: $primary-color-700;
            } 
        }
        
    }
</style>