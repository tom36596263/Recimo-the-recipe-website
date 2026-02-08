<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { parsePublicFile } from '@/utils/parseFile.js';

/**
 * PlanFileCard.vue 
 * 目的：在計畫總覽頁顯示單個計畫檔案。
 * 串接：接收 plan 物件，點擊時導向動態編輯頁。
 */
// --- Props 定義 ---
const props = defineProps({
    plan: {
        type: Object,
        required: true
    },
    coverTemplates: { type: Array, default: () => [] }
});

// 定義emit：刪除、複製
const emit = defineEmits(['delete', 'copy']);

const router = useRouter();

// --- 計算最終要顯示的封面路徑 ---
const activeCoverUrl = computed(() => {
    // 1. 如果是使用者上傳 (type 2)
    if (props.plan.cover_type === 2 && props.plan.custom_cover_url) {
        return parsePublicFile(props.plan.custom_cover_url);
    }

    // 2. 如果是官方預設 (type 1)
    if (props.plan.cover_type === 1) {
        const target = props.coverTemplates.find(
            (t) => Number(t.cover_template_id) === Number(props.plan.cover_template_id)
        );
        return target ? parsePublicFile(target.template_url) : '';
    }

    // 3. 預設圖 (避免空白)
    return 'https://placehold.jp/24/2e6f4a/ffffff/300x150.png?text=No+Cover';
});

// --- 核心邏輯：判斷計畫狀態 ---
const statusInfo = computed(() => {
    const now = new Date();
    now.setHours(0, 0, 0, 0); // 歸零時間，只比日期

    const start = new Date(props.plan.start_date);
    const end = new Date(props.plan.end_date);

    if (now < start) {
        return { text: '未開始', class: 'upcoming' };
    } else if (now >= start && now <= end) {
        return { text: '進行中', class: 'active' };
    } else {
        return { text: '已結束', class: 'closed' };
    }
});

// --- 新增：日期格式化邏輯 ---
const formattedDateRange = computed(() => {
    if (!props.plan.start_date || !props.plan.end_date) return '';

    const start = new Date(props.plan.start_date);
    const end = new Date(props.plan.end_date);

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    const startYear = start.getFullYear();
    const startMonth = months[start.getMonth()];
    const startDate = start.getDate();

    const endYear = end.getFullYear();
    const endMonth = months[end.getMonth()];
    const endDate = end.getDate();

    // 情況 1: 同年且同月
    if (startYear === endYear && startMonth === endMonth) {
        return `${startMonth} ${startDate} ~ ${endDate}, ${startYear}`;
    }

    // 情況 2: 同年但不同月
    if (startYear === endYear) {
        return `${startMonth} ${startDate} ~ ${endMonth} ${endDate}, ${startYear}`;
    }

    // 情況 3: 不同年
    return `${startMonth} ${startDate}, ${startYear} ~ ${endMonth} ${endDate}, ${endYear}`;
});

// 進入編輯頁面：使用 index.js 定義的 name 跳轉
const goToEdit = () => {
    router.push({
        name: 'edit-meal-plan', // 這裡必須與 index.js 裡的路由 name 一致
        params: { id: props.plan.plan_id }
    });
};

// --- 其他功能：刪除、複製 ---
const showMenu = ref(false);
// 切換選單顯示
const toggleMenu = () => {
    showMenu.value = !showMenu.value;
};

// 點擊外部自動關閉選單
const closeMenu = (e) => {
    if (!e.target.closest('.plan-card__more-container')) {
        showMenu.value = false;
    }
};

onMounted(() => window.addEventListener('click', closeMenu));
onUnmounted(() => window.removeEventListener('click', closeMenu));

// 處理複製動作
const handleCopy = () => {
    showMenu.value = false;
    emit('copy', props.plan.plan_id);
};

// 處理刪除動作
const handleRemove = () => {
    showMenu.value = false;
    emit('delete', props.plan.plan_id);
};
</script>

<template>
    <div class="plan-card" @click="goToEdit">
        <div class="plan-card__cover">
            <img :src="activeCoverUrl" alt="Plan Cover" />
        </div>

        <div class="plan-card__content">

            <div class="plan-card__header">
                <h3 class="plan-card__title p-p1">{{ plan.title }}</h3>
                <div :class="['plan-card__status-tag', statusInfo.class]">
                    {{ statusInfo.text }}
                </div>
            </div>


            <div class="plan-card__footer">
                <div class="plan-card__info p-p3">
                    <i-material-symbols-calendar-month-outline />
                    <span>{{ formattedDateRange }}</span>
                </div>
                <div class="plan-card__more-container">
                    <button class="plan-card__more p-p3" @click.stop="toggleMenu">
                        <i-material-symbols-more-vert />
                    </button>

                    <Transition name="fade">
                        <div v-if="showMenu" class="plan-card__dropdown-menu">
                            <div class="menu-item" @click.stop="handleCopy">
                                <i-material-symbols-content-copy-outline /> 複製計畫
                            </div>
                            <div class="menu-item delete" @click.stop="handleRemove">
                                <i-material-symbols-delete-outline-rounded /> 刪除計畫
                            </div>
                        </div>
                    </Transition>
                </div>
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

    &__header {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    &__status-tag {
        height: 32px;
        border-radius: 10px;
        background-color: $neutral-color-100;
        color: $secondary-color-success-700;
        display: flex;
        justify-content: center;
        align-items: center;
        padding: 0 10px;
        flex-shrink: 0;

        &.upcoming {
            color: $secondary-color-info-700;
        }

        &.active {
            color: $secondary-color-success-700;
        }

        &.closed {
            color: $secondary-color-danger-700;
        }
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

    &__more-container {
        position: relative;
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

    &__dropdown-menu {
        position: absolute;
        bottom: 40px; // 向上彈出
        right: 0;
        background: white;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        border: 1px solid $neutral-color-100;
        width: 120px;
        z-index: 50;
        overflow: hidden;

        .menu-item {
            padding: 10px 12px;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
            color: $neutral-color-700;
            transition: 0.2s;

            &:hover {
                background-color: $neutral-color-100;
                color: $primary-color-800;
            }

            &.delete {
                color: $secondary-color-danger-700;

                &:hover {
                    background-color: #fff1f0;
                }
            }

            svg {
                font-size: 16px;
            }
        }
    }

    // 過渡動畫
    .fade-enter-active,
    .fade-leave-active {
        transition: opacity 0.2s, transform 0.2s;
    }

    .fade-enter-from,
    .fade-leave-to {
        opacity: 0;
        transform: translateY(5px);
    }
}
</style>