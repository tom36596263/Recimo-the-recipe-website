<script setup>
// 定義父層傳進來的資料
defineProps({
  // modelValue 是 Vue 中 v-model 的預設名稱
  // 這裡代表「目前被選中的 Tab ID」
  modelValue: {
    type: Number,
    required: true
  },
  // 接收日期陣列，預期格式為 [{ id: 1, day: '日', date: '15' }, ...]
  tabs: {
    type: Array,
    default: () => []
  }
});

// 定義可以發送給父層的事件 (Emits)
const emit = defineEmits(['update:modelValue']);

// 當使用者點擊某個 Tab 時觸發
const selectTab = (id) => {
  // 發送 'update:modelValue' 事件，這會自動更新父層綁定 v-model 的變數
  emit('update:modelValue', id);
};
</script>

<template>
  <div class="date-tabs">
    <div
      v-for="tab in tabs"
      :key="tab.id"
      class="tab-item"
      :class="{ 'is-active': modelValue === tab.id }"
      @click="selectTab(tab.id)"
    >
      <span class="tab-item__day">{{ tab.day }}</span>
      <span class="tab-item__date">{{ tab.date }}</span>
    </div>

    <button class="tab-settings">
      <i-material-symbols-tune />
    </button>
  </div>
</template>

<style lang="scss" scoped>
.date-tabs {
  display: flex;
  align-items: center;
  gap: 12px;
  overflow-x: auto; // 允許水平滾動
  padding-bottom: 8px;

  // 隱藏預設的滾動條 (Chrome/Safari/Edge)
  &::-webkit-scrollbar {
    display: none;
  }
}

.tab-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;

  // 固定尺寸與圓角，形成膠囊狀
  width: 50px;
  height: 70px;
  border-radius: 25px;

  background-color: $neutral-color-100; // 未選中時的背景色
  color: $neutral-color-400; // 未選中時的文字色

  cursor: pointer;
  transition: all 0.3s ease; // 添加過渡動畫，讓顏色切換更滑順
  flex-shrink: 0; // 防止空間不足時被擠壓變形

  &__day {
    font-size: 0.9rem;
    margin-bottom: 4px;
  }

  &__date {
    font-size: 1.1rem;
    font-weight: bold;
    background-color: #fff; // 日期數字背後的白色圓圈
    width: 32px;
    height: 32px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: inherit; // 跟隨父層文字顏色
  }

  // === 選中狀態樣式 ===
  &.is-active {
    background-color: $primary-color-400; // 選中時變淺綠色
    color: $primary-color-800; // 選中時文字變深綠色

    .tab-item__date {
      color: $primary-color-800;
    }
  }
}

.tab-settings {
  margin-left: auto; // 利用 auto margin 將按鈕推到最右邊
  border: none;
  background: none;
  cursor: pointer;
  color: $primary-color-800;
}
</style>
