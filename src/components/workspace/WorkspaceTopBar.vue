<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import { useRoute } from 'vue-router';
import SearchBar from '@/components/common/SearchBar.vue';
import NotificationPanel from '@/components/common/NotificationPanel.vue';

const route = useRoute();

// 通知相關狀態
const showNotifications = ref(false);
const notificationPanelRef = ref(null);
const notificationWrapperRef = ref(null);

// 切換通知面板顯示
const toggleNotifications = () => {
    showNotifications.value = !showNotifications.value;
};

// 關閉通知面板
const closeNotifications = () => {
    showNotifications.value = false;
};

// 點擊外部關閉通知面板
const handleClickOutside = (event) => {
    if (notificationWrapperRef.value && !notificationWrapperRef.value.contains(event.target)) {
        closeNotifications();
    }
};

onMounted(() => {
    document.addEventListener('click', handleClickOutside);
});

onUnmounted(() => {
    document.removeEventListener('click', handleClickOutside);
});
</script>

<template>
    <div class="workspace-top-bar">
        <div class="col-6 col-md-12 personal-info">
            <div class="personal-img">
                <img src="/img/site/Recimo-logo-black.svg" alt="">
            </div>

            <div class="title">
                <h3 class="en-h3">Hi,<span>Recimo</span></h3>
                <h5 class="zh-h5">一起來發現食譜的新創意吧!</h5>
            </div>
        </div>

        <div class="col-6 col-md-12 tool-group">
            <div class="search-bar">
                <SearchBar />
                <div class="tools">
                    <router-link to="/cart" class="cart-btn" @click="closeMenu">
                        <i-material-symbols-Shopping-Cart-outline class="btn-icon" />
                    </router-link>

                    <!-- 通知按鈕 -->
                    <div ref="notificationWrapperRef" class="notification-wrapper">
                        <button class="notification-btn" @click="toggleNotifications">
                            <i-material-symbols-Notifications-outline />
                            <span v-if="notificationPanelRef?.unreadCount > 0" class="notification-badge">
                                {{ notificationPanelRef.unreadCount }}
                            </span>
                        </button>

                        <!-- 通知面板組件 -->
                        <NotificationPanel ref="notificationPanelRef" :show="showNotifications"
                            @close="closeNotifications" />
                    </div>

                    <div class="setting">
                        <i-material-symbols-Settings-outline />
                    </div>
                </div>
            </div>
        </div>
    </div>

</template>



<style lang="scss" scoped>
.workspace-top-bar {
    width: 100%;
    margin: 20px auto;
    border-radius: $radius-base;
    background-color: $primary-color-100;
    display: flex;

    .personal-info {
        display: flex;
        align-items: center;
        padding: 20px;

        .personal-img {
            width: 60px;
            height: 60px;
            flex-shrink: 0;
            margin-right: 12px;
            border-radius: $radius-pill;
            background-color: $neutral-color-white;
            overflow: hidden;
            display: flex;
            justify-content: center;

            img {
                width: 40px;

            }
        }

        .title {
            color: $primary-color-700;
        }
    }

    .tool-group {
        display: flex;
        justify-content: end;
        align-items: center;
        margin-right: 20px;

        .cart-btn {
            color: $primary-color-700;
            font-size: 24px;
            text-decoration: none;
            display: flex;
            align-items: center;

            &:hover {
                color: $accent-color-400;
            }
        }

        .search-bar {
            display: flex;
            gap: 16px;

            .tools {
                display: flex;
                gap: 16px;
                font-size: 24px;
                color: $primary-color-700;
                flex-direction: row;
                align-items: center;
            }
        }
    }
}

/* ==================== 通知按鈕樣式 ==================== */
.notification-wrapper {
    position: relative;
}

.notification-btn {
    position: relative;
    background: none;
    border: none;
    cursor: pointer;
    padding: 0;
    color: $primary-color-700;
    font-size: 24px;
    display: flex;
    align-items: center;
    transition: color 0.3s ease;

    &:hover {
        color: $accent-color-400;
    }
}

.notification-badge {
    position: absolute;
    top: -6px;
    right: -6px;
    background: $secondary-color-danger-700;
    color: $neutral-color-white;
    border-radius: 10px;
    padding: 2px 6px;
    font-size: 11px;
    font-weight: 600;
    min-width: 18px;
    text-align: center;
    line-height: 1.2;
}



@media screen and (max-width: 810px) {
    .workspace-top-bar {
        position: relative;

        .personal-info {
            padding-top: 35px;
        }

        .tool-group {
            position: absolute;
            top: -20px;
            left: 0;
            display: flex;

            .search-bar {
                width: 100%; // 強制搜尋欄填滿
                display: flex;
                justify-content: center;
                flex-direction: column;
            }
        }

        .tools {
            position: absolute;
            top: -50px;
            right: 0;

            .setting {
                display: none;
            }
        }
    }
}
</style>