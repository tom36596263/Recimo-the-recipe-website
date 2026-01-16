<script setup>
import RecipeCardLg from '@/components/common/RecipeCardLg.vue'
import FilterSection from '@/components/site/RecipeOverview/FilterSection.vue'

import { ref, onMounted, computed } from 'vue';

const allRecipe = ref([])
const currentPage = ref(1)
const pageSize = 6


const recipes = ref([
    {
        "recipe_name": "舒肥雞胸藜麥飯",
        "image_url": "/img/mall/PROD-001_01.jpg",
        "tags": ["低卡健身系列", "低溫舒肥", "超級食物"],
        "nutritional_info": {
            "calories": "250kcal",
            "serving_size": "1",
            "cooking_time": "3分鐘",
        },
        "author": {
        "name": "健康廚房",
        "likes": 850
        }
    },
    {
        "recipe_name": "香煎鮭魚糙米便當",
        "image_url": "/img/mall/PROD-002_01.jpg",
        "tags": ["低卡健身系列", "阿拉斯加鮭魚", "高纖"],
        "nutritional_info": {
            "calories": "580kcal",
            "serving_size": "1",
            "cooking_time": "5分鐘",
        },
        "author": {
        "name": "山海味鮮",
        "likes": 1200
        }
    },
    {
        "recipe_name": "蒜香毛豆嫩豬排",
        "image_url": "/img/mall/PROD-003_01.jpg",
        "tags": ["低卡健身系列", "台灣活菌豬", "職人調味"],
        "nutritional_info": {
            "calories": "318kcal",
            "serving_size": "1",
            "cooking_time": "4分鐘",
        },
        "author": {
        "name": "職人調味",
        "likes": 640
        }
    }
]);

</script>

<template>
    <section class="container filter-content">
        <div class="row">
            
                <FilterSection />
            
            
        </div>
    </section>
    <section class="container recipe-cards-section">
        <div class="row">
            <div v-for="item in recipes" :key="item.recipe_name" class="col-4 col-lg-12">
                <RecipeCardLg :recipe="item" class="recipe-card"/>
            </div>
        </div>
    </section>

    <section class="container">
        <div class="row">
            <div class="pagination">
                <a href="#" class="page-link">1</a>
                <a href="#" class="page-link active">2</a>
                <a href="#" class="page-link">3</a>
                <a href="#" class="page-link">4</a>
            </div>
        </div>

    </section>
    
</template>

<style lang="scss" scoped>
    .filter-content{
        margin-top: 40px;
    }
    .recipe-cards-section{
        margin: 60px auto;
    }
    @media screen and (max-width: 1024px){
        .recipe-card{
            margin-bottom: 20px;

        }
    }
</style>