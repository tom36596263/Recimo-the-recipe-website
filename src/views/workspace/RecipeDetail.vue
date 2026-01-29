<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { publicApi } from '@/utils/publicApi';
import { useRecipeStore } from '@/stores/recipeEditor';

// 引用元件 
import RecipeSteps from '../../components/workspace/recipedetail/RecipeSteps.vue';
import NutritionCard from '../../components/workspace/recipedetail/NutritionCard.vue';
import RecipeIngredients from '../../components/workspace/recipedetail/RecipeIngredients.vue';
import RecipeComments from '../../components/workspace/recipedetail/RecipeComments.vue';
import CookSnap from '../../components/workspace/recipedetail/CookSnap.vue';
import RecipeIntro from '../../components/workspace/recipedetail/RecipeIntro.vue';
import RecipeReportModal from '@/components/workspace/recipedetail/modals/RecipeReportModal.vue';
import RelatedRecipes from '@/components/workspace/recipedetail/RelatedRecipes.vue';

const route = useRoute();
const router = useRouter();
const recipeStore = useRecipeStore();

// 🏆 修正：抓取 .env 中的 8888 位址，不再使用 Vite 預設的 baseUrl
const fileUrl = import.meta.env.VITE_FILE_URL || 'http://localhost:8888/recimo_api/';

// 🏆 核心：路徑格式化函式，防止 http:// 變成 http:/
const formatImg = (rawPath) => {
    if (!rawPath) return 'https://placehold.co/800x600?text=No+Image';

    // 如果是完整網址、base64 或 blob，直接回傳
    if (rawPath.startsWith('http') || rawPath.startsWith('data:') || rawPath.startsWith('blob:')) {
        return rawPath;
    }

    // 確保 fileUrl 末尾有斜線，且 rawPath 開頭沒有斜線
    const base = fileUrl.endsWith('/') ? fileUrl : `${fileUrl}/`;
    const cleanPath = rawPath.replace(/^\//, '');

    return `${base}${cleanPath}`;
};

// --- 1. 響應式資料狀態 ---
const rawRecipe = ref(null);
const rawIngredients = ref([]);
const rawSteps = ref([]);
const rawComments = ref([]);
const rawGallery = ref([]);
const rawUsers = ref([]);
const servings = ref(1);
const isLoading = ref(true);

const isLiked = ref(false);
const localLikesOffset = ref(0);

const currentUser = ref({ id: 999, name: '渲染測試', avatar: '' });
const isPreviewMode = computed(() => route.query.mode === 'preview');

// --- 2. 功能函式 ---
const toggleRecipeLike = () => {
    if (isPreviewMode.value) return;
    isLiked.value = !isLiked.value;
    localLikesOffset.value = isLiked.value ? 1 : 0;
};

const handlePostSnap = (uploadPayload) => {
    if (isPreviewMode.value) return;
    const now = new Date();
    const formattedDate = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;

    const newSnap = {
        GALLERY_ID: Date.now(),
        RECIPE_ID: Number(route.params.id),
        USER_ID: currentUser.value.id,
        GALLERY_URL: uploadPayload.image,
        GALLERY_TEXT: uploadPayload.content,
        UPLOAD_AT: formattedDate
    };

    const userExists = rawUsers.value.find(u => Number(u.USER_ID || u.id) === Number(currentUser.value.id));
    if (!userExists) {
        rawUsers.value.push({
            USER_ID: currentUser.value.id,
            USER_NAME: currentUser.value.name,
            USER_URL: currentUser.value.avatar || ''
        });
    }

    rawGallery.value.unshift(newSnap);
};

const handleGoToEdit = () => {
    const currentId = isPreviewMode.value
        ? (route.query.editId || recipeStore.previewData?.recipe_id)
        : (rawRecipe.value?.recipe_id || route.params.id);

    const queryParams = { editId: currentId };
    if (!isPreviewMode.value) { queryParams.action = 'adapt'; }
    router.push({ path: '/workspace/edit-recipe', query: queryParams });
};

const backToEdit = () => { handleGoToEdit(); };

const toggleWorkspaceTopBar = (show) => {
    const topBar = document.querySelector('.workspace-top-bar');
    if (topBar) { topBar.style.display = show ? '' : 'none'; }
};

// --- 3. fetchData ---
const fetchData = async () => {
    isLoading.value = true;
    const recipeId = Number(route.params.id);

    try {
        const [resR, resRecipeIng, resIngMaster, resS, resC, resG, resU] = await Promise.all([
            publicApi.get('data/recipe/recipes.json'),
            publicApi.get('data/recipe/recipe_ingredient.json'),
            publicApi.get('data/recipe/ingredients.json'),
            publicApi.get('data/recipe/steps.json'),
            publicApi.get('data/social/comments.json'),
            publicApi.get('data/social/gallery.json'),
            publicApi.get('data/user/users.json')
        ]);

        rawUsers.value = resU.data || [];
        const recipes = resR.data || [];
        rawRecipe.value = recipes.find(r => Number(r.recipe_id || r.RECIPE_ID) === recipeId);

        if (!rawRecipe.value) return;

        servings.value = 1;
        const masterIng = resIngMaster.data || [];
        const recipeIng = resRecipeIng.data || [];
        const filteredLinks = recipeIng.filter(i => Number(i.recipe_id || i.RECIPE_ID) === recipeId);

        rawIngredients.value = filteredLinks.map(link => {
            const master = masterIng.find(m => Number(m.ingredient_id) === Number(link.ingredient_id));
            let unitWeight = Number(link.gram_conversion || master?.gram_conversion || master?.unit_weight || 1);
            const unitName = link.unit_name || master?.unit_name || '';
            if (['克', 'g', 'G', '毫升', 'ml', 'ML'].includes(unitName)) { unitWeight = 1; }
            const kcal = Number(master?.kcal_per_100g || link.kcal_per_100g || 0);
            const amount = Number(link.amount || 0);
            return {
                ...link,
                ingredient_name: master?.ingredient_name || link.ingredient_name || '未知食材',
                gram_conversion: unitWeight,
                kcal_per_100g: kcal,
                protein_per_100g: Number(master?.protein_per_100g || link.protein_per_100g || 0),
                fat_per_100g: Number(master?.fat_per_100g || link.fat_per_100g || 0),
                carbs_per_100g: Number(master?.carbs_per_100g || link.carbs_per_100g || 0),
                unit_name: unitName || '份',
                calc_total_grams: (amount * unitWeight).toFixed(2),
                calc_total_kcal: ((amount * unitWeight / 100) * kcal).toFixed(2)
            };
        });

        rawSteps.value = (resS.data || []).filter(s => Number(s.recipe_id || s.RECIPE_ID) === recipeId)
            .sort((a, b) => (a.step_order || 0) - (b.step_order || 0));
        rawComments.value = (resC.data || []).filter(c => Number(c.RECIPE_ID || c.recipe_id) === recipeId);
        rawGallery.value = (resG.data || []).filter(g => Number(g.RECIPE_ID || g.recipe_id) === recipeId);

    } catch (err) {
        console.error('資料讀取出錯:', err);
    } finally {
        setTimeout(() => { isLoading.value = false; }, 100);
    }
};

onMounted(() => {
    fetchData();
    if (isPreviewMode.value) { toggleWorkspaceTopBar(false); }
});

onUnmounted(() => { toggleWorkspaceTopBar(true); });

watch(() => isPreviewMode.value, (newVal) => { toggleWorkspaceTopBar(!newVal); });
watch(() => [route.params.id, route.query.mode], () => { fetchData(); });

// --- 4. 計算屬性 (使用 formatImg 保護路徑) ---

const recipeIntroData = computed(() => {
    if (!rawRecipe.value) return null;
    const rawImg = rawRecipe.value.recipe_image_url || rawRecipe.value.coverImg || rawRecipe.value.recipe_cover_image || '';

    return {
        id: rawRecipe.value.recipe_id || rawRecipe.value.RECIPE_ID || route.params.id,
        title: rawRecipe.value.recipe_title || rawRecipe.value.title || rawRecipe.value.RECIPE_TITLE || '未命名食譜',
        image: formatImg(rawImg), // 🏆 修正點
        time: formatTime(rawRecipe.value.recipe_total_time || rawRecipe.value.RECIPE_TOTAL_TIME),
        difficulty: rawRecipe.value.recipe_difficulty || rawRecipe.value.RECIPE_DIFFICULTY || 1,
        description: rawRecipe.value.recipe_descreption || rawRecipe.value.recipe_description || rawRecipe.value.RECIPE_DESCRIPTION || '暫無簡介'
    };
});

const stepsData = computed(() => {
    if (!rawSteps.value || rawSteps.value.length === 0) return [];
    return rawSteps.value.map((s, index) => {
        const rawImg = s.step_image_url || s.image || s.img || s.STEP_IMAGE_URL || '';
        return {
            id: s.step_id || s.id || s.STEP_ID || `s-${index}`,
            title: s.step_title || s.title || s.STEP_TITLE || `步驟 ${index + 1}`,
            content: s.step_content || s.content || s.text || s.STEP_CONTENT || '',
            image: formatImg(rawImg), // 🏆 修正點
            time: s.step_total_time || s.time || s.STEP_TOTAL_TIME || '',
            tags: s.tags || []
        };
    });
});

const snapsData = computed(() => {
    return rawGallery.value.map(g => {
        const rawUrl = g.GALLERY_URL || g.url || g.gallery_url || '';
        const userId = Number(g.USER_ID || g.user_id);
        const user = rawUsers.value.find(u => Number(u.USER_ID || u.user_id || u.id) === userId);

        return {
            url: formatImg(rawUrl), // 🏆 修正點
            comment: g.GALLERY_TEXT || g.comment || g.gallery_text || '',
            userId: userId,
            userName: user?.USER_NAME || user?.user_name || user?.name || `用戶ID:${userId}`,
            time: g.UPLOAD_AT || g.time || '剛剛'
        };
    });
});

const commentList = computed(() => {
    return rawComments.value.map(c => {
        const userId = Number(c.USER_ID || c.user_id);
        const user = rawUsers.value.find(u => Number(u.USER_ID || u.user_id || u.id) === userId);
        const rawAvatar = user?.USER_URL || user?.user_url || '';

        return {
            userName: user?.USER_NAME || user?.user_name || user?.name || `用戶ID:${userId}`,
            handle: `user_${userId}`,
            time: c.COMMENT_AT || c.comment_at || '剛剛',
            content: c.COMMENT_TEXT || c.comment_text || '',
            avatar: rawAvatar ? formatImg(rawAvatar) : `https://i.pravatar.cc/150?u=${userId}`, // 🏆 修正點
            likes: Number(c.LIKE_COUNT || c.like_count || 0)
        };
    }).reverse();
});

// --- 其他輔助邏輯保持不變 ---
const formatTime = (timeVal) => {
    if (!timeVal || timeVal === '00:00' || timeVal === 0) return '0 分鐘';
    const timeStr = String(timeVal);
    if (timeStr.includes(':')) {
        const parts = timeStr.split(':');
        return (parseInt(parts[0], 10) || 0) === 0 ? `${parseInt(parts[1], 10) || 0} 分鐘` : `${parseInt(parts[0], 10) || 0} 小時 ${parseInt(parts[1], 10) || 0} 分鐘`;
    }
    return `${timeStr} 分鐘`;
};

const ingredientsData = computed(() => {
    const originalServings = Number(rawRecipe.value?.recipe_servings || 1);
    const scale = (servings.value || 1) / originalServings;
    return rawIngredients.value.map(item => ({
        INGREDIENT_NAME: item.ingredient_name || '未知食材',
        amount: (Number(item.amount) * scale).toFixed(1),
        unit_name: item.unit_name || '份',
        note: item.remark || item.note || '',
        calories_per_100g: item.kcal_per_100g || 0,
        protein_per_100g: item.protein_per_100g || 0,
        fat_per_100g: item.fat_per_100g || 0,
        carbs_per_100g: item.carbs_per_100g || 0,
        unit_weight: item.gram_conversion || 1
    }));
});

const nutritionWrapper = computed(() => {
    if (!rawRecipe.value) return [];
    const originalServings = Number(rawRecipe.value.recipe_servings || 1);
    const scale = (servings.value || 1) / originalServings;
    let totalKcal = 0, totalProtein = 0, totalFat = 0, totalCarbs = 0;
    rawIngredients.value.forEach(ing => {
        const ratio = (Number(ing.amount) * Number(ing.gram_conversion || 1)) / 100;
        totalKcal += (Number(ing.kcal_per_100g) || 0) * ratio;
        totalProtein += (Number(ing.protein_per_100g) || 0) * ratio;
        totalFat += (Number(ing.fat_per_100g) || 0) * ratio;
        totalCarbs += (Number(ing.carbs_per_100g) || 0) * ratio;
    });
    return [{
        calories_per_100g: totalKcal * scale,
        protein_per_100g: totalProtein * scale,
        fat_per_100g: totalFat * scale,
        carbs_per_100g: totalCarbs * scale,
        amount: 1, unit_weight: 1
    }];
});

const handlePostComment = async (text) => {
    if (isPreviewMode.value || !text || !text.trim()) return;
    rawComments.value.push({
        RECIPE_ID: route.params.id,
        USER_ID: currentUser.value.id,
        COMMENT_TEXT: text.trim(),
        COMMENT_AT: new Date().toLocaleString(),
        LIKE_COUNT: 0
    });
    alert("留言成功！");
};

const baseRecipeLikes = ref(0);
watch(rawRecipe, (newVal) => {
    if (newVal) baseRecipeLikes.value = isPreviewMode.value ? 0 : Math.floor(Math.random() * 200) + 50;
}, { immediate: true });

const displayRecipeLikes = computed(() => baseRecipeLikes.value + localLikesOffset.value);

const handleShare = async () => {
    if (isPreviewMode.value) return;
    if (navigator.share) {
        try { await navigator.share({ title: recipeIntroData.value?.title, url: window.location.href }); } catch (err) { }
    } else {
        await navigator.clipboard.writeText(window.location.href);
        alert('連結已複製！');
    }
};

const handleServingsChange = (newVal) => { servings.value = newVal; };
const isReportModalOpen = ref(false);
const onReportSubmit = (data) => { isReportModalOpen.value = false; };
</script>

<template>
    <div v-if="isPreviewMode" class="preview-sticky-bar">
        <div class="container">
            <div class="row">
                <div class="col-12">
                    <div class="bar-content">
                        <span class="p-p1">✨ 正在預覽食譜草稿（尚未儲存）</span>
                        <button class="exit-preview-btn p-p2" @click="backToEdit">返回編輯</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="recipe-container-root" v-if="!isLoading && rawRecipe" :class="{ 'preview-padding': isPreviewMode }">
        <main class="container">
            <div class="title-content fade-up" style="--delay: 1">
                <div class="zh-h2">
                    <i-material-symbols-restaurant-rounded class="main-icon" />
                    {{ recipeIntroData.title }}
                </div>
                <div class="icon-group" :class="{ 'is-preview': isPreviewMode }">
                    <div class="action-item" :class="{ 'active': isLiked }" @click="toggleRecipeLike">
                        <i-material-symbols-thumb-up-rounded v-if="isLiked" class="action-icon" />
                        <i-material-symbols-thumb-up-outline-rounded v-else class="action-icon" />
                        <span class="count-text">{{ displayRecipeLikes }}</span>
                    </div>

                    <div class="action-item" @click="handleShare">
                        <i-material-symbols-share-outline class="action-icon" />
                    </div>

                    <div class="action-item" @click="handleGoToEdit">
                        <i-material-symbols-edit class="action-icon" />
                    </div>

                    <div class="action-item" @click="isReportModalOpen = true">
                        <i-material-symbols-error-outline-rounded class="action-icon report-btn" />
                    </div>

                    <div v-if="!isPreviewMode" class="adapt-btn-wrapper">
                        <router-link :to="`/workspace/modify-recipe/${rawRecipe.recipe_id}`">
                            <BaseBtn title="改編一覽" variant="outline" height="40" class="w-auto" />
                        </router-link>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-7 col-lg-12">
                    <RecipeIntro :info="recipeIntroData" :is-preview="isPreviewMode" class="fade-up"
                        style="--delay: 2" />

                    <div class="d-lg-none">
                        <section class="mb-10 fade-up" style="--delay: 3">
                            <NutritionCard :servings="servings" :ingredients="nutritionWrapper"
                                @change-servings="handleServingsChange" />
                        </section>
                        <section class="mb-10 fade-up" style="--delay: 4">
                            <RecipeIngredients :servings="servings" :list="ingredientsData" />
                        </section>
                    </div>

                    <section class="mb-10 steps-section fade-up" style="--delay: 5">
                        <RecipeSteps :steps="stepsData" />
                    </section>
                </div>

                <div class="col-5 col-lg-12">
                    <div class="d-none-lg">
                        <section class="mb-10 fade-up" style="--delay: 3">
                            <NutritionCard :servings="servings" :ingredients="nutritionWrapper"
                                @change-servings="handleServingsChange" />
                        </section>
                        <section class="mb-10 fade-up" style="--delay: 4">
                            <RecipeIngredients :servings="servings" :list="ingredientsData" />
                        </section>
                    </div>
                    <section v-if="!isPreviewMode" class="mb-10 fade-up" style="--delay: 6">
                        <RecipeComments :list="commentList" @post-comment="handlePostComment" />
                    </section>
                </div>

                <div v-if="!isPreviewMode" class="col-12 cook-snap-full fade-up" style="--delay: 7">
                    <section class="mb-10 content-wrapper">
                        <CookSnap :list="snapsData" @post-snap="handlePostSnap" />
                    </section>
                </div>
            </div>
        </main>
    </div>

    <div v-else-if="isLoading" class="loading-state">
        <p>正在為您準備食譜資料...</p>
    </div>
    <div v-else class="error-state">
        <p>抱歉，找不到該食譜資料 (ID: {{ route.params.id }})。</p>
        <router-link to="/">返回首頁</router-link>
    </div>

    <RecipeReportModal v-model="isReportModalOpen" :targetData="{
        title: recipeIntroData?.title,
        content: recipeIntroData?.description,
        // 🏆 這裡確保傳入作者名稱
        userName: rawRecipe?.author_name || '未知作者',
        // 🏆 關鍵：新增傳入 author_id，這樣 Modal 才能判斷是否為官方
        author_id: rawRecipe?.author_id || rawRecipe?.AUTHOR_ID,
        image: recipeIntroData?.image
    }" @submit="onReportSubmit" />

    <div v-if="!isPreviewMode" class="col-12 fade-up" style="--delay: 8">
        <RelatedRecipes :currentId="route.params.id" />
    </div>
</template>

<style lang="scss" scoped>
/* 原有的樣式保持不變... */
@import '@/assets/scss/abstracts/_color.scss';

.fade-up {
    opacity: 0;
    animation: fadeUpIn 0.8s cubic-bezier(0.2, 0.6, 0.35, 1) forwards;
    animation-delay: calc(var(--delay) * 0.12s);
}

@keyframes fadeUpIn {
    from {
        opacity: 0;
        transform: translateY(25px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.preview-sticky-bar {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    z-index: 110;
    padding: 12px 0;
    pointer-events: none;
    transition: all 0.3s ease;

    @media screen and (min-width: 810px) {
        left: 260px;
        width: calc(100% - 260px);
        background: transparent;
    }

    @media screen and (max-width: 809px) {
        left: 0;
        width: 100%;
        background: rgba(255, 255, 255, 0.7);
        backdrop-filter: blur(8px);
        padding: 8px 0;
    }

    .container {
        max-width: 1000px;
        margin: 0 auto;
        padding: 0 16px;
    }

    .bar-content {
        display: flex;
        justify-content: space-between;
        align-items: center;
        background-color: $primary-color-400;
        color: $neutral-color-white;
        padding: 10px 20px;
        border-radius: 12px;
        pointer-events: auto;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);

        @media screen and (max-width: 480px) {
            padding: 8px 12px;

            span {
                font-size: 11px;
            }
        }

        span {
            font-weight: 500;
            font-size: 14px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .exit-preview-btn {
            flex-shrink: 0;
            background-color: $neutral-color-white;
            color: $primary-color-700;
            border: none;
            padding: 6px 16px;
            border-radius: 50px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            margin-left: 12px;
            white-space: nowrap;
            transition: transform 0.2s ease;

            &:hover {
                background-color: $primary-color-100;
                transform: scale(1.05);
            }
        }
    }
}

.recipe-container-root {
    background-color: $neutral-color-white;
    min-height: 100vh;
    padding: 0 0 100px 0;

    &.preview-padding {
        padding-top: 90px;

        @media screen and (max-width: 768px) {
            padding-top: 0px;
        }
    }
}

.title-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px 0;
    margin-bottom: 20px;
    border-bottom: 1px solid $neutral-color-100;

    @media screen and (max-width: 768px) {
        flex-direction: column;
        align-items: flex-start;
        gap: 16px;
        padding: 15px 0;
    }

    .zh-h2 {
        display: flex;
        align-items: center;
        gap: 12px;

        .main-icon {
            font-size: 24px;
            color: $neutral-color-black;
        }
    }

    .icon-group {
        display: flex;
        align-items: center;
        gap: 20px;
        color: $primary-color-700;

        @media screen and (max-width: 768px) {
            gap: 16px;
            width: 100%;
            justify-content: flex-start;
        }

        &.is-preview {
            opacity: 0.6;

            .action-item {
                cursor: not-allowed;
                pointer-events: none;
            }
        }

        .action-item {
            display: flex;
            align-items: center;
            gap: 6px;
            cursor: pointer;
            transition: color 0.2s ease;

            &.active {
                color: $primary-color-700;

                .action-icon {
                    fill: $primary-color-700;
                }
            }

            &:hover {
                color: $primary-color-400;
            }
        }

        .count-text {
            font-size: 16px;
            font-weight: 500;
        }

        .action-icon {
            font-size: 24px;
        }

        .adapt-btn-wrapper {
            @media screen and (max-width: 768px) {
                margin-left: auto;
            }

            :deep(.base-btn) {
                padding: 0 10px;
                font-size: 13px;
                border-radius: 6px;
            }
        }
    }
}

.cook-snap-full {
    display: flex;
    justify-content: center;
    width: 100%;
    margin-top: 40px;
    background-color: $neutral-color-100;
    padding: 40px 0;

    .content-wrapper {
        width: 100%;
        max-width: 800px;
    }
}

.steps-section {
    margin-top: 40px;
}

.loading-state,
.error-state {
    text-align: center;
    padding: 100px 0;
    color: $primary-color-700;
}

.d-lg-none {
    @media screen and (min-width: 1024px) {
        display: none !important;
    }
}

.d-none-lg {
    @media screen and (max-width: 1023.98px) {
        display: none !important;
    }
}
</style>