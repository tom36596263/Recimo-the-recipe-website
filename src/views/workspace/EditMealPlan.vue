<script setup>
import { ref, computed } from 'vue';
import DayColumn from '@/components/workspace/mealplan/DayColumn.vue';
import ColumnTitle from '@/components/workspace/mealplan/ColumnTitle.vue';
import PlanPanel from '@/components/workspace/mealplan/PlanPanel.vue';

// 控制面板顯示的狀態，預設關閉
const showPanel = ref(false);

// 假資料
const planData = ref({
  planId: 1001,
  title: '2024春季增肌減脂計畫',
  startDate: '2024-03-01',
  endDate: '2024-03-10'
});

// 根據開始與結束日期，產生成一個Date物件的陣列
const datelist = computed(function () {
  const start = new Date(planData.value.startDate);
  const end = new Date(planData.value.endDate);
  const list = [];

  for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
    list.push(new Date(d));
  }

  return list;
});

// 橫向滾動
const onWheel = (e) => {
  const container = e.currentTarget;
  container.scrollLeft += e.deltaY * 0.2;
};

// 開啟面板
const openPanel = () => {
  showPanel.value = true;
};

// 關閉面板 ，給子元件呼叫用
const closePanel = () => {
  showPanel.value = false;
};
</script>

<template>
  <main class="container">
    <div class="row">
      <div class="btn-bar col-12">
        <div class="btn-bar__bread-crumbs"></div>

        <div class="btn-bar__info-btn" @click="openPanel">
          <i-material-symbols-info-i />
        </div>
      </div>

      <div class="meal-plan-container col-12">
        <ColumnTitle />

        <div class="meal-plan-container__columns" @wheel.prevent="onWheel">
          <DayColumn
            v-for="date in datelist"
            :key="date.getTime()"
            :current-date="date"
          />
        </div>
      </div>
    </div>

    <Transition name="slide-fade">
      <PlanPanel v-if="showPanel" :plan-data="planData" @close="closePanel" />
    </Transition>

    <Transition name="fade">
      <div v-if="showPanel" class="panel-overlay" @click="closePanel"></div>
    </Transition>
  </main>
</template>

<style lang="scss" scoped>
.btn-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;

  &__info-btn {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background-color: $primary-color-100;
    cursor: pointer;

    &:hover {
      background-color: $accent-color-100;
      color: $accent-color-700;
      border: 1px solid $accent-color-800;
    }
  }
}

.meal-plan-container {
  display: flex;
  gap: 10px;

  &__columns {
    flex-grow: 1;
    display: flex;
    flex-wrap: nowrap;
    gap: 10px;
    overflow-x: auto;

    &::-webkit-scrollbar {
      display: none;
    }
  }
}

.panel-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background-color: rgba($neutral-color-black, 0.3);
  z-index: 998;
}

// 面板滑入滑出
.slide-fade-enter-active,
.slide-fade-leave-active {
  transition: transform 0.3s ease, opacity 0.3s ease;
}

.slide-fade-enter-from,
.slide-fade-leave-to {
  transform: translateX(100%);
  opacity: 0;
}

// 遮罩淡入淡出
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
