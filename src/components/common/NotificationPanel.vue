/**
* 通知面板組件
*
* 功能說明：
* - 顯示系統通知列表
* - 支持未讀/已讀狀態切換
* - 提供全部標記為已讀功能
* - 支持不同通知類型（成功、警告、危險、資訊）
* - 響應式設計，適配桌面和移動端
*/
<script setup>
import { ref, computed, watch, onMounted } from 'vue';
import { useNotificationStore } from '@/stores/notificationStore';
import { useAuthStore } from '@/stores/authStore';
import { useRouter } from 'vue-router';
import { parsePublicFile } from '@/utils/parseFile';

// ==================== Props & Emits ====================
const props = defineProps({
    show: {
        type: Boolean,
        default: false
    }
});

const emit = defineEmits(['close']);

// ==================== Store ====================
const notificationStore = useNotificationStore();
const authStore = useAuthStore();
const router = useRouter();

// ==================== 響應式數據 ====================
const userId = computed(() => authStore.user?.id || authStore.user?.user_id || null);

// 從 store 獲取通知列表和未讀數量
const notifications = computed(() => notificationStore.notifications);
const unreadCount = computed(() => notificationStore.unreadCount);
const isLoading = computed(() => notificationStore.isLoading);

// ==================== 生命週期 ====================
onMounted(() => {
    // 組件掛載時載入通知
    if (userId.value) {
        notificationStore.fetchNotifications(userId.value);
    }
});

// 監聽面板顯示狀態，每次打開時刷新
watch(() => props.show, (isShow) => {
    if (isShow && userId.value) {
        notificationStore.fetchNotifications(userId.value, true);
    }
});

// ==================== 方法定義 ====================
/**
 * 關閉通知面板
 */
const closePanel = () => {
    emit('close');
};

/**
 * 標記為已讀並跳轉
 * @param {Object} notification - 通知物件
 */
const handleNotificationClick = async (notification) => {
    // 標記為已讀（嚴格判定：0 或 "0" 都視為未讀）
    if (notification.is_read == 0 || notification.is_read === false) {
        await notificationStore.markAsRead(notification.notification_id);
    }

    // 如果有連結，則跳轉
    if (notification.link_url) {
        router.push(notification.link_url);
        closePanel();
    }
};

/**
 * 全部標記為已讀
 */
const handleMarkAllAsRead = async () => {
    if (userId.value) {
        await notificationStore.markAllAsRead(userId.value);
    }
};

/**
 * 獲取通知類型對應的圖標顏色
 * @param {String} type - 通知類型
 * @returns {String} 顏色值
 */
const getNotificationColor = (type) => {
    const colorMap = {
        success: '#5ED822',
        warning: '#EEEE05',
        danger: '#FF5858',
        info: '#5AABFF',
        comment: '#5AABFF',
        follow: '#3E8D60',
        like: '#FF5858',
        system: '#868686'
    };
    return colorMap[type] || '#5AABFF';
};

/**
 * 格式化時間顯示
 * @param {String} datetime - 時間字串
 * @returns {String} 格式化後的時間
 */
const formatTime = (datetime) => {
    if (!datetime) return '';

    const now = new Date();
    const time = new Date(datetime);
    const diff = Math.floor((now - time) / 1000); // 秒數差異

    if (diff < 60) return '剛剛';
    if (diff < 3600) return `${Math.floor(diff / 60)}分鐘前`;
    if (diff < 86400) return `${Math.floor(diff / 3600)}小時前`;
    if (diff < 604800) return `${Math.floor(diff / 86400)}天前`;

    // 超過一週顯示具體日期
    return time.toLocaleDateString('zh-TW', {
        month: 'short',
        day: 'numeric'
    });
};

// ==================== Expose ====================
defineExpose({
    unreadCount
});
</script>

<template>
    <!-- 通知下拉面板 -->
    <div v-if="show" class="notification-panel">
        <!-- 面板標題 -->
        <div class="notification-header">
            <h4 class="zh-h4">通知中心</h4>
            <button v-if="unreadCount > 0" class="mark-all-btn" @click.stop="handleMarkAllAsRead">
                全部標示為已讀
            </button>
        </div>

        <!-- 通知列表 -->
        <div class="notification-list">
            <!-- 載入中狀態 -->
            <div v-if="isLoading" class="notification-loading">
                <p>載入中...</p>
            </div>

            <!-- 通知項目 -->
            <div v-else-if="notifications.length > 0">
                <div v-for="notification in notifications" :key="notification.notification_id" class="notification-item"
                    :class="{ 'unread': notification.is_read == 0 || notification.is_read === false }"
                    @click.stop="handleNotificationClick(notification)">
                    <!-- 類型指示器 -->
                    <div class="notification-indicator"
                        :style="{ backgroundColor: getNotificationColor(notification.notification_type) }"></div>

                    <!-- 圖片（如果有） -->
                    <div v-if="notification.notification_photo_url" class="notification-photo">
                        <img :src="parsePublicFile(notification.notification_photo_url)" alt="通知圖片" />
                    </div>

                    <!-- 內容 -->
                    <div class="notification-content">
                        <h5 class="notification-title">{{ notification.notification_title }}</h5>
                        <p class="notification-message">{{ notification.notification_content }}</p>
                        <span class="notification-time">{{ formatTime(notification.created_at) }}</span>
                    </div>

                    <!-- 未讀標記 -->
                    <div v-if="notification.is_read == 0 || notification.is_read === false" class="unread-dot"></div>
                </div>
            </div>

            <!-- 空狀態 -->
            <div v-else class="notification-empty">
                <i-material-symbols-Notifications-outline />
                <p>目前沒有任何通知</p>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
/* ==================== 通知下拉面板 ==================== */
.notification-panel {
    position: absolute;
    top: calc(100% + 12px);
    right: 0;
    width: 400px;
    max-height: 600px;
    background: $neutral-color-white;
    border-radius: 12px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
    z-index: 1000;
    display: flex;
    flex-direction: column;
    animation: slideDown 0.3s ease;
}

/* ==================== 面板標題 ==================== */
.notification-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px;
    border-bottom: 1px solid $neutral-color-100;

    h4 {
        margin: 0;
        color: $neutral-color-800;
        font-size: 18px;
    }
}

.mark-all-btn {
    background: none;
    border: none;
    color: $primary-color-700;
    font-size: 13px;
    cursor: pointer;
    padding: 6px 12px;
    border-radius: 6px;
    transition: all 0.3s ease;

    &:hover {
        background: $primary-color-100;
        color: $primary-color-800;
    }
}

/* ==================== 通知列表 ==================== */
.notification-list {
    overflow-y: auto;
    max-height: 500px;
    padding: 8px;

    &::-webkit-scrollbar {
        width: 6px;
    }

    &::-webkit-scrollbar-thumb {
        background: $neutral-color-400;
        border-radius: 3px;
    }

    &::-webkit-scrollbar-track {
        background: $neutral-color-100;
    }
}

/* ==================== 載入中狀態 ==================== */
.notification-loading {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 60px 20px;
    color: $neutral-color-400;

    svg {
        font-size: 32px;
        margin-bottom: 12px;
    }

    p {
        margin: 0;
        font-size: 14px;
    }
}

/* ==================== 單個通知項目 ==================== */
.notification-item {
    display: flex;
    gap: 12px;
    padding: 16px;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.3s ease;
    position: relative;
    margin-bottom: 8px;

    &:hover {
        background: $neutral-color-100;
    }

    &.unread {
        background: $primary-color-100;

        &:hover {
            background: darken($primary-color-100, 3%);
        }
    }
}

/* ==================== 類型指示器 ==================== */
.notification-indicator {
    width: 4px;
    height: 100%;
    border-radius: 2px;
    flex-shrink: 0;
}

/* ==================== 通知圖片 ==================== */
.notification-photo {
    width: 48px;
    height: 48px;
    border-radius: 8px;
    overflow: hidden;
    flex-shrink: 0;

    img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
}

/* ==================== 通知內容 ==================== */
.notification-content {
    flex: 1;
    min-width: 0;
}

.notification-title {
    font-size: 14px;
    font-weight: 600;
    color: $neutral-color-800;
    margin: 0 0 6px 0;
}

.notification-message {
    font-size: 13px;
    color: $neutral-color-700;
    margin: 0 0 8px 0;
    line-height: 1.5;
    word-wrap: break-word;
}

.notification-time {
    font-size: 12px;
    color: $neutral-color-400;
}

/* ==================== 未讀標記點 ==================== */
.unread-dot {
    width: 8px;
    height: 8px;
    background: $primary-color-700;
    border-radius: 50%;
    flex-shrink: 0;
    align-self: center;
}

/* ==================== 空狀態 ==================== */
.notification-empty {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 60px 20px;
    color: $neutral-color-400;

    svg {
        font-size: 48px;
        margin-bottom: 16px;
        opacity: 0.5;
    }

    p {
        margin: 0;
        font-size: 14px;
    }
}

/* ==================== 動畫 ==================== */
@keyframes slideDown {
    from {
        opacity: 0;
        transform: translateY(-10px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}

/* ==================== 響應式設計 ==================== */
@media screen and (max-width: 810px) {
    .notification-panel {
        right: -10px;
        width: 90vw;
        max-width: 400px;
        max-height: 70vh;
    }
}
</style>
