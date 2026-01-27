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
    const total = props.totalPages;
    const current = props.currentPage;
    const pages = [];
    if(total <= 7){
        for (let i = 1; i <= total; i++) pages.push(i);
    }else{
        pages.push(1);
        if(current > 4){
            pages.push('...');
        }
        const start = Math.max(2, current - 1);
        const end = Math.min(total - 1, current + 1);
        for(let i = start; i <= end; i++){
            pages.push(i);
        }
        if(current < total - 3){
            pages.push('...');
        }
        pages.push(total);
    }
    return pages;
});

const changePage = (page) => {
    if(page === '...')return;
    if (page >= 1 && page <= props.totalPages) {
        emit('update:page', page);
    }
};
</script>
<template>
    <div class="pagination">
        <button 
            class="page-link"
            :disabled="currentPage === 1"
            @click="changePage(currentPage - 1)"
        >
            &lt;
        </button>
        <button 
            v-for="(page, index) in pageNumbers" 
            :key="index" @click="changePage(page)"
            :class="['page-link', { active: page === currentPage, dots: page === '...' }]">
            {{ page }}
        </button>
        <button 
            class="page-link"
            :disabled="currentPage === totalPages"
            @click="changePage(currentPage + 1)"
        >
            &gt;
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
        &[disabled]{
            opacity: 0.5;
            cursor: not-allowed;
            border-color: $neutral-color-700;
            color: $neutral-color-700;
        }
        &.dots{
            cursor: default;
            border: none;
            font-size: 30px;
            &:hover{
                background: none;
            }
        }
    }
}
</style>