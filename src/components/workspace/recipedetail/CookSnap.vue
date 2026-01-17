<script setup>
import { ref } from 'vue';
// 1. 引入檢舉彈窗組件
import PostReportModal from '@/components/workspace/recipedetail/modals/PostReportModal.vue';

const props = defineProps({
  list: {
    type: Array,
    required: true,
    default: () => []
  }
});

// 建立 DOM 引用
const fileInput = ref(null);
const wallViewport = ref(null);

// --- 彈窗控制邏輯 ---
const isReportModalOpen = ref(false);
const selectedPhotoData = ref({
  content: '',
  userName: '',
  time: '',
  image: ''
});

// 處理檢舉點擊
const handleReport = (photo) => {
  // 將點選的照片資料格式化，傳遞給彈窗
  selectedPhotoData.value = {
    content: photo.comment,      // 照片留言內容
    userName: photo.userName || '匿名用戶', // 假設資料中有 userName
    time: photo.time || '剛剛',   // 假設資料中有時間
    image: photo.url            // 照片網址
  };
  // 開啟彈窗
  isReportModalOpen.value = true;
};

const onReportSubmit = (reportResult) => {
  console.log('收到檢舉提交資料:', reportResult);
  // 這裡執行 API 提交邏輯
  isReportModalOpen.value = false;
};
// ------------------

const handleUploadClick = () => {
  fileInput.value.click();
};

const scrollWall = (direction) => {
  if (wallViewport.value) {
    const scrollAmount = 256;
    wallViewport.value.scrollBy({
      left: direction === 'next' ? scrollAmount : -scrollAmount,
      behavior: 'smooth'
    });
  }
};

const onFileSelected = (event) => {
  const file = event.target.files[0];
  if (file) {
    console.log("已選取檔案:", file.name);
  }
};
</script>

<template>
  <div class="recipe-result-container">
    <input type="file" ref="fileInput" style="display: none" accept="image/*" @change="onFileSelected" />

    <div class="result-header">
      <div class="upload-trigger-area" @click="handleUploadClick">
        <div class="upload-card">
          <span class="plus-sign zh-h2">+</span>
          <span class="main-label zh-h5">成品展示</span>
          <span class="sub-label en-h3">add photo</span>
        </div>
      </div>

      <div class="header-text-group">
        <h5 class="zh-h5">每一份手作的溫度，都值得被記錄與分享</h5>
        <div class="description">
          <p class="p-p1">上傳您的作品照，與同樣熱愛烹飪的夥伴們交換那份成就感，</p>
          <p class="p-p1">不用追求完美，這裡記錄的是屬於您廚房裡最真實的美味故事。</p>
        </div>
      </div>
    </div>

    <div class="result-wall">
      <button class="nav-btn prev" @click="scrollWall('prev')">
        <i-material-symbols-arrow-back-ios-new-rounded />
      </button>

      <div class="wall-viewport" ref="wallViewport">
        <div v-for="(photo, index) in list" :key="index" class="work-item">
          <img :src="photo.url" :alt="'User work ' + index">
          <div class="work-overlay">
            <p class="comment-text p-p2">{{ photo.comment }}</p>

            <div class="report-icon-wrapper" @click.stop="handleReport(photo)">
              <i-material-symbols:error-outline-rounded />
            </div>
          </div>
        </div>
      </div>

      <button class="nav-btn next" @click="scrollWall('next')">
        <i-material-symbols-arrow-forward-ios-rounded />
      </button>
    </div>

    <PostReportModal v-model="isReportModalOpen" :commentData="selectedPhotoData" @submit="onReportSubmit" />
  </div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

// ... 你的樣式表保持不變 ...
.recipe-result-container {
  padding: 40px 0;

  .result-header {
    display: flex;
    align-items: center;
    gap: 40px;
    margin-bottom: 48px;

    .upload-card {
      width: 180px;
      height: 140px;
      border: 1px solid $primary-color-700;
      border-radius: 10px;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      background-color: $neutral-color-white;
      cursor: pointer;
      transition: all 0.3s ease;

      &:hover {
        background-color: $primary-color-100;
        border-style: dashed;
      }

      .plus-sign {
        color: $neutral-color-black;
        margin-bottom: -4px;
      }

      .main-label {
        color: $neutral-color-black;
        margin-top: 4px;
      }

      .sub-label {
        color: $neutral-color-400;
        transform: scale(0.8);
      }
    }

    .header-text-group {
      .description {
        margin-top: 8px;
        color: $neutral-color-700;
      }
    }
  }

  .result-wall {
    position: relative;
    display: flex;
    align-items: center;

    .wall-viewport {
      display: flex;
      gap: 16px;
      overflow-x: auto;
      padding: 10px 0;
      scroll-behavior: smooth;

      &::-webkit-scrollbar {
        display: none;
      }

      -ms-overflow-style: none;
      scrollbar-width: none;
    }

    .nav-btn {
      position: absolute;
      top: 50%;
      transform: translateY(-50%);
      width: 44px;
      height: 44px;
      border-radius: 50%;
      border: 1px solid $primary-color-400;
      background-color: $neutral-color-white;
      color: $primary-color-700;
      display: flex;
      justify-content: center;
      align-items: center;
      cursor: pointer;
      z-index: 5;
      transition: all 0.3s ease;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);

      &:hover {
        background-color: $primary-color-700;
        color: $neutral-color-white;
      }

      &.prev {
        left: -22px;
      }

      &.next {
        right: -22px;
      }

      svg {
        font-size: 20px;
      }
    }

    .work-item {
      flex: 0 0 240px;
      height: 150px;
      position: relative;
      border-radius: 12px;
      overflow: hidden;

      img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform 0.5s ease;
      }

      .work-overlay {
        position: absolute;
        inset: 0;
        background-color: rgba($neutral-color-700, 0.8);
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 20px;
        opacity: 0;
        transition: opacity 0.3s ease;

        .comment-text {
          color: $neutral-color-white;
          text-align: center;
          line-height: 1.6;
        }

        .report-icon-wrapper {
          position: absolute;
          bottom: 12px;
          right: 12px;
          color: rgba($neutral-color-white, 0.7);
          cursor: pointer;
          display: flex;
          transition: all 0.2s ease;

          &:hover {
            color: $neutral-color-white;
            transform: scale(1.1);
          }

          svg {
            font-size: 20px;
          }
        }
      }

      &:hover {
        img {
          transform: scale(1.1);
        }

        .work-overlay {
          opacity: 1;
        }
      }
    }
  }
}

@media screen and (max-width: 810px) {
  .result-header {
    flex-direction: column;
    text-align: center;
    gap: 20px;

    .upload-card {
      width: 100%;
    }
  }

  .nav-btn {
    display: none;
  }
}
</style>