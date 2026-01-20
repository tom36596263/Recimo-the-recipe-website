<script setup>
import { ref, onMounted } from 'vue'
import { publicApi } from '@/utils/publicApi'
import SearchBar from '@/components/common/SearchBar.vue'
import BaseTag from '@/components/common/BaseTag.vue'


const props = defineProps(['modelValue'])
const emit = defineEmits(['update:modelValue'])

const hotTags = ref([])

const fetchRandomTags = async () => {
    try{
        const res = await publicApi.get('data/recipe/tags.json');
        const allTags = res.data;

        hotTags.value = [...allTags]
            .sort(() => Math.random() - 0.5)
            .slice(0, 5)
            .map(tag => tag.tag_name);
    }catch(err){
        console.error("無法載入隨機標籤:", err);
    }
}
onMounted(() => {
    fetchRandomTags();
});
const handleTagClick = (tagName) => {
    emit('update:modelValue', tagName);
}

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
                <SearchBar
                :modelValue="modelValue"
                @update:modelValue="val => emit('update:modelValue', val)"
                placeholder="輸入關鍵字尋找好料理..." 
                maxWidth="100%"/>
            </div>
            <div class="tags-group">
                <BaseTag v-for="tag in hotTags"
                :key="tag"
                :text="tag"
                @click="handleTagClick(tag)"
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
                flex-wrap: wrap;
                .tag-item{
                    word-wrap: nowrap;
                }
            }
            .search-container{
                width: 50%;
                margin-bottom: 20px;
            }
        }
        
    }
    @media screen and (max-width: 810px){
        .search-banner{
            .content-overlay{
                .search-container{
                    width: 100%;
                    margin-bottom: 20px;
                }
                .tags-group{
                    gap:4px;
                }
            }
        }
        
        
    }
</style>
