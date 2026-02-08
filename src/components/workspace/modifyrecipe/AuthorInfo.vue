<template>
    <router-link :to="`/workspace/user/${userId}`" class="user-info-box-link">
        <div class="user-info-box">
            <div class="user-avatar-circle" :style="avatarStyle">
                <img v-if="avatarUrl" :src="parsePublicFile(avatarUrl)" class="avatar-img" />
                <span v-else>{{ name?.charAt(0).toUpperCase() }}</span>
            </div>
            <div class="user-text-meta">
                <div class="user-name">{{ name }}</div>
                <div class="user-sub">
                    @{{ displayHandle }}<span v-if="time"> • {{ time }}</span>
                </div>
            </div>
        </div>
    </router-link>
</template>

<script setup>
import { computed } from 'vue';
import { parsePublicFile } from '@/utils/parseFile';

const props = defineProps({
    userId: { type: [Number, String], required: true },
    name: { type: String, default: 'Recimo官方' },
    handle: { type: String, default: 'recimo' },
    time: { type: String, default: '' },
    avatarUrl: { type: String, default: null }
});

/**
 * 🏆 核心邏輯：把 email 前綴當成帳號
 * 如果 handle 包含 '@'，則取 '@' 之前的字串
 */
const displayHandle = computed(() => {
    if (!props.handle) return 'user';
    if (props.handle.includes('@')) {
        return props.handle.split('@')[0];
    }
    return props.handle;
});

const avatarStyle = computed(() => {
    if (props.avatarUrl) {
        return { backgroundColor: 'transparent', border: 'none' };
    }
    const safeName = props.name || 'User';
    const brandingColors = ['#74D09C', '#FFCB82', '#8FEF60', '#F7F766', '#FF8686', '#90C6FF'];
    const charCodeSum = safeName.split('').reduce((sum, char) => sum + char.charCodeAt(0), 0);

    return {
        backgroundColor: brandingColors[charCodeSum % 6],
        color: '#555555'
    };
});
</script>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.user-info-box {
    display: flex;
    align-items: center;
    gap: 12px;

    .user-avatar-circle {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 600;
        font-size: 15px;
        border: 1px solid rgba(0, 0, 0, 0.05);
        flex-shrink: 0;
        overflow: hidden;

        .avatar-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
    }

    .user-text-meta {
        text-align: left;

        .user-name {
            font-weight: 600;
            margin-bottom: 2px;
            color: $neutral-color-800;
            font-size: 15px;
        }

        .user-sub {
            font-size: 12px;
            color: $neutral-color-400;
        }
    }
}

/* 針對包裝組件的 router-link 進行樣式重置 */
.user-info-box-link {
    text-decoration: none !important; // 強制去掉底線
    color: inherit !important; // 強制繼承原本的文字顏色
    display: inline-block; // 確保寬度正確

    &:hover {
        opacity: 0.8; // 增加回饋感
    }
}

/* 確保全域 a 標籤在組件內不顯示底線 */
a {
    text-decoration: none;
    color: inherit;
}
</style>