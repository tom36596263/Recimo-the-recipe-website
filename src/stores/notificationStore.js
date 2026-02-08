// 通知全域狀態管理（Pinia）
import { defineStore } from 'pinia';
import {
    getNotifications,
    getUnreadCount,
    markAsRead,
    markAllAsRead
} from '@/utils/notificationApi';

export const useNotificationStore = defineStore('notification', {
    state: () => ({
        notifications: [], // 所有通知
        unreadCount: 0, // 未讀數量
        isLoading: false, // 是否正在載入
        lastFetchTime: null // 上次獲取時間
    }),

    getters: {
        /**
         * 未讀通知列表
         */
        unreadNotifications: (state) => {
            return state.notifications.filter(n => n.is_read == 0 || n.is_read === false);
        },

        /**
         * 已讀通知列表
         */
        readNotifications: (state) => {
            return state.notifications.filter(n => n.is_read == 1 || n.is_read === true);
        },

        /**
         * 是否有未讀通知
         */
        hasUnread: (state) => {
            return state.unreadCount > 0;
        }
    },

    actions: {
        /**
         * 獲取通知列表
         * @param {Number} userId - 用戶 ID
         * @param {Boolean} forceRefresh - 是否強制刷新
         */
        async fetchNotifications(userId, forceRefresh = false) {
            if (!userId) return;

            // 防止短時間內重複請求（60秒內不重複請求，除非強制刷新）
            const now = Date.now();
            if (!forceRefresh &&
                this.lastFetchTime &&
                now - this.lastFetchTime < 60000) {
                return;
            }

            this.isLoading = true;
            try {
                const { data } = await getNotifications(userId, { limit: 50 });

                if (data.success) {
                    this.notifications = data.notifications || [];
                    this.lastFetchTime = now;

                    // 同時更新未讀數量
                    await this.fetchUnreadCount(userId);
                }
            } catch (error) {
                console.error('獲取通知失敗:', error);
            } finally {
                this.isLoading = false;
            }
        },

        /**
         * 獲取未讀數量
         * @param {Number} userId - 用戶 ID
         */
        async fetchUnreadCount(userId) {
            if (!userId) return;

            try {
                const { data } = await getUnreadCount(userId);

                if (data.success) {
                    this.unreadCount = data.count || 0;
                }
            } catch (error) {
                console.error('獲取未讀數量失敗:', error);
            }
        },

        /**
         * 標記為已讀
         * @param {Number} notificationId - 通知 ID
         */
        async markAsRead(notificationId) {
            try {
                const { data } = await markAsRead(notificationId);

                if (data.success) {
                    // 更新本地狀態
                    const notification = this.notifications.find(
                        n => n.notification_id === notificationId
                    );
                    if (notification && (notification.is_read == 0 || notification.is_read === false)) {
                        notification.is_read = 1;
                        this.unreadCount = Math.max(0, this.unreadCount - 1);
                    }
                }

                return data;
            } catch (error) {
                console.error('標記已讀失敗:', error);
                throw error;
            }
        },

        /**
         * 全部標記為已讀
         * @param {Number} userId - 用戶 ID
         */
        async markAllAsRead(userId) {
            if (!userId) return;

            try {
                const { data } = await markAllAsRead(userId);

                if (data.success) {
                    // 更新本地狀態
                    this.notifications.forEach(n => {
                        n.is_read = 1;
                    });
                    this.unreadCount = 0;
                }

                return data;
            } catch (error) {
                console.error('全部標記已讀失敗:', error);
                throw error;
            }
        },

        /**
         * 添加新通知（用於即時通知）
         * @param {Object} notification - 通知物件
         */
        addNotification(notification) {
            this.notifications.unshift(notification);
            if (notification.is_read == 0 || notification.is_read === false) {
                this.unreadCount++;
            }
        },

        /**
         * 清空通知列表
         */
        clearNotifications() {
            this.notifications = [];
            this.unreadCount = 0;
            this.lastFetchTime = null;
        }
    }
});
