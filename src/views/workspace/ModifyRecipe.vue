<script setup>
import { ref, watch, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { phpApi } from '@/utils/phpApi';
import { publicApi } from '@/utils/publicApi';
import { parsePublicFile } from '@/utils/parseFile';
import { useNutritionStore } from '@/stores/nutritionStore.js';

import AdaptRecipeCard from '@/components/workspace/modifyrecipe/AdaptRecipeCard.vue';
import AdaptationDetailModal from '@/components/workspace/modifyrecipe/modals/AdaptationDetailModal.vue';

const router = useRouter();
const route = useRoute();
const nutritionStore = useNutritionStore();

// --- 狀態定義 ---
const originalRecipe = ref({ id: null, title: '', coverImg: '', description: '', servings: 1 });
const variantItems = ref([]);

// --- 燈箱控制 ---
const isModalOpen = ref(false);
const selectedRecipe = ref(null);
const currentNutrition = ref(null);

// --- 🏆 Toast 提示狀態 ---
const isToastVisible = ref(false);
const toastMessage = ref('');

/**
 * 顯示全域 Toast
 */
function showToast(msg) {
    toastMessage.value = msg;
    isToastVisible.value = true;
    setTimeout(() => {
        isToastVisible.value = false;
    }, 3000);
}

/**
 * 打開改編詳情燈箱
 */
async function openAdaptDetail(item) {
    selectedRecipe.value = {
        ...item,
        servings: 1
    };

    if (!nutritionStore.isLoaded) {
        await nutritionStore.fetchMasterData();
    }

    if (item.ingredients && item.ingredients.length > 0) {
        const total = nutritionStore.calculateRecipeNutrition(item.ingredients);
        currentNutrition.value = {
            calories: Math.round(total.kcal),
            protein: total.protein.toFixed(1),
            fat: total.fat.toFixed(1),
            carbs: total.carbs.toFixed(1)
        };
    } else {
        currentNutrition.value = { calories: 0, protein: 0, fat: 0, carbs: 0 };
    }
    isModalOpen.value = true;
}

/**
 * 從後端載入食譜完整資料
 */
async function loadRecipeData(recipeId) {
    try {
        const res = await phpApi.get('recipes/recipe_detail_get.php', {
            params: { recipe_id: recipeId }
        });
        const apiResponse = res.data;
        if (!apiResponse.success || !apiResponse.data) return;

        const { main, adaptations } = apiResponse.data;
        if (!main) return;

        originalRecipe.value = {
            id: main.recipe_id,
            title: main.recipe_title,
            description: main.recipe_description || main.recipe_descreption || '暫無簡介',
            coverImg: parsePublicFile(main.recipe_image_url),
            servings: Number(main.recipe_servings || 2)
        };

        const formattedDbAdaptations = (adaptations || []).map(child => {
            const shortDisplay = child.adaptation_note ||
                (child.recipe_description ? child.recipe_description.slice(0, 15) + '...' : '點擊查看改編重點');

            return {
                ...child,
                id: `db-${child.recipe_id}`,
                title: child.recipe_title || '未命名食譜',
                card_summary: shortDisplay,
                description: child.recipe_description,
                recipe_description: child.recipe_description,
                adaptation_note: child.adaptation_note,
                coverImg: parsePublicFile(child.recipe_image_url),
                is_mine: false,
                ingredients: child.ingredients || [],
                steps: child.steps || child.recipe_steps || [],
                servings: Number(child.recipe_servings || 2)
            };
        });

        const targetParentId = Number(recipeId);
        const localRevisions = JSON.parse(localStorage.getItem('user_revisions') || '[]');
        const localAdaptations = localRevisions
            .filter(r => Number(r.parent_recipe_id) === targetParentId)
            .map(r => ({
                ...r,
                id: r.id,
                title: r.title || '未命名改編',
                description: r.description || r.recipe_description || r.adapt_description || '',
                ingredients: r.ingredients || [],
                steps: r.steps || [],
                servings: Number(r.servings || r.recipe_servings || 1),
                is_mine: true
            }));

        variantItems.value = [...localAdaptations, ...formattedDbAdaptations];
    } catch (err) {
        console.error('❌ 載入失敗:', err.message);
    }
}

// 🏆 刪除功能 + Toast
function deleteLocalRecipe(targetId) {
    if (!confirm('確定要刪除這個本地改編版本嗎？')) return;
    const localData = JSON.parse(localStorage.getItem('user_revisions') || '[]');
    const filtered = localData.filter(r => String(r.id) !== String(targetId));
    localStorage.setItem('user_revisions', JSON.stringify(filtered));

    // 
    handleDelete(targetId);
}

// 🏆 發布成功處理 (由燈箱 emit 過來)
function handlePublishSuccess() {
    isModalOpen.value = false;
    showToast('作品已發布'); // <--- 觸發 Toast
    loadRecipeData(route.params.id || route.query.editId);
}

function initEmptyRecipe() {
    originalRecipe.value = { id: null, title: '新食譜', coverImg: '', description: '', servings: 1 };
    variantItems.value = [];
}

function handleCreateNew() {
    if (!originalRecipe.value.id) return;
    router.push({
        path: '/workspace/edit-recipe',
        query: { editId: originalRecipe.value.id, action: 'adapt' }
    });
}

function goBack() {
    if (!originalRecipe.value.id) return;
    router.push(`/workspace/recipe-detail/${originalRecipe.value.id}`);
}

function handleLikeUpdate(data) {
    const target = variantItems.value.find(item => String(item.id) === String(data.recipeId));
    if (target) {
        target.is_liked = data.isLiked;
        target.like_count = data.likeCount;
        if (selectedRecipe.value && String(selectedRecipe.value.id) === String(data.recipeId)) {
            selectedRecipe.value.is_liked = data.isLiked;
            selectedRecipe.value.like_count = data.likeCount;
        }
    }
}

function handleDelete(recipeId) {
    // 1. 顯示黑色膠囊提示
    showToast('作品已刪除');

    // 2. 重新從 API 載入最新資料，確保畫面同步
    const currentId = route.params.id || route.query.editId;
    if (currentId) {
        loadRecipeData(currentId);
    }
}

onMounted(async () => {
    await nutritionStore.fetchMasterData();
    const recipeId = route.params.id || route.query.editId;
    if (recipeId) {
        loadRecipeData(recipeId);
    } else {
        initEmptyRecipe();
    }
});

watch(() => route.params.id, (newId) => {
    if (newId) loadRecipeData(newId);
});
</script>

<template>
    <div class="variants-gallery container">
        <div class="row mb-40 desktop-only-btn fade-in-down">
            <div class="col-12 text-right">
                <BaseBtn title="返回原食譜" variant="outline" :width="120" @click="goBack" />
            </div>
        </div>

        <section class="original-recipe-hero mb-40">
            <div class="row align-center">
                <div class="col-7 col-md-12">
                    <div class="main-image-container">
                        <img :src="originalRecipe.coverImg" class="hero-img" />
                    </div>
                </div>
                <div class="col-5 col-md-12">
                    <div class="info-content">
                        <h1 class="zh-h2 mb-16">{{ originalRecipe.title }}</h1>
                        <p class="p-p1 color-p1 mb-24">{{ originalRecipe.description }}</p>
                        <div class="stat-tag p-p3 mb-24">
                            共有 {{ variantItems.length }} 個改編版本
                        </div>
                        <div class="mobile-only-btn">
                            <BaseBtn title="返回原食譜" variant="outline" class="w-100" @click="goBack" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="decorative-line"></div>
        </section>

        <div class="row align-stretch custom-grid">
            <div class="col-3 col-lg-4 col-md-6 mb-24 grid-item">
                <div class="add-card-placeholder full-height" @click="handleCreateNew">
                    <div class="add-content">
                        <span class="plus-icon">+</span>
                        <p class="zh-h4">創建食譜</p>
                        <p class="p-p3 uppercase">add recipe</p>
                    </div>
                </div>
            </div>

            <TransitionGroup name="staggered-list">
                <div v-for="(item, index) in variantItems" :key="item.id"
                    class="col-3 col-lg-4 col-md-6 mb-24 grid-item" :style="{
                        '--delay': index + 1,
                        'cursor': String(item.id).startsWith('json-') ? 'default' : 'pointer'
                    }" @click="openAdaptDetail(item)">

                    <div class="card-wrapper" style="position: relative; height: 100%;">
                        <AdaptRecipeCard class="demo-readonly-card" :recipe="{
                            adaptation_title: item.adaptation_title,
                            title: item.title,
                            adaptation_note: item.adaptation_note || item.summary,
                            coverImg: item.coverImg
                        }" :readonly="true" />

                        <button v-if="item.is_mine" class="local-delete-btn" title="刪除此改編版本"
                            @click.stop="deleteLocalRecipe(item.id)">
                            ✕
                        </button>
                    </div>
                </div>
            </TransitionGroup>
        </div>

        <AdaptationDetailModal v-model="isModalOpen" :recipe="selectedRecipe" :nutrition="currentNutrition"
            @update-like="handleLikeUpdate" @publish-success="handlePublishSuccess" @delete-recipe="handleDelete" />

        <Transition name="toast">
            <div v-if="isToastVisible" class="global-delete-toast">
                <i-material-symbols-check-circle-rounded class="toast-icon" />
                <span>{{ toastMessage }}</span>
            </div>
        </Transition>
    </div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

// 🏆 Toast 專用樣式 (你提供的版本)
.global-delete-toast {
    position: fixed;
    top: 40px;
    left: 50%;
    transform: translateX(-50%);
    z-index: 20000;
    background-color: #323232;
    color: white;
    padding: 14px 28px;
    border-radius: 50px;
    display: flex;
    align-items: center;
    gap: 12px;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.25);
    pointer-events: none;
}

.toast-icon {
    color: #2ecc71 !important;
    /* 亮綠色勾勾 */
    font-size: 20px !important;
}

.toast-enter-active,
.toast-leave-active {
    transition: all 0.4s ease;
}

.toast-enter-from,
.toast-leave-to {
    opacity: 0;
    transform: translate(-50%, -40px);
}

// --- 以下為原本的 CSS (保持原樣) ---
.mobile-only-btn {
    display: none !important;
}

.desktop-only-btn {
    display: block;
}

.fade-in-down {
    animation: fadeInDown 0.6s ease-out;
}

.original-recipe-hero {
    animation: fadeInUp 0.8s ease-out;

    .main-image-container {
        overflow: hidden;
        width: 100%;
        height: 320px;
        border-radius: 16px;
        background-color: $neutral-color-100;

        .hero-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
    }

    .info-content {
        padding-left: 32px;
    }
}

.staggered-list-enter-active {
    transition: all 0.6s cubic-bezier(0.34, 1.56, 0.64, 1);
    transition-delay: calc(var(--delay) * 0.1s);
}

.staggered-list-enter-from {
    opacity: 0;
    transform: translateY(40px) scale(0.9);
}

.decorative-line {
    height: 10px;
    background-color: $primary-color-100;
    border-radius: 4px;
    margin-top: 40px;
    transform-origin: left;
    animation: lineExtend 1s cubic-bezier(0.65, 0, 0.35, 1) forwards;
}

@keyframes fadeInDown {
    from {
        opacity: 0;
        transform: translateY(-20px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}

@keyframes fadeInUp {
    from {
        opacity: 0;
        transform: translateY(30px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}

@keyframes lineExtend {
    from {
        transform: scaleX(0);
    }

    to {
        transform: scaleX(1);
    }
}

.custom-grid {
    display: flex;
    flex-wrap: wrap;

    &>span {
        display: contents;
    }
}

.variants-gallery {
    padding: 20px 0 60px;
}

.text-right {
    text-align: right;
}

.w-100 {
    width: 100% !important;
}

.add-card-placeholder {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    border: 2px dashed $primary-color-400;
    border-radius: 12px;
    cursor: pointer;
    transition: all 0.3s ease;
    padding: 40px 20px;

    &:hover {
        background-color: $primary-color-100;
        transform: translateY(-8px);
        border-style: solid;
    }

    .add-content {
        text-align: center;
        color: $primary-color-700;

        .plus-icon {
            font-size: 56px;
            display: block;
        }
    }
}

.demo-readonly-card {
    cursor: pointer;
    transition: all 0.4s cubic-bezier(0.165, 0.84, 0.44, 1);

    &:hover {
        transform: scale(1.05);
        box-shadow: 0 15px 35px rgba(0, 0, 0, 0.12);
    }

    :deep(.key-change-badge),
    :deep(.key-change-wrapper),
    :deep(.change-hint-overlay),
    :deep(.hover-overlay),
    :deep(.mask),
    :deep(.result-overlay),
    :deep(.adaptation-hover-info),
    :deep(.adaptation-result),
    :deep(.adapt-result-text),
    :deep(.overlay),
    :deep(.overlay-content) {
        display: none !important;
        opacity: 0 !important;
        visibility: hidden !important;
        pointer-events: none !important;
    }
}

@media screen and (max-width: 810px) {
    .desktop-only-btn {
        display: none !important;
    }

    .mobile-only-btn {
        display: block !important;
        margin-top: 16px;
    }

    .original-recipe-hero {
        .info-content {
            padding-left: 0;
            margin-top: 16px;
        }

        .main-image-container {
            height: 240px;
        }
    }

    .custom-grid {
        .grid-item {
            flex: 0 0 50% !important;
            max-width: 50% !important;
            padding: 0 8px !important;
        }
    }
}

.card-wrapper {
    &:hover {
        .local-delete-btn {
            opacity: 1;
        }
    }
}

.local-delete-btn {
    position: absolute;
    top: -10px;
    right: -10px;
    width: 28px;
    height: 28px;
    background-color: #ff4d4f;
    color: white;
    border: 2px solid white;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    cursor: pointer;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    z-index: 20;
    opacity: 0;
    transition: all 0.3s ease;

    &:hover {
        background-color: #ff7875;
        transform: scale(1.1);
    }
}

.full-height {
    height: 100%;
}

.mb-16 {
    margin-bottom: 16px;
}

.mb-24 {
    margin-bottom: 24px;
}

.mb-40 {
    margin-bottom: 40px;
}
</style>