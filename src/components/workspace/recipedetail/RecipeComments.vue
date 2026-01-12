<script setup>
import { ref } from "vue";

const props = defineProps({
list: {
    type: Array,
    default: () => []
}
});

const userInput = ref("");

const handleSend = () => { 
if (!userInput.value.trim()) return;
// 未來可改為 emit('send', userInput.value) 讓父層更新資料
alert("送出留言！" + userInput.value); 
userInput.value = "";
};
</script>

<template>
<div class="comment-container">
    <header class="comment-header">
    <h3 class="zh-h3">美味悄悄話</h3>
    </header>

    <div class="input-section">
    <div class="input-wrapper">
        <input 
        v-model="userInput"
        type="text"
        class="comment-input p-p2"
        placeholder="Share your thoughts or questions..."
        @keyup.enter="handleSend"
        />
        <button 
        @click="handleSend" 
        class="send-btn" 
        :class="{ 'active': userInput.trim().length > 0 }"
        :disabled="!userInput.trim()"
        >
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <line x1="22" y1="2" x2="11" y2="13"></line>
            <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
        </svg>
        </button>
    </div>
    </div>

    <div class="comment-list">
    <div 
        v-for="(item, index) in list" 
        :key="index" 
        class="comment-item animate-in"
    >
        <div class="avatar-box">
        <img :src="item.avatar" class="avatar-img" alt="avatar" />
        </div>

        <div class="comment-content">
        <div class="user-info">
            <span class="user-name p-p1">{{ item.userName }}</span>
            <span class="user-handle p-p3">@{{ item.handle }} · {{ item.time }}</span>
        </div>

        <p class="comment-text p-p2">{{ item.content }}</p>

        <div class="comment-actions">
            <button class="like-btn" @click="item.likes++">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M14 9V5a3 3 0 0 0-3-3l-4 9v11h11.28a2 2 0 0 0 2-1.7l1.38-9a2 2 0 0 0-2-2.3z"></path>
                <path d="M7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3"></path>
            </svg>
            <span class="action-text p-p3">{{ item.likes }}</span>
            </button>

            <button class="report-btn" title="檢舉此留言">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"></circle>
                <line x1="12" y1="8" x2="12" y2="12"></line>
                <line x1="12" y1="16" x2="12.01" y2="16"></line>
            </svg>
            </button>
        </div>
        </div>
    </div>
    </div>
</div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.comment-container {
background-color: transparent;
padding: 20px 0;
}

.comment-header {
margin-bottom: 20px;
.zh-h3 {
    font-size: 20px;
    color: #333;
    font-weight: 500;
}
}

.input-section {
margin-bottom: 30px;

.input-wrapper {
    display: flex;
    align-items: center;
    border: 1px solid $primary-color-700;
    border-radius: 12px;
    padding: 10px 16px;
    background: #fff;
    transition: box-shadow 0.2s;

    &:focus-within {
    box-shadow: 0 2px 8px rgba($primary-color-700, 0.15);
    }
    
    .comment-input {
    flex: 1;
    border: none;
    outline: none;
    background: transparent;
    color: #444;
    &::placeholder { color: #bbb; }
    }

    .send-btn {
    background: none;
    border: none;
    cursor: pointer;
    color: #ddd; // 預設禁用色
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s;
    padding-left: 8px;

    &.active {
        color: $primary-color-700;
        &:hover {
        color: $primary-color-800;
        transform: scale(1.1);
        }
    }

    &:disabled {
        cursor: not-allowed;
    }
    }
}
}

.comment-list {
display: flex;
flex-direction: column;
gap: 32px;
}

.comment-item {
display: flex;
gap: 16px;

.avatar-box {
    flex-shrink: 0;
    .avatar-img {
    width: 44px;
    height: 44px;
    border-radius: 50%;
    object-fit: cover;
    background-color: #f5f5f5;
    }
}

.comment-content {
    flex: 1;

    .user-info {
    display: flex;
    align-items: baseline;
    gap: 10px;
    margin-bottom: 4px;
    
    .user-name {
        font-weight: 600;
        color: #333;
    }
    .user-handle {
        color: #999;
    }
    }

    .comment-text {
    color: #444;
    line-height: 1.5;
    margin-bottom: 10px;
    white-space: pre-line;
    }
}
}

.comment-actions {
display: flex;
justify-content: flex-end;
align-items: center;
gap: 16px;

button {
    background: none;
    border: none;
    cursor: pointer;
    display: flex;
    align-items: center;
    color: #888;
    padding: 0;
    transition: color 0.2s;

    &:hover {
    color: #444;
    }
}

.like-btn {
    &:hover {
    color: $primary-color-700;
    }
}

.report-btn {
    &:hover {
    color: #ff6b6b;
    }
}

.action-text {
    margin-left: 5px;
    font-weight: 500;
}
}

.animate-in {
animation: fadeIn 0.4s ease-out forwards;
}

@keyframes fadeIn {
from { opacity: 0; transform: translateY(8px); }
to { opacity: 1; transform: translateY(0); }
}
</style>