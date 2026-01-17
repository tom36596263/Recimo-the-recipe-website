<script setup>
import { ref } from "vue";
import CommentReportModal from './modals/CommentReportModal.vue';

const props = defineProps({
    list: {
        type: Array,
        default: () => []
    }
});

const userInput = ref("");
const isReportModalOpen = ref(false);
const isSuccessShow = ref(false); // 成功彈窗狀態
const activeComment = ref({ content: '', userName: '', time: '' });

const handleSend = () => {
    if (!userInput.value.trim()) return;

    // 模擬發送
    console.log("送出留言內容：", userInput.value);
    userInput.value = "";

    // 觸發成功彈窗
    isSuccessShow.value = true;
    setTimeout(() => {
        isSuccessShow.value = false;
    }, 2000);
};

const openReport = (item) => {
    activeComment.value = {
        content: item.content,
        userName: item.userName,
        time: item.time
    };
    isReportModalOpen.value = true;
};

const onReportSubmit = (data) => {
    isReportModalOpen.value = false;
};

const toggleLike = (item) => {
    item.isLiked = !item.isLiked;
    if (item.isLiked) {
        item.likes++;
    } else {
        item.likes--;
    }
};
</script>

<template>
    <div class="comment-container">
        <div class="input-section">
            <div class="input-wrapper">
                <textarea v-model="userInput" placeholder="分享你的烹飪心得或修改建議..." class="comment-textarea p-p2"
                    rows="3"></textarea>
            </div>
            <div class="input-actions-row">
                <span class="p-p3 tip-text">請保持友善的社群交流環境</span>
                <button @click="handleSend" class="send-btn p-p2" :disabled="!userInput.trim()">
                    發表評論
                </button>
            </div>
        </div>

        <div class="comment-list">
            <div v-for="(item, index) in list" :key="index" class="comment-item animate-in">
                <div class="avatar-box">
                    <img :src="item.avatar" class="avatar-img" alt="avatar" />
                </div>

                <div class="comment-content">
                    <div class="user-info-header">
                        <div class="header-left">
                            <span class="user-name zh-h4-bold">{{ item.userName }}</span>
                            <span class="user-handle p-p3">@{{ item.handle }} · {{ item.time }}</span>
                        </div>
                    </div>

                    <p class="comment-text p-p1">{{ item.content }}</p>

                    <div class="comment-actions">
                        <button class="like-btn" :class="{ 'active': item.isLiked }" @click="toggleLike(item)">
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24"
                                :fill="item.isLiked ? 'currentColor' : 'none'" stroke="currentColor" stroke-width="2"
                                stroke-linecap="round" stroke-linejoin="round">
                                <path d="M14 9V5a3 3 0 0 0-3-3l-4 9v11h11.28a2 2 0 0 0 2-1.7l1.38-9a2 2 0 0 0-2-2.3z">
                                </path>
                                <path d="M7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3"></path>
                            </svg>
                            <span class="action-text p-p3">{{ item.likes }}</span>
                        </button>

                        <button class="report-btn" title="檢舉此留言" @click="openReport(item)">
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24"
                                fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                stroke-linejoin="round">
                                <circle cx="12" cy="12" r="10"></circle>
                                <line x1="12" y1="8" x2="12" y2="12"></line>
                                <line x1="12" y1="16" x2="12.01" y2="16"></line>
                            </svg>
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <CommentReportModal v-model="isReportModalOpen" :comment-data="activeComment" @submit="onReportSubmit" />

        <Transition name="fade">
            <div v-if="isSuccessShow" class="success-toast">
                <div class="toast-content">
                    <i-material-symbols:check-circle-rounded class="success-icon" />
                    <span class="zh-h5-bold">留言已成功發表！</span>
                </div>
            </div>
        </Transition>
    </div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.comment-container {
    position: relative;
    background-color: transparent;
    padding: 24px 0;
}

// --- 輸入區樣式 ---
.input-section {
    margin-bottom: 48px;
    border-bottom: 1px solid $neutral-color-100;
    padding-bottom: 32px;

    .input-wrapper {
        margin-bottom: 16px;

        .comment-textarea {
            width: 100%;
            border: 1px solid $neutral-color-100;
            border-radius: 12px;
            padding: 16px;
            background-color: $neutral-color-white;
            color: $neutral-color-black;
            resize: none;
            transition: border-color 0.3s;

            &::placeholder {
                color: $neutral-color-400;
            }

            &:focus {
                outline: none;
                border-color: $primary-color-400;
            }
        }
    }

    .input-actions-row {
        display: flex;
        justify-content: space-between;
        align-items: center;

        .tip-text {
            color: $neutral-color-400;
        }

        .send-btn {
            background-color: $primary-color-700;
            color: $neutral-color-white;
            border: none;
            padding: 10px 28px;
            border-radius: 30px;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.3s;

            &:disabled {
                background-color: $neutral-color-100;
                color: $neutral-color-400;
                cursor: not-allowed;
            }

            &:hover:not(:disabled) {
                background-color: $primary-color-800;
            }
        }
    }
}

// --- 留言列表樣式 ---
.comment-list {
    display: flex;
    flex-direction: column;
    gap: 40px; // 增加留言間的間距
}

.comment-item {
    display: flex;
    gap: 20px;

    .avatar-box {
        flex-shrink: 0;

        .avatar-img {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            object-fit: cover;
            border: 1px solid $neutral-color-100;
        }
    }

    .comment-content {
        flex: 1;

        .user-info-header {
            margin-bottom: 8px;

            .header-left {
                display: flex;
                align-items: center;
                gap: 12px;

                .user-name {
                    color: $neutral-color-black;
                }

                .user-handle {
                    color: $neutral-color-700;
                }
            }
        }

        .comment-text {
            line-height: 1.8;
            margin-bottom: 14px;
            white-space: pre-line;
            color: $neutral-color-800; // 使用 800 提升內文質感
        }
    }
}

// --- 操作按鈕區 ---
.comment-actions {
    display: flex;
    justify-content: flex-end;
    align-items: center;
    gap: 20px;

    button {
        background: none;
        border: none;
        cursor: pointer;
        display: flex;
        align-items: center;
        color: $neutral-color-black; // 預設使用黑色
        padding: 6px;
        transition: transform 0.2s, color 0.2s;

        &:active {
            transform: scale(0.9);
        }
    }

    .like-btn {
        &.active {
            color: $primary-color-700;
        }

        &:hover {
            color: $primary-color-700;
        }
    }

    .report-btn {
        &:hover {
            color: $secondary-color-danger-700;
        }
    }

    .action-text {
        margin-left: 6px;
        font-weight: 500;
    }
}

// --- 成功彈窗 ---
.success-toast {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    z-index: 10000;
    background-color: rgba(0, 0, 0, 0.85);
    backdrop-filter: blur(4px);
    color: $neutral-color-white;
    padding: 32px 56px;
    border-radius: 20px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);

    .toast-content {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 12px;

        .success-icon {
            font-size: 56px;
            color: $secondary-color-success-700;
        }
    }
}

// 動畫與其餘過渡
.fade-enter-active,
.fade-leave-active {
    transition: opacity 0.3s, transform 0.3s;
}

.fade-enter-from,
.fade-leave-to {
    opacity: 0;
    transform: translate(-50%, -40%);
}

.animate-in {
    animation: fadeIn 0.5s ease-out forwards;
}

@keyframes fadeIn {
    from {
        opacity: 0;
        transform: translateY(12px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}
</style>