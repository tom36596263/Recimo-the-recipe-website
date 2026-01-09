<script setup>
import { ref } from 'vue';
import DayColumn from '@/components/workspace/mealplan/DayColumn.vue';
import ColumnTitle from '@/components/workspace/mealplan/ColumnTitle.vue';

const weekDays = ref([
  { id: 1, name: '週一', date: '11/11' },
  { id: 2, name: '週二', date: '11/12' },
  { id: 3, name: '週三', date: '11/13' },
  { id: 4, name: '週四', date: '11/14' },
  { id: 5, name: '週五', date: '11/15' },
  { id: 6, name: '週六', date: '11/16' },
  { id: 7, name: '週日', date: '11/17' }
]);
</script>

<template>
  <main class="meal-plan-container">
    <ColumnTitle />
    <DayColumn
      v-for="day in weekDays"
      :key="day.id"
      :date="day.date"
      :day-name="day.name"
    />
  </main>
</template>

<style lang="scss" scoped>
.meal-plan-container {
  display: flex;
}
</style>
