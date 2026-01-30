<script setup>
import { ref, onMounted, watch, nextTick } from "vue"; // 🏆 加入 nextTick
import { useRoute } from "vue-router";
import { useAuthStore } from '@/stores/authStore';
import CommentReportModal from './modals/CommentReportModal.vue';

const props = defineProps({
    list: { type: Array, default: () => [] }
});

const emit = defineEmits(['post-comment', 'like-comment', 'delete-comment']);
const route = useRoute();
const authStore = useAuthStore();

const userInput = ref("");
const inputRef = ref(null); // 🏆 用於操控高度
const isReportModalOpen = ref(false);
const activeComment = ref({ content: '', userName: '', time: '' });
const reportingIndex = ref(null);

// 🚀 權限判斷
const isOwner = (handle) => {
    if (!handle) return false;
    const userIdFromComment = Number(handle.replace('user_', ''));
    const currentUserId = Number(authStore.user?.user_id || authStore.user?.id);
    return userIdFromComment === currentUserId;
};

// 🚀 自動調整高度邏輯
const autoResize = () => {
    const el = inputRef.value;
    if (!el) return;
    el.style.height = '46px'; // 重設基準高度
    el.style.height = el.scrollHeight + 'px'; // 撐開高度
};

// 點讚紀錄與持久化
const clickedLikes = ref(new Set());
const getStorageKey = () => `liked_comments_recipe_${route.params.id || 'common'}`;
const loadLikedStatus = () => {
    const saved = localStorage.getItem(getStorageKey());
    if (saved) {
        const likedArray = JSON.parse(saved);
        clickedLikes.value = new Set(likedArray);
    }
};

onMounted(() => { loadLikedStatus(); });
watch(() => route.params.id, () => { loadLikedStatus(); });

const getAvatarStyle = (name) => {
    const brandingColors = ['#74D09C', '#FFCB82', '#8FEF60', '#F7F766', '#FF8686', '#90C6FF'];
    const charCodeSum = String(name).split('').reduce((sum, char) => sum + char.charCodeAt(0), 0);
    return { backgroundColor: brandingColors[charCodeSum % 6], color: '#555555' };
};

const handleSend = () => {
    if (!userInput.value.trim()) return;
    emit('post-comment', userInput.value);
    userInput.value = "";
    // 🏆 送出後重設高度
    nextTick(() => {
        if (inputRef.value) inputRef.value.style.height = '46px';
    });
};

const handleLikeClick = (commentId) => {
    const id = Number(commentId);
    if (clickedLikes.value.has(id)) {
        clickedLikes.value.delete(id);
        localStorage.setItem(getStorageKey(), JSON.stringify([...clickedLikes.value]));
        emit('like-comment', id, 'dislike');
    } else {
        clickedLikes.value.add(id);
        localStorage.setItem(getStorageKey(), JSON.stringify([...clickedLikes.value]));
        emit('like-comment', id, 'like');
    }
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
            <textarea ref="inputRef" v-model="userInput" placeholder="分享你的想法..." class="styled-input" maxlength="200"
                rows="1" @input="autoResize" @keydown.enter.exact.prevent="handleSend"></textarea>

            <span class="char-counter" :class="{ 'limit': userInput.length >= 200 }">
                {{ userInput.length }}/200
            </span>

            <button class="send-icon-btn" :class="{ 'active': userInput.trim() }" @click="handleSend">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z" />
                </svg>
            </button>
        </div>

        <div class="comment-list">
            <template v-if="list && list.length > 0">
                <div v-for="(item, index) in list" :key="item.comment_id || index" class="comment-item">
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
                            <button class="action-btn like-btn"
                                :class="{ 'active': clickedLikes.has(Number(item.comment_id)) }"
                                @click="handleLikeClick(item.comment_id)">
                                <i-material-symbols-thumb-up-rounded v-if="clickedLikes.has(Number(item.comment_id))"
                                    class="action-icon" />
                                <i-material-symbols-thumb-up-outline-rounded v-else class="action-icon" />
                                <span class="count">{{ item.likes || 0 }}</span>
                            </button>

                            <button v-if="!isOwner(item.handle)" class="action-btn report-btn"
                                :class="{ 'active': reportingIndex === index }" @click="openReport(item, index)">
                                <i-material-symbols-error-outline-rounded class="action-icon" />
                            </button>

                            <button v-if="isOwner(item.handle)" class="action-btn delete-btn"
                                @click="emit('delete-comment', item.comment_id)">
                                <i-material-symbols-delete-outline-rounded class="action-icon" />
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
    align-items: flex-end; // 🏆 讓按鈕靠底部
    margin-bottom: 32px;

    .styled-input {
            width: 100%;
            min-height: 46px;
            max-height: 200px;
            padding: 12px 95px 12px 16px; // 🏆 稍微增加右側內距，給計數器更多空間
            border: 1.5px solid $primary-color-700;
            border-radius: 12px;
            font-size: 15px;
            outline: none;
            transition: border-color 0.2s;
            resize: none;
            line-height: 1.5;
            font-family: inherit;
    
            /* 🏆 隱藏捲軸但保留捲動功能 (針對不同瀏覽器) */
            scrollbar-width: none; // Firefox
    
            &::-webkit-scrollbar {
                display: none; // Chrome, Safari, Edge
            }
    
            &:focus {
                border-color: $primary-color-800;
                box-shadow: 0 0 0 3px rgba(74, 131, 96, 0.1);
            }
        }
    
        /* 🏆 微調計數器位置，讓它跟發送按鈕保持一點距離 */
        .char-counter {
            position: absolute;
            right: 52px; // 從 48px 微調到 52px
            bottom: 12px;
            font-size: 12px;
            color: $neutral-color-400;
            user-select: none; // 防止計數器文字被選取
            background: $neutral-color-white; // 避免文字疊在捲軸位置時透過去
    
            &.limit {
                color: $secondary-color-danger-700;
            }
        }

    .send-icon-btn {
        position: absolute;
        right: 15px;
        bottom: 12px;
        background: none;
        border: none;
        cursor: pointer;
        color: $neutral-color-400;
        display: flex;
        align-items: center;

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
        width: 44px;
        height: 44px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 600;
        font-size: 16px;
        flex-shrink: 0;
        user-select: none;
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
            // 🏆 關鍵：讓留言能顯示換行並強制斷詞
            white-space: pre-wrap;
            word-break: break-all;
        }
    }
}

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

.comment-footer {
    display: flex;
    justify-content: flex-end;
    align-items: center;
    gap: 8px;

    .action-btn {
        background: none;
        border: none;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        color: $neutral-color-700;
        transition: all 0.2s;
        padding: 4px 8px;
        height: 32px;

        .action-icon {
            font-size: 20px;
            width: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .count {
            margin-left: 4px;
            font-size: 14px;
            font-weight: 500;
            font-variant-numeric: tabular-nums;
            line-height: 1;
            position: relative;
            top: 1px;
        }

        &.like-btn:hover,
        &.like-btn.active {
            color: $primary-color-700;

            .action-icon {
                fill: currentColor;
            }
        }

        &.report-btn:hover,
        &.active {
            color: $accent-color-700;
        }

        &.delete-btn:hover {
            color: $secondary-color-danger-700;
            transform: scale(1.1);
        }
    }
}
</style>