<script setup>
import { computed } from "vue";

const props = defineProps({
  servings: { type: Number, default: 1 },
  ingredients: { type: Array, default: () => [] },
});

const emit = defineEmits(["change-servings"]);

const calculateTotal = (fieldName) => {
  if (!props.ingredients.length) return 0;

  const oneServingTotal = props.ingredients.reduce((sum, item) => {
    // 總重 = 數量 * 單個單位重 (g)
    const weight = (item.amount || 0) * (item.unit_weight || 1);
    // 營養素 = (重量 / 100) * 每100g數值
    const nutrientValue = (weight / 100) * (item[fieldName] || 0);
    return sum + nutrientValue;
  }, 0);

  return Math.round(oneServingTotal * props.servings);
};

const totalCalories = computed(() => calculateTotal("calories_per_100g"));
const totalProtein = computed(() => calculateTotal("protein_per_100g"));
const totalFat = computed(() => calculateTotal("fat_per_100g"));
const totalCarbs = computed(() => calculateTotal("carbs_per_100g"));

const updateServings = (delta) => {
  const next = props.servings + delta;
  if (next >= 1 && next <= 20) emit("change-servings", next);
};
</script>

<template>
  <div class="nutrition-card bg-[#F9FAFB] rounded-[2.5rem] p-10 border border-gray-100 shadow-sm">
    <div class="text-center mb-8">
      <h4 class="text-lg font-bold text-gray-800 tracking-tight">營養小清單</h4>
      <span class="text-[10px] text-gray-300 font-normal uppercase tracking-widest block mt-1">Nutrition List</span>
    </div>

    <div class="flex items-center justify-between bg-white border border-gray-200 rounded-2xl p-2 mb-10 shadow-inner">
      <button @click="updateServings(-1)" :disabled="servings <= 1" class="w-10 h-10 flex items-center justify-center bg-emerald-800 text-white rounded-xl shadow-md hover:bg-emerald-900 transition-colors disabled:opacity-30">
        <span class="text-xl font-bold">−</span>
      </button>
      <span class="font-bold text-gray-700 text-sm">{{ servings }} 人份</span>
      <button @click="updateServings(1)" :disabled="servings >= 20" class="w-10 h-10 flex items-center justify-center bg-emerald-800 text-white rounded-xl shadow-md hover:bg-emerald-900 transition-colors">
        <span class="text-xl font-bold">+</span>
      </button>
    </div>

    <div class="text-center mb-10">
      <span class="text-[10px] text-gray-400 block uppercase tracking-[0.2em] mb-2 font-bold">Total Energy</span>
      <div class="flex items-baseline justify-center gap-1">
        <span class="text-5xl font-black text-gray-800">{{ totalCalories }}</span>
        <span class="text-sm text-gray-400 font-bold uppercase tracking-widest">kcal</span>
      </div>
    </div>

    <div class="grid grid-cols-3 gap-3">
      <div class="bg-white p-4 rounded-[2rem] text-center shadow-sm border border-white">
        <span class="block text-xl font-black text-gray-800">{{ totalProtein }}g</span>
        <span class="text-[9px] text-gray-400 font-bold uppercase">蛋白質</span>
      </div>
      <div class="bg-white p-4 rounded-[2rem] text-center shadow-sm border border-white">
        <span class="block text-xl font-black text-gray-800">{{ totalFat }}g</span>
        <span class="text-[9px] text-gray-400 font-bold uppercase">脂質</span>
      </div>
      <div class="bg-white p-4 rounded-[2rem] text-center shadow-sm border border-white">
        <span class="block text-xl font-black text-gray-800">{{ totalCarbs }}g</span>
        <span class="text-[9px] text-gray-400 font-bold uppercase">碳水</span>
      </div>
    </div>
  </div>
</template>