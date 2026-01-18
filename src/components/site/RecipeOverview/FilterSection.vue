<script setup>
import { ref, computed } from 'vue';
import BaseTag from '@/components/common/BaseTag.vue';
import BaseBtn from '@/components/common/BaseBtn.vue';

const props = defineProps({modelValue: Object});
const emit = defineEmits(['update:modelValue']);

const filters = ref([
    {
        "id": "time",
        "label": "製作時長",
        "options": ["全部", "15分鐘內", "15-30分鐘", "30-60分鐘", "1小時以上", "慢火長燉"]
    },
    {
        "id": "difficulty",
        "label": "難度分級",
        "options": ["全部", "廚藝新手", "基礎實作", "進階挑戰", "職人等級"]
    },
    {
        "id": "mealPortions",
        "label": "用餐份數",
        "options": ["全部", "1人獨享", "2人世界", "3-4人家庭", "6人以上聚會"]
    },
    {
        "id": "kcal",
        "label": "熱量估算",
        "options": ["全部", "150kcal(輕食)", "150-300kcal(均衡)", "300kcal以上(豐盛)"]
    }
]);

const handleSelect = (filterId, option) => {
    const newValue = { ...props.modelValue, [filterId]: option };
    emit('update:modelValue', newValue);
};
</script>
<template>
    <div class="col-9 col-lg-12">
        <div class="filter-content">
            <div v-for="item in filters" :key="item.id" class="filter-options">
                <span>{{ item.label }}</span>
                <div class="filter-tag">
                    <BaseTag 
                        v-for="opt in item.options" 
                        :key="opt" 
                        :text="opt" 
                        :show-icon="false"
                        :variant="props.modelValue[item.id] === opt ? 'primary' : 'action'" 
                        @click="handleSelect(item.id, opt)"
                    ></BaseTag>
                </div>
                
            </div>
        </div>
    </div>
    
    
    <div class="col-3 col-lg-12">
        <div class="inspiration-kitchen-cta">
            <h3 class="zh-h3-bold">用食材找到好料理</h3>
            <BaseBtn title="前往靈感廚房" height="50" variant="outline"/>
        </div>
    </div>
    
</template>
<style lang="scss" scoped>
        .filter-content{
            background-color: $neutral-color-100;
            padding: 40px;
            display: flex;
            flex-direction: column;
            gap: 24px;
            border-radius: $radius-base;
        }
        .filter-options{
            display: flex;
            gap: 10px;
            align-items: center;
            flex-wrap: nowrap;
            overflow-x: scroll; 
            white-space: nowrap;
            
            &::-webkit-scrollbar {
                display: none; /* Chrome, Safari, Opera */
            }
            -ms-overflow-style: none;  /* IE and Edge */
            scrollbar-width: none;
            .filter-tag{
                display: flex;
                gap: 10px;
            }
        }
        .inspiration-kitchen-cta{
            background-color: $primary-color-100;
            padding: 40px;
            height: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
            text-align: center;
            border-radius: $radius-base;
            .zh-h3-bold{
                margin-bottom: 20px;
            }
        }
        @media screen and (max-width: 1024px){
            .filter-content{
                padding: 30px;
                gap: 16px;
            }
            .inspiration-kitchen-cta{
                margin-top: 20px;
                
            }
        }

</style>