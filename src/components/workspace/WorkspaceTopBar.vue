<script setup>
import { useRoute } from 'vue-router';
import SearchBar from '@/components/common/SearchBar.vue'
const route = useRoute();
</script>

<template>
    <header class="workspace-top-bar container">
        <div class="row">
            <div class="col-6 personal-info">
                    <div class="personal-img">
                        <img src="@/assets/images/site/Recimo-logo-black.svg" alt="">
                    </div>
                    
                    <div class="title">
                        <h3 class="en-h3">Hi,<span>Recimo</span></h3>
                        <h5 class="zh-h5">一起來發現食譜的新創意吧!</h5>
                    </div>
            </div>
            <div class="col-6 tool-group">
                <SearchBar />
                <i-material-symbols-Shopping-Cart-outline />
                <i-material-symbols-Notifications-outline />
                <i-material-symbols-Settings-outline />
            </div>
        </div>
    </header>
</template>



<style lang="scss" scoped>
.workspace-top-bar {
    padding: 20px; 
    margin: 20px auto;
    border-radius: $radius-base;
    background-color: $primary-color-100;

    .personal-info{
        display: flex;
        align-items: center;
        .personal-img{
            width: 60px;
            height: 60px;
            margin-right: 12px;
            border-radius: $radius-pill;
            background-color: $neutral-color-white;
            overflow: hidden;
            display: flex;
            justify-content: center;
            img{
                width: 40px;
                
            }
        }
        .title{
            color: $primary-color-700;
        }
    }
    .tool-group{
        display: flex;
        align-items: center;
        font-size: 24px;
        color: $primary-color-700;
        gap: 16px;
    }
}
</style>