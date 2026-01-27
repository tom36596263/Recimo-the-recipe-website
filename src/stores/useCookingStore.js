// stores/useCookingStore.js
import { defineStore } from 'pinia';
import { ref } from 'vue';

export const useCookingStore = defineStore('cooking', () => {
    const tempLogData = ref({
        recipeId: null,
        stepNotes: {},   // 格式：{ stepId: "筆記內容" }
        noteImages: {}   // 格式：{ stepId: "blob路徑" }
    });

    const setLogData = (id, notes, images) => {
        tempLogData.value = { recipeId: id, stepNotes: notes, noteImages: images };
    };

    return { tempLogData, setLogData };
});