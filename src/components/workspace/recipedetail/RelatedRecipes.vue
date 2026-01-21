<script setup>
import { ref, onMounted, watch, nextTick } from 'vue';
import { publicApi } from '@/utils/publicApi';
import RecipeCardSm from '@/components/common/RecipeCardSm.vue';

// Swiper 相關
import { Swiper, SwiperSlide } from 'swiper/vue';
import { Navigation, Pagination } from 'swiper/modules';
import 'swiper/css';
import 'swiper/css/navigation';
import 'swiper/css/pagination';

const props = defineProps({
    currentId: { type: [String, Number], required: true }
});

const modules = [Navigation, Pagination];
const relatedList = ref([]);
const isLoading = ref(true);
const isReady = ref(false);

const fetchRelated = async () => {
    isLoading.value = true;
    isReady.value = false;

    try {
        const res = await publicApi.get('data/recipe/recipes.json');

        const cleanedData = res.data.map(r => {
            // 1. 處理圖片路徑：確保開頭有 /
            let rawImg = r.recipe_image_url || r.recipe_cover_image || '';
            let finalImg = '';

            if (rawImg) {
                // 如果已經是絕對路徑或 base64 就不用動，否則補上 /
                finalImg = (rawImg.startsWith('http') || rawImg.startsWith('/') || rawImg.startsWith('data:'))
                    ? rawImg
                    : `/${rawImg}`;
            }

            return {
                ...r,
                id: r.recipe_id,
                recipe_name: r.recipe_title || '美味食譜',
                // 2. 這裡要確保 RecipeCardSm 吃的是 image_url 還是 cover_image？
                // 建議兩個都給，增加相容性
                image_url: finalImg,
                cover_image: finalImg,
                author: {
                    name: r.author_name || '作者',
                    likes: r.likes || 0
                }
            };
        });

        relatedList.value = cleanedData
            .filter(r => Number(r.id) !== Number(props.currentId))
            .sort(() => 0.5 - Math.random())
            .slice(0, 8);

        await nextTick();
        isReady.value = true;

    } catch (err) {
        console.error('資料抓取失敗:', err);
    } finally {
        isLoading.value = false;
    }
};

onMounted(fetchRelated);
watch(() => props.currentId, fetchRelated);

// 調整斷點：讓卡片更緊湊，間距縮小
const swiperBreakpoints = {
    320: { slidesPerView: 2, spaceBetween: 10 },
    768: { slidesPerView: 3, spaceBetween: 12 },
    1200: { slidesPerView: 5, spaceBetween: 14 }
};
</script>

<template>
    <div class="related-recipes-section">
        <h3 class="zh-h3 section-title">其他食譜推薦</h3>

        <div v-if="isReady && relatedList.length > 0" class="swiper-container">
            <swiper :modules="modules" :breakpoints="swiperBreakpoints" navigation :pagination="{ clickable: true }"
                class="recipe-swiper">
                <swiper-slide v-for="item in relatedList" :key="item.id">
                    <RecipeCardSm :recipe="item" />
                </swiper-slide>
            </swiper>
        </div>

        <div v-else-if="isLoading" class="msg-box">找尋相似美味中...</div>
        <div v-else class="msg-box">目前沒有相關推薦</div>
    </div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.related-recipes-section {
    width: 100%;
    padding: 10px 0 20px 0;
    margin: 20px 0 40px 0;
    min-width: 0;
    overflow: hidden;
    position: relative;
    background-color: transparent;
}

.section-title {
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    margin-bottom: 40px; 
    color: $neutral-color-800;
    white-space: nowrap; 


    &::before,
    &::after {
        content: "";
        flex: 1; 
        height: 1px; 
        background-color: $neutral-color-400; 
        margin: 0 20px; 
    }

    
    max-width: 1000px;
    margin-left: auto;
    margin-right: auto;
}

.recipe-swiper {
    padding: 0 0 40px 0;

    :deep(.swiper-slide) {
        display: flex;
        justify-content: center;
        height: auto;
    }


    :deep(.swiper-button-next),
    :deep(.swiper-button-prev) {
        color: $neutral-color-700;
        opacity: 0.1;
        transition: all 0.3s ease;

        &::after {
            font-size: 14px; 
            font-weight: bold;
        }

        &:hover {
            opacity: 0.8;
            color: $primary-color-700;
        }
    }

    :deep(.swiper-button-prev) {
        left: 0px;
    }

    :deep(.swiper-button-next) {
        right: 0px;
    }

    :deep(.swiper-pagination-bullet) {
        width: 5px;
        height: 5px;
        background: $neutral-color-400;
        opacity: 0.3;
    }

    :deep(.swiper-pagination-bullet-active) {
        background: $primary-color-700;
        opacity: 1;
        width: 10px;
        border-radius: 4px;
    }
}

.msg-box {
    text-align: center;
    padding: 50px;
    color: $neutral-color-700;
}
</style>