<script setup>
import { ref, computed, watch } from 'vue';
import { useRouter } from 'vue-router';
import { parsePublicFile } from '@/utils/parseFile';
import { useAuthStore } from '@/stores/authStore';
import { phpApi } from '@/utils/phpApi';

import RecipeIntro from '@/components/workspace/recipedetail/RecipeIntro.vue';
import RecipeIngredients from '@/components/workspace/recipedetail/RecipeIngredients.vue';
import RecipeSteps from '@/components/workspace/recipedetail/RecipeSteps.vue';
import NutritionCard from '@/components/workspace/recipedetail/NutritionCard.vue';
import AuthorInfo from '@/components/workspace/modifyrecipe/AuthorInfo.vue';

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
const authStore = useAuthStore();

// 統一清理 ID 的小工具
const getCleanId = (id) => {
    if (!id) return '';
    return String(id).replace(/[^\d]/g, '');
};

/**
 * 權限判斷：是否為食譜擁有者
 */
const isOwner = computed(() => {
    const currentUserId = authStore.user?.user_id || authStore.user?.id;
    const authorId = props.recipe?.author_id || props.recipe?.user_id;
    if (!currentUserId || !authorId) return false;
    return Number(currentUserId) === Number(authorId);
});

/**
 * 處理刪除改編食譜
 */
const handleDelete = async () => {
    if (!confirm('確定要刪除您的改編版本嗎？此操作將無法復原。')) return;

    const rawId = props.recipe?.id || props.recipe?.recipe_id;
    const cleanId = getCleanId(rawId);
    const isDbData = String(rawId).startsWith('db-') || props.recipe?.recipe_id;

    if (isDbData) {
        try {
            const res = await phpApi.post('recipes/recipe_adaptation_delete.php', {
                recipe_id: cleanId,
                user_id: authStore.user?.user_id || authStore.user?.id
            });

            if (res.data.success) {
                alert('刪除成功！');
                emit('delete-recipe', cleanId);
                closeModal();
            } else {
                alert('刪除失敗：' + (res.data.message || '未知錯誤'));
            }
        } catch (err) {
            console.error('刪除 API 請求出錯:', err);
            alert('連線伺服器失敗，請檢查網路狀態');
        }
    } else {
        emit('delete-recipe', cleanId);
        closeModal();
    }
};

// --- 份量與營養計算邏輯 ---
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
    const list = props.recipe?.ingredients || [];
    const ratio = (1 / originalServings.value) * currentServings.value;
    return list.map(item => ({
        INGREDIENT_NAME: item.ingredient_name || item.name || '未知食材',
        amount: item.amount ? (Number(item.amount) * ratio).toFixed(1) : 0,
        unit_name: item.unit_name || item.unit || 'g',
        note: item.remark || item.note || ''
    }));
});

watch(() => props.modelValue, (isOpen) => {
    if (isOpen) {
        currentServings.value = originalServings.value;
    }
}, { immediate: true });

/**
 * 整合介紹區域所需的資料
 */
const introData = computed(() => {
    if (!props.recipe) return null;
    const r = props.recipe;

    const rawTime = r.totalTime || r.time || 30;
    const formattedTime = String(rawTime).includes('分') ? rawTime : `${rawTime} 分鐘`;

    const rawImg = r.adaptation_image_url || r.coverImg || r.recipe_image_url || '';
    const finalImage = (rawImg && (rawImg.startsWith('data:') || rawImg.startsWith('http'))) ? rawImg : parsePublicFile(rawImg);

    return {
        id: getCleanId(r.id || r.recipe_id),
        title: r.title || r.recipe_title || '未命名食譜',
        image: finalImage,
        description: r.description || r.recipe_description || '暫無詳細說明',
        time: formattedTime,
        difficulty: r.difficulty || 1,
        tags: r.tags || []
    };
});

/**
 * 整合步驟資料
 */
const stepsData = computed(() => {
    const steps = props.recipe?.steps || [];
    return steps.map((s, idx) => {
        const stepImg = s.image || s.step_image_url || '';
        return {
            id: s.id || idx,
            title: s.step_title || s.title || `步驟 ${idx + 1}`,
            content: s.content || s.step_content || s.description || '',
            image: (stepImg && (stepImg.startsWith('data:') || stepImg.startsWith('http'))) ? stepImg : parsePublicFile(stepImg),
            time: s.time || ''
        };
    });
});

const closeModal = () => emit('update:modelValue', false);
</script>

<template>
    <Transition name="modal-fade">
        <div v-if="modelValue" class="adaptation-modal-overlay" @click.self="closeModal">
            <div class="modal-window">
                <button class="close-x" @click="closeModal">✕</button>

                <div class="fixed-floating-bar">
                    <button class="action-circle-btn">
                        <i-material-symbols-thumb-up-outline-rounded />
                    </button>
                    <button class="action-circle-btn">
                        <i-material-symbols-share-outline />
                    </button>
                    <button class="action-circle-btn report">
                        <i-material-symbols-error-outline-rounded />
                    </button>
                </div>

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
                                <AuthorInfo
                                    :name="isOwner ? (authStore.user?.user_name || authStore.user?.name) : (recipe.user_name || recipe.author_name || 'Recimo 用戶')"
                                    :handle="`user_${recipe.author_id || recipe.user_id}`" :time="recipe.created_at" />

                                <button v-if="isOwner" class="btn-delete-adaptation" @click="handleDelete">
                                    <i-material-symbols-delete-outline-rounded class="mr-4" />
                                    刪除改編
                                </button>
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

.btn-delete-adaptation {
    display: flex;
    align-items: center;
    white-space: nowrap; // 確保文字不會折行
    background-color: #fff1f0;
    color: #ff4d4f;
    border: 1px solid #ffccc7;
    padding: 8px 16px;
    border-radius: 8px;
    font-weight: 600;
    font-size: 14px;
    transition: all 0.2s ease;
    cursor: pointer;

    &:hover {
        background-color: #ff4d4f;
        color: white;
        border-color: #ff4d4f;
    }
}

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

    @media (max-width: 768px) {
        padding: 24px;
    }
}

.action-group {
    display: flex;
    align-items: center;
    gap: 20px; // 作者與按鈕之間的間距

    :deep(.author-info-wrapper) {
        margin-bottom: 0; // 移除組件內可能的下間距
    }

    @media (max-width: 768px) {
        width: 100%;
        flex-direction: row; // 手機版保持水平
        justify-content: space-between; // 一左一右
        align-items: center;
        gap: 12px;
    }

    @media (max-width: 480px) {
        flex-direction: column; // 極窄螢幕才改垂直
        align-items: flex-start;
    }
}

.modal-title-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 2px solid $neutral-color-100;
    padding-bottom: 20px;

    .title-group {
        display: flex;
        align-items: center;
        gap: 16px;
    }

        .badge {
            display: inline-flex;
            /* 使用 flex 且保持行內塊特性 */
            align-items: center;
            justify-content: center;
    
            height: 25px;
            background: $primary-color-100;
            color: $primary-color-700;
            padding: 0 14px;
            border-radius: 99px;
            font-weight: 600;
            font-size: 14px;
            white-space: nowrap;
            line-height: 1;
        }

    @media (max-width: 992px) {
        flex-direction: column;
        align-items: flex-start;
        gap: 20px;
    }

    @media (max-width: 768px) {
        padding-right: 0;

        .title-group {
            width: 100%;
            flex-wrap: wrap;
        }
    }
}

.fixed-floating-bar {
    position: absolute;
    bottom: 30px;
    right: 40px;
    display: flex;
    gap: 12px;
    z-index: 100;
    background: rgba(255, 255, 255, 0.4);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    padding: 8px;
    border-radius: 50px;
    border: 1px solid rgba(255, 255, 255, 0.3);
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.12);

    @media (max-width: 768px) {
        bottom: 20px;
        right: 20px;
    }

    .action-circle-btn {
        width: 42px;
        height: 42px;
        border-radius: 50%;
        background: white;
        border: none;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #74D09C;
        font-size: 22px;
        cursor: pointer;
        transition: all 0.2s ease;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);

        &:hover {
            transform: translateY(-3px);
            background: #f0fdf4;
        }

        &.report {
            color: #ff7875;

            &:hover {
                background: #fff1f0;
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

/* 調整圖示垂直位置 */
.icon-v-align {
    vertical-align: middle;
    position: relative;
    top: -2px;
    color: $neutral-color-800;
}

.mb-32 {
    margin-bottom: 32px;
}

.mr-4 {
    margin-right: 4px;
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