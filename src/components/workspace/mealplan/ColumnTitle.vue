<script setup></script>

<template>
  <div class="day-column">
    <div class="day-column__date"></div>

    <div class="day-column__slot">早餐</div>
    <div class="day-column__slot">午餐</div>
    <div class="day-column__slot">晚餐</div>

    <div class="day-column__kcal">火icon</div>
  </div>
</template>

<style lang="scss" scoped>
.day-column {
  display: flex;
  flex-direction: column;
  width: 50px;
  text-align: center;
  gap: 4px;

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
    height: 50px;
  }

  &__slot {
    height: 200px; // 只有它比較高
  }
}
</style>
