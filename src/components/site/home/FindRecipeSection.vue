<script setup>
    import CircleBtn from '@/components/common/CircleBtn.vue'

    import { ref, onMounted } from 'vue'

    const recipesData = ref([])
    const currentBigImg = ref([])
    const displayIngredients = ref([])

    const activeId = ref(null)

    const fetchData = async () => {
        try {
            const response = await fetch('/data/others/remove-bg-ingredients.json') 
            const data = await response.json()
            
            recipesData.value = data
            initRandomIngredients()

            if (displayIngredients.value.length > 0) {
                const firstItem = displayIngredients.value[0]
                toggleRecipe(firstItem.recipe_image_url, firstItem.id)
            }
        } catch (error) {
            console.error('抓取資料失敗:', error)
        }
    }
    const initRandomIngredients = () => {
        if (recipesData.value.length > 0) {
            const shuffled = [...recipesData.value].sort(() => 0.5 - Math.random())
            displayIngredients.value = shuffled.slice(0, 7)
        }
    }

    const toggleRecipe = (recipePath, id) => {
        currentBigImg.value = recipePath
        activeId.value = id
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
        <router-link to="/search">
            <CircleBtn title="搜尋好料理" />
        </router-link>
        
    </div>

    <div class="col-6 col-md-12">
        <div class="find-recipe-img">
            <img :src="$parsePublicFile(currentBigImg)" alt="菜餚">
        </div>
    </div>
    <div class="col-12 ingredients">
        <img 
            v-for="item in displayIngredients" 
            :key="item.id" 
            :src="$parsePublicFile(item.url)" 
            :alt="item.recipe_name"
            @click="toggleRecipe(item.recipe_image_url, item.id)"
            :class="['ingredient-item', { 'active': item.id === activeId }]"
        >
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
            transition: opacity 0.3s ease-in-out;
            object-fit: cover;
        }
    }
    .ingredients{
        display: flex;
        margin-top: 30px;
        justify-content: space-around;
        overflow-x: scroll;
        white-space: nowrap;

        &::-webkit-scrollbar {
            display: none;
            /* Chrome, Safari, Opera */
        }

        -ms-overflow-style: none;
        /* IE and Edge */
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
    @media screen and (max-width: 810px){
        .find-recipe-img{
            margin-top: 40px;
        }
        .ingredients{
            .ingredient-item {
                width: 50px;
                height: 50px;
            }
        }
        
    }
</style>