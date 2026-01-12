<script setup>
const props = defineProps(['ingredients', 'isEditing']);

const addItem = () => {
props.ingredients.push({ id: 'id' + Date.now(), name: '', amount: '' });
};

const removeItem = (id) => {
const index = props.ingredients.findIndex(i => i.id === id);
if (index !== -1) props.ingredients.splice(index, 1);
};
</script>

<template>
<h2 class="text-xl font-bold mb-6 flex justify-between items-center">
    食材列表 
    <button v-if="isEditing" @click="addItem" class="text-emerald-500 text-sm hover:underline">+ 新增</button>
</h2>
<div class="space-y-4">
    <div v-for="ing in ingredients" :key="ing.id" class="bg-white p-4 rounded-2xl border border-slate-100 shadow-sm relative group">
    <template v-if="isEditing">
        <input type="text" v-model="ing.name" class="font-bold border-b border-slate-100 w-full focus:border-emerald-500 outline-none mb-1 text-sm" placeholder="食材名稱">
        <input type="text" v-model="ing.amount" class="text-xs text-slate-400 border-b border-slate-100 w-full focus:border-emerald-500 outline-none text-xs" placeholder="份量">
        <button @click="removeItem(ing.id)" class="absolute top-4 right-4 text-red-300 hover:text-red-500 transition">✕</button>
    </template>
    <template v-else>
        <div class="font-bold">{{ ing.name || '(未命名)' }}</div>
        <div class="text-xs text-slate-400">{{ ing.amount }}</div>
    </template>
    </div>
</div>
</template>