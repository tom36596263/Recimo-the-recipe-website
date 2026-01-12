<script setup>
const props = defineProps({
    list: {
        type: Array,
        default: () => []
    }
});

// 定義點擊上傳按鈕的函式 (目前先留空)
const handleUploadClick = () => {
    console.log("未來將開啟彈窗");
};
</script>

<template>
<div class="recipe-result-container">
    <div class="result-header">
    <div class="upload-trigger-area" @click="handleUploadClick">
        <div class="upload-card">
        <span class="plus-sign zh-h2">+</span>
        <span class="main-label zh-h5">成品展示</span>
        <span class="sub-label en-h3">add photo</span>
        </div>
    </div>

    <div class="header-text-group">
        <h5 class="zh-h5-bold">每一份手作的溫度，都值得被記錄與分享</h5>
        <div class="description">
        <p class="p-p2">上傳您的作品照，與同樣熱愛烹飪的夥伴們交換那份成就感，</p>
        <p class="p-p2">不用追求完美，這裡記錄的是屬於您廚房裡最真實的美味故事。</p>
        </div>
    </div>
    </div>

    <div class="result-wall">
    <div class="wall-viewport">
        <div v-for="(photo, index) in list" :key="index" class="work-item">
        <img :src="photo.url" :alt="'User work ' + index">
        <div class="work-overly">
            <p class="comment-text p-p2">{{ photo.comment }}</p>
        </div>
        </div>
    </div>
    </div>
</div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.recipe-result-container {
padding: 40px 0;

.result-header {
    display: flex;
    align-items: center;
    gap: 40px;
    margin-bottom: 32px;

    .upload-card {
    width: 180px;
    height: 140px;
    border: 1px solid $primary-color-700;
    border-radius: 12px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    background-color: #fff;
    cursor: pointer;
    transition: all 0.2s;

    &:hover { background-color: rgba($primary-color-700, 0.05); }

    .plus-sign { color: #333; margin-bottom: -4px; }
    .main-label { color: #333; margin-top: 4px; }
    .sub-label { color: #888; transform: scale(0.8); }
    }

    .header-text-group {
    .description { margin-top: 8px; color: #888; }
    }
}

.result-wall {
    .wall-viewport {
    display: flex;
    gap: 16px;
    overflow-x: auto;
    padding-bottom: 10px;
    &::-webkit-scrollbar { height: 0; }
    }

    .work-item {
    flex: 0 0 240px;
    height: 160px;
    position: relative;
    border-radius: 12px;
    overflow: hidden;
    
    img { 
        width: 100%; 
        height: 100%; 
        object-fit: cover; }

    &:hover .work-overly { opacity: 1; }
    }
}
}
</style>