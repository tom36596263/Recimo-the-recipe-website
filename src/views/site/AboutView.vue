<script setup>
import { ref } from 'vue';
import StepCard from '@/components/site/about/StepCard.vue';

const activeIndex = ref(0);

const headerList = [
    {
        title: '靈感與規劃',
        contents: ['靈感廚房', '備餐計畫'],
        color: '$primary-color-800',
        bg: '$neutral-color-white',
        // 下方介紹區內容
        mainDescription: '利用系統化工具深度管理您的廚房生活，讓每一次的烹飪決策都變得更高效、更智慧，從容享受下廚樂趣。',
        features: [
            { icon: 'fa-utensils', title: '互動式食譜推薦', desc: '當不知道要做什麼料理時，透過趣味的小遊戲互動，系統將從茫茫食譜海中為您篩選出最符合當下心情與需求的驚喜方案。' },
            { icon: 'fa-calendar-days', title: '週曆飲食規劃', desc: '利用週曆介面規劃早、中、晚三餐，系統自動加總每日熱量，協助您的健康管理。' }
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
                link: '/search'
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
        mainDescription: '告別照本宣科，Recimo打造專注的實作空間，結合Recipe + Memo設計，讓您即時紀錄火候與靈感，封存每一場實踐。',
        features: [
            { icon: 'fa-utensils', title: '雲端私房收藏庫', desc: '一鍵收藏喜愛的各種風味，隨時隨地都能開啟，且支援自定義資料夾功能，可以根據習慣建立專屬分類，讓食譜井然有序。' },
            { icon: 'fa-calendar-days', title: '智慧份量與營養分析', desc: '系統將根據您的用餐人數自動縮放食材比例，免去繁瑣計算並確保風味如一；同時即時估算配方熱量與營養成分，協助您輕鬆實踐科學化的飲食生活。' },
            { icon: 'fa-utensils', title: '沉浸式烹飪', desc: '專屬食譜步驟頁面配備「智慧計時器」，確保每道工序精準無誤。' },
            { icon: 'fa-calendar-days', title: '自訂食譜筆記', desc: '打破固定食譜的框架，在烹飪步驟中可以即時加入筆記，紀錄火候微調、食材替換或遇到的疑難雜症等，完整保留最真實的實作筆記。' }
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
        mainDescription: '專屬的廚藝數據庫，透過精密且直觀的圖表分析，深度剖析您的烹飪習慣與飲食偏好，讓每一次下廚都成為進步的基石。',
        features: [
            { icon: 'fa-utensils', title: '多媒體烹飪日誌', desc: '在烹飪結束後加入心得，並上傳成品照，建立最完整的美味紀錄與評分。' },
            { icon: 'fa-calendar-days', title: '烹飪節奏與靈魂伴侶食材分析', desc: '系統自動統計您每週、每月的食譜使用數量與廚房活躍度及自動分析您最常使用的 Top 5 食材，找出您的個人口味 DNA。' },
            { icon: 'fa-utensils', title: '廚藝成長指標', desc: '紀錄每一道菜的製作次數與滿意度評分，見證廚藝的點滴進步。' },
            { icon: 'fa-calendar-days', title: '食譜進化論', desc: '打將現有的官方食譜作為基礎，每一次的微調都是靈感的延伸，透過改編集見證美味的進化過程。' }
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
        mainDescription: '從個人私廚筆記到具備影響力的社群分享，Recimo 協助您將烹飪靈感轉化為實質價值，串起從食譜到餐桌的最後一哩路。',
        features: [
            { icon: 'fa-utensils', title: '個人與社群發布食譜', desc: '自由定義食譜權限，無論是個人私房秘笈或社群公開分享，讓您的美味靈感與世界產生連結。' },
            { icon: 'fa-calendar-days', title: '官方食譜即食版採購', desc: '讓食譜不再只是文字。一鍵下單即可將心儀配方轉化為新鮮食材組直送到家，實踐從螢幕到餐桌的無縫體驗。' }
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
</script>
<template>
    <div class="hero-container container">
        <div class="row">
            <div class="hero-banner col-12">
                <h1 class="zh-h2">關於Recimo</h1>
            </div>
        </div>
    </div>
    <section class="features-section">
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

            <div class="row main-content" v-if="headerList[activeIndex]">
                <div class="col-12 col-lg-6">
                    <div class="image-preview-box" :style="{ backgroundColor: headerList[activeIndex].bg }">
                        <img :src="`https://picsum.photos/300/200/?random=${activeIndex}`" alt="功能預覽">
                        <div class="pagination-dots">
                            <span v-for="n in 8" :key="n" :class="{ active: n === 1 }"></span>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-lg-6">
                    <div class="info-wrapper">
                        <h2 class="zh-h3 section-title">{{ headerList[activeIndex].title }}</h2>
                        <hr class="title-line" />
                        <p class="section-desc">{{ headerList[activeIndex].mainDescription }}</p>

                        <ul class="feature-list">
                            <li class="feature-item" v-for="feat in headerList[activeIndex].features" :key="feat.title">
                                <div class="icon-circle"><i :class="['fa-solid', feat.icon]"></i></div>
                                <div class="text">
                                    <h3>{{ feat.title }}</h3>
                                    <p>{{ feat.desc }}</p>
                                    <div class="hover-detail">詳細說明的文字 hover 再顯示</div>
                                </div>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="introduce" v-if="headerList[activeIndex]?.subSections?.length">
        <div class="container">
            <div v-for="sub in headerList[activeIndex].subSections" :key="sub.id" class="sub-section-block">
                <h3 class="zh-h3 title">{{ sub.title }}</h3>
                <p class="p-p1 content">{{ sub.description }}</p>
                <div class="row">
                    <div v-for="step in sub.steps" :key="step.id" class="col-2">
                        <StepCard :number="step.id" :content="step.content" />
                    </div>
                </div>
                <div class="btn-align-right">
                    <CircleBtn :title="sub.btnTitle" type="white" :href="sub.link" />
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
    background-image: url(@/assets/images/about/about-bg.jpg);
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    display: flex;
    flex-direction: column;
    justify-content: center;
    height: 60vh;
    margin-top: 40px;
    margin-bottom: 40px;

    @media screen and (max-width: 1024px) {
        margin-bottom: 20px;
    }

    @media screen and (max-width: 810px) {
        margin-bottom: 20px;
    }
}

h1 {
    text-align: center;
    color: $primary-color-800;
}

// ==========================================
// 功能介紹
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

    }

    // 選中時的樣式
    &.active {
        transform: translateY(-5px);
        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
        transition: transform 0.5s ease;

        .card-head {
            background-color: $primary-color-700;
            color: $neutral-color-white;
        }
    }
}

// ==========================================
// 功能使用介紹
// ==========================================
.introduce {
    background-color: $primary-color-800;
    padding: 50px 0;
}

// 針對底下的第一個直接子層 div
.introduce .container {
    &>div:first-child {
        margin-bottom: 80px;
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
}

.introduce .row {
    margin-bottom: 20px;
}

.btn-align-right {
    text-align: right;
}
</style>