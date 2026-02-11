<script setup>
import { ref, computed, onMounted } from 'vue';
import PlanRecipeCard from '../PlanRecipeCard.vue';

const props = defineProps({
    recipes: {
        type: Array,
        default: () => []
    }
});

const emit = defineEmits(['close', 'select']);

const searchQuery = ref('');
// const recipes = ref([]);

const filteredRecipes = computed(() => {
    if (!searchQuery.value.trim()) return props.recipes;

    return props.recipes.filter(recipe =>
        recipe.recipe_title.toLowerCase().includes(searchQuery.value.toLowerCase())
    );
});

</script>

<template>
    <div class="recipe-picker-modal" @click="$emit('close')">

        <div class="modal-content" @click.stop>
            <div class="modal-header">
                <h2 class="modal-title p-p1">選擇食譜</h2>
                <button class="close-btn" @click="$emit('close')">
                    <i-material-symbols-close />
                </button>
            </div>

            <div class="search-area">
                <i-material-symbols-search class="search-icon" />
                <input type="text" placeholder="搜尋食譜名稱..." class="search-input p-p1" v-model="searchQuery">
            </div>

            <div class="recipe-list">
                <div v-for="recipe in filteredRecipes" :key="recipe.recipe_id" class="card-wrapper">
                    <PlanRecipeCard :recipe="recipe" @click="emit('select', recipe); emit('close')" />
                </div>

                <div v-if="filteredRecipes.length === 0" class="no-results">
                    沒有找到符合「{{ searchQuery }}」的食譜。
                </div>
            </div>
        </div>
        <div class="modal-overlay" @click="$emit('close')"></div>
    </div>
</template>

<style lang="scss" scoped>
.recipe-picker-modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    z-index: 1000;
    display: flex;
    flex-direction: column;
    justify-content: flex-end;
    align-items: center;
    background: rgba($neutral-color-black, 0.5);

    .modal-content {
        position: fixed;
        background: $neutral-color-white;
        width: 95%;
        height: 80vh;
        border-radius: 20px 20px 0 0;
        padding: 20px;
        display: flex;
        flex-direction: column;
        z-index: 2;
        overflow: hidden;
        animation: slide-up 0.3s ease-out;
    }

    .modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;

        .modal-title {
            font-size: 1.25rem;
            font-weight: bold;
            color: $primary-color-800;
            margin: 0;
        }

        .close-btn {
            background: none;
            border: none;
            font-size: 1.5rem;
            color: $neutral-color-400;
            cursor: pointer;
            padding: 5px;
        }
    }

    .search-area {
        position: relative;
        margin-bottom: 15px;

        .search-icon {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: $neutral-color-400;
        }

        .search-input {
            width: 100%;
            padding: 10px 10px 10px 40px;
            border: 1px solid transparent;
            border-radius: 30px;
            height: 45px;
            background-color: $neutral-color-100;
            outline: none;
            font-size: 1rem;

            &:focus {
                border-color: $primary-color-700;
                background-color: $neutral-color-white;
            }
        }
    }

    .recipe-list {
        flex: 1;
        overflow-y: auto;
        display: flex;
        flex-wrap: wrap;
        gap: 2%;
        padding-bottom: 20px;

        .card-wrapper {
            width: 48%;

            @media (max-width: 390px) {
                width: 100%;
            }
        }

        .no-results {
            width: 100%;
            text-align: center;
            color: $neutral-color-400;
            margin-top: 30px;
        }
    }
}

@keyframes slide-up {
    from {
        transform: translateY(100%);
    }

    to {
        transform: translateY(0);
    }
}
</style>