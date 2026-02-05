<script setup>
import { computed } from 'vue';
import { useRouter } from 'vue-router';

/**
 * PlanFileCard.vue 
 * 目的：在計畫總覽頁顯示單個計畫檔案。
 * 串接：接收 plan 物件，點擊時導向動態編輯頁。
 */
const props = defineProps({
    plan: {
        type: Object,
        required: true
    }
});

const router = useRouter();

// 計算計畫天數：利用結束日期減開始日期
const durationDays = computed(() => {
    const start = new Date(props.plan.start_date);
    const end = new Date(props.plan.end_date);
    const diffTime = Math.abs(end - start);
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;
});

// 進入編輯頁面：使用 index.js 定義的 name 跳轉
const goToEdit = () => {
    router.push({
        name: 'edit-meal-plan', // 這裡必須與 index.js 裡的路由 name 一致
        params: { id: props.plan.plan_id }
    });
};
</script>

<template>
    <div class="plan-card" @click="goToEdit">
        <div class="plan-card__cover">
            <img src="https://placehold.jp/24/2e6f4a/ffffff/300x150.png?text=MealPlan" alt="Cover" />
        </div>

        <div class="plan-card__content">
            <h3 class="plan-card__title p-p1">{{ plan.title }}</h3>


            <div class="plan-card__footer">
                <div class="plan-card__info p-p3">
                    <i-material-symbols-calendar-month-outline />
                    <span>{{ plan.start_date }} ~ {{ plan.end_date }}</span>
                </div>
                <button class="plan-card__more p-p3" @click.stop>
                    <i-material-symbols-more-vert />
                </button>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.plan-card {
    background: $neutral-color-white;
    border-radius: 10px;
    overflow: hidden;
    border: 1px solid $neutral-color-100;
    transition: all 0.3s ease;
    cursor: pointer;
    height: 250px;
    width: 100%;

    &:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 20px rgba($neutral-color-black, 0.08);
    }

    &__cover {
        position: relative;
        height: 140px;
        background: $primary-color-100;

        img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
    }


    &__content {
        padding: 16px;
        display: flex;
        flex-direction: column;
        gap: 8px;
    }

    &__title {
        color: $primary-color-800;
        margin: 0;
        // 限制顯示兩行，過長則顯示省略號
        display: -webkit-box;
        -webkit-line-clamp: 1;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }

    &__footer {
        margin-top: auto;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding-top: 10px;
    }


    &__info {
        display: flex;
        align-items: center;
        color: $neutral-color-700;

        svg {
            font-size: 1rem;
        }
    }

    &__more {
        background: none;
        border: none;
        color: $neutral-color-400;
        cursor: pointer;
        padding: 4px;
        border-radius: 4px;

        &:hover {
            color: $primary-color-800;
            background-color: $neutral-color-100;
        }
    }
}
</style>