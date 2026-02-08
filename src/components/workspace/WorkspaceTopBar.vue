<script setup>
import { ref, onMounted, onUnmounted, computed, getCurrentInstance } from 'vue';
import { useRoute } from 'vue-router';
import SearchBar from '@/components/common/SearchBar.vue';
import NotificationPanel from '@/components/common/NotificationPanel.vue';
import { useCartStore } from '@/stores/cartStore';
import { useAuthStore } from '@/stores/authStore';
import { base } from '@/utils/publicApi';
const route = useRoute();
const authStore = useAuthStore();

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

const { proxy } = getCurrentInstance(); // 取得實例代理，這樣才能在 script 裡用 $parsePublicFile

// 暫時解決user img前多/的問題
const getAvatarUrl = (path) => {
    if (!path) return proxy.$parsePublicFile('img/site/None_avatar.svg');
    // 如果是外部連結或 base64 就直接回傳
    if (/^https?:\/\/|^data:image/.test(path)) return path;

    // 處理內部路徑：去掉開頭斜線並交給全域函式
    const cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return proxy.$parsePublicFile(cleanPath);
};

// 使用者資訊從 authStore 取得
const userName = computed(() => authStore.user?.name || authStore.user?.user_name || 'Recimo');
const userAvatar = computed(() => {
    // 直接從 authStore.user 取得，確保響應式更新
    const url = authStore.user?.image || authStore.user?.user_url || authStore.user?.avatar;

    console.log('🖼️ WorkspaceTopBar 計算頭像 URL:', url);

    if (!url) return proxy.$parsePublicFile('img/site/None_avatar.svg');
    if (/^https?:\/\/|^data:image/.test(url)) return url;
    const cleanPath = url.startsWith('/') ? url.substring(1) : url;
    return proxy.$parsePublicFile(cleanPath);
});

onMounted(() => {
    document.addEventListener('click', handleClickOutside);
});

onUnmounted(() => {
    document.removeEventListener('click', handleClickOutside);
});

//購物車數量圓點
const cartStore = useCartStore();
const cartTotal = computed(() => cartStore.totalCount);
</script>

<template>
    <div class="workspace-top-bar">
        <div class="col-6 col-md-12 personal-info">
            <div class="personal-img">
                <img :src="userAvatar" :alt="`${userName}.img`"
                    @error="(e) => e.target.src = getAvatarUrl('img/site/None_avatar.svg')">
            </div>

            <div class="title">
                <h3 class="en-h3">Hi~ <span>{{ userName }}</span></h3>
                <h5 class="zh-h5">一起來發現食譜的新創意吧!</h5>
            </div>
        </div>

        <div class="col-6 col-md-12 tool-group">
            <div class="search-bar">
                <SearchBar />
                <div class="tools">
                    <router-link to="/cart" class="cart-btn" @click="closeMenu">
                        <div class="cart-icon-wrapper">
                            <i-material-symbols-Shopping-Cart-outline class="btn-icon" />
                            <span v-if="cartTotal > 0" class="cart-badge">{{ cartTotal }}</span>
                        </div>
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
                    <router-link to="settings" class="settings-btn">
                        <div class="setting">
                            <i-material-symbols-Settings-outline />
                        </div>
                    </router-link>
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
                // width: 40px;
                width: 100%; // 寬度填滿父層
                height: 100%; // 高度填滿父層
                object-fit: cover; // 裁切並填滿，不會變形
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

        .cart-btn,
        .settings-btn {
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
    // 稍微調整位置，讓圓心對準圖示右上角
    top: -6px;
    right: -6px;

    background: $secondary-color-danger-700;
    color: $neutral-color-white;

    // 強制寬高相等並設為圓形
    width: 18px;
    height: 18px;
    border-radius: 50%;

    // 確保內容置中
    display: flex;
    justify-content: center;
    align-items: center;

    font-size: 11px; // 圓形內空間較小，稍微縮小字體
    font-weight: 600;
    line-height: 1;
    padding: 0; // 圓形不需要 padding，靠 flex 置中即可

    // 防止數字擠壓變形
    flex-shrink: 0;

    // 超過 99 還是圓的
    aspect-ratio: 1 / 1;
}

.cart-icon-wrapper {
    position: relative;
    display: flex;
    align-items: center;

    .cart-badge {
        position: absolute;
        // 稍微調整位置，讓圓心對準圖示右上角
        top: -6px;
        right: -6px;

        background: $secondary-color-danger-700;
        color: $neutral-color-white;

        // 強制寬高相等並設為圓形
        width: 18px;
        height: 18px;
        border-radius: 50%;

        // 確保內容置中
        display: flex;
        justify-content: center;
        align-items: center;

        font-size: 11px; // 圓形內空間較小，稍微縮小字體
        font-weight: 600;
        line-height: 1;
        padding: 0; // 圓形不需要 padding，靠 flex 置中即可

        // 防止數字擠壓變形
        flex-shrink: 0;

        // 超過 99 還是圓的
        aspect-ratio: 1 / 1;
    }
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