<script setup></script>

<template>
  <div class="day-column">
    <div class="day-column__date">15</div>

    <div class="day-column__slot">+<br />新增菜色</div>
    <div class="day-column__slot">+<br />新增菜色</div>
    <div class="day-column__slot">+<br />新增菜色</div>

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
