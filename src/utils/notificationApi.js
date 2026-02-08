// 通知 API 服務
import { phpApi } from './phpApi';

/**
 * 獲取用戶的通知列表
 * @param {Number} userId - 用戶 ID
 * @param {Object} params - 查詢參數 { is_read: 0|1, limit: 10 }
 * @returns {Promise}
 */
export const getNotifications = (userId, params = {}) => {
    return phpApi.get('/social/notifications.php', {
        params: {
            receiver_id: userId,
            ...params
        }
    });
};

/**
 * 獲取未讀通知數量
 * @param {Number} userId - 用戶 ID
 * @returns {Promise}
 */
export const getUnreadCount = (userId) => {
    return phpApi.get('/social/notifications.php', {
        params: {
            receiver_id: userId,
            count_only: 1,
            is_read: 0
        }
    });
};

/**
 * 標記單個通知為已讀
 * @param {Number} notificationId - 通知 ID
 * @returns {Promise}
 */
export const markAsRead = (notificationId) => {
    return phpApi.patch('/social/notifications.php', {
        notification_id: notificationId,
        is_read: 1
    });
};

/**
 * 全部標記為已讀
 * @param {Number} userId - 用戶 ID
 * @returns {Promise}
 */
export const markAllAsRead = (userId) => {
    return phpApi.patch('/social/notifications.php', {
        receiver_id: userId,
        mark_all: 1
    });
};

/**
 * 刪除通知
 * @param {Number} notificationId - 通知 ID
 * @returns {Promise}
 */
export const deleteNotification = (notificationId) => {
    return phpApi.delete('/social/notifications.php', {
        data: {
            notification_id: notificationId
        }
    });
};

/**
 * 創建新通知（系統使用）
 * @param {Object} notification - 通知資料
 * @returns {Promise}
 */
export const createNotification = (notification) => {
    const payload = {
        receiver_id: notification.receiver_id,
        notification_type: notification.type,
        notification_title: notification.title,
        notification_content: notification.content
    };

    if (notification.photo_url) {
        payload.notification_photo_url = notification.photo_url;
    }
    if (notification.link_url) {
        payload.link_url = notification.link_url;
    }
    if (notification.sender_id) {
        payload.sender_id = notification.sender_id;
    }

    return phpApi.post('/social/notifications.php', payload);
};
