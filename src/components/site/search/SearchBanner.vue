<script setup>
import { ref } from 'vue';
import SearchBar from '@/components/common/SearchBar.vue'
import BaseTag from '@/components/common/BaseTag.vue';

const hotTags = ref(['雞胸肉', '創意吐司', '輕食早餐', '荷包蛋', '地瓜']);

</script>

<template>
    <div class="search-banner">
        <img 
        :src="$parsePublicFile('img/site/search-page-banner.png')" 
        alt="search banner"
        class="banner-bg"
        />
        <div class="content-overlay">
            <div class="title">
                <i-material-symbols-restaurant-rounded class="main-icon zh-h2" />
                <h2 class="zh-h2">快速搜尋好料理</h2>
            </div>
            <div class="search-container">
                <SearchBar placeholder="尋找靈感食譜..." />
            </div>
            <div class="tags-group">
                <BaseTag v-for="tag in hotTags"
                :key="tag"
                :text="tag"
                height="30"
                variant="outline"
                class="tag-item"/>
            </div>
        </div>
    </div>
    
</template>

<style lang="scss" scoped>
    .search-banner{
        margin-top: 30px;
        position: relative;
        width: 100%;
        border-radius: $radius-base;
        overflow: hidden;
        margin-bottom: 30PX;
        .banner-bg{
            width: 100%;
            height: auto;
            display: block;
            object-fit: cover;
            min-height: 250px;
        }
        .content-overlay{
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            padding: 0 8%;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: flex-start;
            .title{
                display: flex;
                align-items: center;
                margin-bottom: 10px;
                gap:8px;
                .main-icon {
                    font-size: 24px;
                }
            }
            .tags-group{
                display: flex;
                gap: 10px;
            }
            .search-container{
                width: 450px;
                margin-bottom: 20px;
            }
        }
        
    }
</style>
