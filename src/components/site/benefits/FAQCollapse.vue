<script setup>
import { ref, onMounted } from 'vue';
import { phpApi } from '@/utils/publicApi';

// 1. 初始化 faqs 為空陣列
const faqs = ref([]);

// 2. 建立獲取資料的函式
const fetchFaqs = async () => {
    try {
        // 改為串接 faqs.php 取得 FAQ 資料
        const response = await phpApi.get('system/faqs.php');
        const data = Array.isArray(response.data.faqs) ? response.data.faqs : [];

        // 按類別分組
        const grouped = data.reduce((acc, item) => {
            let category = acc.find(c => c.category === item.faq_type);
            if (!category) {
                category = { category: item.faq_type, questions: [] };
                acc.push(category);
            }
            category.questions.push({
                q: item.faq_title,
                a: item.faq_answer,
                isOpen: false
            });
            return acc;
        }, []);
        faqs.value = grouped;
    } catch (error) {
        console.error('讀取 FAQ 失敗:', error);
    }
};

// 4. 元件掛載時執行
onMounted(() => {
    fetchFaqs();
});

const toggleFaq = (targetQuestion) => {
    targetQuestion.isOpen = !targetQuestion.isOpen;
};
</script>

<template>
    <div class="faq-container">
        <h1 class="main-title zh-h2">常見問題</h1>

        <div v-for="group in faqs" :key="group.category" class="faq-group">
            <h3 class="category-title zh-h4">【{{ group.category }}】</h3>

            <div v-for="(item, index) in group.questions" :key="index" class="faq-item"
                :class="{ 'is-active': item.isOpen }">
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
                grid-template-rows: 1fr; //平滑展開動畫//1fr：代表「分配到剩下的所有可用空間」
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