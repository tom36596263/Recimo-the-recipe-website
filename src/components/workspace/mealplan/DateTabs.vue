<script setup>
/**
 * DateTabs.vue
 * 目的：提供橫向滾動的日期頁籤。
 * 串接：透過 v-model (modelValue) 與父組件 PlanPanel 進行雙向綁定。
 */

import { computed, ref, watch, nextTick } from 'vue';

const props = defineProps({
  modelValue: {
    type: Number,
    required: true
  },
  tabs: {
    type: Array,
    default: () => []
  },
  startDate: {
    type: String,
    default: ''
  },
  endDate: {
    type: String,
    default: ''
  }
});

const emit = defineEmits(['update:modelValue', 'date-change', 'update-range']);

// 切換頁籤並通知父組件
const selectTab = (id) => {
  emit('update:modelValue', id);
};

// ------ 滑鼠滾輪轉水平捲動邏輯 ------
const onWheel = (e) => {
  if (scrollContainer.value) {
    // 1. 將滾輪的垂直移動量 (deltaY) 加到容器的水平捲動位置 (scrollLeft)
    // 2. 加上 'e.deltaY' 表示向下滾是向右移，向上滾是向左移
    scrollContainer.value.scrollLeft += e.deltaY;
  }
};

// ------自動捲動 (Scroll to Active)------
// 1. 定義 Ref 來綁定捲動容器
const scrollContainer = ref(null);

// 2. 自動捲動函式
const scrollToActive = async () => {
  await nextTick(); // 等待 DOM 更新
  if (!scrollContainer.value) return;
  const activeEl = scrollContainer.value.querySelector('.is-active');
  if (activeEl) {
    activeEl.scrollIntoView({
      behavior: 'smooth', // 平滑滾動
      block: 'nearest', // 垂直方向：最近邊緣 (因為是橫向捲動，不過這個設定影響較小)
      inline: 'center' // 讓選中項目置中
    });
  }
};
// 3. 監聽 modelValue 變化，一旦變更就捲動
watch(() => props.modelValue, scrollToActive, { immediate: true });

// --- 日期範圍計算 ---
const rangeValue = computed({
  get: () => {
    // 防呆機制：如果傳入空字串或 undefined，給予當天日期，避免 VCalendar 崩潰
    const start = props.startDate ? new Date(props.startDate) : new Date();
    const end = props.endDate ? new Date(props.endDate) : new Date();
    return { start, end };
  },
  set: (val) => {
    // 當使用者選擇新範圍時，觸發事件
    if (val && val.start && val.end) {
      emit('update-range', val);
    }
  }
});
</script>

<template>
  <div class="tab-wrapper">
    <div class="date-tabs" ref="scrollContainer" @wheel.prevent="onWheel">
      <div v-for="tab in tabs" :key="tab.id" class="tab-item" :class="{ 'is-active': modelValue === tab.id }"
        @click="selectTab(tab.id)">
        <span class="tab-item__day p-p1">{{ tab.day }}</span>
        <span class="tab-item__date">{{ tab.date }}</span>
      </div>
    </div>

    <VDatePicker v-model.range="rangeValue" color="green" :popover="{
      visibility: 'click', placement: 'bottom', modifiers: [
        { name: 'offset', options: { offset: [0, 10] } } // 調整彈窗與按鈕的距離 [左右, 上下]
      ]
    }">
      <template #default="{ togglePopover }">
        <button class="tab-settings" title="選擇日期" @click="togglePopover">
          <i-material-symbols-calendar-month-outline />
        </button>
      </template>
    </VDatePicker>
  </div>
</template>

<style lang="scss" scoped>
.tab-wrapper {
  display: flex;
  align-items: center;
}

.date-tabs {
  display: flex;
  align-items: center;
  gap: 6px;
  overflow-x: auto;

  &::-webkit-scrollbar {
    display: none;
  }
}

.tab-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 50px;
  height: 90px;
  border-radius: 25px;
  background-color: $neutral-color-100;
  color: $neutral-color-400;
  cursor: pointer;
  flex-shrink: 0;

  &__day {
    // font-size: 0.85rem;
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

  &.is-active {
    background-color: $primary-color-400;
    color: $primary-color-800;
  }

  &:hover {
    background-color: $accent-color-100;
    color: $accent-color-800;
    border: 1px solid $accent-color-800;
    // background-color: $primary-color-400;
    // color: $primary-color-800;
  }
}

.tab-settings {
  margin-left: 6px;
  border: none;
  background: $neutral-color-100;
  width: 50px;
  height: 90px;
  border-radius: 25px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: $primary-color-800;
  transition: 0.2s;
  flex-shrink: 0;

  &:hover {
    background-color: $accent-color-100;
    color: $accent-color-800;
    border: 1px solid $accent-color-800;
  }
}
</style>