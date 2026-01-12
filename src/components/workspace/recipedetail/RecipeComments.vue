<script setup>
import { ref } from "vue";

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  }
});

const userInput = ref(""); // 捕捉使用者正在輸入的內容

// 使用者按下 Enter 鍵或點擊送出按鈕
const handleSend = () => { 
  if (!userInput.value.trim()) return;
  alert("送出留言！" + userInput.value); // 未來可介接 API
  userInput.value = "";
};
</script>

<template>
    <div class="comment-container bg-white p-6 md:p-8 border border-gray-100 rounded-[2.5rem] shadow-sm">
        <h3 class="text-xl font-bold text-gray-800 mb-8 flex items-center justify-between">
        美味悄悄話
        <span class="text-[10px] font-normal text-gray-300 uppercase tracking-widest">
            {{ list.length }} 則評論
        </span>
        </h3>

        <div class="relative mb-10 group">
        <div class="flex items-center gap-3 bg-gray-50 rounded-2xl px-5 py-3 border border-transparent focus-within:border-emerald-500/30 focus-within:bg-white focus-within:shadow-sm transition-all duration-300">
            <input 
            v-model="userInput"
            type="text"
            class="w-full bg-transparent text-sm text-gray-700 placeholder:text-gray-300 outline-none"
            placeholder="Share your thoughts or questions..."
            @keyup.enter="handleSend"
            />
            <button 
            @click="handleSend"
            class="text-emerald-600 hover:text-emerald-700 transition-colors p-1"
            title="送出留言"
            >
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="22" y1="2" x2="11" y2="13"></line><polygon points="22 2 15 22 11 13 2 9 22 2"></polygon></svg>
            </button>
        </div>
        </div>

        <div class="recipe-comment-list space-y-8">
        <div 
            v-for="(item, index) in list"
            :key="index"
            class="recipe-comment-item flex gap-4 animate-in fade-in slide-in-from-bottom-2 duration-500"
        >
            <div class="flex-shrink-0">
            <div class="p-0.5 border border-emerald-100 rounded-full">
                <img :src="item.avatar" class="w-10 h-10 rounded-full object-cover shadow-sm" alt="avatar" />
            </div>
            </div>

            <div class="flex-1">
            <div class="flex items-center gap-2 mb-1">
                <span class="text-sm font-bold text-gray-800">{{ item.userName }}</span>
                <span class="text-[10px] text-gray-300 font-medium">
                @{{ item.handle }} · {{ item.time }}
                </span>
            </div>

            <p class="text-sm text-gray-500 leading-relaxed mb-3">
                {{ item.content }}
            </p>

            <div class="flex items-center gap-6">
                <button 
                class="flex items-center gap-1.5 group/like" 
                @click="item.likes++"
                >
                <div class="w-7 h-7 flex items-center justify-center rounded-full bg-gray-50 group-hover/like:bg-emerald-50 transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-gray-400 group-hover/like:text-emerald-600 transition-colors"><path d="M14 9V5a3 3 0 0 0-3-3l-4 9v11h11.28a2 2 0 0 0 2-1.7l1.38-9a2 2 0 0 0-2-2.3z"></path><path d="M7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3"></path></svg>
                </div>
                <span class="text-[11px] font-bold text-gray-400 group-hover/like:text-emerald-700 transition-colors">
                    {{ item.likes }}
                </span>
                </button>

                <button class="text-gray-300 hover:text-red-400 transition-colors" title="檢舉此留言">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                </button>
            </div>
            </div>
        </div>
        </div>
    </div>
    </template>

    <style scoped>
    /* 簡單的列表進場動畫 */
    .animate-in {
    animation: fadeIn 0.5s ease-out;
    }
    @keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
    }
</style>