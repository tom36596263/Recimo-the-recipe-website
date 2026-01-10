<script setup>
import { ref } from 'vue';
import DayColumn from '@/components/workspace/mealplan/DayColumn.vue';
import ColumnTitle from '@/components/workspace/mealplan/ColumnTitle.vue';
</script>

<template>
  <main class="meal-plan-container col-12">
    <ColumnTitle />
    <DayColumn v-for="day in 7" :key="day" />
  </main>
</template>

<style lang="scss" scoped>
.meal-plan-container {
  display: flex;
  gap: 5px;
}
</style>
