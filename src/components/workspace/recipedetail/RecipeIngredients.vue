<script setup>
import { computed } from 'vue';

// 1. 定義 props：接收來自父層的份量與食材原始陣列
const props = defineProps({
    servings: {
        type: Number,
        default: 1
    },
    list: {
        type: Array,
        default: () => []
    }
});

// 2. 計算邏輯：根據份量即時換算顯示數值
const computedIngredients = computed(() => {
    return props.list.map(item => {
        return {
            ...item,
            // 確保 amount 是數字再進行運算，並處理可能的小數點
            displayAmount: parseFloat((Number(item.amount) * props.servings).toFixed(1))
        };
    });
});
</script>

<template>
    <div class="ingredients-section px-2">
        <h3 class="text-xl font-bold mb-6 flex items-center gap-3 text-gray-800">
            <span class="w-1.5 h-6 bg-emerald-600 rounded-full"></span>
            所需食材
            <span class="text-[10px] text-gray-300 font-normal uppercase tracking-widest ml-auto">Ingredients</span>
        </h3>

        <div class="space-y-1">
            <div 
                v-for="(item, index) in computedIngredients" 
                :key="index"
                class="group flex flex-col py-4 border-b border-dashed border-gray-200 last:border-0 hover:bg-gray-50/50 transition-colors rounded-xl px-2"
            >
                <div class="flex justify-between items-baseline">
                    <div class="flex flex-col">
                        <span class="font-bold text-gray-700 group-hover:text-emerald-700 transition-colors">
                            {{ item.INGREDIENT_NAME }}
                        </span>
                        <span v-if="item.note" class="text-[11px] text-gray-400 mt-0.5 italic">
                            {{ item.note }}
                        </span>
                    </div>
                    
                    <div class="flex items-baseline gap-1">
                        <span class="text-lg font-mono font-bold text-emerald-700">
                            {{ item.displayAmount }}
                        </span>
                        <span class="text-xs text-gray-400 font-medium">
                            {{ item.unit_name }}
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <div v-if="list.length > 0" class="mt-4 text-[10px] text-gray-300 flex items-center gap-1 justify-center">
            <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
            份量已根據 {{ servings }} 人份自動換算
        </div>
    </div>
</template>

<style scoped>
/* 確保數字在切換時不會造成排版抖動 */
.font-mono {
    font-variant-numeric: tabular-nums;
}

/* 輕微的進場動畫 */
.ingredients-section div {
    animation: slideIn 0.4s ease-out forwards;
}

@keyframes slideIn {
    from { opacity: 0; transform: translateX(5px); }
    to { opacity: 1; transform: translateX(0); }
}
</style>