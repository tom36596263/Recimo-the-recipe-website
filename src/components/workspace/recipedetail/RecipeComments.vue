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

const handleSend = () => {
    if (!userInput.value.trim()) return;
    userInput.value = "";
    alert("感謝你的分享！為了維護社群品質，你的留言正在進行審核，通過後將會立即顯示在食譜頁面上。");
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
            <div v-for="(item, index) in list" :key="index" class="comment-item">
                <div class="user-avatar-text" :style="getAvatarStyle(item.userName)">
                    {{ item.userName.charAt(0).toUpperCase() }}
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
        </div>

        <CommentReportModal v-model="isReportModalOpen" :comment-data="activeComment"
            @update:modelValue="val => !val && (reportingIndex = null)" />
    </div>
</template>

<style lang="scss" scoped>
/* 此處保留你原始的所有 CSS 樣式 */
@import '@/assets/scss/abstracts/_color.scss';

.comment-section {
    max-width: 1400px;
    margin: 0 auto;
    padding: 24px 20px;
    font-family: "PingFang TC", sans-serif;
}

.section-title {
    margin-bottom: 24px;
    color: $neutral-color-black;
}

.input-container {
    position: relative;
    display: flex;
    align-items: center;
    margin-bottom: 24px;

    .styled-input {
        width: 100%;
        padding: 12px 50px 12px 16px;
        border: 1.5px solid $primary-color-700;
        border-radius: 12px;
        font-size: 15px;
        outline: none;
        transition: all 0.2s;

        &::placeholder {
            color: $neutral-color-400;
        }

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
        padding: 5px;
        cursor: pointer;
        color: $neutral-color-400;
        display: flex;
        align-items: center;
        transition: color 0.2s;

        &.active {
            color: $primary-color-700;
        }
    }
}

.comment-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.comment-item {
    display: flex;
    gap: 12px;
    padding-bottom: 12px;
    border-bottom: 1px solid $neutral-color-100;

    &:last-child {
        border-bottom: none;
    }

    .user-avatar-text {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 600;
        font-size: 14px;
        flex-shrink: 0;
        user-select: none;
        border: 1px solid rgba(0, 0, 0, 0.05);
    }

    .comment-body {
        flex: 1;

        .comment-header {
            margin-bottom: 4px;

            .user-name {
                font-weight: 600;
                margin-right: 6px;
                color: $neutral-color-800;
            }

            .user-meta {
                color: $neutral-color-400;
                font-size: 12px;
            }
        }

        .comment-text {
            line-height: 1.6;
            color: $neutral-color-800;
            margin-bottom: 8px;
            white-space: pre-line;
            font-size: 14px;
        }

        .comment-footer {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 16px;

            .action-btn {
                background: none;
                border: none;
                cursor: pointer;
                display: flex;
                align-items: center;
                color: $neutral-color-700;
                padding: 4px;
                transition: all 0.2s ease;

                .action-icon {
                    font-size: 18px;
                }

                .count {
                    margin-left: 4px;
                    font-size: 13px;
                }

                &.like-btn:hover,
                &.like-btn.active {
                    color: $primary-color-700;

                    .action-icon {
                        fill: currentColor;
                    }
                }

                &.report-btn:hover,
                &.report-btn.active {
                    color: $secondary-color-danger-700;
                }
            }
        }
    }
}
</style>