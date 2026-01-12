<script setup>
import { computed } from "vue";

const props = defineProps({
  info: {
    type: Object,
    default: () => ({
      title: "雲朵般口感 - 經典日式舒芙蕾鬆餅",
      image: "https://images.unsplash.com/photo-1598214813591-203900a9a56e?auto=format&fit=crop&w=1200&q=80",
      time: "30 分鐘",
      difficulty: 2,
      description: "日式舒芙蕾鬆餅以其驚人的空氣感與雲朵般的綿密口感聞名。不同於傳統美式鬆餅的紮實，它透過細緻打發蛋白創造出極致蓬鬆的層次，入口即化並散發清淡蛋香。這款甜點不僅具備視覺上的療癒動感，更是追求輕盈食感的下午茶首選。"
    })
  }
});

// 星星評分邏輯
const starArray = computed(() => {
  const score = props.info.difficulty || 0;
  return Array.from({ length: 5 }, (_, i) => (i < score ? "★" : "☆"));
});
</script>

<template>
<section class="recipe-intro">
    <div class="flex justify-between items-end mb-6">
    <h2 class="text-3xl md:text-4xl font-bold text-gray-800 tracking-tight flex items-center gap-3">
        <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-gray-700"><path d="M12 21s-8-4.5-8-11.8A8 8 0 0 1 12 2a8 8 0 0 1 8 7.2c0 7.3-8 11.8-8 11.8z"/><circle cx="12" cy="9" r="3"/></svg>
        {{ info.title }}
    </h2>
    <div class="flex gap-4 text-gray-300">
        <button class="hover:text-emerald-600 transition-colors">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
        </button>
        <button class="hover:text-emerald-600 transition-colors">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="18" cy="5" r="3"></circle><circle cx="6" cy="12" r="3"></circle><circle cx="18" cy="19" r="3"></circle><line x1="8.59" y1="13.51" x2="15.42" y2="17.49"></line><line x1="15.41" y1="6.51" x2="8.59" y2="10.49"></line></svg>
        </button>
    </div>
    </div>

    <div class="relative rounded-[2.5rem] overflow-hidden shadow-2xl mb-8 group">
    <img 
        :src="info.image" 
        :alt="info.title" 
        class="w-full h-[400px] md:h-[500px] object-cover transition duration-1000 group-hover:scale-105" 
    />
    
    <button class="absolute top-8 left-8 bg-black/10 backdrop-blur-md border border-white/20 text-white px-5 py-2 rounded-full text-xs font-medium flex items-center gap-2 hover:bg-black/30 transition-all">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"></path></svg>
        加收藏
    </button>
    </div>

    <div class="flex flex-col md:flex-row md:items-center gap-6 md:gap-8 mb-10">
    <div class="flex items-center gap-6 text-xs text-gray-500 font-medium">
        <div class="flex items-center gap-2">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-gray-400"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
        製作時間：{{ info.time }}
        </div>
        
        <div class="flex items-center gap-2">
        <span>難易度：</span>
        <div class="flex text-emerald-500 text-sm tracking-tighter">
            <span v-for="(char, index) in starArray" :key="index">
            {{ char === '★' ? '★' : '☆' }}
            </span>
        </div>
        </div>
    </div>

    <button class="md:ml-auto bg-emerald-700 text-white px-10 py-3 rounded-2xl font-bold hover:bg-emerald-800 transition-all shadow-lg shadow-emerald-700/20 active:scale-95">
        開始烹飪
    </button>
    </div>

    <div class="description-content">
    <p class="text-gray-500 leading-loose text-base md:text-lg italic border-l-4 border-emerald-500/30 pl-6 py-1">
        " {{ info.description }} "
    </p>
    </div>
</section>
</template>

<style scoped>
/* 讓星星在不同瀏覽器渲染下對齊 */
.text-emerald-500 {
font-family: serif;
}
</style>