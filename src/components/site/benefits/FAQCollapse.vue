<script setup>
import { ref } from 'vue';

const faqs = ref([
    {
    category: 'Recimo商城',
    questions: [
        {
            q: 'Recimo 商城賣什麼？與食譜有什麼關係？',
            a: '我們專門販售由「官方食譜」轉化而成的即食料理包。您可以將其視為食譜的實體縮影，讓您省去備料繁瑣，在家也能快速還原與官方食譜一模一樣的美味。',
            isOpen: false
        },
        {
            q: '下單後多久會出貨？',
            a: '待管理員在後台確認訂單後，通常於 1-2 個工作天內完成備貨並出貨。出貨後，您會收到「商品運送進度通知」。',
            isOpen: false
        },
        {
            q: '如果收到料理包後發現品質有問題該怎麼辦？',
            a: '請立即拍照並透過網站的「聯絡我們表單」反映。管理員會在後台查看您的訂單詳情並進行售後處理。',
            isOpen: false
        }
    ]
    },
    {
        category: 'Recimo功能',
        questions: [
        {
            q: '沒登入可以使用網站嗎？',
            a: '未登入狀態下，您可以瀏覽「食譜總覽」並使用「靈感廚房」小遊戲。但若要使用個人筆記、備餐計畫，則需註冊 Recimo ID。',
            isOpen: false
        },
        {
            q: '可以把別人食譜排進「備餐計劃」嗎？',
            a: '可以，只需點擊食譜下方的「加入收藏」，即可在行事曆介面中拖曳排入。',
            isOpen: false
        }
        ]
    },
    {
        category: '食譜與社群',
        questions: [
        {
            q: '可以怎麼「改編食譜」？',
            a: '當您參考官方食譜想加入自己的創意時，可以點擊食譜內頁的「筆/編輯食譜/改編食譜」的按鈕，進行編輯。不必擔心會修改到官方食譜，系統會保留原食譜，完成改編後您的改編食譜會上傳至原食譜內頁中「改編輯」內。',
            isOpen: false
        },
        {
            q: '留言被檢舉會發生什麼事？',
            a: '若留言違反社群守則並經管理員審核屬實，該留言將被移除，您也會在登入後頁面中的「小鈴鐺」收到通知。',
            isOpen: false
        }
        ]
    }
]);

const toggleFaq = (targetQuestion) => {
    targetQuestion.isOpen = !targetQuestion.isOpen;
};
</script>

<template>
    <div class="faq-container">
        <h1 class="main-title zh-h2">常見問題</h1>

            <div v-for="group in faqs" :key="group.category" class="faq-group">
            <h3 class="category-title zh-h4">【{{ group.category }}】</h3>

            <div 
                v-for="(item, index) in group.questions" 
                :key="index"
                class="faq-item"
                :class="{ 'is-active': item.isOpen }"
            >
                <div class="faq-header" @click="toggleFaq(item)">
                <div class="question-text zh-3">
                    <span class="q-prefix">Q :</span> {{ item.q }}
                </div>
                <div class="icon">{{ item.isOpen ? '−' : '+' }}</div>
                </div>

                <div class="faq-body-wrapper">
                <div class="faq-body">
                    <div class="content-inner p-p2">
                    {{ item.a }}
                    </div>
                </div>
                </div>
            </div>
            </div>
        </div>
</template>

<style lang="scss" scoped>


.faq-container {
    max-width: 900px; 
    margin: 40px auto;
    padding: 0 20px;

    .main-title {
        text-align: center;
        color: $primary-color-700;
        margin-bottom: 40px;
    }

    .faq-group {
        margin-bottom: 40px;

        .category-title {
        color: $primary-color-700;
        margin-bottom: 15px;
        }
    }

    .faq-item {
        border: 1px solid $primary-color-700;
        border-radius: 12px;
        margin-bottom: 16px;
        background-color: $primary-color-100;
        transition: all 0.3s ease;
        overflow: hidden;

        &.is-active {
        background-color: $neutral-color-white;
        border-color: $primary-color-700;

            .faq-body-wrapper {
                grid-template-rows: 1fr;//平滑展開動畫//1fr：代表「分配到剩下的所有可用空間」
            }
        }

        .faq-header {
        padding: 20px 24px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        cursor: pointer;
        user-select: none;

        .question-text {
            display: flex;
            gap: 8px;
            line-height: 1.4;

            .q-prefix {
            color: $primary-color-700;
            flex-shrink: 0; // 防止 Q : 被擠壓
            }
        }

        .icon {
            font-size: 1.5rem;
            color: #999;
            margin-left: 15px;
        }
        }

        .faq-body-wrapper {
        display: grid;
        grid-template-rows: 0fr;
        transition: grid-template-rows 0.3s cubic-bezier(0.4, 0, 0.2, 1);

        .faq-body {
            overflow: hidden;

            .content-inner {
            padding: 0 24px 24px 24px;
            // 移除原本樣式中的 border-top，因為圖片中似乎沒有明顯的分隔線
            // 如果需要可以加回來
            line-height: 1.8;
            }
        }
        }
    }
    }
</style>