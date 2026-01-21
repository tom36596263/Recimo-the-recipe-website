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
import { ref } from 'vue';

// ==================== Props & Emits ====================
defineProps({
    show: {
        type: Boolean,
        default: false
    }
});

const emit = defineEmits(['close']);

// ==================== 響應式數據 ====================
const unreadCount = ref(3); // 未讀通知數量

// 假的通知數據
const notifications = ref([
    {
        id: 1,
        type: 'success',
        title: '食譜審核通過',
        message: '您的「義式番茄燉飯」已通過審核，現在可以公開分享了！',
        time: '2分鐘前',
        isRead: false
    },
    {
        id: 2,
        type: 'info',
        title: '新留言通知',
        message: 'Roger 在您的食譜「法式吐司」中留言了',
        time: '1小時前',
        isRead: false
    },
    {
        id: 3,
        type: 'warning',
        title: '系統維護通知',
        message: '系統將於今晚 23:00-24:00 進行維護，屆時將暫停服務',
        time: '3小時前',
        isRead: false
    },
    {
        id: 4,
        type: 'success',
        title: '收藏達成',
        message: '恭喜！您的食譜收藏已達到 100 個',
        time: '昨天',
        isRead: true
    },
    {
        id: 5,
        type: 'info',
        title: '新粉絲',
        message: '有人關注您了',
        time: '2天前',
        isRead: true
    }
]);

// ==================== 方法定義 ====================
/**
 * 關閉通知面板
 */
const closePanel = () => {
    emit('close');
};

/**
 * 標記為已讀
 * @param {Number} id - 通知 ID
 */
const markAsRead = (id) => {
    const notification = notifications.value.find(n => n.id === id);
    if (notification && !notification.isRead) {
        notification.isRead = true;
        unreadCount.value = Math.max(0, unreadCount.value - 1);
    }
};

/**
 * 全部標記為已讀
 */
const markAllAsRead = () => {
    notifications.value.forEach(n => n.isRead = true);
    unreadCount.value = 0;
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
        info: '#5AABFF'
    };
    return colorMap[type] || '#5AABFF';
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
            <button v-if="unreadCount > 0" class="mark-all-btn" @click.stop="markAllAsRead">
                全部標示為已讀
            </button>
        </div>

        <!-- 通知列表 -->
        <div class="notification-list">
            <div v-for="notification in notifications" :key="notification.id" class="notification-item"
                :class="{ 'unread': !notification.isRead }" @click.stop="markAsRead(notification.id)">
                <!-- 類型指示器 -->
                <div class="notification-indicator"
                    :style="{ backgroundColor: getNotificationColor(notification.type) }"></div>

                <!-- 內容 -->
                <div class="notification-content">
                    <h5 class="notification-title">{{ notification.title }}</h5>
                    <p class="notification-message">{{ notification.message }}</p>
                    <span class="notification-time">{{ notification.time }}</span>
                </div>

                <!-- 未讀標記 -->
                <div v-if="!notification.isRead" class="unread-dot"></div>
            </div>

            <!-- 空狀態 -->
            <div v-if="notifications.length === 0" class="notification-empty">
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
