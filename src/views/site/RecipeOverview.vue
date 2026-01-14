<script setup>
import RecipeCardLg from '@/components/common/RecipeCardLg.vue'
//  setup: 這是 Vue 3 的語法糖，讓你不用寫 export default {}，且能直接使用變數和函式，開發效率最高。
// 所有的變數、函式、或是從 JSON 引入的資料都寫在script裡面。
import { ref, onMounted } from 'vue';

</script>

<template>
    <section class="container">
        <div class="row">
            
        </div>
    </section>
    <section class="container recipe-cards">
        <div class="row">
            <div class="col-4">
                <RecipeCardLg />
            </div>
            <div class="col-4">
                <RecipeCardLg />
            </div>
            <div class="col-4">
                <RecipeCardLg />
            </div>
        </div>
    </section>
    
</template>

<style lang="scss" scoped>
.recipe-cards{
    margin-top: 100px;
}
</style>