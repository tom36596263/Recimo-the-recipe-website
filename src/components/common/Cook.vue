<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import SearchBar from '@/components/common/SearchBar.vue';
import CookCard from '@/components/common/CookCard.vue';
import axios from 'axios';

const ingredients = ref([]);

onMounted(() => {
    axios.get('/data/recipe/ingredients.json')
        .then(res => {
            ingredients.value = res.data;
        })
        .catch(err => {
            console.error('讀取 JSON 失敗', err);
        });
});

// --- 標籤設定 ---
const activeTag = ref('蔬菜');
const tags = [
    { text: '蔬菜', width: '62px' },
    { text: '水果', width: '62px' },
    { text: '肉類', width: '62px' },
    { text: '海鮮', width: '62px' },
    { text: '乳蛋豆製品', width: '125px' },
    { text: '米麵主食與烘焙 ', width: '150px' },
    { text: '佐料、醬汁與油品', width: '165px' },
    { text: '乾貨、粉類與堅果', width: '165px' }
];



</script>
<template>
    <div class="container">
        <div class="row">
            <div class="col-7">
                <div class="title">
                    <h3 class="zh-h3 title">靈感廚房</h3>
                </div>
                <div class="cook-wrap">
                    <div class="cook-stage">
                        <div class="lid">
                            <img src="/src/assets/images/cook/lid.png" alt="">
                        </div>
                        <div class="pot">
                            <img src="/src/assets/images/cook/pot.png" alt="">
                        </div>
                        <div class="fire">
                            <img src="/src//assets/images/cook/fire.png" alt="">
                        </div>
                        <div class="fire">
                            <img src="" alt="">
                        </div>
                    </div>
                    <div class="btn">
                        <BaseBtn title="開始烹飪" @click="handleDelete" />
                    </div>
                </div>
            </div>


            <div class="col-5 search-wrap">
                <div class="close">
                    <i class="fa-solid fa-xmark"></i>
                </div>
                <div class="search">
                    <SearchBar placeholder="搜尋食譜" style="width: 270px;" />
                </div>
                <div class="tag">
                    <BaseTag v-for="item in tags" :key="item.text" :text="item.text" :width="item.width"
                        :show-icon="false" :variant="activeTag === item.text ? 'primary' : 'action'"
                        @click="selectTag(item.text)"></BaseTag>
                </div>
                <div class="card-container">
                    <CookCard v-for="item in ingredients" :key="item.ingredient_id" :name="item.ingredient_name"
                        :calories="item.kcal_per_100g" :fat="item.fat_per_100g"
                        :image-src="item.ingredient_image_url" />
                </div>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.container {
    width: 790px;
    height: 487px;
    border: 1px solid red;
}

.row {
    height: 100%;
}

.cook-wrap {
    display: flex;
    flex-direction: column;
    align-items: center;
    position: relative;
}

.title {
    margin-left: 20px;
    margin-top: 10px;
    margin-bottom: 39px;
    color: $primary-color-700;
}

.cook-stage {
    position: relative;
    width: 100%;
    height: 260px; // ⭐ 撐出你圖片需要的高度
    margin-left: 250px;
    margin-top: 40px;
}

.lid {
    position: absolute;
    top: -30px;
    left: 18px;
    width: 150px;
    height: 30px;
}

.pot {
    position: absolute;
    top: 70px;
    left: -80px;
    width: 300px;
    height: 150px;
}

.fire {
    position: absolute;
    top: 130px;
    left: -20px;
    width: 240px;
    height: 80px;
}

.search-wrap {
    background-color: $neutral-color-100;
    display: flex;
    flex-direction: column;
    align-items: center;
    overflow: hidden;
    height: 100%;
}

.close {
    margin-right: -280px;
    margin-top: 10px;
    margin-bottom: -10px;
}

.search {
    margin: 15px 0;
}

.tag {
    display: flex;
    gap: 8px;
    width: 100%;
    overflow-x: auto;
    overflow-y: hidden;
    -webkit-overflow-scrolling: touch;
    padding-bottom: 10px;
    // padding-left: 20px;
    user-select: none; //禁止文字被選取
    -webkit-user-select: none;
    -ms-user-select: none;
    padding: 0 20px 10px 20px;

    >* {
        flex-shrink: 0;
    }

}

.card-container {
    margin-top: 15px;
    width: 100%; // 確保寬度
    flex: 1;
    overflow-y: auto;
    padding-bottom: 20px;
}
</style>