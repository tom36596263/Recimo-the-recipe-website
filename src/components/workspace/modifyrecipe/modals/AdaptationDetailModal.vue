<script setup>
import { ref, computed, watch } from 'vue';
import RecipeIntro from '@/components/workspace/recipedetail/RecipeIntro.vue';
import RecipeIngredients from '@/components/workspace/recipedetail/RecipeIngredients.vue';
import RecipeSteps from '@/components/workspace/recipedetail/RecipeSteps.vue';

const props = defineProps({
    modelValue: Boolean,
    recipe: Object
});

const emit = defineEmits(['update:modelValue']);

const currentServings = ref(1);
const closeModal = () => emit('update:modelValue', false);

// --- 模擬評論區的頭像顏色邏輯 ---
const getAvatarStyle = (name) => {
    if (!name) return { backgroundColor: '#74D09C' };
    const brandingColors = ['#74D09C', '#FFCB82', '#8FEF60', '#F7F766', '#FF8686', '#90C6FF'];
    const charCodeSum = name.split('').reduce((sum, char) => sum + char.charCodeAt(0), 0);
    return { backgroundColor: brandingColors[charCodeSum % 6], color: '#555555' };
};

watch(() => props.recipe, (newVal) => {
    if (newVal) {
        currentServings.value = Number(newVal.servings) || 1;
    }
}, { immediate: true });

const introData = computed(() => {
    if (!props.recipe) return null;
    const r = props.recipe;
    const rawTime = r.totalTime || r.time || 30;
    const formattedTime = String(rawTime).includes('分') ? rawTime : `${rawTime} 分鐘`;

    let finalDescription = '暫無詳細說明';
    if (r.recipe_descreption) finalDescription = r.recipe_descreption;
    else if (r.description && r.description !== r.adapt_description) finalDescription = r.description;

    return {
        id: r.id,
        title: r.adaptation_title || r.title || '改編食譜',
        image: r.adaptation_image_url || r.coverImg || 'https://placehold.co/800x600?text=No+Image',
        description: finalDescription,
        time: formattedTime,
        difficulty: r.difficulty || 1,
        // --- 這裡先放假資料 ---
        userName: "小當家",
        handle: "cooking_master",
        publishTime: "2024-05-20"
    };
});

const ingredientsData = computed(() => {
    if (!props.recipe?.ingredients) return [];
    return props.recipe.ingredients.map(item => ({
        INGREDIENT_NAME: item.name || item.ingredient_name || '未知食材',
        amount: item.amount,
        unit_name: item.unit || item.unit_name || 'g',
        note: item.note || ''
    }));
});

const stepsData = computed(() => {
    if (!props.recipe?.steps) return [];
    return props.recipe.steps.map((s, idx) => ({
        id: s.id || idx,
        title: s.step_title || s.title || `步驟 ${idx + 1}`,
        content: s.content || s.step_content || '',
        image: s.image || s.step_image_url || '',
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
                                    <div class="ingredients-wrapper">
                                        <h3 class="zh-h3 mb-16 sidebar-title">所需食材</h3>
                                        <RecipeIngredients :list="ingredientsData" :readonly="true" />
                                    </div>
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

        .user-text-meta {
            text-align: right;

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
            order: 2; // 電腦版頭像在右
        }

        .user-text-meta {
            order: 1; // 電腦版文字在左
        }
    }

    @media (max-width: 768px) {
        flex-direction: column;
        align-items: flex-start;
        gap: 16px;
        padding-right: 30px; // 給關閉按鈕留空間

        .user-info-box {
            width: 100%;
            justify-content: flex-start;

            .user-avatar-circle {
                order: 1; // 手機版頭像改到左邊
            }

            .user-text-meta {
                order: 2; // 手機版文字改到右邊
                text-align: left;
            }
        }
    }
}

.sticky-sidebar {
    position: sticky;
    top: 0;

    .ingredients-wrapper {
        background: $neutral-color-100;
        padding: 24px;
        border-radius: 20px;
        border: 1px solid rgba($primary-color-400, 0.2);
    }

    .sidebar-title {
        padding-left: 10px;
    }
}

.content-left {
    padding-right: 32px;
}

.mr-8 {
    margin-right: 8px;
}

.mb-16 {
    margin-bottom: 16px;
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
</style>