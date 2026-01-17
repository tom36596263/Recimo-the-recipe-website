<script setup>
import { computed } from 'vue';

// 接收父元件傳來的日期物件
const props = defineProps({
  currentDate: {
    type: Date,
    required: true
  }
});

// 計算是「幾號」
const dayNumber = computed(() => props.currentDate.getDate());

//計算是「星期幾」
const dayOfWeek = computed(() => {
  const days = ['日', '一', '二', '三', '四', '五', '六'];
  // .getDay()會會傳0到6，0是星期日，6是星期六
  return days[props.currentDate.getDay()];
});
</script>

<template>
  <div class="day-column">
    <div class="day-column__date">{{ dayNumber }} ( {{ dayOfWeek }} )</div>

    <div v-for="index in 3" :key="index" class="day-column__slot p-p1">
      +<br />新增菜色
    </div>

    <div class="day-column__kcal">1866kcal</div>
  </div>
</template>

<style lang="scss" scoped>
.day-column {
  display: flex;
  flex-direction: column;
  width: 130px;
  text-align: center;
  gap: 4px;
  cursor: pointer;
  flex-shrink: 0;

  &__date,
  &__slot,
  &__kcal {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 100%;
    background-color: $neutral-color-100;
    border-radius: 10px;
    color: $primary-color-800;
    height: 5.5555555556vh;
  }

  &__slot {
    height: 22.2222222222vh;
  }

  &:hover {

    .day-column__date,
    .day-column__slot,
    .day-column__kcal {
      background-color: $accent-color-100;
      color: $accent-color-700;
      border: 1px solid $accent-color-800;
      transition: 0.2 ease;
    }
  }
}
</style>
