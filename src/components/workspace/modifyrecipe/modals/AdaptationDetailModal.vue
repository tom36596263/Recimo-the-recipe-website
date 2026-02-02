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
    const currentUserId = authStore.user?.id || authStore.user?.user_id;
    const recipeAuthorId = props.recipe?.author_id || props.recipe?.user_id;
    if (!currentUserId || !recipeAuthorId) return false;
    return Number(currentUserId) === Number(recipeAuthorId);
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
                user_id: authStore.user?.id || authStore.user?.user_id
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

/**
 * 整合介紹區域所需的資料
 */
const introData = computed(() => {
    if (!props.recipe) return null;
    const r = props.recipe;
    const today = new Date().toISOString().split('T')[0];

    // --- 修正邏輯：找不到作者名稱就設為 null ---
    const resolvedUserName = (isOwner.value
        ? (authStore.user?.user_name || authStore.user?.name)
        : (r.user_name || r.author_name)
    ) || null;

    // Handle 解析
    const emailBase = (isOwner.value
        ? (authStore.user?.user_email || authStore.user?.email)
        : (r.user_email || r.author_email)
    ) || '';
    const resolvedHandle = emailBase ? emailBase.split('@')[0] : '';

    const rawTime = r.totalTime || r.time || 30;
    const formattedTime = String(rawTime).includes('分') ? rawTime : `${rawTime} 分鐘`;

    const rawImg = r.adaptation_image_url || r.coverImg || r.recipe_image_url || '';
    const finalImage = (rawImg && rawImg.startsWith('data:')) ? rawImg : parsePublicFile(rawImg);

    return {
        id: getCleanId(r.id || r.recipe_id),
        title: r.title || r.recipe_title || '未命名食譜',
        image: finalImage,
        description: r.description || r.recipe_description || '暫無詳細說明',
        time: formattedTime,
        difficulty: r.difficulty || 1,
        userName: resolvedUserName,
        handle: resolvedHandle,
        publishTime: r.created_at || today,
        isOwner: isOwner.value,
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
            image: (stepImg && stepImg.startsWith('data:')) ? stepImg : parsePublicFile(stepImg),
            time: s.time || ''
        };
    });
});

const closeModal = () => emit('update:modelValue', false);

const getAvatarStyle = (name) => {
    if (!name) return { backgroundColor: '#eee' };
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
                                <button v-if="isOwner" class="btn-delete-adaptation" @click="handleDelete">
                                    <i-material-symbols-delete-outline-rounded class="mr-4" />
                                    刪除改編
                                </button>

                                <div v-if="introData?.userName" class="user-info-box">
                                    <div class="user-avatar-circle" :style="getAvatarStyle(introData.userName)">
                                        {{ introData.userName.charAt(0).toUpperCase() }}
                                    </div>
                                    <div class="user-text-meta">
                                        <div class="user-name">{{ introData.userName }}</div>
                                        <div class="user-sub">
                                            <span v-if="introData.handle">@{{ introData.handle }} • </span>
                                            {{ introData.publishTime }}
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

.btn-delete-adaptation {
    display: flex;
    align-items: center;
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
    gap: 24px;
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
            border: 1px solid rgba(0, 0, 0, 0.05);
            order: 2;
        }

        .user-text-meta {
            text-align: right;
            order: 1;

            .user-name {
                font-weight: 600;
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
        padding-right: 0;

        .action-group {
            width: 100%;
            flex-direction: column-reverse;
            align-items: flex-end;
            gap: 16px;
        }

        .user-info-box .user-text-meta {
            text-align: left;
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