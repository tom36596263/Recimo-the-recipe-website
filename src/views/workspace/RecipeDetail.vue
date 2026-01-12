<script setup>
import { ref } from 'vue';
import RecipeSteps from '../../components/workspace/recipedetail/RecipeSteps.vue';
import NutritionCard from '../../components/workspace/recipedetail/NutritionCard.vue';
import RecipeIngredients from '../../components/workspace/recipedetail/RecipeIngredients.vue';
import RecipeComments from '../../components/workspace/recipedetail/RecipeComments.vue';
import CookSnap from '../../components/workspace/recipedetail/CookSnap.vue';
import RecipeIntro from '../../components/workspace/recipedetail/RecipeIntro.vue';


const servings = ref(1);

const updateServings = (delta) => {
if (servings.value + delta >= 1) {
    servings.value += delta;
}
};

const recipeIntroData = {
title: '雲朵般口感 - 經典日式舒芙蕾鬆餅',
image: 'https://images.unsplash.com/photo-1598214813591-203900a9a56e?auto=format&fit=crop&w=1200&q=80',
time: '30 分鐘',
description: '不同於傳統美式鬆餅的紮實，它透過細緻打發蛋白創造出極致蓬鬆的層次，入口即化並散發清淡蛋香。這款甜點不僅具備視覺上的療癒動感，更是追求輕盈食感的下午茶首選。'
};

const stepsData = [
{
    title: "分離蛋黃與蛋白",
    content: "將兩顆雞蛋分離，蛋白放入冰過頭的攪拌盆（蛋白霜穩定的關鍵）。",
    image: ""
},
{
    title: "製作蛋黃糊",
    content: "蛋黃加入牛奶、香草精拌勻，再篩入低筋麵粉與泡打粉，攪拌至無顆粒狀。",
    image: ""
},
{
    title: "打發蛋白霜",
    content: "砂糖分三次加入蛋白，使用電動打蛋器打至「硬性發泡」。",
    image: ""
},
{
    title: "混合麵糊",
    content: "取 1/3 蛋白霜加入蛋黃糊拌勻，再倒回剩餘蛋白霜中，用「切拌法」輕柔混合，避免消泡。",
    image: ""
},
{
    title: "低溫煎烤",
    content: "平底鍋抹薄油，小火預熱。用冰淇淋勺挖取麵糊堆疊高度，加入一匙水，蓋鍋蓋悶煎 4 分鐘。",
    image: ""
},
{
    title: "翻面與盛盤",
    content: "底部呈金黃色後小心翻面，再悶煎 3 分鐘即可出爐。",
    image: ""
},
];

const ingredientsData = [
{
    INGREDIENT_NAME: '雞蛋',
    amount: 2,
    unit_weight: 60, // 一顆蛋約 60g
    unit_name: '顆',
    calories_per_100g: 155,
    protein_per_100g: 13,
    fat_per_100g: 11,
    carbs_per_100g: 1.1,
    note: '需將蛋黃與蛋白分離'
},
{
    INGREDIENT_NAME: '低筋麵粉',
    amount: 35,
    unit_weight: 1, // 單位已經是 g
    unit_name: 'g',
    calories_per_100g: 364,
    protein_per_100g: 8,
    fat_per_100g: 1,
    carbs_per_100g: 76,
    note: ''
},
{
    INGREDIENT_NAME: '全脂牛奶',
    amount: 20,
    unit_weight: 1, // ml 與 g 近似 1:1
    unit_name: 'ml',
    calories_per_100g: 61,
    protein_per_100g: 3.2,
    fat_per_100g: 3.3,
    carbs_per_100g: 4.8,
    note: ''
},
{
    INGREDIENT_NAME: '細砂糖',
    amount: 25,
    unit_weight: 1,
    unit_name: 'g',
    calories_per_100g: 387,
    protein_per_100g: 0,
    fat_per_100g: 0,
    carbs_per_100g: 100,
    note: '用於打發蛋白'
},
{
    INGREDIENT_NAME: '香草精',
    amount: 2,
    unit_weight: 0.5, 
    unit_name: '滴',
    calories_per_100g: 288,
    protein_per_100g: 0,
    fat_per_100g: 0,
    carbs_per_100g: 12,
    note: '去蛋腥味'
},
{
    INGREDIENT_NAME: '泡打粉',
    amount: 1,
    unit_weight: 1,
    unit_name: 'g',
    calories_per_100g: 53,
    protein_per_100g: 0,
    fat_per_100g: 0,
    carbs_per_100g: 28,
    note: '可選，增加穩定度'
}
];

const handleServingsChange = (newVal) => {
    servings.value = newVal;
};

const commentList = ref([
{
    userName: "Leo Harrison",
    handle: "leo_h_bake",
    time: "2d ago",
    content: "質地非常完美！跟著步驟圖示觀察蛋白霜的尖角狀態真的很關鍵。口感輕盈像雲朵一樣，跟我之前在巴黎吃到的一模一樣。",
    avatar: "https://i.pravatar.cc/150?u=leo", // 測試用頭像
    likes: 55
},
{
    userName: "Marcus Miller",
    handle: "mar_cooks",
    time: "1w ago",
    content: "排版非常人性化。當我手上沾滿麵粉時，這種文字在圖片上方的排版超有幫助。特別是「小撇步」區塊，成功阻止了我過度攪拌。",
    avatar: "https://i.pravatar.cc/150?u=marcus",
    likes: 42
},
{
    userName: "Sophia Chen",
    handle: "sophia_lab",
    time: "5h ago",
    content: "數據精確且具科學性。我非常喜歡你們提供的精確分量數據。不再需要靠感覺瞎猜了！",
    avatar: "https://i.pravatar.cc/150?u=sophia",
    likes: 21
}
]);

</script>

<template>
<div class="recipe-container-root">
    <main class="container"> 
        <header class="flex justify-between items-center mb-6">
            <nav class="text-gray-400">
                Home / Recipe / <span class="text-gray-800 font-bold">Classic Souffle</span>
            </nav>

            <BaseBtn 
                title="改編集+" 
                variant="outline" 
                @click="" 
                height="30" 
                class="w-auto" 
            />
        </header>

        <div class="zh-h2">{{ recipeIntroData.title }}</div>


        <div class="row">
            <div class="col-7 col-sm-12 space-y-12">
                <section>
                    <RecipeIntro :info="recipeIntroData" />



                </section>

                

                <section>
                    <RecipeSteps :steps="stepsData" />
                </section>
            </div>

            <div class="col-5 col-sm-12 space-y-12">
                <div class="nutrition-card-wrapper">
                    <NutritionCard 
                        :servings="servings" 
                        :ingredients="ingredientsData" 
                        @change-servings="handleServingsChange" 
                    />
                </div>

                <div class="ingredients-wrapper">
                    <RecipeIngredients :servings="servings" :list="ingredientsData" />
                </div>

                
                <div>
                    <RecipeComments :list="commentList" />
                </div>


                
            </div>
            <div>
                <CookSnap />
            </div>
            
        </div>
    </main>
</div>
</template>

<style lang="scss">

    /* --- [第一部分：全域解鎖區] --- */
    .workspace-layout {
    height: auto !important;
    overflow: visible !important;
    .page-content {
        height: auto !important;
        overflow: visible !important;
    }
    }
    html, body {
    overflow-y: auto !important;
    height: auto !important;
    }
    /* --- [第二部分：頁面專屬樣式] --- */
    header {
        display: flex;
        justify-content: space-between
    }

    .recipe-container-root {
    background-color: $neutral-color-white;
    min-height: 100vh;
    padding: 0px 0 100px 0;

    

    .zh-h2 {
        margin-bottom: 20px; 
    }
    
}
</style>