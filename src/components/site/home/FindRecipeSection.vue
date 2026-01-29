<script setup>
    import CircleBtn from '@/components/common/CircleBtn.vue'
    import { phpApi } from '@/utils/publicApi'
    import { ref, onMounted } from 'vue'

    const recipesData = ref([])
    const currentBigImg = ref('img/recipes/1/cover.png')
    const displayIngredients = ref([])
    const activeId = ref(null)
    const isRotating = ref(false)

    //隨機產生新食材按鈕
    const handleReset = () => {
        if(isRotating.value) return

        isRotating.value = true
        initRandomIngredients();

        if(displayIngredients.value.length > 0){
            const firstItem = displayIngredients.value[0]
            toggleRecipe(firstItem.recipe_image_url, firstItem.id)
        }
        setTimeout(() => {
            isRotating.value = false
        }, 500)
    }
    // const base = import.meta.env.BASE_URL;
    const fetchData = async () => {
        try {
            // const response = await fetch(`${import.meta.env.BASE_URL}data/others/remove-bg-ingredients.json`) 
            const res = await phpApi.get('others/get_remove_bg_ingredients.php');
            const result = res.data;
            // const data = await response.json()
            if (result.status === 'success'){
                recipesData.value = result.data.map(item => ({
                    ...item,
                    // 解析食材圖路徑
                    url:item.url,
                    // 解析大圖路徑
                    recipeImg: item.recipe_image_url
                }));
                // recipesData.value = result.data
                initRandomIngredients()

                if (displayIngredients.value.length > 0) {
                    const firstItem = displayIngredients.value[0]
                    toggleRecipe(firstItem.recipe_image_url, firstItem.id)
                }
            }
            
        } catch (error) {
            console.error('抓取資料失敗:', error)
        }
    }
    const initRandomIngredients = () => {
        if (recipesData.value.length > 0) {
            const shuffled = [...recipesData.value].sort(() => 0.5 - Math.random())
            displayIngredients.value = []
            setTimeout(() => {
                displayIngredients.value = shuffled.slice(0, 7)
            }, 50);
        }
    }

    const toggleRecipe = (recipePath, Id) => {
        currentBigImg.value = recipePath
        activeId.value = Id
    }

    onMounted(() => {
        fetchData()
    })
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
        <router-link to="/search" class="to-search-btn">
            <CircleBtn title="搜尋好料理" />
        </router-link>
        <div class="reset-btn" @click="handleReset">
            <i-material-symbols-Restart-Alt 
            class="reset-icon"
            :class="{ 'is-active': isRotating }"
            :style="{ 'animation-delay': `${index * 0.1}s` }"/>
            <p class="p-p2">隨機產生新食材</p>
        </div>
        
    </div>

    <div class="col-6 col-md-12">
        <router-link :to="`/workspace/recipe-detail/${activeId}`" class="recipe-link">
            <div class="find-recipe-img">
                <transition name="fade" mode="out-in">
                    <img 
                    :key="currentBigImg"
                    :src="$parsePublicFile(currentBigImg)" alt="菜餚">
                </transition>
            </div>
        </router-link>
        
    </div>
    <div class="col-12 ingredients">
        <transition-group name="list-fade">
            <img 
                v-for="item in displayIngredients" 
                :key="item.id" 
                :src="$parsePublicFile(item.url)" 
                :alt="item.recipe_title"
                @click="toggleRecipe($parsePublicFile(item.recipeImg), item.id)"
                :class="['ingredient-item', { 'active': item.id === activeId }]"
            >
        </transition-group>
        
    </div>
</template>
<style lang="scss" scoped>
    .find-recipe-info{
        display: flex;
        justify-content: center;
        align-items: start;
        flex-direction: column;
        position: relative;
        .find-recipe-title{
            color: $primary-color-700;
            margin-bottom: 20px;
        }
        .find-recipe-text{
            margin-bottom: 30px;
        }
        .reset-btn{
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            transition: .3s ease;
            position: absolute;
            bottom: 0px;
            right: 20px;
            &:hover{
                cursor: pointer;
                color: $primary-color-700;
                
            }
            .reset-icon.is-active{
                animation: resetactive 1s ease-in-out;
            }
        }
    }
    @keyframes resetactive{
        0% {
            transform: rotate(0deg);
        }
        100%{
            transform: rotate(-360deg);
        }
    }
    .find-recipe-img{
        border-radius: $radius-base;
        height: 450px;
        overflow: hidden;
        transition: opacity 0.3s ease-in-out;
        position: relative;
        img{
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
            position: absolute;
            top: 0;
            left: 0;
        }
    }
    .ingredients{
        display: flex;
        margin-top: 30px;
        justify-content: space-around;
        overflow-x: scroll;
        white-space: nowrap;
        height: 80px;

        &::-webkit-scrollbar {
            display: none;
        }
        -ms-overflow-style: none;
        scrollbar-width: none;

        .ingredient-item {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            cursor: pointer;
            transition: all 0.3s ease;
            padding: 5px;

            &:hover {
                transform: translateY(-5px) scale(1.1);
            }
        }
    }
    @media screen and (max-width: 1024px){
        .find-recipe-img{
            height: 300px;
        }
    }
    @media screen and (max-width: 810px){
        .reset-btn{
            bottom:-30px;
        }
        .to-search-btn{
            margin-bottom: 30px;
        }
        .find-recipe-img{
            margin-top: 10px;
        }
        .ingredients{
            height: 60px;
            .ingredient-item {
                width: 60px;
                height: 60px;
            }
        }
        
    }
    /* 1. 定義您的 Keyframes */
@keyframes fadeInUp {
    0%{
        opacity: 0;
        transform: translateY(0);
    }
    50% {
        opacity: 0;
        transform: translateY(20px);
    }
    100% {
        opacity: 1;
        transform: translateY(0);
    }
}

    /* 2. 套用到 Vue Transition Group */
    .list-fade-enter-active {
        animation: fadeInUp 0.5s ease-out forwards;
    }
    /* 離開時的動畫（可以選用簡單的消失） */
    .list-fade-leave-active {
        position: absolute;
    }
    .list-fade-leave-to {
        opacity: 0;
    }
</style>