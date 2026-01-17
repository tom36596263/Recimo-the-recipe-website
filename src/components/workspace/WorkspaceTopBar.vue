<script setup>
import { useRoute } from 'vue-router';
import SearchBar from '@/components/common/SearchBar.vue'
const route = useRoute();
</script>

<template>
    <div class="workspace-top-bar">
        <div class="col-6 col-md-12 personal-info">
            <div class="personal-img">
                <img src="/img/site/Recimo-logo-black.svg" alt="">
            </div>
            
            <div class="title">
                <h3 class="en-h3">Hi,<span>Recimo</span></h3>
                <h5 class="zh-h5">一起來發現食譜的新創意吧!</h5>
            </div>
        </div>

        <div class="col-6 col-md-12 tool-group">
            <div class="search-bar">
                <SearchBar />
                <div class="tools">
                    <i-material-symbols-Shopping-Cart-outline />
                    <i-material-symbols-Notifications-outline />
                    <div class="setting">
                        <i-material-symbols-Settings-outline />
                    </div>
                </div>
            </div>
        </div>
    </div>
    
</template>



<style lang="scss" scoped>
    .workspace-top-bar {
        width: 100%;
        margin: 20px auto;
        border-radius: $radius-base;
        background-color: $primary-color-100;
        display: flex;
            .personal-info{
            display: flex;
            align-items: center;
            padding: 20px;
            .personal-img{
                width: 60px;
                height: 60px;
                flex-shrink: 0;
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
            justify-content: end;
            align-items: center;
            margin-right: 20px;
            .search-bar{
                display: flex;
                gap: 16px;
                
                .tools{
                    display: flex;
                    gap: 16px;
                    font-size: 24px;
                    color: $primary-color-700;
                    flex-direction: row;
                    align-items: center;
                }
            }
        }
    }
    
    
    
    @media screen and (max-width: 810px){
        .workspace-top-bar{
            position: relative;
            .personal-info{
                padding-top: 35px;
            }
            .tool-group{
                position: absolute;
                top: -20px;
                left: 0;
                display: flex;
                .search-bar{
                    width: 100%; // 強制搜尋欄填滿
                    display: flex;
                    justify-content: center;
                    flex-direction: column;
                }
            }
            .tools{
                position: absolute;
                top: -50px;
                right: 0;
                .setting{
                    display: none;
                }
            }
        }
        
    }
</style>