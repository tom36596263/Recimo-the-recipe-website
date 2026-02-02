<template>
    <div class="user-info-box">
        <div class="user-avatar-circle" :style="avatarStyle">
            {{ name?.charAt(0).toUpperCase() }}
        </div>
        <div class="user-text-meta">
            <div class="user-name">{{ name }}</div>
            <div class="user-sub">@{{ handle }} • {{ time }}</div>
        </div>
    </div>
</template>

<script setup>
import { computed } from 'vue';

// 1. 定義接收的資料 (Props)
const props = defineProps({
    name: { type: String, default: 'Recimo官方' },
    handle: { type: String, default: 'recimo' },
    time: { type: String, default: '' }
});

// 2. 把頭貼顏色邏輯搬進來
const avatarStyle = computed(() => {
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
    }

    .user-text-meta {
        text-align: left;

        /* 這裡預設靠左，如果你原本頁面要靠右，可以在父組件蓋掉它 */
        .user-name {
            font-weight: 600;
            margin-bottom: 4px;
            color: $neutral-color-800;
            font-size: 15px;
        }

        .user-sub {
            font-size: 12px;
            color: $neutral-color-400;
        }
    }
}
</style>