<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import AdaptRecipeCard from '@/components/workspace/modifyrecipe/AdaptRecipeCard.vue';

const router = useRouter();

// 模擬原始食譜基礎資料
const originalRecipe = ref({
    id: 32,
    title: '經典日式舒芙蕾鬆餅',
    coverImg: 'https://picsum.photos/1200/600'
});

// 模擬 7 張改編卡片
const variantItems = ref(new Array(7).fill({
    id: 99,
    title: '極致減糖實驗',
    adapt_title: '糖 -15g / 增加甜菊糖',
    author: 'Recimo',
    likes: 128,
    coverImg: 'https://picsum.photos/400/300'
}));

const handleCreateNew = () => {
    router.push(`/workspace/modify-recipe/${originalRecipe.value.id}`);
};

const goBack = () => {
    router.back();
};
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
                        <img :src="originalRecipe.coverImg" class="hero-img" alt="Original Recipe" />
                    </div>
                </div>
                <div class="col-5 col-md-12">
                    <div class="info-content">
                        <h1 class="zh-h2 mb-16">{{ originalRecipe.title }}（改編版）</h1>
                        <p class="p-p2 color-700 mb-24">
                            這是一系列基於經典日式舒芙蕾鬆餅進行的各種實驗與改編。
                            無論是低脂、高蛋白，或是各種口味嘗試，都能在這裡找到靈感。
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

    .color-700 {
        color: $neutral-color-700;
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
        // 這裡不需要額外設字體大小，已套用 p-p3 class
    }

    .decorative-line {
        height: 4px;
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