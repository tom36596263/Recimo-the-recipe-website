<script setup>
import { computed } from 'vue';
import BaseTag from '@/components/common/BaseTag.vue';
import BaseBtn from '@/components/common/BaseBtn.vue';

const props = defineProps({
    recipe: {
        type: Object,
        required: true
    },
    recipeTags:{
        type: Array,
        default: () => []
    }
});

const recipeImagePath = computed(() => {
    return `img/recipes/${props.recipe.recipe_id}/cover.png`;
})
</script>

<template>
    <div class="search-card">
        
        <div class="recipe-img">
            <img :src="$parsePublicFile(recipeImagePath)" alt="recipe.recipe_title" />
        </div>
        <div class="recipe-info">
            <div class="title">
                <h4 class="zh-h3">{{recipe.recipe_title}}</h4>
                <div class="tags-group">
                    <BaseTag 
                    v-for="tag in recipeTags"
                    :key="tag.tag_id"
                    :text="tag.tag_name"
                    class="tag-item"/>
                </div>
                <p class="p-p2">{{ recipe.recipe_descreption }}</p>
            </div>
            <div class="btn-group">
                <BaseBtn title="食譜詳情" variant="solid"/>
                <BaseBtn title="料理包詳情" variant="outline"/>
            </div>
        </div>
        
    </div>
</template>

<style lang="scss" scoped>
    .search-card {
        display: flex;
        
        padding: 20px 0;
        border-bottom: 1px solid $neutral-color-400;
        width: 100%;

        .recipe-img {
            height: 160px;
            min-width: 200px;
            border-radius: $radius-base;
            overflow: hidden;
            margin-right: 20px;
            
            img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }
        }

        .recipe-info {
            display: flex;
            flex-direction: row;
            justify-content: space-between;
            align-items: center;
            width: 100%;

            
            .title {
                margin-right: 30px;
                .tags-group {
                    display: flex;
                    gap: 8px;
                    flex-wrap: wrap;
                    margin: 8px 0;
                }
            }
            .btn-group{
                display: flex;
                flex-direction: column;
                gap:10px;
            }
        }
    }
@media screen and (max-width: 810px){

}

@media screen and (max-width: 810px) {
    .search-card {
        flex-direction: column;
        align-items: stretch;
        border-bottom: none;
        margin-bottom: 30px;

        .recipe-img {
            width: 100%;
            height: 200px;
            margin-right: 0;
            margin-bottom: 16px;
        }

        .recipe-info {
            flex-direction: column;
            .title {
                margin-right: 0;
                
                .zh-h3 {
                    font-size: 1.25rem;
                }
                
                .p-p2 {
                    display: none;
                }
            }

            .btn-group {
                display: flex;
                gap: 10px;
                margin-top: 16px;
                flex-direction: row;
            }
        }
    }
}
</style>