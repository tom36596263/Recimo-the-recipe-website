<script setup>
import { ref, computed, watch } from 'vue';
// 🏆 1. 引入團隊規範工具
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

// 1. 取得食譜原始設定的份數 (例如 2)
const originalServings = computed(() => {
    return Math.max(Number(props.recipe?.recipe_servings || props.recipe?.servings || 1), 1);
});

// 2. 當前 UI 選擇的份數
const currentServings = ref(1);

// 3. 核心修正：基準營養值
const baseNutritionPerServing = computed(() => {
    const n = props.nutrition;
    return {
        calories: Number(n?.calories || 0),
        protein: Number(n?.protein || 0),
        fat: Number(n?.fat || 0),
        carbs: Number(n?.carbs || 0),
    };
});

// 4. 顯示營養數值
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

// 🏆 修正重點：配合 RecipeIngredients.vue 的欄位名稱
const ingredientsData = computed(() => {
    const list = props.recipe?.ingredients || [];
    // 這裡的 scale 設為 1，是因為 RecipeIngredients 內部已經會乘上 props.servings 了
    // 為了避免重複計算，我們傳入原始比例
    const scale = 1 / originalServings.value;

    return list.map(item => ({
        INGREDIENT_NAME: item.ingredient_name || item.name || '未知食材',
        // 傳入「單份份量」給子組件，讓它自己去乘 currentServings
        amount: item.amount ? (Number(item.amount) * scale) : 0,
        unit_name: item.unit_name || item.unit || 'g',
        // 🚩 重點：子組件顯示的是 item.note，所以我們要把資料塞進 note 欄位
        note: item.remark || item.note || ''
    }));
});

// 監聽燈箱開啟
watch(() => props.modelValue, (isOpen) => {
    if (isOpen) {
        currentServings.value = originalServings.value;
    }
}, { immediate: true });

// --- 資料轉換邏輯 (Intro & Steps) ---

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
        id: r.id || r.recipe_id,
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

// --- 原有 Modal 核心樣式保持不變 ---
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

// --- 調整 RWD 佈局邏輯 ---
.main-content-row {
    @media (max-width: 768px) {
        display: flex;
        flex-direction: column;

        .content-left {
            display: flex;
            flex-direction: column;
            padding-right: 0; // 行動版取消右邊距
        }

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

            // 🚀 關鍵優化：強制內部的 Step 項目在行動版寬度全滿
            :deep(.step-item) {
                flex-direction: column !important;
                gap: 16px;

                .step-image {
                    width: 100% !important;
                    height: 200px !important;
                    margin: 0 0 16px 0 !important;
                }

                .step-content {
                    width: 100% !important;
                }
            }
        }
    }
}

// --- 標題與用戶資訊 ---
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
}

.content-left {
    padding-right: 32px;
}

// --- 通用間距與動畫 ---
.mb-16 {
    margin-bottom: 16px;
}

.mb-24 {
    margin-bottom: 24px;
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