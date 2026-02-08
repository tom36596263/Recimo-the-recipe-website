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

// 取得原始份量與當前選擇份量
const originalServings = computed(() => {
    const r = props.recipe?.main || props.recipe;
    const s = r?.recipe_servings || r?.servings || 1;
    return Math.max(Number(s), 1);
});

// 預設份量設為 1
const currentServings = ref(1);

// 修正後的計算邏輯
// 修正後的計算邏輯 - 保持你的公式不變，僅對齊欄位
const displayedNutrition = computed(() => {
    // 優先檢查 props.recipe.main，若無則用 props.recipe (相容不同 API 結構)
    const r = props.recipe?.main || props.recipe;
    if (!r) return { calories: 0, protein: 0, fat: 0, carbs: 0 };

    // 🏆 欄位對接：轉為數字以利計算
    const perKcal = parseFloat(r.recipe_kcal_per_100g || 0);
    const perP = parseFloat(r.recipe_protein_per_100g || 0);
    const perF = parseFloat(r.recipe_fat_per_100g || 0);
    const perC = parseFloat(r.recipe_carbs_per_100g || 0);

    // 🏆 邏輯保持：數值 * 當前選擇的人數 (currentServings)
    const count = currentServings.value;

    return {
        calories: Math.round(perKcal * count),
        protein: Number((perP * count).toFixed(1)),
        fat: Number((perF * count).toFixed(1)),
        carbs: Number((perC * count).toFixed(1))
    };
});

const ingredientsData = computed(() => {
    // 確保抓到陣列
    const list = props.recipe?.ingredients || [];

    // 計算份量比例 (保持你的邏輯)
    const ratio = currentServings.value;

    return list.map(item => {
        const rawAmount = parseFloat(item.amount || item.INGREDIENT_AMOUNT || 0);

        return {
            // 對齊資料庫回傳的欄位名
            INGREDIENT_NAME: item.ingredient_name || item.name || '未知食材',
            amount: isNaN(rawAmount) ? 0 : (rawAmount * ratio).toFixed(1),
            unit_name: item.unit_name || item.unit || 'g',
            note: item.remark || item.note || ''
        };
    });
});

watch(() => props.recipe, (newVal) => {
    console.log('當前用戶 ID:', authStore.user?.user_id || authStore.user?.id);
    console.log('食譜作者 ID:', newVal?.author_id || newVal?.user_id);
    console.log('比對結果:', isOwner.value);
}, { immediate: true });

const introData = computed(() => {
    if (!props.recipe) return null;
    const r = props.recipe;

    // 🏆 修改 1: 時間對齊 recipe_total_time
    const rawTime = r.recipe_total_time || r.totalTime || r.time || 30;
    const formattedTime = String(rawTime).includes('分') ? rawTime : `${rawTime} 分鐘`;

    // --- 圖片路徑清洗邏輯保持不變 ---
    let rawImg = r.adaptation_image_url || r.coverImg || r.recipe_image_url || '';
    let finalImage = '';
    if (!rawImg) {
        finalImage = '';
    } else if (rawImg.startsWith('data:') || rawImg.startsWith('http')) {
        finalImage = rawImg;
    } else if (rawImg.includes('/cjd102/g2/')) {
        finalImage = `${window.location.origin}${rawImg.startsWith('/') ? '' : '/'}${rawImg}`;
    } else {
        finalImage = parsePublicFile(rawImg);
    }

    return {
        id: getCleanId(r.recipe_id || r.id),
        // 🏆 修改 2: 標題優先對齊 recipe_title
        title: r.adaptation_title || r.recipe_title || r.title || '未命名食譜',
        image: finalImage,
        // 🏆 修改 3: 描述優先對齊 recipe_description
        description: r.recipe_description || r.description || '暫無詳細說明',
        difficulty: r.recipe_difficulty || r.difficulty || 1,
        tags: r.tags || [],
        time: formattedTime
    };
});

/**
 * 整合步驟資料
 */
const stepsData = computed(() => {
    const steps = props.recipe?.steps || [];
    return steps.map((s, idx) => {
        let stepImg = s.image || s.step_image_url || '';
        let finalStepImg = '';

        if (!stepImg) {
            finalStepImg = '';
        } else if (stepImg.startsWith('data:') || stepImg.startsWith('http')) {
            finalStepImg = stepImg;
        } else if (stepImg.includes('/cjd102/g2/')) {
            // 🔥 防止步驟圖片也發生重複路徑問題
            finalStepImg = `${window.location.origin}${stepImg.startsWith('/') ? '' : '/'}${stepImg}`;
        } else {
            finalStepImg = parsePublicFile(stepImg);
        }

        return {
            id: s.id || idx,
            title: s.step_title || s.title || `步驟 ${idx + 1}`,
            content: s.content || s.step_content || s.description || '',
            image: finalStepImg,
            time: s.time || ''
        };
    });
});

const closeModal = () => emit('update:modelValue', false);

/**
 * 處理跳轉編輯頁面
 */
/**
 * 處理跳轉編輯頁面
 */
const handleGoToEdit = () => {
    const rawId = props.recipe?.recipe_id || props.recipe?.id;
    const cleanId = getCleanId(rawId);

    if (!cleanId) {
        alert('無法取得食譜 ID，無法編輯');
        return;
    }

    // 跳轉至編輯頁
    router.push({
        path: '/workspace/edit-recipe',
        query: {
            editId: cleanId,
            // 🔥 關鍵修改：改為 edit_adaptation
            // 這樣 EditRecipe.vue 的 onMounted 才會正確執行「載入舊改編」的邏輯
            action: 'edit_adaptation'
        }
    });
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
                        <span v-if="recipe?.like_count > 0" class="badge like-badge">
                            {{ recipe.like_count }}
                        </span>
                    </button>

                    <button v-if="isOwner" class="action-circle-btn edit-btn custom-tooltip" @click="handleGoToEdit"
                        data-tooltip="編輯此改編版本">
                        <i-material-symbols-edit />
                    </button>

                    <button class="action-circle-btn custom-tooltip" @click="handleShare" data-tooltip="分享此版本">
                        <i-material-symbols-share-outline />
                    </button>

                    <button class="action-circle-btn report custom-tooltip" @click="isReportModalOpen = true"
                        data-tooltip="檢舉內容">
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
                                    :name="isOwner ? (authStore.user?.user_name || authStore.user?.name) : (recipe.author_name || 'Recimo 用戶')"
                                    :handle="`user_${recipe.author_id || recipe.user_id || 'unknown'}`"
                                    :time="recipe.recipe_created_at || recipe.created_at || '剛剛'" />

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
                                        :servings="currentServings" :base-servings="originalServings"
                                        @change-servings="val => currentServings = val" />
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

        &.edit-btn {
                color: $primary-color-700; // 使用你的主色調
        
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

/* --- 自定義漂亮的提示框 (Modal 專用) --- */
.custom-tooltip {
    position: relative;

    &::before {
        content: attr(data-tooltip);
        position: absolute;
        bottom: 125%; // 電腦版預設：顯示在按鈕上方
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
        z-index: 2100; // 確保高於 Modal

        // 🏆 手機版調整：向左彈出
        @media screen and (max-width: 809px) {
            bottom: auto;
            left: auto;
            right: 130%; // 稍微拉開一點距離
            top: 50%;
            transform: translateY(-50%) translateX(10px);
        }
    }

    &::after {
        content: '';
        position: absolute;
        bottom: 110%; // 電腦版預設：箭頭在下
        left: 50%;
        transform: translateX(-50%);
        border: 6px solid transparent;
        border-top-color: $primary-color-700;
        opacity: 0;
        visibility: hidden;
        transition: all 0.3s ease;
        z-index: 2100;

        // 🏆 手機版調整：箭頭轉向右側（指回按鈕）
        @media screen and (max-width: 809px) {
            bottom: auto;
            left: auto;
            right: 110%;
            top: 50%;
            transform: translateY(-50%);
            border-top-color: transparent;
            border-left-color: $primary-color-700; // 指向按鈕
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

    // 檢舉按鈕提示變紅色
    &.report {
        &::before {
            background-color: $accent-color-700;
        }

        &::after {

            // 電腦版顏色
            @media screen and (min-width: 810px) {
                border-top-color: $accent-color-700;
            }

            // 手機版顏色
            @media screen and (max-width: 809px) {
                border-left-color: $accent-color-700;
            }
        }
    }
}

</style>