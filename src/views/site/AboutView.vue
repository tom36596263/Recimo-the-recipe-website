<script setup>
import { ref, onMounted, markRaw } from 'vue';
import StepCard from '@/components/site/about/StepCard.vue';

// 引入 Swiper
import { Swiper, SwiperSlide } from 'swiper/vue';
import { Pagination, Autoplay } from 'swiper/modules';
import 'swiper/css';
import 'swiper/css/pagination';

// icon
import IconSkillet from '~icons/material-symbols/Skillet-outline';
import IconHandMeal from '~icons/material-symbols/Hand-Meal-outline';
import IconFavorite from '~icons/material-symbols/Favorite-outline';
import IconAnalytics from '~icons/material-symbols/analytics';
import IconAlarm from '~icons/material-symbols/alarm-outline';
import IconNoteStack from '~icons/material-symbols/Note-Stack-outline';
import IconStickyNote from '~icons/material-symbols/sticky-note-2-outline';
import IconFire from '~icons/material-symbols/local-fire-department-rounded';
import IconTableCart from '~icons/material-symbols/table-chart-view';
import IconChef from '~icons/material-symbols/chef-hat-outline';
import IconAddReaction from '~icons/material-symbols/add-reaction-outline';
import IconCart from '~icons/material-symbols/Shopping-Cart-outline';

import AboutBanner from '@/components/site/about/AboutBanner.vue'

const activeIndex = ref(0);

const headerList = [
    {
        title: '靈感與規劃',
        contents: ['靈感廚房', '備餐計畫'],
        color: '$primary-color-800',
        bg: '$neutral-color-white',
        // 下方介紹區內容
        images: [
            new URL('@/assets/images/about/introduce-01.jpg', import.meta.url).href,
            new URL('@/assets/images/about/introduce-02.jpg', import.meta.url).href,
        ],
        mainDescription: '利用系統化工具深度管理您的廚房生活，讓每一次的烹飪決策都變得更高效、更智慧，從容享受下廚樂趣。',
        features: [
            { icon: markRaw(IconSkillet), title: '互動式食譜推薦', desc: '當不知道要做什麼料理時，透過趣味的小遊戲互動，系統將從茫茫食譜海中為您篩選出最符合當下心情與需求的驚喜方案。' },
            { icon: markRaw(IconHandMeal), title: '週曆飲食規劃', desc: '利用週曆介面規劃早、中、晚三餐，系統自動加總每日熱量，協助您的健康管理。' }
        ],
        // 步驟介紹區內容 
        subSections: [
            {
                id: 'kitchen',
                title: '靈感廚房',
                description: '常常不知道要吃什麼煮什麼嗎？透過有趣的小遊戲，告訴我們您現有的食材，智慧推薦最適合的美味食譜。',
                steps: [
                    { id: 1, content: '選取您想要吃的食材或是冰箱剩餘的食材' },
                    { id: 2, content: '按順序拖曳食材或是按旁邊的+號，新增食材至鍋中' },
                    { id: 3, content: '系統將依您選擇的順序篩選出適合您的食譜' },
                    { id: 4, content: '直接點選食譜卡片可以進入該食譜的詳細內頁' },
                    { id: 5, content: '如有喜歡的食譜，可以點選食譜卡片上的「加入收藏」' },
                    { id: 6, content: '也可以點選食譜卡片上的「開始烹飪」立即烹飪' }
                ],
                btnTitle: '前往靈感廚房',
                link: '/recipes?action=open-kitchen'
            },
            {
                id: 'plan',
                title: '備餐計畫',
                description: '無論是為了健康管理還是節省時間又或者是規劃控，在Recimo可以讓您告別選擇困難，輕鬆搞定一週伙食安排。',
                steps: [
                    { id: 1, content: '請先登入Recimo會員' },
                    { id: 2, content: '可先至食譜總覽將有興趣的食譜加入收藏' },
                    { id: 3, content: '至備餐計畫，拖曳旁邊的食譜卡片至指定位置' },
                    { id: 4, content: '也可先設定身體狀況或目標熱量，後續系統會幫忙計算' },
                    { id: 5, content: '如完全沒有想法，也有提供幾款飲食篩選可供選擇' },
                    { id: 6, content: '完成所有欄位食譜拖曳，一週備餐計畫就完成囉' }
                ],
                btnTitle: '前往備餐計畫',
                link: '/workspace/plan'
            }
        ]
    },
    {
        title: '實作與紀錄',
        contents: ['開始烹飪', '食譜筆記'],
        color: '$neutral-color-black',
        bg: '$primary-color-100',
        // 下方介紹區內容
        images: [
            new URL('@/assets/images/about/introduce-03.jpg', import.meta.url).href,
            new URL('@/assets/images/about/introduce-04.jpg', import.meta.url).href,
            new URL('@/assets/images/about/introduce-05.jpg', import.meta.url).href,
            new URL('@/assets/images/about/introduce-06.jpg', import.meta.url).href
        ],
        mainDescription: '告別照本宣科，Recimo打造專注的實作空間，結合Recipe + Memo設計，讓您即時紀錄火候與靈感，封存每一場實踐。',
        features: [
            { icon: markRaw(IconFavorite), title: '雲端私房收藏庫', desc: '一鍵收藏喜愛的各種風味，隨時隨地都能開啟，且支援自定義資料夾功能，可以根據習慣建立專屬分類，讓食譜井然有序。' },
            { icon: markRaw(IconAnalytics), title: '智慧份量與營養分析', desc: '系統將根據您的用餐人數縮放食材比例，免去繁瑣計算並確保風味如一；同時即時估算配方熱量與營養成分，協助您輕鬆實踐科學化的飲食生活。' },
            { icon: markRaw(IconAlarm), title: '沉浸式烹飪', desc: '專屬食譜步驟頁面配備「智慧計時器」，確保每道工序精準無誤。' },
            { icon: markRaw(IconNoteStack), title: '自訂食譜筆記', desc: '打破固定食譜的框架，在烹飪步驟中可以即時加入筆記，紀錄火候微調、食材替換或遇到的疑難雜症等，完整保留最真實的實作筆記。' }
        ],
        // 步驟介紹區內容 
        subSections: [
            {
                id: 'startcooking',
                title: '開始烹飪',
                description: '這是我們最自豪的功能！將食譜步驟轉化為清晰的 PPT 簡報模式(並設有份量換算、計時器等)，解決手忙腳亂、忘記計時、食譜步驟太密集等痛點。',
                steps: [
                    { id: 1, content: '請先登入Recimo會員' },
                    { id: 2, content: '從任一食譜路徑挑選一份食譜，進入食譜內頁' },
                    { id: 3, content: '選擇製作份量後點選「開始烹飪」，進入食譜步驟頁' },
                    { id: 4, content: '每個步驟設有計時器，可自行針對需求使用' },
                    { id: 5, content: '針對當前所需食材與步驟，畫面中都會清楚顯示' },
                    { id: 6, content: '也可以自由提前或是回頭查看每個步驟' }
                ],
                btnTitle: '前往食譜總覽',
                link: '/recipes'
            },
            {
                id: 'recipenotes',
                title: '食譜筆記',
                description: '別讓靈光一現的美味消失，無論是紀錄火候微調、食材替換或遇到的疑難雜症等，在實作中隨手輕鬆記下，就能打造永不遺失的專屬對味資料庫。',
                steps: [
                    { id: 1, content: '請先登入Recimo會員' },
                    { id: 2, content: '從任一食譜路徑挑選一份食譜，進入食譜內頁' },
                    { id: 3, content: '點選「開始烹飪」，各步驟裡可以自由新增筆記' },
                    { id: 4, content: '完成所有步驟後，還有「食譜總結」心得頁面' },
                    { id: 5, content: '心得及筆記存至「烹飪實驗室>最近製作過的食譜」' },
                    { id: 6, content: '之後可查看或編輯烹飪過的食譜及當時的筆記、心得' }
                ],
                btnTitle: '前往食譜總覽',
                link: '/recipes'
            }
        ]
    },
    {
        title: '實驗與進化',
        contents: ['烹飪實驗室', '食譜改編集'],
        color: '$neutral-color-black',
        bg: '$primary-color-100',
        // 下方介紹區內容
        images: [
            new URL('@/assets/images/about/introduce-07.jpg', import.meta.url).href,
            new URL('@/assets/images/about/introduce-08.jpg', import.meta.url).href,
            new URL('@/assets/images/about/introduce-09.jpg', import.meta.url).href,
            new URL('@/assets/images/about/introduce-10.jpg', import.meta.url).href,
            new URL('@/assets/images/about/introduce-11.jpg', import.meta.url).href
        ],
        mainDescription: '專屬的廚藝數據庫，透過精密且直觀的圖表分析，深度剖析您的烹飪習慣與飲食偏好，讓每一次下廚都成為進步的基石。',
        features: [
            { icon: markRaw(IconStickyNote), title: '多媒體烹飪日誌', desc: '在烹飪結束後加入心得，並上傳成品照，建立最完整的美味紀錄與評分。' },
            { icon: markRaw(IconFire), title: '烹飪節奏與靈魂伴侶食材分析', desc: '系統自動統計您每週、每月的食譜使用數量與廚房活躍度及自動分析您最常使用的 Top 5 食材，找出您的個人口味 DNA。' },
            { icon: markRaw(IconTableCart), title: '廚藝成長指標', desc: '紀錄每一道菜的製作次數與滿意度評分，見證廚藝的點滴進步。' },
            { icon: markRaw(IconChef), title: '食譜進化論', desc: '打將現有的官方食譜作為基礎，每一次的微調都是靈感的延伸，透過改編集見證美味的進化過程。' }
        ],
        // 步驟介紹區內容 
        subSections: [
            {
                id: 'cookinglab',
                title: '烹飪實驗室',
                description: '把每次烹飪都視為一場實驗，完成料理後紀錄您的成功率、心得評分等，Recimo 會將這些數據轉化為可視圖表，讓您清楚看見自己的廚藝進化軌跡。',
                steps: [
                    { id: 1, content: '請先登入Recimo會員' },
                    { id: 2, content: '選擇任一食譜並點選「開始烹飪」進入食譜步驟頁' },
                    { id: 3, content: '完成所有步驟後，填寫「食譜總結」心得頁面' },
                    { id: 4, content: '系統會紀錄您填寫的心得與實作的資料' },
                    { id: 5, content: '之後可至「我的烹飪實驗室」查看歷史紀錄與數據' },
                    { id: 6, content: '清楚看見自己的廚藝進化軌跡，與更了解自己的偏好' }
                ],
                btnTitle: '前往烹飪實驗室',
                link: '/workspace/lab'
            },
            {
                id: 'recipeadaptation',
                title: '食譜改編集',
                description: '覺得某個食譜味道不對？或是您發現了更好的替代食材？直接在官方食譜上進行「改編」，分享您的改編紀錄。下次再做，味道依然完美精準。',
                steps: [
                    { id: 1, content: '請先登入Recimo會員' },
                    { id: 2, content: '從任一食譜路徑選擇官方食譜，並進入食譜內頁' },
                    { id: 3, content: '點「筆」按鈕，進行編輯，免擔心系統仍會保留原食譜' },
                    { id: 4, content: '完成改編會上傳至原食譜內頁中「改編輯」內' },
                    { id: 5, content: '「改編輯」內會以重點顯示更改的地方' },
                    { id: 6, content: '之後可至「我的食譜>個人食譜」查看與編輯' }
                ],
                btnTitle: '前往食譜總覽',
                link: '/recipes'
            }
        ]
    },
    {
        title: '創作與共享',
        contents: ['食譜發布與私藏', 'Recimo商城'],
        color: '$neutral-color-black',
        bg: '$primary-color-100',
        // 下方介紹區內容
        images: [
            new URL('@/assets/images/about/introduce-12.jpg', import.meta.url).href,
            new URL('@/assets/images/about/introduce-13.jpg', import.meta.url).href
        ],
        mainDescription: '從個人私廚筆記到具備影響力的社群分享，Recimo 協助您將烹飪靈感轉化為實質價值，串起從食譜到餐桌的最後一哩路。',
        features: [
            { icon: markRaw(IconAddReaction), title: '個人與社群發布食譜', desc: '自由定義食譜權限，無論是個人私房秘笈或社群公開分享，讓您的美味靈感與世界產生連結。' },
            { icon: markRaw(IconCart), title: '官方食譜即食版採購', desc: '讓食譜不再只是文字。一鍵下單即可將心儀配方轉化為新鮮食材組直送到家，實踐從螢幕到餐桌的無縫體驗。' }
        ],
        // 步驟介紹區內容 
        subSections: [
            {
                id: 'recipeshareorprivate',
                title: '食譜發布與私藏',
                description: '好手藝不該被埋沒！您的精采食譜可以公開發布到 Recimo 社群，與大家交流，也可以不公開將獨家私房菜上傳至雲端，讓珍貴的美味記憶永久留存。',
                steps: [
                    { id: 1, content: '請先登入Recimo會員，進入「我的廚房」工作區' },
                    { id: 2, content: '在「我的食譜>個人食譜」 點選「創建食譜」' },
                    { id: 3, content: '依指定欄位上傳食譜資訊與各項步驟與圖片' },
                    { id: 4, content: '熱量及時間系統將依各步驟食材及時間自動幫忙計算' },
                    { id: 5, content: '編輯完可選是否公開發布，後續要修改都可以' },
                    { id: 6, content: '之後可至「我的食譜>個人食譜」查看與編輯' }
                ],
                btnTitle: '前往我的廚房',
                link: '/workspace'
            },
            {
                id: 'recimomall',
                title: 'Recimo商城',
                description: '商城內每一款料理包皆由專業團隊對平台上的熱門食譜開發，精準配比每一克調料與食材數量，百分之百重現靈魂美味。',
                steps: [
                    { id: 1, content: '請先登入Recimo會員，進入 「Recimo商城」' },
                    { id: 2, content: '挑選中意的料理包，可以直接加入購物車' },
                    { id: 3, content: '點選商品卡片也可以直接進入商品詳情內頁' },
                    { id: 4, content: '至購物車確定品項數量及金額，就可以準備前往結帳' },
                    { id: 5, content: '結帳完畢後，商品約 1-2 個工作天就會寄出囉' },
                    { id: 6, content: '之後可至「訂單查詢」查看原始訂單或取消訂單' }
                ],
                btnTitle: '前往Recimo商城',
                link: '/mall'
            }
        ]
    }
];

const setActive = (index) => {
    activeIndex.value = index;
};

// ==========================================
// 隨機食材圖裝飾
// ==========================================
// 1. 先定義原始資料與響應式變數 (放在最外層)
const foods = [
    'banana.png', 'cheese.png', 'chili.png', 'egg.png', 'garlic.png',
    'oil.png', 'orange.png', 'salt.png', 'scallion.png', 'strawberry.png'
];
const shuffledFoods = ref([]);

// 2. 定義洗牌演算法
const shuffleArray = (array) => {
    const newArr = [...array];
    for (let i = newArr.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [newArr[i], newArr[j]] = [newArr[j], newArr[i]];
    }
    return newArr;
};

// 3. 定義供 Template 呼叫的函式 (在 HTML 裡用的名字)
const getUniqueFoodImg = (index) => {
    if (shuffledFoods.value.length === 0) return '';
    // 使用餘數運算確保如果 index 超過陣列長度也能循環取圖
    const foodName = shuffledFoods.value[index % shuffledFoods.value.length];
    return new URL(`../../assets/images/about/${foodName}`, import.meta.url).href;
};

// 4. 生命週期鉤子
onMounted(() => {
    // 這裡會將 foods 洗牌後存入 shuffledFoods
    shuffledFoods.value = shuffleArray(foods);

    // 檢查路由 (有定義 checkRoute 函式)
    if (typeof checkRoute === 'function') {
        checkRoute();
    }
});
</script>
<template>
    <!-- ==========================================
            banner
    ========================================= -->
    <div class="hero-container container fade-in-init">
        <div class="row">
            <div class="hero-banner col-12">
                <AboutBanner />
            </div>
        </div>
    </div>
    <!-- ==========================================
            功能介紹-頁籤切換
    ========================================= -->
    <section class="features-section">
        <div>
            <div class="container">
                <div class="row classification">
                    <div class="col-3" v-for="(item, index) in headerList" :key="item.title" @click="setActive(index)"
                        style="cursor: pointer;">
                        <div class="category-card" :class="{ 'active': activeIndex === index }">
                            <div class="zh-h3 card-head"
                                :style="{ backgroundColor: activeIndex === index ? item.color : '' }">
                                {{ item.title }}
                            </div>
                            <div class="zh-h4 card-body">
                                <p v-for="desc in item.contents" :key="desc">{{ desc }}</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="introduce-wrap container">
                <!-- ==========================================
                        功能介紹-輪播圖
                ========================================= -->
                <div class="row main-content" v-if="headerList[activeIndex]">
                    <div class="col-6 col-md-12">
                        <div class="image-preview-box" :style="{ backgroundColor: headerList[activeIndex].bg }">
                            <swiper :modules="[Pagination, Autoplay]" :slides-per-view="1"
                                :pagination="{ clickable: true }" :autoplay="{ delay: 3000 }" :key="activeIndex"
                                class="about-swiper">
                                <swiper-slide v-for="(imgSrc, imgIndex) in headerList[activeIndex].images"
                                    :key="imgIndex">
                                    <img :src="imgSrc" alt="功能預覽">
                                </swiper-slide>
                            </swiper>
                        </div>
                    </div>

                    <!-- ==========================================
                        功能介紹-內容
                ========================================= -->
                    <div class="introduce-wrap-content col-6 col-md-12">
                        <div>
                            <h2 class="zh-h3 section-title">{{ headerList[activeIndex].title }}</h2>
                            <hr class="title-line" />
                            <p class="p-p1 section-desc">{{ headerList[activeIndex].mainDescription }}</p>
                            <ul class="feature-list">
                                <li class="feature-item" v-for="feat in headerList[activeIndex].features"
                                    :key="feat.title">
                                    <div class="icon-circle"><template v-if="typeof feat.icon === 'string'">
                                            <i :class="['fa-solid', feat.icon]"></i>
                                        </template>
                                        <template v-else>
                                            <component :is="feat.icon" style="font-size: 1.5rem;" />
                                        </template>
                                    </div>
                                    <div class="text">
                                        <h3 class="zh-h4">{{ feat.title }}</h3>
                                        <p class="p-p2 hover-desc">{{ feat.desc }}</p>
                                    </div>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- ==========================================
            功能使用步驟
    ========================================= -->
    <section class="introduce" v-if="headerList[activeIndex]?.subSections?.length">
        <div class="container">
            <div v-for="(sub, index) in headerList[activeIndex].subSections" :key="sub.id" class="sub-section-block">
                <img :src="getUniqueFoodImg(index)" class="random-food-icon" :style="{
                    top: sub.foodPos?.top,
                    right: sub.foodPos?.right,
                    left: sub.foodPos?.left,
                    transform: `rotate(${sub.foodPos?.rotate || '0deg'})`
                }" alt="food img">

                <div class="row stepcontainer">
                    <h3 class="zh-h3 title">{{ sub.title }}</h3>
                    <p class="p-p1 content col-6 col-lg-12">{{ sub.description }}</p>
                </div>

                <div class="stepcard row">
                    <div v-for="step in sub.steps" :key="step.id" class="col-2 col-lg-4 col-md-6">
                        <StepCard :number="step.id" :content="step.content" />
                    </div>
                </div>

                <div class="btn-align-right">
                    <router-link :to="sub.link">
                        <CircleBtn :title="sub.btnTitle" type="white" :href="sub.link"
                            :class="{ 'hide-on-mobile': sub.id === 'kitchen' }" />
                    </router-link>
                </div>
            </div>
        </div>
    </section>
</template>
<style lang="scss" scoped>
// ==========================================
// banner
// ==========================================
.hero-banner {
    display: flex;
    flex-direction: column;
    justify-content: center;
    margin-top: 20px;
    margin-bottom: 40px;
    border-radius: $radius-base;

    @media screen and (max-width: 1024px) {
        // 如果圖片主體在右邊，就把位置往右靠，避免右側被裁切
        background-position: left center;
        margin-bottom: 20px;
    }

    @media screen and (max-width: 810px) {
        margin-bottom: 20px;
    }
}

.fade-in-init {
    animation: fadeInScale 0.8s ease-out forwards;
}

// ==========================================
// 功能介紹-頁籤切換
// ==========================================
.category-card {
    cursor: pointer;
    border: 1px solid $primary-color-700;
    text-align: center;
    border-radius: 10px;
    overflow: hidden;

    // 預設未選中的樣式
    .card-head {
        padding: 10px;
        background-color: $primary-color-100;
        color: $primary-color-400;
        transition: all 0.3s ease;
    }

    .card-body {
        padding: 5px;
        line-height: 1.5em;
        background-color: $neutral-color-white;
        color: $neutral-color-black;

        // 當螢幕小於或等於 810px 時隱藏文字區塊
        @media screen and (max-width: 810px) {
            display: none;
        }

    }

    // 選中時的樣式
    &.active {
        transform: translateY(-5px);
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        transition: transform 0.5s ease;

        .card-head {
            background-color: $primary-color-700;
            color: $neutral-color-white;
        }
    }
}

// ==========================================
// 功能介紹-輪播圖
// ==========================================
.introduce-wrap {
    margin-top: 40px;
    margin-bottom: 40px;

    .main-content {
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
}

.image-preview-box img {
    width: 100%;
    border: 1px solid $primary-color-700;
    border-radius: 10px;
}

/* 修改分頁點顏色 */
:deep(.swiper-pagination-bullet) {
    background: $primary-color-400; // 未選中時的顏色
    opacity: 0.5;
}

:deep(.swiper-pagination-bullet-active) {
    background: $primary-color-700; // 選中時的顏色
    opacity: 1;
}

// ==========================================
// 功能介紹-內容
// ==========================================
.introduce-wrap-content {
    padding-left: 50px;

    @media screen and (max-width: 1320px) {
        padding-left: 10px;
    }

    @media screen and (max-width: 810px) {
        padding-left: 0;
        margin-top: 20px;
    }
}

.section-title {
    color: $primary-color-700;
    text-align: center;
    margin: 10px 0;
}

.title-line {
    color: $primary-color-700;
    text-align: center;
    margin-bottom: 10px;
}

.section-desc {
    margin-bottom: 20px;
}

.feature-list {
    .feature-item {
        display: flex;
        align-items: center; // 圖標與文字永遠保持垂直置中
        margin-bottom: 25px;
        cursor: pointer;
        min-height: 80px; // 給予一個最小高度，確保展開時不會劇烈推擠
        transition: background-color 0.3s;

        .icon-circle {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            border: 1.5px solid $primary-color-700;
            color: $primary-color-700;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 15px;
            flex-shrink: 0;
            transition: all 0.3s ease;
        }

        .text {

            h3 {
                // margin-bottom: 5px;
                color: $primary-color-700;
                transition: margin 0.3s ease;
            }

            p {
                // 預設隱藏狀態
                max-height: 0;
                opacity: 0;
                overflow: hidden;
                transition: all 0.4s ease-in-out;
                margin: 0;
            }
        }

        // 當滑鼠 Hover 項目時
        &:hover {
            .icon-circle {
                background-color: $primary-color-700;
                color: $neutral-color-white;
            }

            .text h3 {
                margin-bottom: 5px; // 展開時再推開間距
            }

            .text p {
                max-height: 100px; // 設定一個足夠大的高度讓它展開
                opacity: 1;
                margin-top: 5px;
            }
        }
    }
}

@media screen and (max-width: 810px) {
    .feature-list .feature-item {
        // 移除指標手指樣式
        cursor: default;

        // 強制展開內容，不允許隱藏
        .text p {
            max-height: none !important;
            opacity: 1 !important;
            margin-top: 8px !important;
            visibility: visible !important;
        }

        // 確保 hover 時不會產生變化
        &:hover {
            transform: none !important;

            .icon-circle {
                // 維持原本的邊框色，不變實心色
                background-color: transparent !important;
                color: $primary-color-700 !important;
            }

            .text h3 {
                margin-bottom: 0 !important;
            }
        }
    }
}

// ==========================================
// 功能使用步驟
// ==========================================
.introduce {
    background-color: $primary-color-800;
    padding: 50px 0;
}

.stepcontainer {
    flex-direction: column;
}

//針對底下的第一個直接子層 
div .introduce .container {
    &>div:first-child {
        margin-bottom: 100px;
    }
}

.introduce .title {
    text-align: center;
    margin-bottom: 10px;
    color: $neutral-color-white;
}

.introduce .content {
    text-align: center;
    margin-bottom: 20px;
    color: $neutral-color-white;
    margin-left: auto;
    margin-right: auto;
}

.introduce .row {
    margin-bottom: 20px;
}

.btn-align-right {
    text-align: right;
}

.stepcard.row {
    @media screen and (max-width: 810px) {
        :deep(.col-md-6) {
            width: 50% !important;
            flex: 0 0 50%; // 確保 flex 屬性同步
        }
    }
}

// ==========================================
// 隨機食材圖裝飾
// ==========================================
// 定義上下飄浮動畫
@keyframes floating {
    0% {
        transform: translateY(0px) rotate(0deg);
    }

    50% {
        transform: translateY(-15px) rotate(5deg); // 向上移動 15px 並稍微旋轉
    }

    100% {
        transform: translateY(0px) rotate(0deg);
    }
}

.sub-section-block {
    position: relative;

    // 預設所有圖的位置
    .random-food-icon {
        position: absolute;
        top: -100px;
        right: 20px;
        width: 150px;
        height: auto;
        z-index: 10;
        pointer-events: none; // 讓滑鼠穿透這個元素
        animation: floating 3s ease-in-out infinite;

        @media screen and (max-width: 890px) {
            top: -90px;
            right: 5px;
            width: 120px;
        }
    }

    // 針對第二個區塊的圖
    &:nth-child(2) .random-food-icon {
        top: -100px;
        left: 20px;
        animation-duration: 2.5s;
        transform: rotate(-15deg);

        @media screen and (max-width: 890px) {
            left: 0;
        }
    }
}
</style>