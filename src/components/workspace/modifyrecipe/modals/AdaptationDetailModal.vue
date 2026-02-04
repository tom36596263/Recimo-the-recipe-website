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

// 2. 定義檢舉彈窗的狀態
const isReportModalOpen = ref(false);

// 3. 處理檢舉提交邏輯
const onReportSubmit = (reportForm) => {
    console.log('改編食譜檢舉內容:', reportForm);
    isReportModalOpen.value = false;
    alert('感謝您的回饋，我們已收到針對此改編版本的檢舉。');
};

/**
 * 處理按讚邏輯 (純前端模擬版)
 */
const handleToggleLike = () => {
    // 雖然不接 PHP，但可以保留登入檢查的邏輯
    if (!authStore.isLoggedIn) {
        alert('請先登入才能為食譜按讚！');
        return;
    }

    const rawId = props.recipe?.id || props.recipe?.recipe_id;

    // 直接計算新狀態並傳給父層
    const newIsLiked = !props.recipe.is_liked;
    const newLikeCount = newIsLiked
        ? (props.recipe.like_count || 0) + 1
        : Math.max(0, (props.recipe.like_count || 0) - 1);

    // 觸發事件讓父層更新 variantItems
    emit('update-like', {
        recipeId: rawId,
        isLiked: newIsLiked,
        likeCount: newLikeCount
    });
};

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

/**
 * 處理分享邏輯：抓取原始食譜 ID 並生成固定格式網址
 */
const handleShare = async () => {
    // 1. 抓取並清理 ID
    // 優先順序：props.recipe.recipe_id (資料庫回傳) 或 props.recipe.id (本地或通用)
    const rawId = props.recipe?.recipe_id || props.recipe?.id;
    const cleanId = getCleanId(rawId);

    if (!cleanId) {
        alert('無法取得食譜 ID，分享失敗');
        return;
    }

    // 2. 組成目標網址 (指向詳情頁)
    const shareUrl = `${window.location.origin}/workspace/recipe-detail/${cleanId}`;

    // 3. 準備分享資料
    const shareData = {
        title: props.recipe?.title || props.recipe?.recipe_title || '分享食譜',
        text: props.recipe?.description || props.recipe?.recipe_description || '來看看這份好吃的食譜！',
        url: shareUrl,
    };

    // 4. 執行分享或複製
    try {
        if (navigator.share) {
            await navigator.share(shareData);
        } else {
            await navigator.clipboard.writeText(shareUrl);
            alert(`網址已複製到剪貼簿：\n${shareUrl}`);
        }
    } catch (err) {
        // 使用者點擊取消分享會進到這裡，不需要特別報錯
        console.warn('分享操作已取消或失敗:', err);
    }
};

const isHubOpen = ref(false);

// --- 份量與營養計算邏輯 ---
// --- 份量與營養計算邏輯 ---

// 1. 取得原始份量 (servings)
// --- 份量與營養計算邏輯 ---

// 1. 取得原始份量與當前選擇份量
const originalServings = computed(() => {
    return Math.max(Number(props.recipe?.recipe_servings || props.recipe?.servings || 1), 1);
});
const currentServings = ref(1);

// 2. 🏆 核心營養計算邏輯 (修正：資料庫已是單份，直接乘人數)
const displayedNutrition = computed(() => {
    const r = props.recipe;
    if (!r) return { calories: 0, protein: 0, fat: 0, carbs: 0 };

    // 資料庫現在存的是「單份」數值 (例如 964)
    const perServingKcal = parseFloat(r.recipe_kcal_per_100g || 0);
    const perServingP = parseFloat(r.recipe_protein_per_100g || 0);
    const perServingF = parseFloat(r.recipe_fat_per_100g || 0);
    const perServingC = parseFloat(r.recipe_carbs_per_100g || 0);

    // 🏆 修改重點：直接乘以「當前畫面上選的人數」
    // 如果畫面上選 2 人，就是 964 * 2 = 1928
    const count = currentServings.value;

    return {
        calories: Math.round(perServingKcal * count),
        protein: Number((perServingP * count).toFixed(1)),
        fat: Number((perServingF * count).toFixed(1)),
        carbs: Number((perServingC * count).toFixed(1))
    };
});

// 3. 食材清單顯示 (隨人數縮放量)
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
                    <button class="action-circle-btn like-btn" :class="{ 'active': recipe?.is_liked }"
                        @click="handleToggleLike">
                        <i-material-symbols-thumb-up-rounded v-if="recipe?.is_liked" />
                        <i-material-symbols-thumb-up-outline-rounded v-else />
                        <span v-if="recipe?.like_count > 0" class="badge like-badge">
                            {{ recipe.like_count }}
                        </span>
                    </button>
                    <button class="action-circle-btn" @click="handleShare" title="分享">
                        <i-material-symbols-share-outline />
                    </button>
                    <button class="action-circle-btn report" @click="isReportModalOpen = true" title="檢舉">
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

                <Teleport to="body">
                    <RecipeReportModal v-if="isReportModalOpen" v-model="isReportModalOpen" :targetData="{
                        recipe_id: introData?.id,
                        title: introData?.title,
                        content: introData?.description,
                        userName: isOwner ? (authStore.user?.user_name || authStore.user?.name) : (recipe.user_name || recipe.author_name || '未知作者'),
                        author_id: recipe.author_id || recipe.user_id,
                        image: introData?.image
                    }" @submit="onReportSubmit" />
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

/* --- 修改後的按讚與 Hub 樣式邏輯 --- */
.fixed-floating-bar {
    position: absolute;
    bottom: 30px;
    right: 40px;
    display: flex;
    align-items: center;
    gap: 12px;
    z-index: 100;

    // 桌機版容器樣式
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
        flex-direction: column-reverse; // 確保按讚在最下面作為主按鈕
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

        svg,
        :deep(svg) {
            fill: currentColor;
        }

        &:hover {
            background: $primary-color-100;
            transform: translateY(-2px);
        }

        // 按讚啟動樣式 (主按鈕樣式)
        &.like-btn.active {
            // background: $primary-color-700 !important;
            // color: $neutral-color-white !important;

            svg,
            :deep(svg) {
                fill: $neutral-color-white !important;
            }
        }

        // 檢舉按鈕專用顏色
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

        // 數字標籤
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
</style>