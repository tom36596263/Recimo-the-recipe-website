<script setup>

import CircleBtn from '@/components/common/CircleBtn.vue';

const emit = defineEmits(['open-login']);

const handleOpen = () => {
    emit('open-login');
};
</script>

<template>
    <div class="membership-banner">
        <div class="banner-content">
            <img src="@/assets/images/benifit/Placeholder Image.png" alt="會員權益 Banner" />
            <div class="banner-text">
                <div class="zh-h2">會員權益</div>
                <div class="zh-h5">
                    「快加入 Recimo，解鎖各項專屬功能！用數據<br />
                    與靈感，定義您的新烹飪生活~」
                </div>
                <CircleBtn title="立即加入會員" @click="handleOpen" />
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>

.membership-banner {
    width: 100%;
    height: 60vh;
    min-height: 320px;
    max-height: 560px;
    margin-top: 30px;
    position: relative;
    overflow: hidden;
    border-radius: 10px;

    .banner-content {
        width: 100%;
        height: 100%;
        position: relative;
        overflow: hidden;
    }

    img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        object-position: center;
        display: block;
    }

    .banner-text {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -40%);
        width: 100%;
        text-align: center;
        color: $primary-color-800;
        display: flex;
        flex-direction: column;

        .zh-h2 {
            margin-bottom: 8px;
        }

        .zh-h5 {
            margin-top: 8px;
            line-height: 25px;
            margin-bottom: 40px;
        }
    }
}


:deep(::selection) {
    background: rgba($primary-color-700, 0.2);
    color: $primary-color-800;
}

@media (max-width: 768px) {
    .membership-banner {
        height: 45vh;
        margin-top: 12%;
    }

    .membership-banner img {
        object-position: center 30%;
    }

    .banner-text {
        padding: 0 16px;
    }
}
</style>