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
            <div class="plan-card__badge">{{ durationDays }}日計畫</div>
        </div>

        <div class="plan-card__content">
            <h3 class="plan-card__title">{{ plan.title }}</h3>
            <div class="plan-card__info">
                <i-material-symbols-calendar-month-outline />
                <span>{{ plan.start_date }} ~ {{ plan.end_date }}</span>
            </div>

            <div class="plan-card__footer">
                <span class="plan-card__date">建立於 {{ plan.created_at.split(' ')[0] }}</span>
                <button class="plan-card__more" @click.stop>
                    <i-material-symbols-more-vert />
                </button>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.plan-card {
    background: $neutral-color-white;
    border-radius: 12px;
    overflow: hidden;
    border: 1px solid $neutral-color-100;
    transition: all 0.3s ease;
    cursor: pointer;
    height: 100%;

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

    &__badge {
        position: absolute;
        top: 10px;
        right: 10px;
        background: rgba($primary-color-800, 0.85);
        color: white;
        padding: 2px 10px;
        border-radius: 20px;
        font-size: 0.75rem;
        backdrop-filter: blur(4px);
    }

    &__content {
        padding: 16px;
        display: flex;
        flex-direction: column;
        gap: 8px;
    }

    &__title {
        font-size: 1.1rem;
        font-weight: bold;
        color: $primary-color-800;
        margin: 0;
        // 限制顯示兩行，過長則顯示省略號
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }

    &__info {
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 0.85rem;
        color: $neutral-color-700;

        svg {
            font-size: 1rem;
        }
    }

    &__footer {
        margin-top: auto;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding-top: 10px;
        border-top: 1px solid $neutral-color-100;
    }

    &__date {
        font-size: 0.75rem;
        color: $neutral-color-400;
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