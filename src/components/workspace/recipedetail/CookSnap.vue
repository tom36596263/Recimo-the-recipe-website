<script setup>
import { ref } from 'vue'
import PostReportModal from '@/components/workspace/recipedetail/modals/PostReportModal.vue'
// 導入上傳燈箱
import CookSnapUploadModal from '@/components/workspace/recipedetail/modals/CookSnapUploadModal.vue'

const props = defineProps({
  list: {
    type: Array,
    required: true,
    default: () => []
  }
})

const wallViewport = ref(null)

// --- 檢舉彈窗邏輯 ---
const isReportModalOpen = ref(false)
const selectedPhotoData = ref({
  content: '',
  userName: '',
  time: '',
  image: ''
})

const handleReport = (photo) => {
  selectedPhotoData.value = {
    content: photo.comment,
    userName: photo.userName || '匿名用戶',
    time: photo.time || '剛剛',
    image: photo.url
  }
  isReportModalOpen.value = true
}

const onReportSubmit = () => {
  isReportModalOpen.value = false
}

// --- 上傳成品燈箱邏輯 ---
const isUploadModalOpen = ref(false)

const handleUploadClick = () => {
  isUploadModalOpen.value = true
}

const onUploadSubmit = (data) => {
  console.log('上傳成功:', data)
  isUploadModalOpen.value = false
}

// 橫向捲動
const scrollWall = (direction) => {
  if (!wallViewport.value) return
  const offset = direction === 'next' ? 256 : -256
  wallViewport.value.scrollBy({ left: offset, behavior: 'smooth' })
}
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
        <h5 class="zh-h5">每一份手作的溫度，都值得被記錄與分享</h5>
        <div class="description">
          <p class="p-p2">上傳您的作品照，與同樣熱愛烹飪的夥伴們交換那份成就感，</p>
          <p class="p-p2">不用追求完美，這裡記錄的是屬於您廚房裡最真實的美味故事。</p>
        </div>
      </div>
    </div>

    <div class="result-wall">
      <button v-if="list.length > 0" class="nav-btn prev" @click="scrollWall('prev')">
        <i-material-symbols-arrow-back-ios-new-rounded />
      </button>

      <div class="wall-viewport" ref="wallViewport">
        <div v-for="(photo, index) in list" :key="index" class="work-item">
          <img :src="photo.url" :alt="'User work ' + index" />
          <div class="work-overlay">
            <p class="comment-text p-p2">{{ photo.comment }}</p>
            <div class="report-icon-wrapper" @click.stop="handleReport(photo)">
              <i-material-symbols:error-outline-rounded />
            </div>
          </div>
        </div>

        <div v-if="list.length === 0" class="empty-placeholder">
          <p class="p-p2">目前還沒有作品分享，快來上傳您的第一張成品照吧！</p>
        </div>
      </div>

      <button v-if="list.length > 0" class="nav-btn next" @click="scrollWall('next')">
        <i-material-symbols-arrow-forward-ios-rounded />
      </button>
    </div>

    <PostReportModal v-model="isReportModalOpen" :commentData="selectedPhotoData" @submit="onReportSubmit" />

    <CookSnapUploadModal v-model="isUploadModalOpen" @submit="onUploadSubmit" />
  </div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.recipe-result-container {
  padding: 24px 0;

  .result-header {
    max-width: 960px;
    margin: 0 auto 32px;
    display: flex;
    align-items: center;
    gap: 32px;

    .upload-card {
      width: 180px;
      height: 120px;
      border: 1px solid $primary-color-700;
      border-radius: 10px;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      gap: 4px;
      background-color: $neutral-color-white;
      cursor: pointer;
      transition: all 0.3s ease;

      &:hover {
        background-color: $primary-color-100;
        border-style: dashed;
      }

      .plus-sign {
        margin-bottom: -6px;
      }

      .sub-label {
        transform: scale(0.8);
        color: $neutral-color-400;
      }
    }

    .header-text-group {
      .zh-h5 {
        text-align: center;
      }

      .description {
        width: 100%;
        margin-top: 25px;
        line-height: 20px;
        color: $neutral-color-700;

        p {
          margin-bottom: 2px;
          line-height: 30px !important;
        }
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
      padding: 8px 0;
      scroll-behavior: smooth;
      width: 100%;

      &::-webkit-scrollbar {
        display: none;
      }

      .empty-placeholder {
        width: 100%;
        padding: 40px;
        text-align: center;
        background-color: $neutral-color-100;
        border-radius: 12px;
        color: $neutral-color-400;
        border: 1px dashed $neutral-color-100;
      }
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
      align-items: center;
      justify-content: center;
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
    }

    .work-item {
      flex: 0 0 240px;
      height: 150px;
      border-radius: 12px;
      overflow: hidden;
      position: relative;

      img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform 0.4s ease;
      }

      .work-overlay {
        position: absolute;
        inset: 0;
        background-color: rgba($neutral-color-700, 0.8);
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 16px;
        opacity: 0;
        transition: opacity 0.3s ease;

        .comment-text {
          color: $neutral-color-white;
          text-align: center;
          line-height: 1.5;
        }

        .report-icon-wrapper {
          position: absolute;
          bottom: 10px;
          right: 10px;
          cursor: pointer;
          opacity: 0.8;
          color: $neutral-color-white;

          &:hover {
            opacity: 1;
            transform: scale(1.1);
          }
        }
      }

      &:hover {
        img {
          transform: scale(1.08);
        }

        .work-overlay {
          opacity: 1;
        }
      }
    }
  }
}

@media (max-width: 810px) {
  .result-header {
    flex-direction: column;
    text-align: center;
    gap: 16px;

    .upload-card {
      width: 100%;
    }
  }

  .nav-btn {
    display: none;
  }
}
</style>