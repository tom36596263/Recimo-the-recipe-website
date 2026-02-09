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
                <div class="btn-wrapper">
                    <CircleBtn title="立即加入會員" @click="handleOpen" />
                </div>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.membership-banner {
    width: 100%;
    margin-top: 30px;
    position: relative;
    overflow: hidden;
    border-radius: 10px;

    .banner-content {
        width: 100%;
        height: 100%;
        position: relative;
    }

    img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        object-position: center; // 確保圖片上下左右都置中裁切
        display: block;
    }

    .banner-text {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%); // 完美的絕對置中
        width: 100%;
        text-align: center;
        color: $primary-color-800;
        display: flex;
        flex-direction: column;
        align-items: center; // 確保 Flex 內子元素（按鈕）水平置中

        .zh-h2 {
            margin-bottom: 8px;
            width: 100%;
        }

        .zh-h5 {
            margin-top: 8px;
            line-height: 1.5;
            margin-bottom: 40px;
            width: 100%;
        }

        .btn-wrapper {
            width: 100%;
            display: flex;
            justify-content: center; // 確保按鈕容器內置中
        }
    }
}

:deep(::selection) {
    background: rgba($primary-color-700, 0.2);
    color: $primary-color-800;
}

@media (max-width: 768px) {
    .membership-banner {
        height: 400px; // 固定高度，你可以根據需求調整數值
        margin-top: 12%;

        .banner-content {
            height: 100%;
        }

        img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            object-position: center; // 強制圖片正中心對齊，左右自動裁切
        }

        .banner-text {
            padding: 0 20px;
            left: 50%;
            top: 50%;
            transform: translate(-50%, -50%); // 手機版維持正中央

            .zh-h5 {
                font-size: 1rem; // 稍微縮小字體以防溢出
                margin-bottom: 30px;

                br {
                    display: block; // 若手機版不想要換行，可設為 none
                }
            }
        }
    }
}
</style>