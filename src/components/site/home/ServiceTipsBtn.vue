<script setup>
    import { ref, markRaw } from 'vue';
    import CircleIcon from '@/components/common/CircleIcon.vue';

    import IconNoteStack from '~icons/material-symbols/Note-Stack-outline';
    import IconHandMeal from '~icons/material-symbols/Hand-Meal-outline';
    import IconSkillet from '~icons/material-symbols/Skillet-outline';

    const props = defineProps({
        activeIndex: {
            type: Number,
            default: 0
        }
    });
    
    const emit = defineEmits(['targetSlide']);

    const tips = ref([
        { icon: markRaw(IconNoteStack), title:'隨心編寫筆記' , text: '在實作中隨手記下，同步筆記美味步驟永不遺失' },
        { icon: markRaw(IconHandMeal), title:'專屬備餐計畫' , text: '告別選擇困難，快速生成您的一周專屬菜單' },
        { icon: markRaw(IconSkillet), title:'沉浸式烹飪 ' , text: '步驟引導專為實作設計，就像有位助教在旁引導' }
    ]);

    const handleBtnClick = (index) => {
        emit('targetSlide', index);
    }
</script>

<template>
    <div 
    v-for="(item, index) in tips" 
    :key="index" 
    class="tips-btn"
    :class="{ 'is-active': activeIndex === index }"
    @click="handleBtnClick(index)"
    >
        <CircleIcon size="sm" class="circle-icon">
            <component :is="item.icon" />
        </CircleIcon>
        <div class="tips-text">
            <h4 class="zh-h4" v-html="item.title"></h4>
            <h5 class="zh-h5" v-html="item.title"></h5>
            <p class="p-p1" v-html="item.text"></p>
        </div>
        <div class="dot"></div>
    </div>
</template>

<style lang="scss" scoped>
    .tips-btn{
        display: flex;
        margin-bottom: 12px;
        padding:20px 50px;
        border-radius: $radius-base;
        transition: background-color .5s ease;
        position: relative;
        transition: all 0.3s ease;
        &:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba($neutral-color-black, 0.08);
            border-color: $primary-color-400;
        }
        .tips-text{
            margin-left: 20px;
            .zh-h4{
                color: $primary-color-700;
                margin-bottom: 6px;
            }
            .zh-h5{
                display: none;
            }
        }
        .dot{
            width: 14px;
            height: 14px;
            border-radius: 50%;
            background-color: $primary-color-400;
            position: absolute;
            right: 20px;
            top: 20px;
            opacity: 0;
            transition: opacity .3s ease, trensform .3s ease;
        }
        &:hover, &.is-active{
            background-color: $primary-color-100;
            border: 1px solid $primary-color-400;
            box-shadow: 0 10px 20px rgba($neutral-color-black, 0.08);
            cursor: pointer;
            .dot{
                opacity: 1;
                transform: scale(1);
            }
        }
    }
    @media screen and (max-width: 1200px){
        .tips-btn{
            padding:36px 30px;
        }
    }
    @media screen and (max-width: 1024px){
        .tips-btn{
            flex-direction: column;
            align-items: center;
            text-align: center;
            .tips-text{
                margin-left: 0;
            }
            .dot{
                right: 10px;
                top: 10px;
            }
        }
        .circle-icon{
            margin-bottom: 16px;
        }
    }
    @media screen and (max-width: 810px){
        .tips-btn{
            display: flex;
            flex-grow: 1;
            padding:18px 12px;
            .tips-text{
                .p-p1{
                    display: none;
                }
                .zh-h4{
                    display: none;
                }
                .zh-h5{
                    display: block;
                    color: $primary-color-700;
                }
            }
            .circle-icon{
                margin-bottom: 10px;
            }
        }

    }
</style>