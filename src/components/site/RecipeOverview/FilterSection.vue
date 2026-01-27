<script setup>
import { ref, computed, onMounted } from 'vue';
import BaseTag from '@/components/common/BaseTag.vue';
import BaseBtn from '@/components/common/BaseBtn.vue';
import { useRouter, useRoute } from 'vue-router';

const props = defineProps({ modelValue: Object });
const emit = defineEmits([
    'update:modelValue',
    'open-kitchen'
]);

const router = useRouter();
const route = useRoute();

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

// 在關於Recimo裡開起靈感小廚房
const checkRoute = () => {
    if (route.query.action === 'open-kitchen') {
        emit('open-kitchen')
    }
}

onMounted(() => {
    checkRoute()
})

// 關閉靈感小廚房時，清除 Router Query 的函式
const clearQuery = () => {
    // 檢查目前是否有 query，避免重複執行
    if (Object.keys(route.query).length > 0) {
        router.replace({
            path: route.path, // 保持在目前的頁面路徑
            query: {}         // 將 query 設為空物件，清空參數
        });
    }
};

const handleCloseModal = () => {
    // 1. 執行原本關閉燈箱的邏輯 (例如 isShow.value = false)
    // 2. 呼叫清空 URL
    clearQuery();
};

</script>
<template>
    <div class="col-9 col-lg-12">
        <div class="filter-content">
            <div v-for="item in filters" :key="item.id" class="filter-options">
                <span>{{ item.label }}</span>
                <div class="filter-tag">
                    <BaseTag v-for="opt in item.options" :key="opt" :text="opt" :show-icon="false"
                        :variant="props.modelValue[item.id] === opt ? 'primary' : 'action'"
                        @click="handleSelect(item.id, opt)"></BaseTag>
                </div>

            </div>
        </div>
    </div>
    <div class="col-3 col-lg-12">
        <div class="inspiration-kitchen-cta">
            <h3 class="zh-h3-bold">食材找到好料理</h3>
            <p class="p-p1">用現有食材發現新的可能</p>
            <BaseBtn title="前往靈感廚房" height="50" variant="outline" @click="emit('open-kitchen')" />
            <img :src="$parsePublicFile('img/remove-bg-ingredients/1.png')" alt="番茄" class="ingredient1">
            <img :src="$parsePublicFile('img/remove-bg-ingredients/15.png')" alt="檸檬" class="ingredient15">
        </div>
    </div>
    <InspirationKitchenModal v-if="isShow" @close="handleCloseModal" />
</template>
<style lang="scss" scoped>
.filter-content {
    background-color: $neutral-color-100;
    padding: 40px;
    display: flex;
    flex-direction: column;
    gap: 24px;
    border-radius: $radius-base;
}

.filter-options {
    display: flex;
    gap: 10px;
    align-items: center;
    flex-wrap: nowrap;
    overflow-x: scroll;
    white-space: nowrap;

    &::-webkit-scrollbar {
        display: none;
    }

    -ms-overflow-style: none;
    scrollbar-width: none;

    .filter-tag {
        display: flex;
        gap: 10px;
    }
}

.inspiration-kitchen-cta {
    background-color: $primary-color-100;
    padding: 40px 20px;
    height: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: column;
    text-align: center;
    border-radius: $radius-base;
    position: relative;

    .p-p1 {
        margin-bottom: 20px;
    }

    .ingredient1 {
        position: absolute;
        bottom: -50px;
        right: 10px;
        width: 80px;
        animation: floating 3s ease-in-out infinite;
    }

    .ingredient15 {
        position: absolute;
        top: 40px;
        left: -30px;
        width: 60px;
        animation: floating 4s ease-in-out infinite;
        animation-delay: 0.5s;
    }
}

@keyframes floating {
    0% {
        transform: translateY(0px);
    }

    50% {
        transform: translateY(-20px);
        /* 向上移動 15 像素 */
    }

    100% {
        transform: translateY(0px);
    }
}

@media screen and (max-width: 1024px) {
    .filter-content {
        padding: 30px;
        gap: 16px;
    }

    .inspiration-kitchen-cta {
        margin-top: 20px;
        // display: none;
    }
}
@media screen and (max-width: 810px){
    .inspiration-kitchen-cta {
        padding: 20px 0;
        .p-p1 {
            margin-bottom: 10px;
        }
        .ingredient1 {
            bottom: -20px;
            right: 5px;
        }
        .ingredient15 {
            top: 40px;
            left: 10px;
        }
    }
    
}
</style>