<script setup>
const props = defineProps({
  steps: {
    type: Array,
    required: true,
    default: () => [] // 如果父層沒給資料，預設空陣列
  }
});
</script>

<template>
<div class="step-container space-y-8 mt-12">
    <h3 class="text-2xl font-bold text-gray-800 mb-8 flex items-center gap-2">
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="text-emerald-600"><path d="M9 11l3 3L22 4"></path><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path></svg>
    烹飪流程指南
    </h3>

    <div 
    v-for="(step, index) in steps" 
    :key="index" 
    class="step-card group flex flex-col md:flex-row gap-8 p-4 rounded-[2.5rem] border border-gray-100 bg-white hover:shadow-xl hover:shadow-emerald-900/5 transition-all duration-500"
    >
    <div class="step-image w-full md:w-56 h-40 flex-shrink-0 rounded-[2rem] overflow-hidden shadow-sm">
        <img 
        :src="step.image || 'https://via.placeholder.com/400x300?text=Recimo'" 
        :alt="step.title" 
        class="w-full h-full object-cover group-hover:scale-110 transition duration-700"
        />
    </div>

    <div class="step-content flex-1 py-2">
        <div class="step-title-group flex items-center gap-3 mb-3">
        <div class="flex items-baseline gap-1 bg-emerald-50 px-3 py-1 rounded-lg">
            <span class="text-[10px] font-black text-emerald-600 uppercase tracking-tighter">step</span>
            <span class="text-lg font-black text-emerald-700 leading-none">{{ index + 1 }}</span>
        </div>
        <h5 class="step-title text-xl font-bold text-gray-800">{{ step.title }}</h5>
        </div>

        <p class="step-desc text-gray-500 leading-loose text-sm md:text-base">
        {{ step.content }}
        </p>
    </div>
    </div>
</div>
</template>

<style scoped>
/* 增加平滑進場動畫 */
.step-card {
animation: slideUp 0.6s ease-out forwards;
opacity: 0;
}

@keyframes slideUp {
from { opacity: 0; transform: translateY(20px); }
to { opacity: 1; transform: translateY(0); }
}

/* 延遲每個卡片的動畫時間 */
.step-card:nth-child(1) { animation-delay: 0.1s; }
.step-card:nth-child(2) { animation-delay: 0.2s; }
.step-card:nth-child(3) { animation-delay: 0.3s; }
</style>