<script setup>
import { ref, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { publicApi } from '@/utils/publicApi';
import AdaptRecipeCard from '@/components/workspace/modifyrecipe/AdaptRecipeCard.vue';

const router = useRouter();
const route = useRoute();

const originalRecipe = ref({ id: null, title: '', coverImg: '', description: '' });
const variantItems = ref([]);

watch(
    () => [route.params.id, route.query.editId],
    async ([id, editId]) => {
        const targetId = id || editId;
        if (targetId) {
            await loadRecipeData(targetId);
        } else {
            initEmptyRecipe();
        }
    },
    { immediate: true }
);

async function loadRecipeData(recipeId) {
    try {
        const [resRecipes, resAdaptations] = await Promise.all([
            publicApi.get('data/recipe/recipes.json'),
            publicApi.get('data/recipe/recipe_adaptations.json')
        ]);

        const allRecipes = resRecipes.data;
        const allAdaptations = resAdaptations.data;

        const found = allRecipes.find(r => Number(r.recipe_id) === Number(recipeId));
        if (!found) return;

        let rawImg = found.recipe_image_url || found.recipe_cover_image || '';
        let finalImg = rawImg
            ? rawImg.startsWith('http') || rawImg.startsWith('data:')
                ? rawImg
                : `/${rawImg.replace(/^\//, '')}`
            : '';

        originalRecipe.value = {
            id: found.recipe_id,
            title: found.recipe_title,
            description: found.recipe_description || found.recipe_descreption || '暫無簡介',
            coverImg: finalImg
        };

        const filteredAdaptations = allAdaptations.filter(
            a => Number(a.parent_recipe_id) === Number(recipeId)
        );

        variantItems.value = filteredAdaptations.map(adapt => {
            const childInfo = allRecipes.find(
                r => Number(r.recipe_id) === Number(adapt.child_recipe_id)
            );

            let adaptImg =
                adapt.adaptation_image_url || childInfo?.recipe_image_url || '';
            if (adaptImg && !adaptImg.startsWith('http') && !adaptImg.startsWith('data:')) {
                adaptImg = adaptImg.startsWith('/') ? adaptImg : `/${adaptImg}`;
            }

            return {
                id: adapt.child_recipe_id,
                title: adapt.adaptation_title || childInfo?.recipe_title || '未命名改編',
                description:
                    adapt.adaptation_note ||
                    (adapt.key_changes?.[0]
                        ? `${adapt.key_changes[0].from} ➔ ${adapt.key_changes[0].to}`
                        : '關鍵內容載入中...'),
                author: childInfo?.author_name || 'Recimo User',
                likes: childInfo?.likes_count || 0,
                coverImg: adaptImg
            };
        });
    } catch (err) {
        console.error('資料載入失敗', err);
    }
}

function initEmptyRecipe() {
    originalRecipe.value = { id: null, title: '新食譜', coverImg: '', description: '' };
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
                    class="col-3 col-lg-4 col-md-6 mb-24 grid-item" :style="{ '--delay': index + 1 }">
                    <!-- ✅ 唯讀、不可點擊 -->
                    <AdaptRecipeCard :recipe="item" :readonly="true" class="full-height demo-readonly-card" />
                </div>
            </TransitionGroup>
        </div>
    </div>
</template>


<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

/* --- 核心修正：桌機版隱藏手機按鈕 --- */
.mobile-only-btn {
    display: none !important;
}

.desktop-only-btn {
    display: block;
}

/* --- 動畫定義 --- */
.fade-in-down {
    animation: fadeInDown 0.6s ease-out;
}

.original-recipe-hero {
    animation: fadeInUp 0.8s ease-out;

    .main-image-container {
        overflow: hidden;

        img {
            animation: imageScale 1.2s ease-out;
        }
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

@keyframes imageScale {
    from {
        transform: scale(1.1);
    }

    to {
        transform: scale(1);
    }
}

/* --- 佈局樣式 --- */
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

.original-recipe-hero {
    .main-image-container {
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

    .color-p1 {
        color: $neutral-color-700;
        line-height: 2;
    }

    .stat-tag {
        display: inline-block;
        background: $primary-color-100;
        color: $primary-color-800;
        padding: 6px 16px;
        border-radius: 20px;
    }
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

        .uppercase {
            color: $neutral-color-400;
            font-size: 12px;
            margin-top: 8px;
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

    /* ✨ 核心：強制關閉改編卡片上的遮罩樣式 */
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

/* RWD 控制 */
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