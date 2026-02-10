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
import RecipeReportModal from '@/components/workspace/recipedetail/modals/RecipeReportModal.vue';
import BaseModal from '@/components/BaseModal.vue';

const props = defineProps({
    modelValue: Boolean,
    recipe: Object,
    nutrition: {
        type: Object,
        default: () => ({ calories: 0, protein: 0, fat: 0, carbs: 0 })
    }
});

const emit = defineEmits(['update:modelValue', 'delete-recipe', 'update-like']);
const router = useRouter();
const authStore = useAuthStore();

const getCleanId = (id) => {
    if (!id) return '';
    return String(id).replace(/[^\d]/g, '');
};

const isOwner = computed(() => {
    const currentUserId = authStore.user?.user_id || authStore.user?.id;
    const authorId = props.recipe?.author_id || props.recipe?.user_id;
    if (!currentUserId || !authorId) return false;
    return Number(currentUserId) === Number(authorId);
});

const isReportModalOpen = ref(false);
const isReportSuccessOpen = ref(false); // 🏆 檢舉成功狀態
const isDeleteModalOpen = ref(false);

const onReportSubmit = (reportForm) => {
    isReportModalOpen.value = false;
    isReportSuccessOpen.value = true; // 🏆 開啟成功燈箱
};

const handleToggleLike = () => {
    if (!authStore.isLoggedIn) {
        alert('請先登入才能為食譜按讚！');
        return;
    }
    const rawId = props.recipe?.id || props.recipe?.recipe_id;
    const newIsLiked = !props.recipe.is_liked;
    const newLikeCount = newIsLiked
        ? (props.recipe.like_count || 0) + 1
        : Math.max(0, (props.recipe.like_count || 0) - 1);

    emit('update-like', {
        recipeId: rawId,
        isLiked: newIsLiked,
        likeCount: newLikeCount
    });
};

/**
 * 🏆 實際執行刪除邏輯
 */
const confirmDelete = async () => {
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
                isDeleteModalOpen.value = false;
                emit('delete-recipe', rawId);
                closeModal();
            } else {
                alert('刪除失敗：' + (res.data.message || '未知錯誤'));
            }
        } catch (err) {
            console.error('刪除 API 請求出錯:', err);
            alert('連線伺服器失敗');
        }
    } else {
        isDeleteModalOpen.value = false;
        emit('delete-recipe', rawId);
        closeModal();
    }
};

const handleShare = async () => {
    const rawId = props.recipe?.recipe_id || props.recipe?.id;
    const cleanId = getCleanId(rawId);
    if (!cleanId) return;
    const shareUrl = `${window.location.origin}/workspace/recipe-detail/${cleanId}`;
    try {
        if (navigator.share) {
            await navigator.share({ title: props.recipe?.title, url: shareUrl });
        } else {
            await navigator.clipboard.writeText(shareUrl);
            alert(`網址已複製`);
        }
    } catch (err) { console.warn(err); }
};

const originalServings = computed(() => {
    const r = props.recipe?.main || props.recipe;
    return Math.max(Number(r?.recipe_servings || r?.servings || 1), 1);
});

const currentServings = ref(1);

const displayedNutrition = computed(() => {
    const r = props.recipe?.main || props.recipe;
    if (!r) return { calories: 0, protein: 0, fat: 0, carbs: 0 };
    const ratio = currentServings.value;
    return {
        calories: Math.round(parseFloat(r.recipe_kcal_per_100g || 0) * ratio),
        protein: Number((parseFloat(r.recipe_protein_per_100g || 0) * ratio).toFixed(1)),
        fat: Number((parseFloat(r.recipe_fat_per_100g || 0) * ratio).toFixed(1)),
        carbs: Number((parseFloat(r.recipe_carbs_per_100g || 0) * ratio).toFixed(1))
    };
});

const ingredientsData = computed(() => {
    const list = props.recipe?.ingredients || [];
    const ratio = currentServings.value;
    return list.map(item => ({
        INGREDIENT_NAME: item.ingredient_name || item.name || '未知食材',
        amount: (parseFloat(item.amount || 0) * ratio).toFixed(1),
        unit_name: item.unit_name || item.unit || 'g',
        note: item.remark || item.note || ''
    }));
});

const introData = computed(() => {
    if (!props.recipe) return null;
    const r = props.recipe;
    let rawImg = r.recipe_image_url || r.adaptation_image_url || r.coverImg || '';
    const processedImg = (rawImg && (rawImg.includes('http') || rawImg.startsWith('data:')))
        ? rawImg
        : (rawImg ? parsePublicFile(rawImg) : '');

    return {
        id: getCleanId(r.recipe_id || r.id),
        title: r.adaptation_title || r.recipe_title || r.title || '未命名食譜',
        image: processedImg,
        description: r.recipe_description || r.description || '暫無詳細說明',
        difficulty: r.recipe_difficulty || r.difficulty || 1,
        tags: r.tags || [],
        time: String(r.recipe_total_time || 30).includes('分') ? r.recipe_total_time : `${r.recipe_total_time || 30} 分鐘`
    };
});

const stepsData = computed(() => {
    return (props.recipe?.steps || []).map((s, idx) => ({
        id: s.id || idx,
        title: s.step_title || s.title || `步驟 ${idx + 1}`,
        content: s.content || s.step_content || '',
        image: s.step_image_url ? (s.step_image_url.includes('http') ? s.step_image_url : parsePublicFile(s.step_image_url)) : '',
    }));
});

const closeModal = () => emit('update:modelValue', false);

const handleGoToEdit = () => {
    const cleanId = getCleanId(props.recipe?.recipe_id || props.recipe?.id);
    if (!cleanId) return;
    router.push({ path: '/workspace/edit-recipe', query: { editId: cleanId, action: 'edit_adaptation' } });
};
</script>

<template>
    <Transition name="modal-fade">
        <div v-if="modelValue" class="adaptation-modal-overlay" @click.self="closeModal">
            <div class="modal-window">
                <button class="close-x" @click="closeModal">✕</button>

                <div class="fixed-floating-bar">
                    <button class="action-circle-btn like-btn custom-tooltip" :class="{ 'active': recipe?.is_liked }"
                        @click="handleToggleLike" :data-tooltip="recipe?.is_liked ? '取消讚' : '這份改編很讚'">
                        <i-material-symbols-thumb-up-rounded v-if="recipe?.is_liked" />
                        <i-material-symbols-thumb-up-outline-rounded v-else />
                        <span v-if="recipe?.like_count > 0" class="badge like-badge">{{ recipe.like_count }}</span>
                    </button>
                    <button v-if="isOwner" class="action-circle-btn edit-btn custom-tooltip" @click="handleGoToEdit"
                        data-tooltip="編輯">
                        <i-material-symbols-edit />
                    </button>
                    <button class="action-circle-btn custom-tooltip" @click="handleShare" data-tooltip="分享">
                        <i-material-symbols-share-outline />
                    </button>
                    <button class="action-circle-btn report custom-tooltip" @click="isReportModalOpen = true"
                        data-tooltip="檢舉">
                        <i-material-symbols-error-outline-rounded />
                    </button>
                </div>

                <div class="modal-scroll-body">
                    <div class="container-fluid">
                        <div class="modal-title-bar mb-32">
                            <div class="title-group">
                                <h2 class="zh-h2"><i-material-symbols-restaurant-rounded class="mr-8 icon-v-align" />{{
                                    introData?.title }}</h2>
                                <span class="badge">改編版本</span>
                            </div>
                            <div class="action-group">
                                <AuthorInfo
                                    :user-id="isOwner ? (authStore.user?.id || authStore.user?.user_id) : recipe.author_id"
                                    :name="isOwner ? (authStore.user?.user_name || authStore.user?.name) : (recipe.author_name || 'Recimo 用戶')"
                                    :handle="isOwner ? (authStore.user?.user_email) : (recipe.user_email || `user_${recipe.author_id}`)"
                                    :time="recipe.recipe_created_at || '剛剛'"
                                    :avatar-url="isOwner ? (authStore.user?.user_url || authStore.user?.avatarUrl) : (recipe.author_image || recipe.user_url)" />
                                <button v-if="isOwner" class="btn-delete-adaptation" @click="isDeleteModalOpen = true">
                                    <i-material-symbols-delete-outline-rounded class="mr-4" />刪除改編
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
                                        :servings="currentServings" :base-servings="originalServings"
                                        @change-servings="val => currentServings = val" />
                                    <RecipeIngredients :list="ingredientsData" :readonly="true" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <Teleport to="body">
                    <RecipeReportModal v-if="isReportModalOpen && introData" v-model="isReportModalOpen" :targetData="{
                        recipe_id: introData.id,
                        title: introData.title,
                        image: introData.image,
                        author_name: recipe.author_name || recipe.user_name || 'Recimo 用戶'
                    }" @submit="onReportSubmit" />

                    <BaseModal :isOpen="isReportSuccessOpen" type="success" iconClass="fa-solid fa-circle-check"
                        title="檢舉已成功送出！" @close="isReportSuccessOpen = false">
                        <template #default>
                            <div style="margin-top: 8px; margin-bottom: 8px; text-align: center;">
                                <p class="p-p2" style="color: #666;">感謝您的回饋，我們已收到針對此改編版本的檢舉。<br>管理團隊將會盡快審核並處理。</p>
                            </div>
                        </template>

                        <template #actions>
                            <div
                                style="display: flex; width: 100%; justify-content: center; margin-top: 25px; margin-bottom: 5px;">
                                <BaseBtn title="太好了！" variant="solid" style="width: 130px;"
                                    @click="isReportSuccessOpen = false" />
                            </div>
                        </template>
                    </BaseModal>

                    <BaseModal :isOpen="isDeleteModalOpen" type="info" iconClass="fa-regular fa-trash-can"
                        title="確定要刪除您的改編版本嗎？" @close="isDeleteModalOpen = false">
                        <template #default>
                            <div style="margin-top: 8px; margin-bottom: 8px; text-align: center;">
                                <p class="p-p2" style="color: #666;">此操作將無法復原，您將永久失去這份紀錄。</p>
                            </div>
                        </template>

                        <template #actions>
                            <div
                                style="display: flex; gap: 16px; width: 100%; justify-content: center; align-items: center; margin-top: 25px; margin-bottom: 5px;">
                                <BaseBtn title="確定刪除" variant="solid" style="width: 130px;" @click="confirmDelete" />
                                <BaseBtn title="取消" variant="outline" style="width: 130px;"
                                    @click="isDeleteModalOpen = false" />
                            </div>
                        </template>
                    </BaseModal>
                </Teleport>
            </div>
        </div>
    </Transition>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.btn-delete-adaptation {
    display: flex;
    align-items: center;
    white-space: nowrap;
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
    gap: 20px;

    :deep(.author-info-wrapper) {
        margin-bottom: 0;
    }

    @media (max-width: 768px) {
        width: 100%;
        flex-direction: row;
        justify-content: space-between;
        align-items: center;
        gap: 12px;
    }

    @media (max-width: 480px) {
        flex-direction: column;
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
    align-items: center;
    gap: 12px;
    z-index: 100;
    background: rgba(255, 255, 255, 0.6);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    padding: 10px 16px;
    border-radius: 50px;
    border: 1px solid rgba(255, 255, 255, 0.3);
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);

    @media (max-width: 768px) {
        bottom: 20px;
        right: 20px;
        flex-direction: column-reverse;
        padding: 0;
        background: transparent;
        border: none;
        box-shadow: none;
        backdrop-filter: none;
    }

    .action-circle-btn {
        width: 44px;
        height: 44px;
        border-radius: 50%;
        background: $neutral-color-white;
        border: none;
        display: flex;
        align-items: center;
        justify-content: center;
        color: $primary-color-700;
        font-size: 22px;
        cursor: pointer;
        transition: all 0.3s ease;
        position: relative;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);

        &.edit-btn {
            color: $primary-color-700;

            &:hover {
                background-color: $primary-color-100;
                color: $primary-color-700;
            }
        }

        svg,
        :deep(svg) {
            fill: currentColor;
        }

        &:hover {
            background: $primary-color-100;
            transform: translateY(-2px);
        }

        &.like-btn.active {

            svg,
            :deep(svg) {
                fill: $neutral-color-white !important;
            }
        }

        &.report {
            color: $accent-color-700 !important;

            svg,
            :deep(svg) {
                fill: $accent-color-700;
            }

            &:hover {
                background: $neutral-color-100;
            }
        }

        .like-badge {
            position: absolute;
            top: -5px;
            right: -5px;
            background: $primary-color-400;
            color: $neutral-color-white;
            font-size: 10px;
            padding: 2px 6px;
            border-radius: 10px;
            border: 2px solid $neutral-color-white;
            font-weight: bold;
            line-height: 1;
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

.icon-v-align {
    vertical-align: middle;
    position: relative;
    top: -2px;
    color: $neutral-color-800;
}

.modal-scroll-body {
    &::-webkit-scrollbar {
        width: 8px;
    }

    &::-webkit-scrollbar-track {
        background: transparent;
    }

    &::-webkit-scrollbar-thumb {
        background: $neutral-color-100;
        border-radius: 10px;
        border: 2px solid transparent;
        background-clip: padding-box;

        &:hover {
            background: $neutral-color-400;
        }
    }

    scrollbar-width: thin;
    scrollbar-color: $neutral-color-100;
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

.custom-tooltip {
    position: relative;

    &::before {
        content: attr(data-tooltip);
        position: absolute;
        bottom: 125%;
        left: 50%;
        transform: translateX(-50%) translateY(10px);
        background-color: $primary-color-700;
        color: $neutral-color-white;
        padding: 6px 12px;
        border-radius: 8px;
        font-size: 12px;
        white-space: nowrap;
        opacity: 0;
        visibility: hidden;
        transition: all 0.3s cubic-bezier(0.18, 0.89, 0.32, 1.28);
        pointer-events: none;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        z-index: 2100;

        @media screen and (max-width: 809px) {
            bottom: auto;
            left: auto;
            right: 130%;
            top: 50%;
            transform: translateY(-50%) translateX(10px);
        }
    }

    &::after {
        content: '';
        position: absolute;
        bottom: 110%;
        left: 50%;
        transform: translateX(-50%);
        border: 6px solid transparent;
        border-top-color: $primary-color-700;
        opacity: 0;
        visibility: hidden;
        transition: all 0.3s ease;
        z-index: 2100;

        @media screen and (max-width: 809px) {
            bottom: auto;
            left: auto;
            right: 110%;
            top: 50%;
            transform: translateY(-50%);
            border-top-color: transparent;
            border-left-color: $primary-color-700;
        }
    }

    &:hover {
        &::before {
            opacity: 1;
            visibility: visible;

            @media screen and (min-width: 810px) {
                transform: translateX(-50%) translateY(0);
            }

            @media screen and (max-width: 809px) {
                transform: translateY(-50%) translateX(0);
            }
        }

        &::after {
            opacity: 1;
            visibility: visible;
        }
    }

    &.report {
        &::before {
            background-color: $accent-color-700;
        }

        &::after {
            @media screen and (min-width: 810px) {
                border-top-color: $accent-color-700;
            }

            @media screen and (max-width: 809px) {
                border-left-color: $accent-color-700;
            }
        }
    }
}

/* 使用 :deep 穿透並鎖定 .modal-card.success 結構 */
:deep(.modal-card.success) {
    /* 1. 關鍵：增加底部 padding，確保按鈕有生存空間 */
    padding: 40px 24px 40px !important;

    /* 2. 關鍵：不要設定固定高度，讓內容決定高度 */
    height: auto !important;
    min-height: 280px;

    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    /* 讓內容垂直置中 */

    /* 針對按鈕容器的微調 */
    .modal-actions,
    .modal-footer {
        margin-top: 24px;
        /* 增加文字與按鈕之間的間距 */
        margin-bottom: 0;
        width: 100%;
        display: flex;
        justify-content: center;

        .base-btn {
            /* 讓按鈕不要貼底 */
            margin-bottom: 0;
            transform: translateY(-5px);
            /* 輕微往上提昇視覺重心 */
        }
    }

}

/* 針對「刪除確認」燈箱的同步修正 */
:deep(.modal-card.info) {
    max-width: 420px;

    .modal-icon {
        color: #ff4d4f;
    }

    .base-btn.variant-solid {
        background-color: #ff4d4f !important;

        &:hover {
            background-color: #d9363e !important;
        }
    }
}
</style>