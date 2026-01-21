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
            let rawImg = r.recipe_image_url || r.recipe_cover_image || '';
            let finalImg = '';

            if (rawImg) {
                finalImg = (rawImg.startsWith('http') || rawImg.startsWith('/') || rawImg.startsWith('data:'))
                    ? rawImg
                    : `/${rawImg}`;
            }

            return {
                ...r,
                id: r.recipe_id,
                recipe_name: r.recipe_title || '美味食譜',
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
    overflow: hidden; // 保持外層整潔
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
    // ✨ 修正裁切：留出頂部空間給 hover 放大使用
    padding: 30px 20px 50px 20px;
    margin: -30px -20px 0 -20px;
    overflow: visible !important;

    :deep(.swiper-slide) {
        display: flex;
        justify-content: center;
        height: auto;
        overflow: visible !important;
        transition: z-index 0.3s;

        &:hover {
            z-index: 10;
        }
    }

    // ✨ 修正按鈕顏色為綠色 ($primary-color-700)
    :deep(.swiper-button-next),
    :deep(.swiper-button-prev) {
        color: $primary-color-700 !important;
        opacity: 0.3;
        transition: all 0.3s ease;

        &::after {
            font-size: 16px;
            font-weight: bold;
        }

        &:hover {
            opacity: 1;
            color: $primary-color-700 !important;
        }
    }

    :deep(.swiper-button-prev) {
        left: 10px;
    }

    :deep(.swiper-button-next) {
        right: 10px;
    }

    // ✨ 修正分頁點顏色
    :deep(.swiper-pagination-bullet) {
        width: 5px;
        height: 5px;
        background: $neutral-color-400;
        opacity: 0.3;
    }

    :deep(.swiper-pagination-bullet-active) {
        background: $primary-color-700 !important;
        opacity: 1;
        width: 10px;
        border-radius: 4px;
    }
}

// ✨ 強制修正卡片內部箭頭顏色
:deep(.recipe-card-sm) {
    .arrow-icon {
        color: $primary-color-700 !important;
    }
}

.msg-box {
    text-align: center;
    padding: 50px;
    color: $neutral-color-700;
}
</style>