<script setup>
import { defineProps, defineEmits } from 'vue';

// 定義外部傳入的參數 (Props)
const props = defineProps({
  // 控制開關
  isOpen: {
    type: Boolean,
    default: false
  },
  // 彈窗類型: 'danger', 'info', 'success' (對應 SCSS 的 class)
  type: {
    type: String,
    default: 'info',
    validator: (value) => ['danger', 'info', 'success'].includes(value)
  },
  // FontAwesome 圖示 class
  iconClass: {
    type: String,
    default: 'fa-solid fa-circle-info'
  },
  // 標題文字
  title: {
    type: String,
    default: ''
  },
  // 描述文字 (選填)
  description: {
    type: String,
    default: ''
  }
});

// 定義發出的事件
const emit = defineEmits(['close']);

// 關閉彈窗的方法
const closeModal = () => {
  emit('close');
};
</script>

<template>
  <div
    class="modal-overlay"
    :class="{ active: isOpen }"
    @click.self="closeModal"
  >
    <div class="modal-card" :class="type">
      <button class="close-btn" @click="closeModal">
        <i class="fa-solid fa-xmark"></i>
      </button>

      <div class="icon-wrapper">
        <i :class="iconClass"></i>
      </div>

      <div class="text-content">
        <div class="zh-h3-bold" v-if="title">{{ title }}</div>
        <p class="p-p3" v-if="description">{{ description }}</p>

        <slot name="content"></slot>
      </div>

      <div class="btn-group" v-if="$slots.actions">
        <slot name="actions"></slot>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
// // *** 重要：請在此處引入你的全域變數檔案 ***
// // 請依據你的專案路徑修改，例如：
// @use '@/assets/scss/abstracts/variables' as *;
// // 或者如果是 main.scss 包含變數： @use "@/assets/scss/main" as *;

// .modal-card {
//   width: 350px;
//   height: 300px;
//   background-color: $neutral-color-white;
//   border-radius: 10px;
//   position: relative;
//   display: flex;
//   flex-direction: column;
//   align-items: center;
//   justify-content: center;
//   padding: 20px 5px;
//   box-sizing: border-box;
//   box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1); // 增加一點陰影讓它立體

//   // 文字不折行設定
//   * {
//     white-space: nowrap;
//   }

//   // 右上角關閉按鈕
//   .close-btn {
//     position: absolute;
//     top: 15px;
//     right: 15px;
//     background: transparent;
//     border: none;
//     cursor: pointer;
//     font-size: 18px;
//     color: $neutral-color-black;
//     padding: 5px;

//     &:hover {
//       opacity: 0.7;
//     }
//   }

//   // ICON 圓圈區域
//   .icon-wrapper {
//     width: 60px;
//     height: 60px;
//     border-radius: 50%;
//     display: flex;
//     justify-content: center;
//     align-items: center;
//     margin-bottom: 15px;
//     color: $neutral-color-white;
//     font-size: 28px;
//   }

//   // 文字區域間距
//   .text-content {
//     text-align: center;
//     margin-bottom: 25px;
//     width: 100%;

//     // 標題與描述的間距
//     > [class*='zh-h'] {
//       margin-bottom: 8px;
//       color: $neutral-color-black; // 標題預設黑色
//     }

//     > [class*='p-p'] {
//       color: $neutral-color-700; // 描述文字灰色
//       margin: 0;
//       // 確保長文字超出時顯示 ... (若不需要省略號可移除 overflow)
//       overflow: hidden;
//       text-overflow: ellipsis;
//     }
//   }

//   // 按鈕群組
//   .btn-group {
//     display: flex;
//     gap: 15px;
//     width: 100%;
//     justify-content: center;

//     button {
//       flex: 1;
//       height: 40px;
//       border-radius: 10px;
//       cursor: pointer;
//       font-size: 16px; // 假設按鈕文字大小
//       display: flex;
//       align-items: center;
//       justify-content: center;
//       transition: all 0.2s;
//       max-width: 150px; // 限制按鈕不要太寬
//     }
//   }

//   // -------------------------
//   // 狀態變體 (Variants)
//   // -------------------------

//   // 1. Danger (紅色系 - 尚未儲存/登入失敗)
//   &.danger {
//     border: 1px solid $secondary-color-danger-400; // 邊框色

//     .icon-wrapper {
//       background-color: $secondary-color-danger-700; // 圖片中的紅色圓圈較深
//     }

//     .btn-solid {
//       background-color: $secondary-color-danger-700;
//       background-color: $secondary-color-danger-700;
//       color: $neutral-color-white;
//       border: none;

//       &:hover {
//         opacity: 0.9;
//       }
//     }

//     .btn-outline {
//       background-color: transparent;
//       border: 1px solid $secondary-color-danger-700;
//       color: $secondary-color-danger-700;

//       &:hover {
//         background-color: $secondary-color-danger-200;
//       }
//     }
//   }

//   // 2. Info (藍色系 - 刪除確認)
//   &.info {
//     border: 1px solid $secondary-color-info-700;

//     .icon-wrapper {
//       background-color: $secondary-color-info-700;
//     }

//     .btn-solid {
//       background-color: $secondary-color-info-700;
//       color: $neutral-color-white;
//       border: none;
//       &:hover {
//         opacity: 0.9;
//       }
//     }

//     .btn-outline {
//       background-color: transparent;
//       border: 1px solid $secondary-color-info-700;
//       color: $secondary-color-info-700;
//       &:hover {
//         background-color: $secondary-color-info-200;
//       }
//     }
//   }

//   // 3. Success (綠色系 - 已加入購物車)
//   // 特別尺寸：高度 203px
//   &.success {
//     height: 203px;
//     border: 1px solid $secondary-color-success-700;

//     .icon-wrapper {
//       background-color: $secondary-color-success-700; // 綠色打勾背景
//       margin-bottom: 20px;
//     }

//     // 成功狀態通常文字置中且沒有描述或按鈕，微調間距
//     .text-content {
//       margin-bottom: 0;
//     }
//   }
// }

// // 彈窗遮罩層
// .modal-overlay {
//   position: fixed; // 固定在視窗上，不隨捲軸移動
//   top: 0;
//   left: 0;
//   width: 100%;
//   height: 100%;
//   z-index: 9999; // 確保蓋在所有內容上面

//   // 背景色：使用變數黑色的 50% 透明度
//   background-color: rgba($neutral-color-black, 0.5);

//   // (選用) 背景模糊效果：讓背後的網站看起來模糊，更有質感
//   backdrop-filter: blur(3px);

//   // 利用 Flexbox 讓內部的 modal-card 自動置中
//   display: flex;
//   justify-content: center;
//   align-items: center;

//   // 預設隱藏 (需要時透過 JS 加上 .show 類別或直接改 display)
//   // display: none;

//   // 如果想要淡入淡出的動畫效果
//   opacity: 0;
//   visibility: hidden;
//   transition: opacity 0.3s ease, visibility 0.3s ease;

//   // 當加上 .is-active 或 .show 類別時顯示
//   &.active {
//     opacity: 1;
//     visibility: visible;
//   }
// }
</style>
