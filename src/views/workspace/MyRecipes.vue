<script setup>

//  setup: 這是 Vue 3 的語法糖，讓你不用寫 export default {}，且能直接使用變數和函式，開發效率最高。
// 所有的變數、函式、或是從 JSON 引入的資料都寫在script裡面。
import { ref, onMounted } from 'vue';

</script>

<template>
    <h1>我的食譜</h1>
    <div class="container">
        <div class="row">
            <div class="col-6 col-md-12"><div class="test-box">左側欄位有 padding</div></div>
            <div class="col-6 col-md-12"><div class="test-box">右側欄位有 padding</div></div>
        </div>
    </div>
    
</template>

<style lang="scss" scoped>
.test-box {
            background-color: #e0f2f1;
            border: 1px solid #4db6ac;
            padding: 20px;
            text-align: center;
            margin-bottom: 10px;
            border-radius: 4px;
        }
        .row { background-color: #f5f5f5; margin-bottom: 30px; }
//  lang="scss": 告訴 Vue 這裡要用 Scss 編譯
//  scoped: 確保這裡寫的 CSS 只會影響目前這個頁面，不會「跑去污染」到其他頁面的樣式。

</style>