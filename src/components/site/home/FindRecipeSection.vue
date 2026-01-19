<script setup>
    import CircleBtn from '@/components/common/CircleBtn.vue'
</script>
<template>
    <div class="col-6 col-md-12 find-recipe-info">
        <div class="find-recipe-title">
            <h3 class="zh-h3">用食材找到好料理</h3>
            <h2 class="zh-h2-bold">準備好給你的廚房一點新鮮感</h2>
        </div>
        <div class="find-recipe-text">
            <p class="p-p1">冰箱裡剩下的食材可以做什麼好料理呢?</p>
            <p class="p-p1">讓我們為你推薦料理的無限可能</p>
            <p class="p-p1">找出今天的美味食譜，煮出美味菜餚</p>
        </div>
        <router-link to="/search">
            <CircleBtn title="搜尋好料理" />
        </router-link>
        
    </div>

    <div class="col-6 col-md-12">
        <div class="find-recipe-img">
            <img src="@/assets/images/site/meal-pic.png" alt="菜餚">
        </div>
    </div>
    <div class="col-12 ingredients">
        <img src="" alt="">
        <img src="" alt="">
        <img src="" alt="">
        <img src="" alt=""> 
        <img src="" alt="">
        <img src="" alt="">
        <img src="" alt="">
    </div>
</template>
<style lang="scss" scoped>
    .find-recipe-info{
        display: flex;
        justify-content: center;
        align-items: start;
        flex-direction: column;
        .find-recipe-title{
            color: $primary-color-700;
            margin-bottom: 20px;
        }
        .find-recipe-text{
            margin-bottom: 30px;
        }
    }
    
    .find-recipe-img{
        border-radius: $radius-base;
        overflow: hidden;
        img{
            width: 100%;
            display: block;
        }
    }
    .ingredients{
        display: flex;
        margin-top: 60px;
        justify-content: space-around;
        img{
            width:50px;
            height: 50px;
            background-color: $neutral-color-100;
            
        }
    }
    @media screen and (max-width: 810px){
        .find-recipe-img{
            margin-top: 40px;
        }
    }
</style>