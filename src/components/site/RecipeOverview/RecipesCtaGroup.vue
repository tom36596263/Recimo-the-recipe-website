<script setup></script>

<template>
    <div class="cta-group-container">
        <h3 class="zh-h3">沒有找到想要的食譜嗎?</h3>
        <h2 class="zh-h2-bold">靈感廚房幫你用食材找到好料理</h2>
        <div class="bg-layout">
            <img :src="$parsePublicFile('img/site/recipe-overview-cta-group-bg.png')" alt="cta-bg" >
        </div>
        <router-link to="/recipes"><CircleBtn title="靈感廚房" :type="isAltTheme ? 'white' : 'fedault'"/></router-link>
    </div>
    
</template>

<style lang="scss" scoped>
    .cta-group-container{
        position: relative;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        height: 400px;
        .zh-h2-bold{
            color: $primary-color-800;
            margin-bottom: 30px;
        }
        .bg-layout{
            z-index: -1;
            position: absolute;
            top: 0;
            // border-radius: $radius-base;
            overflow: hidden;
            img {
                height: 100%;
                object-fit: cover;
                object-position: center;
                display: block;
            }
        }
    }
    @media screen and (max-width: 1024px){
        .cta-group-container{
            height: 300px;
            .bg-layout{
                height: 300px;
            }
        }
    }
    @media screen and (max-width: 810px){
        .cta-group-container{
            height: 240px;
            .zh-h2-bold{
                margin-bottom: 20px;
            }
            .bg-layout{
                height: 240px;
            }
        }
    }
</style>