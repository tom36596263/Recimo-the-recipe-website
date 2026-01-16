<script setup>
import { ref } from 'vue';
import RecipeSteps from '../../components/workspace/recipedetail/RecipeSteps.vue';
import NutritionCard from '../../components/workspace/recipedetail/NutritionCard.vue';
import RecipeIngredients from '../../components/workspace/recipedetail/RecipeIngredients.vue';
import RecipeComments from '../../components/workspace/recipedetail/RecipeComments.vue';
import CookSnap from '../../components/workspace/recipedetail/CookSnap.vue';
import RecipeIntro from '../../components/workspace/recipedetail/RecipeIntro.vue';

const servings = ref(1);

const recipeIntroData = {
    title: '雲朵般口感 - 經典日式舒芙蕾鬆餅',
    
    image: '/img/recipes/32/cover.png',

    time: '30 分鐘',
    difficulty: 3,
    description: '不同於傳統美式鬆餅的紮實...'
};

    const stepsData = [
    {
        title: '分離蛋黃與蛋白',
        content: '將兩顆雞蛋分離，蛋白放入冰過頭的攪拌盆（蛋白霜穩定的關鍵）。',
        image: '/img/recipes/32/steps/1.jpg'
    },
    {
        title: '製作蛋黃糊',
        content:
        '蛋黃加入牛奶、香草精拌勻，再篩入低筋麵粉與泡打粉，攪拌至無顆粒狀。',
        image: '/img/recipes/32/steps/2.jpg'
    },
    {
        title: '打發蛋白霜',
        content: '砂糖分三次加入蛋白，使用電動打蛋器打至「硬性發泡」。',
        image: '/img/recipes/32/steps/3.jpg'
    },
    {
        title: '混合麵糊',
        content:
        '取 1/3 蛋白霜加入蛋黃糊拌勻，再倒回剩餘蛋白霜中，用「切拌法」輕柔混合，避免消泡。',
        image: '/img/recipes/32/steps/4.jpg'
    },
    {
        title: '低溫煎烤',
        content:
        '平底鍋抹薄油，小火預熱。用冰淇淋勺挖取麵糊堆疊高度，加入一匙水，蓋鍋蓋悶煎 4 分鐘。',
        image: '/img/recipes/32/steps/5.jpg'
    },
    {
        title: '翻面與盛盤',
        content: '底部呈金黃色後小心翻面，再悶煎 3 分鐘即可出爐。',
        image: '/img/recipes/32/steps/6.jpg'
    }
    ]; 

    const ingredientsData = [
    {
        INGREDIENT_NAME: '雞蛋',
        amount: 2,
        unit_weight: 60,
        unit_name: '顆',
        calories_per_100g: 155,
        protein_per_100g: 13,
        fat_per_100g: 11,
        carbs_per_100g: 1.1,
        note: '需將蛋黃與蛋白分離'
    },
    {
        INGREDIENT_NAME: '低筋麵粉',
        amount: 35,
        unit_weight: 1,
        unit_name: 'g',
        calories_per_100g: 364,
        protein_per_100g: 8,
        fat_per_100g: 1,
        carbs_per_100g: 76,
        note: ''
    },
    {
        INGREDIENT_NAME: '全脂牛奶',
        amount: 20,
        unit_weight: 1,
        unit_name: 'ml',
        calories_per_100g: 61,
        protein_per_100g: 3.2,
        fat_per_100g: 3.3,
        carbs_per_100g: 4.8,
        note: ''
    },
    {
        INGREDIENT_NAME: '細砂糖',
        amount: 25,
        unit_weight: 1,
        unit_name: 'g',
        calories_per_100g: 387,
        protein_per_100g: 0,
        fat_per_100g: 0,
        carbs_per_100g: 100,
        note: '用於打發蛋白'
    },
    {
        INGREDIENT_NAME: '香草精',
        amount: 2,
        unit_weight: 0.5,
        unit_name: '滴',
        calories_per_100g: 288,
        protein_per_100g: 0,
        fat_per_100g: 0,
        carbs_per_100g: 12,
        note: '去蛋腥味'
    },
    {
        INGREDIENT_NAME: '泡打粉',
        amount: 1,
        unit_weight: 1,
        unit_name: 'g',
        calories_per_100g: 53,
        protein_per_100g: 0,
        fat_per_100g: 0,
        carbs_per_100g: 28,
        note: '可選，增加穩定度'
    }
    ];

    const handleServingsChange = (newVal) => {
    servings.value = newVal;
    };

    const commentList = ref([
    {
        userName: 'Leo Harrison',
        handle: 'leo_h_bake',
        time: '2d ago',
        content:
        '質地非常完美！跟著步驟圖示觀察蛋白霜的尖角狀態真的很關鍵。口感輕盈像雲朵一樣，跟我之前在巴黎吃到的一模一樣。',
        avatar: 'https://i.pravatar.cc/150?u=leo',
        likes: 55
    },
    {
        userName: 'Marcus Miller',
        handle: 'mar_cooks',
        time: '1w ago',
        content:
        '排版非常人性化。當我手上沾滿麵粉時，這種文字在圖片上方的排版超有幫助。特別是「小撇步」區塊，成功阻止了我過度攪拌。',
        avatar: 'https://i.pravatar.cc/150?u=marcus',
        likes: 42
    },
    {
        userName: 'Sophia Chen',
        handle: 'sophia_lab',
        time: '5h ago',
        content:
        '數據精確且具科學性。我非常喜歡你們提供的精確分量數據。不再需要靠感覺瞎猜了！',
        avatar: 'https://i.pravatar.cc/150?u=sophia',
        likes: 21
    }
    ]);

    const SnapsData = [
    {
        url: '/img/social/32/1.jpg',
        comment: '第一次做舒芙蕾就上手！口感真的很綿密。'
    },
    {
        url: '/img/social/32/2.jpg',
        comment: '加了點蜂蜜後味道更提升了。'
    },
    {
        url: '/img/social/32/3.jpg',
        comment: '孩子們超愛，這是我的週末必備甜點。'
    },
    {
        url: '/img/social/32/4.jpg',
        comment: '沒想到新手照著做也能做出這種療癒的晃動感。'
    },
    {
        url: '/img/social/32/5.jpg',
        comment: '沒開玩笑，超級好吃'
    }
];
    </script>

    <template>
    <div class="recipe-container-root">
        <main class="container">
        <header class="page-header">
            <router-link to="/workspace/modify-recipe/1">
            <BaseBtn
                title="改編集+"
                variant="outline"
                height="30"
                class="w-auto"
            />
            </router-link>
        </header>

        <div class="title-content">
            <div class="zh-h2">
            <i-material-symbols-restaurant-rounded class="main-icon" />
            {{ recipeIntroData.title }}
            </div>
            <div class="icon-group">
            <i-material-symbols:edit-outline-rounded />
            <i-material-symbols-thumb-up-outline />
            <i-material-symbols-share-outline />
            </div>
        </div>

        <div class="row">
            <div class="col-7 col-lg-12">
            <section class="mb-10">
                <RecipeIntro :info="recipeIntroData" />
            </section>

            <div class="d-lg-none">
                <section class="mb-10">
                <NutritionCard
                    :servings="servings"
                    :ingredients="ingredientsData"
                    @change-servings="handleServingsChange"
                />
                </section>
                <section class="mb-10">
                <RecipeIngredients :servings="servings" :list="ingredientsData" />
                </section>
            </div>

            <section class="mb-10 steps-section">
                <RecipeSteps :steps="stepsData" />
            </section>
            </div>

            <div class="col-5 col-lg-12">
            <div class="d-none-lg">
                <section class="mb-10">
                <NutritionCard
                    :servings="servings"
                    :ingredients="ingredientsData"
                    @change-servings="handleServingsChange"
                />
                </section>
                <section class="mb-10">
                <RecipeIngredients :servings="servings" :list="ingredientsData" />
                </section>
            </div>

            <section class="mb-10">
                <RecipeComments :list="commentList" />
            </section>
            </div>

            <div class="col-12 cook-snap-full">
            <section class="mb-10 content-wrapper">
                <CookSnap :list="SnapsData"/>
            </section>
            </div>
        </div>
        </main>
    </div>
    </template>

    <style lang="scss" scoped>
    @import '@/assets/scss/abstracts/_color.scss';

    .recipe-container-root {
    background-color: $neutral-color-white;
    min-height: 100vh;
    padding: 0 0 100px 0;

    @media screen and (max-width: 810px) {
        padding-top: 10px !important;
    }
    }

    .page-header {
    display: flex;
    justify-content: flex-end;
    padding-top: 10px;
    }

    // --- 標題與圖標響應式排版 ---
    .title-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap; // 允許手機版換行
    gap: 12px;
    padding: 20px 0;
    margin-bottom: 20px;
    border-bottom: 1px solid $neutral-color-100;

    .zh-h2 {
        display: flex;
        align-items: center;
        gap: 12px;
        color: $neutral-color-black;
        margin: 0;

        .main-icon {
        font-size: 24px;
        flex-shrink: 0;
        }

        @media screen and (max-width: 1024px) {
        width: 100%;
        }
    }

    .icon-group {
        display: flex;
        align-items: center;
        gap: 20px;
        color: $primary-color-700;

        @media screen and (max-width: 1024px) {
        width: 100%;
        justify-content: flex-start;
        margin-top: 10px;
        }

        svg,
        i {
        font-size: 24px;
        cursor: pointer;
        transition: color 0.2s;

        &:hover {
            color: $primary-color-400;
        }
        }
    }
    }

    // --- 響應式顯示控制 ---
    .d-lg-none {
    @media screen and (min-width: 1024px) {
        display: none !important;
    }
    }

    .d-none-lg {
    @media screen and (max-width: 1024px) {
        display: none !important;
    }
    }

    .cook-snap-full {
    display: flex !important;
    justify-content: center;
    width: 100%;
    margin-top: 40px;
    background-color: $neutral-color-100;
    padding-top: 40px;

    .content-wrapper {
        width: 100%;
        max-width: 800px;
    }
    }

    .steps-section {
    margin-top: 40px;
    @media screen and (max-width: 810px) {
        margin-top: 20px !important;
    }
    }

    /* 全域捲軸修正 */
    :global(.workspace-layout),
    :global(.workspace-layout .page-content),
    :global(html, body) {
    height: auto !important;
    overflow: visible !important;
    overflow-y: auto !important;
}
</style>
