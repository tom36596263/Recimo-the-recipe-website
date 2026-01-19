<script setup>
/**
 * DateTabs.vue
 * 目的：提供橫向滾動的日期頁籤。
 * 串接：透過 v-model (modelValue) 與父組件 PlanPanel 進行雙向綁定。
 */
defineProps({
  // 目前選中的頁籤 ID (由 PlanPanel 的 activeTabId 提供)
  modelValue: {
    type: Number,
    required: true
  },
  // 接收日期陣列，格式：[{ id: 1, day: '一', date: '19', fullDate: '2026-01-19' }]
  tabs: {
    type: Array,
    default: () => []
  }
});

const emit = defineEmits(['update:modelValue']);

// 切換頁籤並通知父組件
const selectTab = (id) => {
  emit('update:modelValue', id);
};
</script>

<template>
  <div class="date-tabs">
    <div v-for="tab in tabs" :key="tab.id" class="tab-item" :class="{ 'is-active': modelValue === tab.id }"
      @click="selectTab(tab.id)">
      <span class="tab-item__day">{{ tab.day }}</span>
      <span class="tab-item__date">{{ tab.date }}</span>
    </div>

    <button class="tab-settings" title="調整計畫設定">
      <i-material-symbols-tune />
    </button>
  </div>
</template>

<style lang="scss" scoped>
.date-tabs {
  display: flex;
  align-items: center;
  gap: 12px;
  overflow-x: auto;
  padding: 4px 0 12px; // 增加底部間距避免陰影被切掉

  &::-webkit-scrollbar {
    display: none;
  }

  // 隱藏捲動條保持美觀
}

.tab-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 50px;
  height: 72px;
  border-radius: 25px;
  background-color: $neutral-color-100;
  color: $neutral-color-400;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  flex-shrink: 0;

  &__day {
    font-size: 0.85rem;
    margin-bottom: 6px;
  }

  &__date {
    font-size: 1.1rem;
    font-weight: bold;
    background-color: $neutral-color-white;
    width: 32px;
    height: 32px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  // 選中狀態：使用主題色 $primary-color-400
  &.is-active {
    background-color: $primary-color-400;
    color: $primary-color-800;
    transform: translateY(-2px); // 增加一點浮起效果
    box-shadow: 0 4px 8px rgba($primary-color-800, 0.15);

    .tab-item__date {
      color: $primary-color-800;
    }
  }
}

.tab-settings {
  margin-left: 12px;
  border: none;
  background: none;
  cursor: pointer;
  color: $primary-color-800;
  font-size: 1.5rem;

  &:hover {
    color: $accent-color-700;
  }
}
</style>