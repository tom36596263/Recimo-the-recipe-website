<script setup>
import { ref, computed, watch } from 'vue';
import { useRouter } from 'vue-router';
import { parsePublicFile } from '@/utils/parseFile';

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
const router = useRouter();

// --- 邏輯處理 ---

/**
 * 核心修正：統一清洗 ID 的函式
 */
const getCleanId = (id) => {
    if (!id) return '';
    // 將 "db-71" 轉換為 "71"，只保留數字部分
    return String(id).replace(/[^\d]/g, '');
};

const handleStartCooking = () => {
    const cleanId = getCleanId(props.recipe?.id || props.recipe?.recipe_id);
    if (cleanId) {
        router.push(`/workspace/guide/${cleanId}`);
    } else {
        console.error('無法解析有效的 ID');
    }
};

const originalServings = computed(() => {
    return Math.max(Number(props.recipe?.recipe_servings || props.recipe?.servings || 1), 1);
});

const currentServings = ref(1);

const baseNutritionPerServing = computed(() => {
    const n = props.nutrition;
    return {
        calories: Number(n?.calories || 0),
        protein: Number(n?.protein || 0),
        fat: Number(n?.fat || 0),
        carbs: Number(n?.carbs || 0),
    };
});

const displayedNutrition = computed(() => {
    const base = baseNutritionPerServing.value;
    const s = currentServings.value;
    return {
        calories: Math.round(base.calories * s),
        protein: (base.protein * s).toFixed(1),
        fat: (base.fat * s).toFixed(1),
        carbs: (base.carbs * s).toFixed(1),
    };
});

const ingredientsData = computed(() => {
    // 1. 獲取原始清單
    const list = props.recipe?.ingredients || [];

    // 2. 核心修正：計算「當前份數」相對於「原始份數」的倍率
    // 公式：(1 / 原始份數) * 當前份數
    const ratio = (1 / originalServings.value) * currentServings.value;

    return list.map(item => ({
        INGREDIENT_NAME: item.ingredient_name || item.name || '未知食材',
        // 3. 套用倍率
        amount: item.amount ? (Number(item.amount) * ratio) : 0,
        unit_name: item.unit_name || item.unit || 'g',
        note: item.remark || item.note || ''
    }));
});

watch(() => props.modelValue, (isOpen) => {
    if (isOpen) {
        currentServings.value = originalServings.value;
    }
}, { immediate: true });

const introData = computed(() => {
    if (!props.recipe) return null;
    const r = props.recipe;
    const loginUser = JSON.parse(localStorage.getItem('user') || '{}');
    const today = new Date().toISOString().split('T')[0];
    const rawTime = r.totalTime || r.time || 30;
    const formattedTime = String(rawTime).includes('分') ? rawTime : `${rawTime} 分鐘`;
    const rawImg = r.adaptation_image_url || r.coverImg || r.recipe_image_url || '';
    const isBase64 = rawImg && rawImg.startsWith('data:');
    const finalImage = isBase64 ? rawImg : parsePublicFile(rawImg);

    return {
        // ✨ 重點：在這裡就先把 ID 洗乾淨，傳給子組件時就不會帶 db-
        id: getCleanId(r.id || r.recipe_id),
        title: r.title || r.recipe_title || '未命名食譜',
        image: finalImage,
        description: r.description || r.recipe_description || '暫無詳細說明',
        time: formattedTime,
        difficulty: r.difficulty || 1,
        userName: r.user_name || r.author_name || loginUser.user_name || "未知作者",
        handle: (r.user_email || loginUser.user_email || "guest@mail.com").split('@')[0],
        publishTime: r.created_at || today,
        isOwner: !!(r.is_mine),
        tags: r.tags || []
    };
});

const stepsData = computed(() => {
    const steps = props.recipe?.steps || [];
    return steps.map((s, idx) => {
        const stepImg = s.image || s.step_image_url || '';
        const isStepBase64 = stepImg && stepImg.startsWith('data:');
        const finalStepImage = isStepBase64 ? stepImg : parsePublicFile(stepImg);
        return {
            id: s.id || idx,
            title: s.step_title || s.title || `步驟 ${idx + 1}`,
            content: s.content || s.step_content || s.description || '',
            image: finalStepImage,
            time: s.time || ''
        };
    });
});

const closeModal = () => emit('update:modelValue', false);

const getAvatarStyle = (name) => {
    if (!name) return { backgroundColor: '#74D09C' };
    const brandingColors = ['#74D09C', '#FFCB82', '#8FEF60', '#F7F766', '#FF8686', '#90C6FF'];
    const charCodeSum = name.split('').reduce((sum, char) => sum + char.charCodeAt(0), 0);
    return { backgroundColor: brandingColors[charCodeSum % 6], color: '#555555' };
};
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

                            <div class="action-group">
                                <!-- <BaseBtn title="開始烹飪" class="cook-btn-modal" @click="handleStartCooking" /> -->

                                <div class="user-info-box">
                                    <div class="user-avatar-circle" :style="getAvatarStyle(introData?.userName || '')">
                                        {{ introData?.userName?.charAt(0).toUpperCase() }}
                                    </div>
                                    <div class="user-text-meta">
                                        <div class="user-name">{{ introData?.userName }}</div>
                                        <div class="user-sub">@{{ introData?.handle }} • {{ introData?.publishTime }}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="row main-content-row">
                            <div class="col-7 col-md-12 content-left">
                                <RecipeIntro :info="introData" :hide-actions="false" class="intro-section" />
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

    &::-webkit-scrollbar-thumb {
        background: $neutral-color-100;
        border-radius: 10px;
    }

    @media (max-width: 768px) {
        padding: 24px;
    }
}

.action-group {
    display: flex;
    align-items: center;
    gap: 24px;

    .cook-btn-modal {
        width: 160px;
        height: 48px;
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
                margin-bottom: 4px;
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

        .action-group {
            width: 100%;
            flex-direction: column-reverse;
            gap: 16px;

            .cook-btn-modal {
                width: 100% !important;
            }
        }

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

.main-content-row {
    @media (max-width: 768px) {
        display: flex;
        flex-direction: column;

        .intro-section {
            order: 1;
            margin-bottom: 32px;
        }

        .sidebar-right {
            order: 2;
            margin-bottom: 40px;
        }

        .steps-section {
            order: 3;
        }

        :deep(.step-item) {
            flex-direction: column !important;

            .step-image {
                width: 100% !important;
                height: 200px !important;
                margin-bottom: 16px !important;
            }

            .step-content {
                width: 100% !important;
            }
        }
    }
}

.sticky-sidebar {
    position: sticky;
    top: 0;
}

.content-left {
    padding-right: 32px;

    @media (max-width: 768px) {
        padding-right: 0;
    }
}

.mb-32 {
    margin-bottom: 32px;
}

.mr-8 {
    margin-right: 8px;
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
</style>