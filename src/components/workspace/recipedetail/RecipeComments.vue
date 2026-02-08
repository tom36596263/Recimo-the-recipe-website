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
                    <router-link :to="`/workspace/user/${item.userId || item.user_id}`" class="user-link-wrapper">
                        <div class="user-avatar-text" :style="getAvatarStyle(item.userName || item.username)">
                            {{ (item.userName || item.username || '?').charAt(0).toUpperCase() }}
                        </div>
                    </router-link>

                    <div class="comment-body">
                        <div class="comment-header">
                            <router-link :to="`/workspace/user/${item.userId || item.user_id}`"
                                class="user-link-wrapper">
                                <span class="user-name p-p1">{{ item.userName || item.username || '訪客' }}</span>
                            </router-link>
                            <span class="user-meta p-p3">
                                @{{
                                    item.handle && item.handle.includes('@')
                                        ? item.handle.split('@')[0]
                                        : (item.handle ? item.handle : '未抓到Email')
                                }}
                                • {{ item.comment_at || item.time }}

                            </span>
                        </div>
                        <p class="comment-text p-p2">{{ item.content || item.comment_text }}</p>

                        <div class="comment-footer">
                            <button class="action-btn like-btn"
                                :class="{ 'active': clickedLikes.has(Number(item.comment_id)) }"
                                @click="handleLikeClick(item.comment_id)">
                                <i-material-symbols-thumb-up-rounded v-if="clickedLikes.has(Number(item.comment_id))"
                                    class="action-icon" />
                                <i-material-symbols-thumb-up-outline-rounded v-else class="action-icon" />
                                <span class="count">{{ item.likes ?? item.like_count ?? 0 }}</span>
                            </button>

                            <button v-if="!isOwner(item)" class="action-btn report-btn"
                                :class="{ 'active': reportingIndex === index }" @click="openReport(item, index)">
                                <i-material-symbols-error-outline-rounded class="action-icon" />
                            </button>

                            <button v-if="isOwner(item)" class="action-btn delete-btn"
                                @click="openDeleteConfirm(item.comment_id)">
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

        <Teleport to="body">
            <CommentReportModal v-model="isReportModalOpen" :comment-data="activeComment"
                @update:modelValue="val => !val && (reportingIndex = null)" />

            <BaseModal :isOpen="isDeleteModalOpen" type="info" iconClass="fa-regular fa-trash-can" title="確定要刪除這條留言嗎？"
                @close="isDeleteModalOpen = false">
                <p class="p-p2" style="text-align: center;">刪除後的留言無法找回喔！</p>
                <template #actions>
                    <button class="btn-solid" @click="handleConfirmDelete">確定刪除</button>
                    <button class="btn-outline" @click="isDeleteModalOpen = false">取消</button>
                </template>
            </BaseModal>
        </Teleport>
    </div>
</template>

<script setup>
import { ref, onMounted, watch, nextTick } from "vue";
import { useRoute } from "vue-router";
import { useAuthStore } from '@/stores/authStore';
import CommentReportModal from './modals/CommentReportModal.vue';
import BaseModal from '@/components/BaseModal.vue';

const props = defineProps({
    list: { type: Array, default: () => [] }
});

const emit = defineEmits(['post-comment', 'like-comment', 'delete-comment']);
const route = useRoute();
const authStore = useAuthStore();

const userInput = ref("");
const inputRef = ref(null);
const isReportModalOpen = ref(false);
const activeComment = ref({ content: '', userName: '', time: '' });
const reportingIndex = ref(null);

const isDeleteModalOpen = ref(false);
const commentIdToDelete = ref(null);

// 🚀 權限判斷：支援 userId (大寫) 與 user_id (底線)
const isOwner = (item) => {
    if (!item || !authStore.user) return false;
    const currentUserId = Number(authStore.user.user_id || authStore.user.id);
    const commentUserId = Number(item.userId || item.user_id);
    return commentUserId === currentUserId;
};

const autoResize = () => {
    const el = inputRef.value;
    if (!el) return;
    el.style.height = '46px';
    el.style.height = el.scrollHeight + 'px';
};

const clickedLikes = ref(new Set());
const getStorageKey = () => `liked_comments_recipe_${route.params.id || 'common'}`;
const loadLikedStatus = () => {
    const saved = localStorage.getItem(getStorageKey());
    if (saved) {
        try {
            clickedLikes.value = new Set(JSON.parse(saved));
        } catch (e) { clickedLikes.value = new Set(); }
    }
};

onMounted(loadLikedStatus);
watch(() => route.params.id, loadLikedStatus);

const getAvatarStyle = (name) => {
    const brandingColors = ['#74D09C', '#FFCB82', '#8FEF60', '#F7F766', '#FF8686', '#90C6FF'];
    const charCodeSum = String(name || 'User').split('').reduce((sum, char) => sum + char.charCodeAt(0), 0);
    return { backgroundColor: brandingColors[charCodeSum % 6], color: '#555555' };
};

const handleSend = () => {
    if (!userInput.value.trim()) return;
    emit('post-comment', userInput.value);
    userInput.value = "";
    nextTick(() => {
        if (inputRef.value) inputRef.value.style.height = '46px';
    });
};

const handleLikeClick = (commentId) => {
    const id = Number(commentId);
    if (clickedLikes.value.has(id)) {
        clickedLikes.value.delete(id);
        emit('like-comment', id, 'dislike');
    } else {
        clickedLikes.value.add(id);
        emit('like-comment', id, 'like');
    }
    localStorage.setItem(getStorageKey(), JSON.stringify([...clickedLikes.value]));
};

const openReport = (item, index) => {
    activeComment.value = { ...item };
    reportingIndex.value = index;
    isReportModalOpen.value = true;
};

const openDeleteConfirm = (id) => {
    commentIdToDelete.value = id;
    isDeleteModalOpen.value = true;
};

const handleConfirmDelete = () => {
    if (commentIdToDelete.value) {
        emit('delete-comment', commentIdToDelete.value);
    }
    isDeleteModalOpen.value = false;
    commentIdToDelete.value = null;
};
</script>

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
    align-items: flex-end;
    margin-bottom: 32px;

    .styled-input {
        width: 100%;
        min-height: 46px;
        max-height: 200px;
        padding: 12px 95px 12px 16px;
        border: 1.5px solid $primary-color-700;
        border-radius: 12px;
        font-size: 15px;
        outline: none;
        transition: border-color 0.2s;
        resize: none;
        line-height: 1.5;
        font-family: inherit;
        scrollbar-width: none;

        &::-webkit-scrollbar {
            display: none;
        }

        &:focus {
            border-color: $primary-color-800;
            box-shadow: 0 0 0 3px rgba(74, 131, 96, 0.1);
        }
    }

    .char-counter {
        position: absolute;
        right: 52px;
        bottom: 12px;
        font-size: 12px;
        color: $neutral-color-400;
        user-select: none;
        background: $neutral-color-white;

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

    // 🚀 新增：跳轉連結包裝層樣式
    .user-link-wrapper {
        text-decoration: none !important;
        color: inherit !important;
        display: flex;
        align-items: center;
        transition: opacity 0.2s;

        &:hover {
            opacity: 0.8;

            .user-name {
                color: $primary-color-700;
            }
        }
    }

    .user-avatar-text {
        margin-top: -40px;
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
            display: flex;
            align-items: center;

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
        justify-content: flex-start;
        color: $neutral-color-700;
        transition: all 0.2s;
        padding: 4px 8px;
        height: 32px;
        min-width: 48px;

        .action-icon {
            font-size: 20px;
            width: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            margin-right: 4px;
        }

        .count {
            font-size: 14px;
            font-weight: 500;
            font-variant-numeric: tabular-nums;
            line-height: 1;
            text-align: left;
            min-width: 14px;
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