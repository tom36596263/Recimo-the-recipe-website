<script setup>
import { ref, computed, onMounted } from 'vue';
import ProductCard from '@/components/mall/ProductCard.vue';

// ==========================================
// 引用swiper
// ==========================================
import { Swiper, SwiperSlide } from 'swiper/vue';
import 'swiper/css';
// 根據原本 SCSS 的斷點數值來設定
const swiperBreakpoints = {
    390: {
        slidesPerView: 1.5,
        spaceBetween: 10
    },
    810: {
        slidesPerView: 2.2,
        spaceBetween: 15
    },
    1200: {
        slidesPerView: 2.8,
        spaceBetween: 20
    }
};

// ==========================================
// vue上課教：以後部屬比較不會有問題(資料放public的話)
// ==========================================
const baseURL = import.meta.env.BASE_URL

// ==========================================
// axios：先把商品卡片引入json檔
// ==========================================
import axios from 'axios'
const productList = ref([])
const isLoading = ref(true); // 新增讀取狀態
const fetchData = async () => {
    isLoading.value = true;
    try {
        // 修正路徑：務必加上 baseURL
        const response = await axios.get(`${baseURL}data/mall/products.json`);
        productList.value = response.data;
    } catch (error) {
        console.error("讀取 JSON 失敗", error);
    } finally {
        isLoading.value = false;
    }
};

// ==========================================
// 推薦商品(只取4筆)
// ==========================================
const randomProducts = computed(() => {
    if (productList.value.length === 0) return [];

    // 淺拷貝陣列進行洗牌
    const list = [...productList.value];
    for (let i = list.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [list[i], list[j]] = [list[j], list[i]];
    }
    return list.slice(0, 4);
});

onMounted(() => {
    fetchData();
});

</script>
<template>
    <section class="product-recommendations">
        <h2 class="zh-h2">推薦商品</h2>
        <div class="container">
            <div class="row">
                <div v-for="product in randomProducts" :key="product.product_id" class="col-3  pc-grid">
                    <ProductCard :item="product" />
                    <!--「把『當下的這份資料』塞進『卡片預留的插槽』裡。」item是在 ProductCard.vue 裡面透過 defineProps 定義的名字。它就像是卡片上的一個「專用收件口」。 product是在 ProductRmd.vue 裡面 v-for="product in randomProducts" 定義的那個變數。它代表「目前這一輪迴圈抓到的那一筆商品資料」。-->
                </div>
                <!-- ==========================================
                    swiper圖片
                ========================================= -->
                <div class="mobile-swiper">
                    <swiper :slides-per-view="1.2" :space-between="10" :breakpoints="swiperBreakpoints">
                        <swiper-slide v-for="product in randomProducts" :key="product.product_id">
                            <ProductCard :item="product" />
                        </swiper-slide>
                    </swiper>
                </div>
            </div>
        </div>
    </section>
</template>
<style lang="scss" scoped>
@import "@/assets/scss/layouts/_grid.scss";

.product-recommendations {
    background-image: url(@/assets/images/mall/Productrmd-bg.jpg);
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 80px 0;
}

.product-recommendations h2 {
    text-align: center;
    margin-bottom: 40px;
    color: $neutral-color-white;
}

.mobile-swiper {
    display: none;
}

@media screen and (max-width: map-get($breakpoints, "lg")) {
    .product-recommendations {
        padding: 40px 20px;
    }

    .pc-grid {
        display: none;
    }

    .mobile-swiper {
        display: block; // 顯示 Swiper
        width: 100%;
    }

    // 強制調整 Swiper 裡面的卡片高度一致
    .swiper-slide {
        height: auto;
        display: flex;
    }
}

@media screen and (max-width: map-get($breakpoints, "md")) {
    .product-recommendations {
        padding: 30px 15px;
    }
}

@media screen and (max-width: map-get($breakpoints, "sm")) {
    .product-recommendations {
        padding: 20px 0;
    }
}
</style>