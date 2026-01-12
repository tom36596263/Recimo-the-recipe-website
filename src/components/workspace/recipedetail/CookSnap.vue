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
                    <span class="plus-sign">+</span>
                    <span class="main-label">成品展示</span>
                    <span class="sub-label">add photo</span>
                </div>
            </div>

            <div class="header-text-group">
                <h5>每一份手作的溫度，都值得被記錄與分享</h5>
                <div class="description">
                    <p>上傳您的作品照，與同樣熱愛烹飪的夥伴們交換那份成就感，</p>
                    <p>不用追求完美，這裡記錄的是屬於您廚房裡最真實的美味故事。</p>
                </div>
            </div>
        </div>

        <div class="result-wall">
            <div class="wall-viewport">
                <div 
                    v-for="(photo, index) in list" :key="index" class="work-item">
                    <img :src="photo.url" alt="'User work' + index">
                    <div class="work-overly">
                        <p class="comment-text">{{ photo.comment }}</p>
                    </div>
                </div>
            </div>
        </div>
    </div>



</template>

<style lang="scss" scoped>

</style>
