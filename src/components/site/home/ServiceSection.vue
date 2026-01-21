<script setup>
    import ServiceTipsBtn from '@/components/site/home/ServiceTipsBtn.vue'
    import { ref } from 'vue';
    import { Swiper, SwiperSlide } from 'swiper/vue';
    import { Mousewheel, FreeMode } from 'swiper/modules';

    import 'swiper/css';
    import 'swiper/css/mousewheel';
    import 'swiper/css/free-mode';

    const modules = [Mousewheel, FreeMode];
    const activeIndex = ref(0);
    const swiperInstance = ref(null);

    const services = [
        { title: '我的筆記', fileName: 'home-service-section-1-note.png' },
        { title: '備餐計畫', fileName: 'home-service-section-2-plan.png' },
        { title: '食譜步驟', fileName: 'home-service-section-3-step.png' },
    ];

    const setSwiperRef = (swiper) => {
        swiperInstance.value = swiper;
    };
    const onSlideChange = (swiper) => {
        activeIndex.value = swiper.activeIndex;
    };
    const slideTo = (index) => {
        swiperInstance.value?.slideTo(index);
    };

</script>

<template>
    <div class="col-12 service-title">
        <h2 class="zh-h2">Recimo核心服務</h2>
        <h2 class="en-h3">Recimo Service</h2>
    </div>
    <div class="col-12 service-tips-btn">
        <ServiceTipsBtn
        :active-index="activeIndex"
        @target-slide="slideTo"
        />
    </div>
    <div class="col-12">
        <swiper 
        direction="horizontal"
        :breakpoints="{
            '0': {
                slidesPerView: 1
            },
            '811': {
                slidesPerView: 1.4
            }
        }"
        :spaceBetween="10"
        :mousewheel="{
            forceToAxis: true,
            releaseOnEdges: true
        }"
        :speed="800"
        :modules="modules"
        class="my-swiper"
        @slideChange="onSlideChange"
        @swiper="setSwiperRef"
        >
        <swiper-slide v-for="(item, index) in services" :key="index">
            
            <div class="img-container">
                <img 
                    :src="$parsePublicFile(`img/site/${item.fileName}`)" 
                    :alt="item.title" 
                    class="service-img" 
                />
            </div>
        </swiper-slide>
    </swiper>
    </div>
</template>

<style lang="scss" scoped>
    .service-title{
        margin: 20px 0 50px 0;
        color: $primary-color-700;
        text-align: center;
        .zh-h2{
            margin-bottom: 10px;
        }
    }
    .service-tips-btn{
        display: flex;
        flex-direction: row;
        gap: 10px;
    }
    .my-swiper{
        height:500px;
        width: 100%;
        overflow: hidden;
        .img-container{
            width: 100%;
            height: 100%;
            .service-img{
                width: 100%;
                object-fit: cover;
            }
        }
        .swiper-slide{
            transition: transform 0.6s cubic-bezier(.25, 1, 0, 1);
            border: 1px solid $neutral-color-400;
            border-radius: $radius-base;
            overflow: hidden;
            &.swiper-slide-next{
                opacity: .5;
                transform: scale(0.9);
            }
        }
    }
    
    @media screen and (max-width: 1200px){
        .my-swiper{
            height:480px;
        }
    }
    @media screen and (max-width: 810px){
        .my-swiper{
            height:40vh;
            width: 100%;
        }
    }
</style>