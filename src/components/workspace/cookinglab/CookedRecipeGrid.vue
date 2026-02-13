<script setup>
import { ref, computed, watch } from 'vue';
import CookedRecipeCard from './CookedRecipeCard.vue';
import PageBtn from '@/components/common/PageBtn.vue';

const props = defineProps({
    recipes: {
        type: Array,
        default: () => []
    },
    loading: {
        type: Boolean,
        default: false
    }
});

const emit = defineEmits(['open-log']);

const currentPage = ref(1);
const pageSize = 8;

const totalPages = computed(() => {
    return Math.ceil(props.recipes.length / pageSize) || 1;
});

const paginatedRecipes = computed(() => {
    const start = (currentPage.value - 1) * pageSize;
    const end = start + pageSize;
    return props.recipes.slice(start, end);
});

const handlePageUpdate = (page) => {
    currentPage.value = page;
    window.scrollTo({ top: 0, behavior: 'smooth' });
};

// 當總資料改變時，重置回第一頁
watch(() => props.recipes, () => {
    currentPage.value = 1;
});
</script>

<template>
    <section class="cooked-recipes-section">
        <h4 class="zh-h4 section-title">製作過的食譜</h4>

        <div v-if="loading" class="loading-state">
            <div class="spinner"></div>
            <p>正在載入烹飪紀錄...</p>
        </div>

        <div v-else-if="recipes.length === 0" class="empty-state">
            <div class="empty-icon">🍳</div>
            <p>還沒有烹飪紀錄，快去「我的食譜」開始第一次料理吧！</p>
        </div>

        <div v-else>
            <div class="row recipe-grid">
                <div v-for="recipe in paginatedRecipes" :key="recipe.recipe_id"
                    class="col-3 col-lg-4 col-md-6 col-sm-12 mb-4">
                    <CookedRecipeCard :recipe="recipe" @click="$emit('open-log', recipe)" />
                </div>
            </div>

            <div class="pagination-wrapper" v-if="totalPages > 1">
                <PageBtn :currentPage="currentPage" :totalPages="totalPages" @update:page="handlePageUpdate" />
            </div>
        </div>
    </section>
</template>

<style lang="scss" scoped>
.cooked-recipes-section {
    background: $neutral-color-white;
    border-radius: 12px;
    padding: 24px;
    // box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
    min-height: 400px;

    .section-title {
        color: $neutral-color-800;
        margin-bottom: 24px;
        font-size: 20px;
        position: relative;
        padding-left: 12px;
    }

    .loading-state,
    .empty-state {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding: 60px 0;
        color: $neutral-color-400;
        gap: 16px;
    }

    .empty-icon {
        font-size: 48px;
        opacity: 0.5;
    }

    .recipe-grid {
        display: flex;
        flex-wrap: wrap;
        // gap: 2px;
    }

    .pagination-wrapper {
        display: flex;
        justify-content: center;
        margin-top: 32px;
    }
}

// Loading Spinner
.spinner {
    width: 40px;
    height: 40px;
    border: 3px solid rgba($primary-color-700, 0.1);
    border-radius: 50%;
    border-top-color: $primary-color-700;
    animation: spin 1s ease-in-out infinite;
}

@keyframes spin {
    to {
        transform: rotate(360deg);
    }
}

@media screen and (max-width: 810px) {
    .cooked-recipes-section {
        padding: 16px;
    }
}
</style>