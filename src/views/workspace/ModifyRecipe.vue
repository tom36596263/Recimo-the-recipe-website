<script setup>
import { ref } from 'vue';
import CommentReportModal from '../../components/workspace/recipedetail/modals/CommentReportModal.vue';

const isReportModalOpen = ref(false);

// 1. 新增：用來存放準備被檢舉的留言資料
const activeComment = ref({
  content: '這是測試用的留言內容，之後會從列表傳進來',
  userName: '測試員',
  time: '1d ago'
});

const onReportSubmit = (data) => {
    console.log('API 發送檢舉中...', data);
    console.log('針對這則留言:', activeComment.value);
    isReportModalOpen.value = false;
};
</script>

<template>
    <div class="parent-container">
        <h1>測試主頁面</h1>
        <button @click="isReportModalOpen = true" class="open-btn">
        點我打開檢舉彈窗
        </button>

        <CommentReportModal 
        v-model="isReportModalOpen" 
        :comment-data="activeComment"
        @submit="onReportSubmit" 
        />
    </div>
</template>