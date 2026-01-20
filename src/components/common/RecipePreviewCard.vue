/**
* 食譜預覽卡片組件
*
* 功能說明：
* - 顯示選中食譜的詳細預覽信息
* - 包含作者資訊、食譜圖片、標題、烹飪時間、熱量、難度、份量
* - 展示前 5 個食材的圖示預覽（從資料庫關聯查詢）
* - 提供「加入收藏」、「食譜詳情」、「開始烹飪」操作按鈕
* - 桌面版會使用 sticky 定位固定在視窗上方
*
* Props:
* @param {Object} recipe - 食譜資料物件，包含 id, recipe_name, image_url, difficulty, nutritional_info, author 等屬性
*/
<script setup>
import { ref, computed, watch, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import BaseBtn from '@/components/common/BaseBtn.vue';

// ==================== Props 定義 ====================
const props = defineProps({
    recipe: {
        type: Object,
        required: true
    }
});

// ==================== 路由實例 ====================
const router = useRouter();

// ==================== 響應式數據 ====================
const recipeIngredients = ref([]); // 食譜關聯的食材列表
const ingredientsData = ref([]); // 所有食材資料
const recipeIngredientsRelation = ref([]); // 食譜-食材關聯表

// ==================== 方法定義 ====================

/**
 * 跳轉到食譜詳細頁面
 * 使用 router.push 導航到對應的食譜詳情頁
 */
const goToRecipeDetail = () => {
    router.push({ name: 'workspace-recipe-detail', params: { id: props.recipe.recipe_id || props.recipe.id } });
};

/**
 * 開始烹飪功能
 * 目前僅記錄日誌，未來可擴展跳轉到烹飪模式頁面
 */
const startCooking = () => {
    console.log('開始烹飪:', props.recipe.recipe_name);
    // TODO: 可以跳轉到烹飪模式頁面
};

/**
 * 取得難度星星顯示陣列
 * @param {Number} difficulty - 難度等級 (1-5)
 * @returns {Array<Boolean>} - 返回長度為 5 的布林陣列，true 表示實心星星，false 表示空心星星
 */
const getDifficultyStars = (difficulty) => {
    return Array(5).fill(0).map((_, index) => index < difficulty);
};

/**
 * 載入食材資料
 * 從 JSON 文件中讀取食材列表和關聯表
 */
const loadIngredients = async () => {
    try {
        // 載入所有食材資料
        const ingredientsResponse = await fetch('/data/recipe/ingredients.json');
        ingredientsData.value = await ingredientsResponse.json();

        // 載入食譜-食材關聯表
        const relationResponse = await fetch('/data/recipe/recipe_ingredient.json');
        recipeIngredientsRelation.value = await relationResponse.json();

        // 篩選出當前食譜的食材
        loadRecipeIngredients();
    } catch (error) {
        console.error('載入食材資料失敗:', error);
    }
};

/**
 * 載入當前食譜的食材
 * 根據 recipe_id 從關聯表中查詢食材，並從食材表中獲取完整信息
 */
const loadRecipeIngredients = () => {
    // 找出當前食譜的所有食材ID
    const currentRecipeIngredients = recipeIngredientsRelation.value.filter(
        relation => relation.recipe_id === (props.recipe.recipe_id || props.recipe.id)
    );

    // 根據食材ID獲取完整的食材資料
    recipeIngredients.value = currentRecipeIngredients
        .map(relation => {
            const ingredient = ingredientsData.value.find(
                ing => ing.ingredient_id === relation.ingredient_id
            );
            return ingredient ? {
                ...ingredient,
                amount: relation.amount,
                unit_name: relation.unit_name
            } : null;
        })
        .filter(item => item !== null);
};

/**
 * 根據食材分類返回對應的圖示 class
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

// ==================== 監聽器 ====================
/**
 * 監聽 recipe prop 的變化
 * 當選擇不同食譜時重新載入食材
 */
watch(() => props.recipe, () => {
    if (ingredientsData.value.length > 0 && recipeIngredientsRelation.value.length > 0) {
        loadRecipeIngredients();
    }
}, { deep: true });

// ==================== 生命週期 ====================
onMounted(() => {
    loadIngredients();
});
</script>

<template>
    <div class="recipe-preview-card">

        <!-- ==================== 頭部區域：作者信息與收藏按鈕 ==================== -->
        <div class="preview-header">
            <!-- 作者信息：頭像 + 名稱 -->
            <div class="author-info">
                <div class="author-avatar">
                    <!-- 自動生成大頭照 -->
                    <img :src="`https://ui-avatars.com/api/?name=${recipe.author?.name || 'RE'}&background=3E8D60&color=fff`" alt="Recimo">
                </div>
                <!--  -->
                <span class="author-name">{{ recipe.author?.name || 'Recimo' }}</span>
            </div>
            <!-- 加入收藏按鈕 -->
            <BaseBtn title="加入收藏" variant="outline" :height="30" />
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
                <span>製作時間：{{ recipe.nutritional_info?.cooking_time || '45分鐘' }}</span>
            </div>
            <!-- 熱量 -->
            <div class="info-item">
                <i class="fa-solid fa-fire"></i>
                <span>熱量：{{ recipe.nutritional_info?.calories || '320kcal' }}</span>
            </div>
        </div>

        <!-- ==================== 難度與份量資訊 ==================== -->
        <div class="recipe-meta">
            <!-- 難度星級顯示 -->
            <div class="difficulty">
                <span class="label">難易度：</span>
                <div class="stars">
                    <i v-for="(filled, index) in getDifficultyStars(recipe.difficulty || 2)" :key="index"
                        class="fa-star" :class="filled ? 'fa-solid' : 'fa-regular'"></i>
                </div>
            </div>
            <!-- 份量 -->
            <div class="servings">
                <span class="label">份量：</span>
                <span>{{ recipe.nutritional_info?.serving_size || 1 }}人份</span>
            </div>
        </div>

        <!-- ==================== 食材預覽區（前5個） ==================== -->
        <div class="ingredients-preview">
            <div class="ingredient-tag" v-for="ingredient in recipeIngredients" :key="ingredient.ingredient_id">
                <!-- 食材圖示 -->
                <div class="ingredient-icon">
                    <!-- <i :class="getIngredientIcon(ingredient.main_category, ingredient.sub_category)"></i> -->
                </div>
                <!-- 食材名稱 -->
                <span class="ingredient-name">{{ ingredient.ingredient_name }}</span>
            </div>
        </div>

        <!-- ==================== 喜歡數統計 ==================== -->
        <div class="like-count">
            <i class="fa-solid fa-heart"></i>
            <span>{{ recipe.author?.likes || 100 }}</span>
            <span class="like-text">個人覺得好吃</span>
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
    display: flex;
    gap: 12px;
    margin-bottom: 20px;
    overflow-x: auto; // 橫向滾動
    padding-bottom: 8px;

    /* 自定義滾動條樣式 */
    &::-webkit-scrollbar {
        height: 4px;
    }

    &::-webkit-scrollbar-thumb {
        background: $neutral-color-400;
        border-radius: 2px;
    }
}

/* 單個食材標籤 */
.ingredient-tag {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    min-width: 80px; // 固定最小寬度避免壓縮
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

    i {
        font-size: 24px;
        color: $primary-color-700;
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

    /* 減少食材間距 */
    .ingredients-preview {
        gap: 8px;
    }

    /* 縮小食材標籤 */
    .ingredient-tag {
        min-width: 70px;
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
