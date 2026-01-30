<script setup>
import { ref, computed, watch } from 'vue';
import RecipeIntro from '@/components/workspace/recipedetail/RecipeIntro.vue';
import RecipeIngredients from '@/components/workspace/recipedetail/RecipeIngredients.vue';
import RecipeSteps from '@/components/workspace/recipedetail/RecipeSteps.vue';
import NutritionCard from '@/components/workspace/recipedetail/NutritionCard.vue';

const props = defineProps({
    modelValue: Boolean,
    recipe: Object,
    nutrition: {
        type: Object,
        default: () => ({ calories: 0, protein: 0, fat: 0, carbs: 0 })
    }
});

const emit = defineEmits(['update:modelValue', 'delete-recipe']);

// --- 🏆 核心修正：加入圖片位址邏輯 ---
const fileUrl = import.meta.env.VITE_FILE_URL || 'http://localhost:8888/recimo_api/';

const formatImg = (rawPath) => {
    if (!rawPath) return 'https://placehold.co/800x600?text=No+Image';
    if (rawPath.startsWith('http') || rawPath.startsWith('data:') || rawPath.startsWith('blob:')) {
        return rawPath;
    }
    const base = fileUrl.endsWith('/') ? fileUrl : `${fileUrl}/`;
    const cleanPath = rawPath.replace(/^\//, '');
    return `${base}${cleanPath}`;
};

// 1. 取得原始份數 (防呆至少為 1)
const originalServings = computed(() => {
    return Math.max(Number(props.recipe?.recipe_servings || props.recipe?.servings || 1), 1);
});

// 在 AdaptationDetailModal.vue 內部
const displayedNutrition = computed(() => {
    if (!props.nutrition) return null;
    const s = currentServings.value; // 使用者在燈箱選的人份
    return {
        calories: props.nutrition.calories * s,
        protein: props.nutrition.protein * s,
        fat: props.nutrition.fat * s,
        carbs: props.nutrition.carbs * s,
    };
});

// 2. 當前的 UI 顯示人份數 (預設設為 1)
const currentServings = ref(1);

// 當燈箱開啟或食譜切換時，初始化 currentServings
watch(() => props.modelValue, (isOpen) => {
    if (isOpen) {
        currentServings.value = 1;
    }
});

// 3. 核心：計算「每一份量」的基礎營養素
const baseNutritionPerServing = computed(() => {
    if (!props.nutrition) return { calories: 0, protein: 0, fat: 0, carbs: 0 };

    const total = props.nutrition;
    const s = originalServings.value;

    return {
        calories: Number(total.calories || 0) / s,
        protein: Number(total.protein || 0) / s,
        fat: Number(total.fat || 0) / s,
        carbs: Number(total.carbs || 0) / s,
    };
});

// 4. 食材數據也要跟著 currentServings 連動
const ingredientsData = computed(() => {
    const list = props.recipe?.ingredients || [];
    const scale = currentServings.value / originalServings.value;

    return list.map(item => ({
        INGREDIENT_NAME: item.name || item.ingredient_name || '未知食材',
        amount: item.amount ? (Number(item.amount) * scale).toFixed(1) : '',
        unit_name: item.unit || item.unit_name || 'g',
        note: item.note || ''
    }));
});

// --- 其他輔助邏輯 ---
const closeModal = () => emit('update:modelValue', false);

const getAvatarStyle = (name) => {
    if (!name) return { backgroundColor: '#74D09C' };
    const brandingColors = ['#74D09C', '#FFCB82', '#8FEF60', '#F7F766', '#FF8686', '#90C6FF'];
    const charCodeSum = name.split('').reduce((sum, char) => sum + char.charCodeAt(0), 0);
    return { backgroundColor: brandingColors[charCodeSum % 6], color: '#555555' };
};

const introData = computed(() => {
    if (!props.recipe) return null;
    const r = props.recipe;
    const loginUser = JSON.parse(localStorage.getItem('user') || '{}');
    const today = new Date().toISOString().split('T')[0];

    const rawTime = r.totalTime || r.time || 30;
    const formattedTime = String(rawTime).includes('分') ? rawTime : `${rawTime} 分鐘`;

    // 🏆 修正封面圖路徑
    const rawImg = r.adaptation_image_url || r.coverImg || r.recipe_image_url || '';

    return {
        id: r.id || r.recipe_id,
        title: r.adapt_title || r.title || '新改編食譜',
        image: formatImg(rawImg),
        description: r.clean_description || r.description || '暫無詳細說明',
        time: formattedTime,
        difficulty: r.difficulty || 1,
        userName: r.user_name || r.author_name || loginUser.user_name || "未知作者",
        handle: (r.user_email || loginUser.user_email || "guest@mail.com").split('@')[0],
        publishTime: r.created_at || today,
        isOwner: !!(r.is_mine)
    };
});

const stepsData = computed(() => {
    const steps = props.recipe?.steps || [];
    return steps.map((s, idx) => ({
        id: s.id || idx,
        title: s.step_title || s.title || `步驟 ${idx + 1}`,
        content: s.content || s.step_content || '',
        // 🏆 修正步驟圖路徑
        image: formatImg(s.image || s.step_image_url || ''),
        time: s.time || ''
    }));
});
</script>

<template>
    <Transition name="modal-fade">
        <div v-if="modelValue" class="adaptation-modal-overlay" @click.self="closeModal">
            <div class="modal-window">
                <button class="close-x" @click="closeModal">✕</button>

                <div class="modal-scroll-body">
                    <div class="container-fluid">
                        <div class="modal-title-bar mb-32">
                            <div class="title-group">
                                <h2 class="zh-h2">
                                    <i-material-symbols-restaurant-rounded class="mr-8 icon-v-align" />
                                    {{ introData?.title }}
                                </h2>
                                <span class="badge">改編版本</span>

                                
                            </div>

                            <div class="user-info-box">
                                <div class="user-avatar-circle" :style="getAvatarStyle(introData?.userName || '')">
                                    {{ introData?.userName?.charAt(0).toUpperCase() }}
                                </div>
                                <div class="user-text-meta">
                                    <div class="user-name">{{ introData?.userName }}</div>
                                    <div class="user-sub">@{{ introData?.handle }} • {{ introData?.publishTime }}</div>
                                </div>
                            </div>
                        </div>

                        <div class="row main-content-row">
                            <div class="col-7 col-md-12 content-left">
                                <RecipeIntro :info="introData" :hide-actions="true" class="intro-section" />
                                <RecipeSteps :steps="stepsData" class="steps-section" />
                            </div>

                            <div class="col-5 col-md-12 sidebar-right">
                                <div class="sticky-sidebar">
                                    <NutritionCard v-if="nutrition" :nutrition="displayedNutrition"
                                        :servings="currentServings" @change-servings="val => currentServings = val" />

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

    .close-x {
        position: absolute;
        top: 20px;
        right: 20px;
        background: none;
        border: none;
        font-size: 26px;
        color: $neutral-color-700;
        cursor: pointer;
        line-height: 1;
        padding: 5px;
        transition: color 0.2s;
        z-index: 10;

        &:hover {
            color: $neutral-color-black;
        }
    }
}

.modal-scroll-body {
    flex: 1;
    overflow-y: auto;
    padding: 48px;

    &::-webkit-scrollbar {
        width: 6px;
    }

    &::-webkit-scrollbar-track {
        background: transparent;
    }

    &::-webkit-scrollbar-thumb {
        background: $neutral-color-100;
        border-radius: 10px;

        &:hover {
            background: $neutral-color-400;
        }
    }

    scrollbar-width: thin;
    scrollbar-color: $neutral-color-100 transparent;

    @media (max-width: 768px) {
        padding: 24px;
    }
}

.main-content-row {
    @media (max-width: 768px) {
        display: flex;
        flex-direction: column;

        .content-left {
            display: contents;
        }

        .intro-section {
            order: 1;
            margin-bottom: 32px;
        }

        .sidebar-right {
            order: 2;
            margin-bottom: 32px;
        }

        .steps-section {
            order: 3;
        }
    }
}

.modal-title-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 2px solid $neutral-color-100;
    padding-bottom: 20px;
    padding-right: 40px;

    .title-group {
        display: flex;
        align-items: center;
        gap: 16px;
    }

    .zh-h2 {
        margin: 0;
        display: flex;
        align-items: center;
    }

    .badge {
        background: $primary-color-100;
        color: $primary-color-700;
        padding: 4px 14px;
        border-radius: 99px;
        font-weight: 600;
        font-size: 14px;
    }

    .user-info-box {
        display: flex;
        align-items: center;
        gap: 12px;

        .user-avatar-circle {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 15px;
            border: 1px solid rgba(0, 0, 0, 0.05);
            flex-shrink: 0;
            order: 2;
        }

        .user-text-meta {
            text-align: right;
            order: 1;

            .user-name {
                font-weight: 600;
                margin-bottom: 7px;
                color: $neutral-color-800;
                font-size: 15px;
            }

            .user-sub {
                font-size: 12px;
                color: $neutral-color-400;
            }
        }
    }

    @media (max-width: 768px) {
        flex-direction: column;
        align-items: flex-start;
        gap: 16px;
        padding-right: 30px;

        .user-info-box {
            width: 100%;
            justify-content: flex-start;

            .user-avatar-circle {
                order: 1;
            }

            .user-text-meta {
                order: 2;
                text-align: left;
            }
        }
    }
}

.sticky-sidebar {
    position: sticky;
    top: 0;

    .ingredients-wrapper {
        margin-top: 30px;
        // background: $primary-color-100;
        padding: 24px;
        border-radius: 20px;
        // border: 1px solid rgba($primary-color-400, 0.2);
    }

    .sidebar-title {
        padding-left: 10px;
    }
}

.nutrition-section {
    background: white;
    padding: 24px;
    border-radius: 20px;
    border: 1px solid $neutral-color-100;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.03);
}

.content-left {
    padding-right: 32px;
}

.color-p4 {
    color: $neutral-color-400;
}

.mt-12 {
    margin-top: 12px;
}

.text-center {
    text-align: center;
}

.mr-8 {
    margin-right: 8px;
}

.mb-16 {
    margin-bottom: 16px;
}

.mb-24 {
    margin-bottom: 24px;
}

.mb-32 {
    margin-bottom: 32px;
}

.modal-fade-enter-active {
    transition: all 0.4s ease-out;
}

.modal-fade-leave-active {
    transition: all 0.3s ease-in;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
    opacity: 0;
    transform: translateY(20px);
}

.fade-in {
    animation: fadeIn 0.6s ease-out;
}

@keyframes fadeIn {
    from {
        opacity: 0;
        transform: translateY(10px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}
</style>