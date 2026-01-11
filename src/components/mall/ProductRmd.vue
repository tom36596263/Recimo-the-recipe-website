<script setup>
import { ref, computed, onMounted } from 'vue';
import card from '@/components/mall/ProductCard.vue';

// ==========================================
// axios：先把商品卡片引入json檔
// ==========================================
import axios from 'axios'
const productList = ref([])
// 快速計算陣列數量結果
const listCount = computed(() => {
    return productList.value.length
})
const noData = computed(() => productList.value.length === 0)
const fetchData = () => {
    axios
        .get('/data/mall/products.json')
        .then((response) => {
            // 檢查點：確保 response.data 真的是那 20 筆陣列
            console.log("抓到的資料：", response.data);
            productList.value = response.data;
        })
        .catch((error) => {
            console.error("讀取 JSON 失敗，請檢查路徑是否正確", error);
        });
};
onMounted(() => {
    fetchData()
})

// ==========================================
// 推薦商品(只取4筆)
// ==========================================
const randomProducts = computed(() => {
    const list = [...productList.value]; // 拿到抓到的資料
    // 洗牌
    for (let i = list.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [list[i], list[j]] = [list[j], list[i]];
    }
    return list.slice(0, 4);
});
</script>
<template>
    <section class="product-recommendations">
        <h2 class="zh-h2">推薦商品</h2>
        <div class="container">
            <div class="row">
                <div v-for="item in randomProducts" :key="item.id" class="col-3 col-md-6">
                    <card :item="item" />
                </div>
            </div>
        </div>
    </section>
</template>
<style lang="scss" scoped>
.product-recommendations {
    background-image: url(@/assets/images/mall/Productrmd-bg.jpg);
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    /* 設定高度或內距，否則背景圖會因為沒內容而看不見 */
    min-height: 630px;
}

.product-recommendations h2 {
    text-align: center;
    margin-bottom: 35px;
}
</style>