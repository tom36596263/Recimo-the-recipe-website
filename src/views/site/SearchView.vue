<script setup>
import { ref, onMounted } from 'vue';
import SearchBanner from '@/components/site/search/SearchBanner.vue'
import SearchResultCard from '@/components/site/search/SearchResultCard.vue'

</script>

<template>
    <div class="container">
        <div class="row">
            <div class="col-12">
                <SearchBanner />
            </div>
        </div>
    </div>
    <div class="container">
        <div class="row">
            <div class="col-12">
                <h3 class="zh-h3">「商品名」搜尋結果</h3>
                <SearchResultCard />
                <SearchResultCard />
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>

</style>
