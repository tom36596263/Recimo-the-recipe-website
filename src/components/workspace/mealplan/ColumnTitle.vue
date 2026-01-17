<script setup>
import { ref, computed, onMounted, markRaw, shallowRef } from 'vue';
import IconBreakfast from '~icons/material-symbols/alarm-outline';
import IconLunch from '~icons/material-symbols/wb-sunny-outline';
import IconDinner from '~icons/material-symbols/moon-stars-outline';

const mealSlots = ref([
  { id: 'breakfast', name: '早餐', icon: markRaw(IconBreakfast) },
  { id: 'lunch', name: '午餐', icon: markRaw(IconLunch) },
  { id: 'dinner', name: '晚餐', icon: markRaw(IconDinner) }
]);
</script>

<template>
  <div class="day-column">
    <div class="day-column__date"></div>

    <div v-for="title in mealSlots" :key="title" class="day-column__slot p-p1">
      <component :is="title.icon" v-if="title.icon" class="icon-style" />
      {{ title.name }}
    </div>

    <div class="day-column__kcal">
      <i-material-symbols-Local-Fire-Department-outline />
    </div>
  </div>
</template>

<style lang="scss" scoped>
.day-column {
  display: flex;
  flex-direction: column;
  width: 7%;
  text-align: center;
  gap: 4px;
  flex-shrink: 0;

  &__date,
  &__slot,
  &__kcal {
    display: flex;
    flex-direction: column;
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
}
</style>
