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
        if (found) {
            let rawImg = found.recipe_image_url || found.recipe_cover_image || '';
            let finalImg = '';

            if (rawImg) {
                if (rawImg.startsWith('http') || rawImg.startsWith('data:')) {
                    finalImg = rawImg;
                } else {
                    const cleanPath = rawImg.replace(/^\//, '');
                    finalImg = `/${cleanPath}`;
                }
            }

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
                const childInfo = allRecipes.find(r => Number(r.recipe_id) === Number(adapt.child_recipe_id));

                // 圖片路徑處理
                let adaptImg = adapt.adaptation_image_url || childInfo?.recipe_image_url || '';
                if (adaptImg && !adaptImg.startsWith('http') && !adaptImg.startsWith('data:')) {
                    adaptImg = adaptImg.startsWith('/') ? adaptImg : `/${adaptImg}`;
                }

                return {
                    id: adapt.child_recipe_id,
                    // 1. 顯示改編標題 (例如：瑪格麗特風舒肥雞)
                    title: adapt.adaptation_title || childInfo?.recipe_title || '未命名改編',

                    // 2. ✨ 關鍵修正：改用 JSON 裡的 "adaptation_note"
                    // 如果沒有 note，就抓 key_changes 的第一筆作為描述
                    description: adapt.adaptation_note || (adapt.key_changes?.[0] ? `${adapt.key_changes[0].from} ➔ ${adapt.key_changes[0].to}` : '關鍵內容載入中...'),

                    author: childInfo?.author_name || 'Recimo User',
                    likes: childInfo?.likes_count || 0,
                    coverImg: adaptImg
                };
            });
        }
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

    // ✨ 修正：改用 path 並確保參數格式正確
    router.push({
        path: '/workspace/edit-recipe',
        query: {
            editId: originalRecipe.value.id,
            action: 'adapt'
        }
    });
}

function goBack() {
    if (!originalRecipe.value.id) return;
    router.push(`/workspace/recipe-detail/${originalRecipe.value.id}`);
}
</script>

<template>
    <div class="variants-gallery container">
        <div class="row mb-40 desktop-only-btn">
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
                        <div class="stat-tag p-p3 mb-24">共有 {{ variantItems.length }} 個改編版本</div>

                        <div class="mobile-only-btn">
                            <BaseBtn title="返回原食譜" variant="outline" class="w-100" @click="goBack" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="decorative-line mt-40"></div>
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

            <div v-for="(item, index) in variantItems" :key="index" class="col-3 col-lg-4 col-md-6 mb-24 grid-item">
                <AdaptRecipeCard :recipe="item" class="full-height demo-readonly-card" />
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

/* 顯示控制 */
.desktop-only-btn {
    display: block;
}

.mobile-only-btn {
    display: none;
}

/* 基礎樣式 */
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
        overflow: hidden;
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

    .decorative-line {
        height: 10px;
        background-color: $primary-color-100;
        border-radius: 4px;
        margin-top: 40px;
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
    cursor: default;
    transition: all 0.4s cubic-bezier(0.165, 0.84, 0.44, 1);

    &:hover {
        transform: scale(1.05);
        box-shadow: 0 15px 35px rgba(0, 0, 0, 0.12);
        z-index: 10;
    }

    :deep(.change-hint-overlay) {
        display: none !important;
    }

    :deep(input) {
        pointer-events: none;
    }
}

/* ✨ 手機版優化 (810px 以下) */
@media screen and (max-width: 810px) {
    .desktop-only-btn {
        display: none;
    }

    .mobile-only-btn {
        display: block;
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

    /* 強制兩欄佈局 */
    .custom-grid {
        display: flex !important;
        flex-wrap: wrap !important;
        margin-left: -8px !important;
        margin-right: -8px !important;

        .grid-item {
            flex: 0 0 50% !important;
            max-width: 50% !important;
            padding: 0 8px !important;
            margin-bottom: 16px;
        }
    }

    .add-card-placeholder {
        padding: 24px 10px;

        .plus-icon {
            font-size: 32px !important;
        }

        .zh-h4 {
            font-size: 16px !important;
        }
    }

    :deep(.recipe-card-sm) {
        .card-header {
            height: 120px !important;
        }

        .card-body {
            padding: 10px !important;
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