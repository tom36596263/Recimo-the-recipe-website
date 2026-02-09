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
    // 🏆 修改點：取消 required，給預設值 0
    userId: { type: [Number, String], default: 0 },
    name: { type: String, default: 'Recimo官方' },
    handle: { type: String, default: '' },
    time: { type: String, default: '' },
    avatarUrl: { type: String, default: null }
});

/**
 * 🏆 終極優化邏輯
 * 無論外部傳什麼進來，這裡都保證輸出一個好看的 handle
 */
const displayHandle = computed(() => {
    // 1. 如果有 handle 且包含 @ (是 Email)，取前面那段
    if (props.handle && String(props.handle).includes('@')) {
        return props.handle.split('@')[0];
    }

    // 2. 如果 handle 存在且不是預設的 'user_xxx' 格式，就直接用 handle
    // 這裡過濾掉像 'user_12' 這種系統生成的暫時 ID
    if (props.handle && !String(props.handle).startsWith('user_')) {
        return props.handle;
    }

    // 3. 如果 handle 是空的，或是 'user_xxx' 格式，
    // 嘗試從 name 轉換（去掉空格、轉小寫）作為替代帳號，若 name 也是預設，則顯示 user
    if (props.name && props.name !== 'Recimo官方' && props.name !== 'Recimo User') {
        // 例如 "Jimmy Wang" -> "jimmywang"
        return props.name.replace(/\s+/g, '').toLowerCase();
    }

    // 4. 最後的最後，顯示 recimo 或 user
    return 'recimo';
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

.user-info-box-link {
    text-decoration: none !important;
    color: inherit !important;
    display: inline-block;

    &:hover {
        opacity: 0.8;
    }
}

a {
    text-decoration: none;
    color: inherit;
}
</style>