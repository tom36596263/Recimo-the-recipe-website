<script setup>
import { ref, onMounted } from 'vue';
import BaseTag from '@/components/common/BaseTag.vue';

const hotTags = ref(['義式料理', '披薩']);
</script>

<template>
    <div class="search-card">
        <div class="recipe-info">
            <div class="recipe-img">
                <img :src="$parsePublicFile('img/recipes/1/cover.png')" alt="" />
            </div>
            <div class="title">
                <h4 class="zh-h4">經典瑪格麗特披薩</h4>
                <div class="tags-group">
                    <BaseTag v-for="tag in hotTags"
                    :key="tag"
                    :text="tag"
                    class="tag-item"/>
                </div>
            </div>
        </div>
        
        <div class="btn-group">
            <BaseBtn title="食譜詳情" variant="solid"/>
            <BaseBtn title="料理包詳情" variant="outline"/>
        </div>
    </div>
</template>

<style lang="scss" scoped>
    .search-card{
        display: flex;
        align-items: center; 
        background-color: $neutral-color-100;
        justify-content: space-between;
        padding: 16px 50px 16px 16px;
        margin: 20px 0;
        .recipe-info{
            height:160px;
            
            display: flex;
            align-items: center;
            .recipe-img{
                height: 100%;
                width: 200px;
                border-radius: $radius-base;
                overflow: hidden;
                margin-right: 20px;
                img{
                    height: 100%;
                }
            }
            .title{
                display: flex;
                flex-direction: column;
                gap: 16px;
            }
            
        }
        .btn-group{
            display: flex;
            gap: 10px;
        }
    }
</style>