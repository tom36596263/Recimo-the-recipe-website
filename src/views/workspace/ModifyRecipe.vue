<script setup>
import { ref } from 'vue';
// 修正路徑：從 views/workspace 跳轉到 components/workspace
import CommentReportModal from '../../components/workspace/recipedetail/modals/CommentReportModal.vue';
import PostReportModal from '../../components/workspace/recipedetail/modals/PostReportModal.vue';

const isReportModalOpen = ref(false);
const isPostModalOpen = ref(false); // 控制照片彈窗

// 留言資料
const activeComment = ref({
    content: '這是一則測試留言內容...',
    userName: '測試員',
    time: '1d ago'
});

// 新增成品照資料
const activePost = ref({
    content: '這張草莓蛋糕的照片好像怪怪的，這是一段很長的測試文字，用來測試右側區域是否能正常產生捲軸。內容包含：草莓蛋糕、奶油、裝飾、拍照背景等等細節。',
    userName: '小食神',
    time: '3h ago',
    // 這裡加入測試圖片網址
    image: 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400&auto=format&fit=crop&q=60'
});

const onReportSubmit = (data) => {
    console.log('留言檢舉送出:', data);
    isReportModalOpen.value = false;
};

// 照片檢舉送出的處理
const onPostReportSubmit = (data) => {
    console.log('照片檢舉送出:', data);
    isPostModalOpen.value = false;
};
</script>

<template>
    <div class="parent-container" style="padding: 50px; display: flex; gap: 20px;">
        <h1>測試主頁面</h1>

        <button @click="isReportModalOpen = true" class="open-btn">
            點我檢舉留言
        </button>

        <button @click="isPostModalOpen = true" class="open-btn" style="background-color: #438b64; color: white;">
            點我檢舉成品照
        </button>

        <CommentReportModal v-model="isReportModalOpen" :comment-data="activeComment" @submit="onReportSubmit" />

        <PostReportModal v-model="isPostModalOpen" :comment-data="activePost" @submit="onPostReportSubmit" />
    </div>
    
    <i-material-symbols:error-outline-rounded />
    
    
</template>

<style scoped>
.open-btn
{
    padding: 10px 20px;
    border-radius: 8px;
    border: 1px solid #ccc;
    cursor: pointer;
    font-weight: bold;
    transition: opacity 0.2s;
}

.open-btn:hover
{
    opacity: 0.8;
}
</style>