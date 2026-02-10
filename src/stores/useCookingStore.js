import { defineStore } from 'pinia';
import { ref } from 'vue';

export const useCookingStore = defineStore('cooking', () => {
    const tempLogData = ref({
        recipeId: null,
        stepNotes: {},
        noteImages: {},
        noteImageFiles: {},
        totalTime: 0,
        estimatedTime: 0,
        rating: 0,
        skillDifficulty: '簡單',
        processDifficulty: '簡單',
        summary: '',
        mainImage: null,
        mainImageFile: null
    });

    const setLogData = (id, notes, images, actualTime, estimateTime, imageFiles = {}) => {
        tempLogData.value = {
            ...tempLogData.value,
            recipeId: id,
            stepNotes: notes,
            noteImages: images,
            noteImageFiles: imageFiles,
            totalTime: actualTime,
            estimatedTime: estimateTime
        };
    };

    const resetLogData = () => {
        tempLogData.value = {
            recipeId: null,
            stepNotes: {},
            noteImages: {},
            noteImageFiles: {},
            totalTime: 0,
            estimatedTime: 0,
            rating: 0,
            skillDifficulty: '簡單',
            processDifficulty: '簡單',
            summary: '',
            mainImage: null,
            mainImageFile: null
        };
    };

    return { tempLogData, setLogData, resetLogData };
});