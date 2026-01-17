<script setup>
import { defineProps, defineEmits, computed } from 'vue'

const props = defineProps({
    currentPage: {
        type: Number,
        default: 1
    },
    totalPages: {
        type: Number,
        required: true
    }
});

const emit = defineEmits(['update:page']);

const pageNumbers = computed(() => {
    const pages = [];
    for (let i = 1; i <= props.totalPages; i++) {
        pages.push(i);
    }
    return pages;
});

const changePage = (page) => {
    if (page >= 1 && page <= props.totalPages) {
        emit('update:page', page);
    }
};
</script>
<template>
    <div class="pagination">
        <button v-for="page in pageNumbers" :key="page" @click="changePage(page)"
            :class="['page-link', { active: page === currentPage }]">
            {{ page }}
        </button>
    </div>
</template>
<style lang="scss" scoped>
.pagination {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
    list-style: none;
    padding: 0;
    margin: 20px 0;

    .page-link {
        display: flex;
        justify-content: center;
        align-items: center;
        width: 40px;
        height: 40px;
        border: 1px solid $primary-color-700; 
        border-radius: $radius-base;
        background-color: transparent;
        color: $primary-color-700;
        font-size: 16px;
        text-decoration: none;
        cursor: pointer;
        transition: all 0.3s ease;

        &:hover {
            background-color: $accent-color-100;
            color: $accent-color-700;
            border: 1px solid $accent-color-700;
        }

        &.active {
            background-color: $primary-color-700; 
            color: $neutral-color-white;
            border-color: $primary-color-700;

            &:hover {
                background-color: $primary-color-700;
                cursor: default;
            }
        }
        &.disabled {
            border-color: $neutral-color-400;
            color: $neutral-color-400;
            cursor: not-allowed;
            pointer-events: none; 

            &:hover {
                background-color: transparent;
            }
        }
    }
}
</style>