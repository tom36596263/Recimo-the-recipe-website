<script setup>
import { ref, computed, watch, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import BaseBtn from '@/components/common/BaseBtn.vue';
import { Swiper, SwiperSlide } from 'swiper/vue';
import { FreeMode } from 'swiper/modules';
import { publicApi } from '@/utils/publicApi';
import { parsePublicFile } from '@/utils/parseFile';
import 'swiper/css';
import 'swiper/css/free-mode';

// Swiper 模組
const modules = [FreeMode];

const router = useRouter();

// ==================== Props 定義 ====================
const props = defineProps({
    recipe: {
        type: Object,
        required: true
    }
});

// ==================== 韺應式數據 ====================
const recipeIngredients = computed(() => Array.isArray(props.recipe.ingredients) ? props.recipe.ingredients : []);


// ==================== 方法定義 ====================

/**
 * 將 xx:xx:xx 轉為 xx小時xx分鐘xx秒
 */
const formatTime = (hhmmss) => {
    if (!hhmmss || typeof hhmmss !== 'string') return '未知';
    const [h, m, s] = hhmmss.split(':').map(Number);
    let result = '';
    if (h) result += `${h}小時`;
    if (m) result += `${m}分鐘`;
    if (s || (!h && !m)) result += `${s}秒`;
    return result;
};

/**
 * 跳轉到食譜詳細頁面
 * 使用 router.push 導航到對應的食譜詳情頁
 */
const goToRecipeDetail = () => {
    router.push({ name: 'workspace-recipe-detail', params: { id: props.recipe.recipe_id || props.recipe.id } });
};

/**
 * 開始烹飪功能
 * 跳轉到 /workspace/guide 並帶上食譜 id
 */
const startCooking = () => {
    // const recipeId = props.recipe.recipe_id || props.recipe.id;
    // router.push({ path: '/workspace/guide', query: { id: recipeId } });
    router.push({ name: 'recipe-guide', params: { id: props.recipe.recipe_id || props.recipe.id } });
};

/**
 * 取得難度星星顯示陣列
 * @param {Number} difficulty - 難度等級 (1-5)
 * @returns {Array<Boolean>} - 返回長度為 5 的布林陣列，true 表示實心星星，false 表示空心星星
 */
const getDifficultyStars = (difficulty) => {
    return Array(5).fill(0).map((_, index) => index < difficulty);
};

// 不再需要載入食材資料，直接從 props.recipe.ingredients 取得

/**
 * 取得食材圖片 URL
 * @param {String} imageUrl - 食材圖片路徑
 * @returns {String} - 完整的圖片 URL
 */
const getIngredientImageUrl = (imageUrl) => {
    if (!imageUrl) return '';

    // 如果是完整 URL，直接返回
    if (imageUrl.startsWith('http')) {
        return imageUrl;
    }

    // 使用 parseFile.js 處理路徑
    return parsePublicFile(imageUrl);
};

/**
 * 根據食材分類返回對應的圖示 class（備用）
 * @param {String} mainCategory - 主分類
 * @param {String} subCategory - 次分類
 * @returns {String} - FontAwesome 圖示 class
 */
const getIngredientIcon = (mainCategory, subCategory) => {
    // 根據主分類和次分類返回對應圖示
    const iconMap = {
        'fresh-produce': {
            'aromatics': 'fa-solid fa-seedling',
            'leafy-greens': 'fa-solid fa-leaf',
            'root-vegetables': 'fa-solid fa-carrot',
            'default': 'fa-solid fa-seedling'
        },
        'fruits': 'fa-solid fa-lemon',
        'meat-poultry': 'fa-solid fa-drumstick-leg',
        'seafood': 'fa-solid fa-fish',
        'dairy-eggs-soy': 'fa-solid fa-egg',
        'grains-pasta-bakery': 'fa-solid fa-wheat-awn',
        'condiments-sauces-oils': 'fa-solid fa-bottle-droplet',
        'pantry-spices-nuts': 'fa-solid fa-pepper-hot',
        'others': 'fa-solid fa-utensils'
    };

    if (typeof iconMap[mainCategory] === 'object') {
        return iconMap[mainCategory][subCategory] || iconMap[mainCategory]['default'];
    }
    return iconMap[mainCategory] || 'fa-solid fa-utensils';
};

// 不需監聽與載入，直接用 props.recipe.ingredients
</script>

<template>
    <div class="recipe-preview-card">

        <!-- ==================== 頭部區域：作者信息 ==================== -->
        <div class="preview-header">
            <!-- 作者信息：頭像 + 名稱 -->
            <div class="author-info">
                <div class="author-avatar">
                    <!-- 自動生成大頭照 -->
                    <img :src="parsePublicFile(recipe.user_url) || `https://ui-avatars.com/api/?name=${recipe.author?.name || 'RE'}&background=3E8D60&color=fff`"
                        alt="Recimo">
                </div>
                <!--  -->
                <span class="author-name">{{ recipe.author?.name || 'Recimo' }}</span>
            </div>
        </div>

        <!-- ==================== 食譜主圖 ==================== -->
        <div class="preview-image">
            <img :src="recipe.image_url" :alt="recipe.recipe_name">
        </div>

        <!-- ==================== 食譜標題 ==================== -->
        <h3 class="preview-title">{{ recipe.recipe_name }}</h3>

        <!-- ==================== 基本資訊：烹飪時間 & 熱量 ==================== -->
        <div class="recipe-info">
            <!-- 製作時間 -->
            <div class="info-item">
                <i class="fa-regular fa-clock"></i>
                <span>製作時間：{{ formatTime(recipe?.recipe_total_time) || '無設定' }}</span>
            </div>
            <!-- 熱量 -->
            <div class="info-item">
                <i class="fa-solid fa-fire"></i>
                <span>熱量：{{ recipe?.recipe_kcal_per_100g || '無設定' }} kcal</span>
            </div>
        </div>

        <!-- ==================== 難度與份量資訊 ==================== -->
        <div class="recipe-meta">
            <!-- 難度星級顯示 -->
            <div class="difficulty">
                <span class="label">難易度：</span>
                <div class="stars">
                    <i v-for="(filled, index) in getDifficultyStars(recipe.recipe_difficulty || 2)" :key="index"
                        class="fa-star" :class="filled ? 'fa-solid' : 'fa-regular'"></i>
                </div>
            </div>
            <!-- 份量 -->
            <div class="servings">
                <span class="label">份量：</span>
                <span>{{ recipe.recipe_servings || 1 }}人份</span>
            </div>
        </div>

        <!-- ==================== 食材預覽區 ==================== -->
        <div class="ingredients-preview">
            <Swiper :modules="modules" :slides-per-view="'auto'" :space-between="12" :free-mode="true"
                class="ingredients-swiper">
                <SwiperSlide v-for="ingredient in recipeIngredients" :key="ingredient.ingredient_id || ingredient.id"
                    class="ingredient-slide">
                    <div class="ingredient-tag">
                        <!-- 食材圖片 -->
                        <div class="ingredient-icon">
                            <img v-if="ingredient.ingredient_image_url"
                                :src="getIngredientImageUrl(ingredient.ingredient_image_url)"
                                :alt="ingredient.ingredient_name" class="ingredient-image" />
                            <i v-else :class="getIngredientIcon(ingredient.main_category, ingredient.sub_category)"></i>
                        </div>
                        <!-- 食材名稱 -->
                        <span class="ingredient-name">{{ ingredient.ingredient_name }}</span>
                    </div>
                </SwiperSlide>
            </Swiper>
        </div>



        <!-- ==================== 操作按鈕區 ==================== -->
        <div class="action-buttons">
            <!-- 查看食譜詳情 -->
            <BaseBtn title="食譜詳情" variant="outline" :height="40" width="50%" @click="goToRecipeDetail" />
            <!-- 開始烹飪 -->
            <BaseBtn title="開始烹飪" variant="solid" :height="40" width="50%" @click="startCooking" />
        </div>
    </div>
</template>

<style lang="scss" scoped>
/* ==================== 卡片容器 ==================== */
.recipe-preview-card {
    background: white;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    position: sticky; // 桌面版固定在視窗上方
    top: 20px;
}

/* ==================== 頭部區域 ==================== */
.preview-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;

    .favorite-btn {
        display: flex;
        align-items: center;

        svg {
            width: 1.5em !important;
            height: 1.5em !important;
            min-width: 1.5em;
            min-height: 1.5em;
            display: inline-block;
        }

        .favorite-animate {
            animation: heart-bounce 0.4s;
        }
    }
}

@keyframes heart-bounce {
    0% {
        transform: scale(1);
    }

    30% {
        transform: scale(1.3);
    }

    60% {
        transform: scale(0.9);
    }

    100% {
        transform: scale(1);
    }
}

/* 作者信息區 */
.author-info {
    display: flex;
    align-items: center;
    gap: 12px;
}

/* 作者頭像 */
.author-avatar {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    overflow: hidden;

    img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
}

/* 作者名稱 */
.author-name {
    font-size: 16px;
    font-weight: 500;
    color: $neutral-color-800;
}

/* ==================== 食譜主圖 ==================== */
.preview-image {
    width: 100%;
    aspect-ratio: 16/9; // 保持 16:9 比例
    border-radius: 8px;
    overflow: hidden;
    margin-bottom: 20px;

    img {
        width: 100%;
        height: 100%;
        object-fit: cover; // 圖片裁切填滿容器
    }
}

/* ==================== 食譜標題 ==================== */
.preview-title {
    font-size: 22px;
    font-weight: 600;
    color: $neutral-color-800;
    margin-bottom: 16px;
}

/* ==================== 基本資訊區（時間、熱量） ==================== */
.recipe-info {
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin-bottom: 16px;
}

/* 資訊項目（時間/熱量） */
.info-item {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 14px;
    color: $neutral-color-700;

    i {
        color: $primary-color-700;
        font-size: 16px;
    }
}

/* ==================== 難度與份量區 ==================== */
.recipe-meta {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding: 12px 0;
    border-top: 1px solid $neutral-color-100;
    border-bottom: 1px solid $neutral-color-100;
}

/* 難度與份量共用樣式 */
.difficulty,
.servings {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 14px;

    .label {
        color: $neutral-color-700;
    }
}

/* 星級評分 */
.stars {
    display: flex;
    gap: 4px;

    i {
        font-size: 14px;
        color: #FFD700; // 金色星星
    }
}

/* ==================== 食材預覽區 ==================== */
.ingredients-preview {
    margin-bottom: 20px;
}

.ingredients-swiper {
    width: 100%;
    padding-bottom: 8px;
}

.ingredient-slide {
    width: auto !important;
}

/* 單個食材標籤 */
.ingredient-tag {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    width: 80px;
}

/* 食材圖示容器 */
.ingredient-icon {
    width: 60px;
    height: 60px;
    background: $primary-color-100;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;

    i {
        font-size: 24px;
        color: $primary-color-700;
    }

    .ingredient-image {
        width: 100%;
        height: 100%;
        object-fit: contain;
        padding: 8px;
    }
}

/* 食材名稱 */
.ingredient-name {
    font-size: 12px;
    color: $neutral-color-800;
    text-align: center;
}

/* ==================== 喜歡數統計 ==================== */
.like-count {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 20px;
    font-size: 14px;
    color: $neutral-color-700;

    i {
        color: #FF5858; // 紅色愛心
        font-size: 16px;
    }

    .like-text {
        margin-left: 4px;
    }
}

/* ==================== 操作按鈕區 ==================== */
.action-buttons {
    display: flex;
    gap: 12px; // 按鈕之間的間距
}

/* ==================== 響應式設計 ==================== */
@media screen and (max-width: 810px) {

    /* 小螢幕時取消 sticky 定位 */
    .recipe-preview-card {
        position: static;
    }

    /* 縮小標題字體 */
    .preview-title {
        font-size: 20px;
    }

    /* 縮小食材標籤 */
    .ingredient-tag {
        width: 70px;
    }

    /* 縮小食材圖示 */
    .ingredient-icon {
        width: 50px;
        height: 50px;

        i {
            font-size: 20px;
        }
    }
}
</style>
