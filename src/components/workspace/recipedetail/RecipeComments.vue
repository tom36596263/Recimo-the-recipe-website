<script setup>
import { ref, reactive } from "vue";
import CommentReportModal from './modals/CommentReportModal.vue';

const props = defineProps({
    // 這裡接收的是你 computed 處理過的 list (小寫 key)
    list: { type: Array, default: () => [] }
});

const userInput = ref("");
const isReportModalOpen = ref(false);
const activeComment = ref({ content: '', userName: '', time: '' });
const reportingIndex = ref(null);

// --- 簡單的點讚邏輯 ---
const localLikes = reactive({});

const toggleLike = (index) => {
    localLikes[index] = !localLikes[index];
};

const getAvatarStyle = (name) => {
    const brandingColors = ['#74D09C', '#FFCB82', '#8FEF60', '#F7F766', '#FF8686', '#90C6FF'];
    const charCodeSum = String(name).split('').reduce((sum, char) => sum + char.charCodeAt(0), 0);
    return { backgroundColor: brandingColors[charCodeSum % 6], color: '#555555' };
};

// 1. 宣告要傳出去的事件
const emit = defineEmits(['post-comment']);

// 2. 修改原本的發送邏輯
const handleSend = () => {
    // A. 防呆：若輸入內容為空或全是空白字元則不執行
    if (!userInput.value.trim()) return;

    // B. 把資料傳給父組件，由父組件處理 rawComments 的 push 動作
    emit('post-comment', userInput.value);

    // C. 成功發送後清空輸入框
    userInput.value = "";
};

const openReport = (item, index) => {
    activeComment.value = { ...item };
    reportingIndex.value = index;
    isReportModalOpen.value = true;
};
</script>

<template>
    <div class="comment-section">
        <h2 class="section-title zh-h3">美味悄悄話</h2>

        <div class="input-container">
            <input v-model="userInput" type="text" placeholder="分享你的想法..." class="styled-input"
                @keyup.enter="handleSend" />
            <button class="send-icon-btn" :class="{ 'active': userInput.trim() }" @click="handleSend">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z" />
                </svg>
            </button>
        </div>

        <div class="comment-list">
            <template v-if="list && list.length > 0">
                <div v-for="(item, index) in list" :key="item.time + item.content" class="comment-item">
                    <div class="user-avatar-text" :style="getAvatarStyle(item.userName)">
                        {{ item.userName ? item.userName.charAt(0).toUpperCase() : '?' }}
                    </div>

                    <div class="comment-body">
                        <div class="comment-header">
                            <span class="user-name p-p1">{{ item.userName }}</span>
                            <span class="user-meta p-p3">@{{ item.handle }} • {{ item.time }}</span>
                        </div>
                        <p class="comment-text p-p2">{{ item.content }}</p>

                        <div class="comment-footer">
                            <button class="action-btn like-btn" :class="{ 'active': localLikes[index] }"
                                @click="toggleLike(index)">
                                <i-material-symbols-thumb-up-rounded v-if="localLikes[index]" class="action-icon" />
                                <i-material-symbols-thumb-up-outline-rounded v-else class="action-icon" />
                                <span class="count">{{ (item.likes || 0) + (localLikes[index] ? 1 : 0) }}</span>
                            </button>

                            <button class="action-btn report-btn" :class="{ 'active': reportingIndex === index }"
                                @click="openReport(item, index)">
                                <i-material-symbols:error-outline-rounded class="action-icon" />
                            </button>
                        </div>
                    </div>
                </div>
            </template>

            <div v-else class="empty-comment-state">
                <i-material-symbols-chat-bubble-outline-rounded class="empty-icon" />
                <p class="p-p2">目前還沒有留言，快來當第一個分享的人吧！</p>
            </div>
        </div>

        <CommentReportModal v-model="isReportModalOpen" :comment-data="activeComment"
            @update:modelValue="val => !val && (reportingIndex = null)" />
    </div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.comment-section {
    max-width: 1400px;
    margin: 0 auto;
    padding: 24px 20px;
}

.section-title {
    margin-bottom: 24px;
    color: $neutral-color-black;
}

.input-container {
    position: relative;
    display: flex;
    align-items: center;
    margin-bottom: 32px;

    .styled-input {
        width: 100%;
        padding: 12px 50px 12px 16px;
        border: 1.5px solid $primary-color-700;
        border-radius: 12px;
        font-size: 15px;
        outline: none;
        transition: all 0.2s;

        &:focus {
            border-color: $primary-color-800;
            box-shadow: 0 0 0 3px rgba(74, 131, 96, 0.1);
        }
    }

    .send-icon-btn {
        position: absolute;
        right: 15px;
        background: none;
        border: none;
        cursor: pointer;
        color: $neutral-color-400;

        &.active {
            color: $primary-color-700;
        }
    }
}

.comment-list {
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.comment-item {
    display: flex;
    gap: 16px;
    padding-bottom: 16px;
    border-bottom: 1px solid $neutral-color-100;

    .user-avatar-text {
        width: 44px; // 稍微放大一點點，視覺更平衡
        height: 44px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 600;
        font-size: 16px;
        flex-shrink: 0;
        user-select: none;
        box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.05); // 增加一點質感邊框
    }

    .comment-body {
        flex: 1;

        .comment-header {
            margin-bottom: 6px;

            .user-name {
                font-weight: 600;
                margin-right: 8px;
                color: $neutral-color-800;
            }

            .user-meta {
                color: $neutral-color-400;
            }
        }

        .comment-text {
            line-height: 1.6;
            color: $neutral-color-800;
            margin-bottom: 8px;
            font-size: 15px;
        }
    }
}

// 空白狀態樣式
.empty-comment-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 60px 0;
    color: $neutral-color-400;
    text-align: center;

    .empty-icon {
        font-size: 48px;
        margin-bottom: 12px;
        opacity: 0.3;
    }
}

// 按鈕樣式 (點讚、檢舉)
.comment-footer {
    display: flex;
    justify-content: flex-end;
    gap: 16px;

    .action-btn {
        background: none;
        border: none;
        cursor: pointer;
        display: flex;
        align-items: center;
        color: $neutral-color-700;
        transition: all 0.2s;

        .action-icon {
            font-size: 18px;
        }

        &.like-btn:hover,
        &.like-btn.active {
            color: $primary-color-700;

            .action-icon {
                fill: currentColor;
            }
        }

        &.report-btn:hover {
            color: $secondary-color-danger-700;
        }
    }
}
</style>