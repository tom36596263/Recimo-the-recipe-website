<script setup>
//  setup: 這是 Vue 3 的語法糖，讓你不用寫 export default {}，且能直接使用變數和函式，開發效率最高。
// 所有的變數、函式、或是從 JSON 引入的資料都寫在script裡面。
import { ref, onMounted } from 'vue';
</script>

<template>
  <h1>Recimo商城</h1>
  <div style="width: 150px">
    <input type="text" class="form-input is-error" placeholder="搜尋" />
  </div>
  <div class="search-bar search-sm">
    <i class="fa-solid fa-magnifying-glass icon-search"></i>
    <input type="text" class="search-input" placeholder="尋找靈感食譜..." />
  </div>

  <div class="btn-recipe">
    <p>尋找食譜</p>
    <div class="icon-circle">
      <i class="fa-solid fa-arrow-right"></i>
    </div>
  </div>
</template>

<style lang="scss" scoped>
//  lang="scss": 告訴 Vue 這裡要用 Scss 編譯
//  scoped: 確保這裡寫的 CSS 只會影響目前這個頁面，不會「跑去污染」到其他頁面的樣式。
</style>
