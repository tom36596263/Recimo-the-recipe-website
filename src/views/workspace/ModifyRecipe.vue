<script setup>
import { ref } from 'vue';
import IngredientSearchModal from '@/components/workspace/editrecipe/modals/IngredientSearchModal.vue';

const isSearchOpen = ref(false);

// 當使用者從彈窗選了一個食材
const onIngredientSelect = (name) => {
    console.log("選中了食材：", name);
    // 在這裡把選中的食材加入你的 recipeData.ingredients 陣列中
};
</script>

<template>
    <button @click="isSearchOpen = true">新增食材</button>

    <IngredientSearchModal v-model="isSearchOpen" @select="onIngredientSelect" />
</template>