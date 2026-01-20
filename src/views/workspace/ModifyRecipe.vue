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

// 原始 / 當前編輯中的食譜資料
const originalRecipe = ref({
    id: null,
    title: '',
    coverImg: '',
    description: '' // 確保包含描述欄位
});

// 改編卡片（目前用假資料）
const variantItems = ref(
    Array.from({ length: 7 }, (_, i) => ({
        id: i + 1,
        title: '極致減糖實驗',
        adapt_title: '糖 -15g / 增加甜菊糖',
        author: 'Recimo',
        likes: 128,
        coverImg: 'https://picsum.photos/400/300'
    }))
);

// 當前頁面模式：edit | adapt | create
const mode = ref('create');

/* =====================================================
    核心初始化邏輯（唯一入口）
===================================================== */

watch(
    () => [route.params.id, route.query.action, route.query.editId],
    async ([id, action, editId]) => {
        // ① 編輯既有食譜
        if (id) {
            mode.value = 'edit';
            await loadRecipeById(id);
            return;
        }

        // ② 改編建立
        if (action === 'adapt' && editId) {
            mode.value = 'adapt';
            await loadRecipeById(editId, { adapt: true });
            return;
        }

        // ③ 全新建立
        mode.value = 'create';
        initEmptyRecipe();
    },
    { immediate: true }
);

/* =====================================================
    資料處理方法
===================================================== */

// 抓取食譜資料
async function loadRecipeById(recipeId, options = {}) {
    try {
        const res = await publicApi.get('data/recipe/recipes.json');
        const found = res.data.find(
            r => Number(r.recipe_id) === Number(recipeId)
        );

        if (!found) {
            initEmptyRecipe();
            return;
        }

        // --- 圖片路徑邏輯優化 ---
        let finalImg = found.recipe_image_url || '';

        // 如果不是 http 開頭，且還沒包含完整的路由路徑，才進行拼接
        if (finalImg && !finalImg.startsWith('http') && !finalImg.startsWith('/img/recipes/')) {
            finalImg = `/img/recipes/${found.recipe_id}/${finalImg}`;
        }

        originalRecipe.value = {
            id: options.adapt ? null : found.recipe_id,
            title: options.adapt
                ? `${found.recipe_title}（改編）`
                : found.recipe_title,
            description: found.recipe_description || found.recipe_descreption || '',
            coverImg: finalImg
        };
    } catch (err) {
        console.error('抓取食譜失敗', err);
        initEmptyRecipe();
    }
}
// 初始化空白食譜
function initEmptyRecipe() {
    originalRecipe.value = {
        id: null,
        title: '新食譜',
        coverImg: '',
        description: ''
    };
}

/* =====================================================
    UI 行為
===================================================== */

// 點擊「創建食譜」（改編）
function handleCreateNew() {
    const sourceId = route.params.id || route.query.editId;
    if (!sourceId) return;

    router.push({
        name: 'edit-recipe',
        query: {
            editId: sourceId,
            action: 'adapt'
        }
    });
}

// 返回原食譜詳情
function goBack() {
    const backId = route.params.id || route.query.editId;
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