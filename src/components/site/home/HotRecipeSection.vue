<script setup>
    import RecipeCardLg from '@/components/common/RecipeCardLg.vue'
    import CircleBtn from '@/components/common/CircleBtn.vue'
import { ref, onMounted } from 'vue';

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
    
    <div class="col-12 hot-recipe-title">
        <h2 class="zh-h2">熱門食譜推薦</h2>
        <h2 class="en-h3">Hot Recipe</h2>
    </div>
    <div v-for="item in recipes" :key="item.recipe_name" class="col-4 col-lg-12">
        <RecipeCardLg :recipe="item"/>
    </div>
    <div class="col-12 more-recipe-btn">
        <CircleBtn title="看更多食譜" href="/recipes"/>
    </div>
    
</template>
<style lang="scss" scoped>
    .hot-recipe-title{
        margin: 20px 0 50px 0;
        color: $primary-color-700;
        text-align: center;
        .zh-h2{
            margin-bottom: 10px;
        }
    }
    .more-recipe-btn{
        display: flex;
        justify-content: center;
        margin-top: 30px;
    }
</style>