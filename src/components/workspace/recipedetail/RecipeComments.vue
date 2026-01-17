<script setup>
import { ref, reactive } from "vue";
import CommentReportModal from './modals/CommentReportModal.vue';

const props = defineProps({
    list: { type: Array, default: () => [] }
});

const userInput = ref("");
const isReportModalOpen = ref(false);
const isSuccessShow = ref(false);
const activeComment = ref({ content: '', userName: '', time: '' });

// --- 記錄目前哪一個 Index 的檢舉視窗是打開的 ---
const reportingIndex = ref(null);

// --- 簡單的點讚邏輯 ---
const localLikes = reactive({});

const toggleLike = (index) => {
    localLikes[index] = !localLikes[index];
};

const getAvatarStyle = (name) => {
    const brandingColors = ['#74D09C', '#FFCB82', '#8FEF60', '#F7F766', '#FF8686', '#90C6FF'];
    const charCodeSum = name.split('').reduce((sum, char) => sum + char.charCodeAt(0), 0);
    return { backgroundColor: brandingColors[charCodeSum % 6], color: '#555555' };
};

const handleSend = () => {
    if (!userInput.value.trim()) return;
    userInput.value = "";
    isSuccessShow.value = true;
    setTimeout(() => { isSuccessShow.value = false; }, 2000);
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

        <Transition name="fade">
            <div v-if="isSuccessShow" class="toast">留言已成功發表！</div>
        </Transition>
    </div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.comment-section {
    max-width: 1400px; // 寬度拉大
    margin: 0 auto;
    padding: 16px 20px; // 高度拉小：減少上下 padding
    font-family: "PingFang TC", sans-serif;
}

.section-title {
    margin-bottom: 20px; // 高度拉小：縮小標題間距
    color: $neutral-color-black;
}

.input-container {
    margin-bottom: 40px;
    position: relative;
    display: flex;
    align-items: center;
    margin-bottom: 16px; // 高度拉小：縮小輸入框下方間距

    .styled-input {
        width: 100%;
        padding: 8px 50px 8px 16px; // 高度拉小：縮小內距
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
    gap: 5px; // 高度拉小：縮小留言之間的距離
}

.comment-item {
    display: flex;
    gap: 12px;
    padding-bottom: 8px; // 高度拉小：縮小底部線條間距
    border-bottom: 1px solid $neutral-color-100;

    &:last-child {
        border-bottom: none;
    }

    .user-avatar-text {
        width: 36px; // 稍微縮小頭像配合高度縮減
        height: 36px;
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
            margin-bottom: 0px; // 高度拉小：緊湊頭部

            .user-name {
                font-weight: 600;
                margin-right: 6px;
                color: $neutral-color-black;
            }

            .user-meta {
                color: $neutral-color-400;
                font-size: 12px;
            }
        }

        .comment-text {
            line-height: 1.4; // 高度拉小：緊湊文字行高
            color: $neutral-color-800;
            margin-bottom: 2px;
            white-space: pre-line;
            font-size: 14px;
        }

        .comment-footer {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 8px;

            .action-btn {
                background: none;
                border: none;
                cursor: pointer;
                display: flex;
                align-items: center;
                color: $neutral-color-700;
                padding: 2px 4px; // 高度拉小：減少按鈕點擊區域厚度
                transition: all 0.2s ease;

                .action-icon {
                    font-size: 16px;
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

.toast {
    position: fixed;
    bottom: 20px;
    left: 50%;
    transform: translateX(-50%);
    background: rgba(0, 0, 0, 0.8);
    color: $neutral-color-white;
    padding: 8px 16px;
    border-radius: 30px;
    z-index: 100;
    font-size: 12px;
}

.fade-enter-active,
.fade-leave-active {
    transition: opacity 0.3s;
}

.fade-enter-from,
.fade-leave-to {
    opacity: 0;
}
</style>