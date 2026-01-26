<script setup>
import { ref, computed, watch } from 'vue';
// 引用原本詳情頁的組件
import RecipeIntro from '@/components/workspace/recipedetail/RecipeIntro.vue';
import RecipeIngredients from '@/components/workspace/recipedetail/RecipeIngredients.vue';
import RecipeSteps from '@/components/workspace/recipedetail/RecipeSteps.vue';
import NutritionCard from '@/components/workspace/recipedetail/NutritionCard.vue';

const props = defineProps({
    modelValue: Boolean, // 控制燈箱開啟
    recipe: Object       // 傳入的改編食譜資料
});

const emit = defineEmits(['update:modelValue']);

// --- 狀態定義 ---
const currentServings = ref(1); // 本地份數狀態

const closeModal = () => emit('update:modelValue', false);

// 監聽 recipe 變化，當開啟不同食譜時重設份數
watch(() => props.recipe, (newVal) => {
    if (newVal) {
        currentServings.value = newVal.servings || 1;
    }
}, { immediate: true });

// 處理份數變更事件
const handleServingsChange = (newVal) => {
    currentServings.value = newVal;
};

// --- 資料橋接邏輯 ---

// 1. 橋接 Intro 資料
const introData = computed(() => {
    if (!props.recipe) return null;
    const r = props.recipe;
    return {
        title: r.title || '未命名改編',
        image: r.coverImg || 'https://placehold.co/800x600?text=No+Image',
        description: r.description || '暫無簡介',
        time: r.time || '0 分鐘',
        difficulty: r.difficulty || 1
    };
});

// 2. 橋接 食材 資料
const ingredientsData = computed(() => {
    if (!props.recipe?.ingredients) return [];
    return props.recipe.ingredients.map(item => ({
        INGREDIENT_NAME: item.name || item.ingredient_name,
        amount: item.amount,
        unit_name: item.unit || item.unit_name,
        note: item.note || ''
    }));
});

// 3. 橋接 步驟 資料
const stepsData = computed(() => {
    if (!props.recipe?.steps) return [];
    return props.recipe.steps.map((s, idx) => ({
        id: s.id || idx,
        title: s.title || `步驟 ${idx + 1}`,
        content: s.content || '',
        image: s.image || s.img || '',
        time: s.time || ''
    }));
});

// 4. 橋接 營養 資料 - 強制對齊版
const nutritionWrapper = computed(() => {
    if (!props.recipe?.ingredients) return [];

    return props.recipe.ingredients.map(item => {
        const kcal = parseFloat(item.kcal_per_100g || item.calories_per_100g || item.kcal || item.calories || 0);
        const protein = parseFloat(item.protein_per_100g || item.protein || 0);
        const fat = parseFloat(item.fat_per_100g || item.fat || 0);
        const carbs = parseFloat(item.carbs_per_100g || item.carbs || 0);
        const amount = parseFloat(item.amount) || 0;
        const unitWeight = parseFloat(item.gram_conversion || item.unit_weight || 1);

        return {
            calories_per_100g: kcal,
            protein_per_100g: protein,
            fat_per_100g: fat,
            carbs_per_100g: carbs,
            amount: amount,
            unit_weight: unitWeight,
            INGREDIENT_NAME: item.ingredient_name || item.name
        };
    });
});
</script>

<template>
    <Transition name="modal-fade">
        <div v-if="modelValue" class="adaptation-modal-overlay" @click.self="closeModal">
            <div class="modal-window">
                <button class="close-x" @click="closeModal">✕</button>

                <div class="modal-scroll-body">
                    <div class="container-fluid">
                        <div class="modal-title-bar mb-24">
                            <h2 class="zh-h2">
                                <i-material-symbols-restaurant-rounded class="mr-8" />
                                {{ introData?.title }}
                            </h2>
                            <span class="badge">改編版本</span>
                        </div>

                        <div class="row">
                            <div class="col-7 col-md-12">
                                <RecipeIntro :info="introData" />
                                <div class="mt-32">
                                    <RecipeSteps :steps="stepsData" />
                                </div>
                            </div>

                            <div class="col-5 col-md-12">
                                <div class="sticky-sidebar">
                                    <div class="mb-16">
                                        <NutritionCard :ingredients="nutritionWrapper" :servings="currentServings"
                                            :readonly="false" @change-servings="handleServingsChange" />
                                    </div>
                                    <RecipeIngredients :list="ingredientsData" :readonly="true" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </Transition>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.adaptation-modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.6);
    backdrop-filter: blur(4px);
    z-index: 2000;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 20px;
}

.modal-window {
    background: white;
    width: 100%;
    max-width: 1100px;
    height: 90vh;
    border-radius: 24px;
    position: relative;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.close-x {
    position: absolute;
    top: 20px;
    right: 20px;
    width: 40px;
    height: 40px;
    border-radius: 50%;
    border: none;
    background: $neutral-color-100;
    cursor: pointer;
    z-index: 10;
    transition: all 0.3s;

    &:hover {
        background: $primary-color-100;
        transform: rotate(90deg);
    }
}

.modal-scroll-body {
    flex: 1;
    overflow-y: auto;
    padding: 40px;

    @media (max-width: 768px) {
        padding: 20px;
    }
}

.modal-title-bar {
    display: flex;
    align-items: center;
    gap: 16px;
    border-bottom: 2px solid $neutral-color-100;
    padding-bottom: 16px;

    .badge {
        background: $primary-color-100;
        color: $primary-color-700;
        padding: 4px 12px;
        border-radius: 6px;
        font-weight: bold;
        font-size: 14px;
    }
}

.sticky-sidebar {
    position: sticky;
    top: 0;
}

.mt-32 {
    margin-top: 32px;
}

.mb-16 {
    margin-bottom: 16px;
}

.mb-24 {
    margin-bottom: 24px;
}

.mr-8 {
    margin-right: 8px;
}

/* 動畫 */
.modal-fade-enter-active,
.modal-fade-leave-active {
    transition: opacity 0.4s;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
    opacity: 0;
}
</style>