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
        :slidesPerView="1.4"
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
        <swiper-slide v-for="n in 3" :key="n">
            <div class="card-mockup">
                <h3 style="color: #333">Slide {{ n }}</h3>
                <div class="img"></div>
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
    }
    .swiper-slide{
        transition: transform 0.6s cubic-bezier(.25, 1, 0, 1);
        border: 1px solid #333;
        padding: 20px;
        border-radius: $radius-base;
        &.swiper-slide-next{
            opacity: .5;
            transform: scale(0.9);
        }
    }
    @media screen and (max-width: 1200px){
        .my-swiper{
            height:480px;
        }
    }
    @media screen and (max-width: 810px){
        .my-swiper{
            height:50vh;
            width: 100%;
        }
    }
</style>