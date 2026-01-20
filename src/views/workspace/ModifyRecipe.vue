<script setup>
import { ref, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { publicApi } from '@/utils/publicApi';
import AdaptRecipeCard from '@/components/workspace/modifyrecipe/AdaptRecipeCard.vue';

const router = useRouter();
const route = useRoute();

/* =====================================================
    狀態定義
===================================================== */
const originalRecipe = ref({
    id: null,
    title: '',
    coverImg: '',
    description: ''
});

// 這裡改為從 API 動態獲取
const variantItems = ref([]);

const mode = ref('create');

/* =====================================================
    核心初始化邏輯
===================================================== */
watch(
    () => [route.params.id, route.query.action, route.query.editId],
    async ([id, action, editId]) => {
        const targetId = id || editId;
        if (targetId) {
            mode.value = id ? 'edit' : 'adapt';
            await loadRecipeData(targetId);
        } else {
            mode.value = 'create';
            initEmptyRecipe();
        }
    },
    { immediate: true }
);

/* =====================================================
    資料處理方法
===================================================== */

async function loadRecipeData(recipeId) {
    try {
        // 同時抓取食譜主表、改編表
        const [resRecipes, resAdaptations] = await Promise.all([
            publicApi.get('data/recipe/recipes.json'),
            publicApi.get('data/recipe/recipe_adaptations.json')
        ]);

        const allRecipes = resRecipes.data;
        const allAdaptations = resAdaptations.data;

        // 1. 處理原食譜資訊
        const found = allRecipes.find(r => Number(r.recipe_id) === Number(recipeId));
        if (found) {
            let finalImg = found.recipe_image_url || '';
            if (finalImg && !finalImg.startsWith('http') && !finalImg.startsWith('/img/recipes/')) {
                finalImg = `/img/recipes/${found.recipe_id}/${finalImg}`;
            }

            originalRecipe.value = {
                id: found.recipe_id,
                title: found.recipe_title,
                description: found.recipe_description || found.recipe_descreption || '',
                coverImg: finalImg
            };

            // 2. 處理該食譜下方的「改編小卡」
            // 找出所有 parent_recipe_id 等於目前這則食譜的改編項目
            const filteredAdaptations = allAdaptations.filter(
                a => Number(a.parent_recipe_id) === Number(recipeId)
            );

            variantItems.value = filteredAdaptations.map(adapt => {
                // 找出改編食譜的原生資料 (為了拿作者、按讚數等)
                const childInfo = allRecipes.find(r => Number(r.recipe_id) === Number(adapt.child_recipe_id));

                return {
                    id: adapt.child_recipe_id,
                    title: childInfo?.recipe_title || '未知食譜',
                    adapt_title: adapt.adaptation_title, // 使用 json 裡的 "洋蔥濃湯風牛丼"
                    author: childInfo?.author_name || 'Recimo User',
                    likes: childInfo?.likes_count || 0,
                    // 優先使用改編專用圖，若無則用該食譜首圖
                    coverImg: adapt.adaptation_image_url || childInfo?.recipe_image_url || 'https://picsum.photos/400/300'
                };
            });
        }
    } catch (err) {
        console.error('抓取資料失敗', err);
        initEmptyRecipe();
    }
}

function initEmptyRecipe() {
    originalRecipe.value = {
        id: null,
        title: '新食譜',
        coverImg: '',
        description: ''
    };
    variantItems.value = [];
}

/* =====================================================
    UI 行為
===================================================== */
function handleCreateNew() {
    const sourceId = originalRecipe.value.id;
    if (!sourceId) return;

    router.push({
        name: 'edit-recipe',
        query: {
            editId: sourceId,
            action: 'adapt'
        }
    });
}

function goBack() {
    const backId = originalRecipe.value.id;
    if (!backId) return;
    router.push(`/workspace/recipe-detail/${backId}`);
}
</script>


<template>
    <div class="variants-gallery container">
        <div class="row mb-40">
            <div class="col-12 text-right">
                <BaseBtn title="返回原食譜" variant="outline" :width="120" @click="goBack" />
            </div>
        </div>

        <section class="original-recipe-hero mb-40">
            <div class="row align-center">
                <div class="col-7 col-md-12">
                    <div class="main-image-container">
                        <img :src="originalRecipe.coverImg" class="hero-img" :alt="originalRecipe.title" />
                    </div>
                </div>
                <div class="col-5 col-md-12">
                    <div class="info-content">
                        <h1 class="zh-h2 mb-16">{{ originalRecipe.title }}</h1>
                        <p class="p-p1 color-p1 mb-24">
                            {{ originalRecipe.description }}
                        </p>
                        <div class="stat-tag p-p3">共有 {{ variantItems.length }} 個改編版本</div>
                    </div>
                </div>
            </div>
            <div class="decorative-line mt-40"></div>
        </section>

        <div class="row align-stretch">
            <div class="col-3 col-lg-4 col-md-6 col-sm-12 mb-24">
                <div class="add-card-placeholder full-height" @click="handleCreateNew">
                    <div class="add-content">
                        <span class="plus-icon">+</span>
                        <p class="zh-h4">創建食譜</p>
                        <p class="p-p3 uppercase">add recipe</p>
                    </div>
                </div>
            </div>

            <div v-for="(item, index) in variantItems" :key="index" class="col-3 col-lg-4 col-md-6 col-sm-12 mb-24">
                <AdaptRecipeCard :recipe="item" class="full-height" />
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

// 頁面基礎間距
.variants-gallery {
    padding: 20px 0 60px;
}

.text-right {
    text-align: right;
}

// Hero 區樣式優化
.original-recipe-hero {
    .main-image-container {
        width: 100%;
        height: 320px;
        border-radius: 16px;
        overflow: hidden;
        background-color: $neutral-color-100;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);

        .hero-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
    }

    .info-content {
        padding-left: 32px;

        @media (max-width: 810px) {
            padding-left: 0;
            margin-top: 24px;
        }
    }

    // 🔹 改為 color-p1 並保留行距設定
    .color-p1 {
        color: $neutral-color-700;
        line-height: 2; // 設定為 2 比較適中，3 可能會太寬，您可以視情況調整
    }

    .mb-16 {
        margin-bottom: 16px;
    }

    .mb-24 {
        margin-bottom: 24px;
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
    }
}

// 網格佈局工具
.row.align-stretch {
    display: flex;
    flex-wrap: wrap;
    align-items: stretch;
}

.mb-24 {
    margin-bottom: 24px;
}

.mb-40 {
    margin-bottom: 40px;
}

.mt-40 {
    margin-top: 40px;
}

.full-height {
    height: 100%;
}

// 創建按鈕卡片
.add-card-placeholder {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    border: 2px dashed $primary-color-400;
    border-radius: 12px;
    background-color: $neutral-color-white;
    cursor: pointer;
    transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
    padding: 40px 20px;

    .add-content {
        text-align: center;
        color: $primary-color-700;

        .plus-icon {
            font-size: 56px;
            line-height: 1;
            margin-bottom: 12px;
            display: block;
        }

        .uppercase {
            color: $neutral-color-400;
            margin-top: 8px;
            letter-spacing: 1px;
            text-transform: uppercase;
        }
    }

    &:hover {
        background-color: $primary-color-100;
        border-color: $primary-color-700;
        transform: translateY(-8px);
        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
    }
}
</style>