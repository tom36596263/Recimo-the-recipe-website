<script setup>
import { computed } from 'vue';
import { useRouter } from 'vue-router'

import BaseTag from '@/components/common/BaseTag.vue';
import BaseBtn from '@/components/common/BaseBtn.vue';

const props = defineProps({
    recipe: {
        type: Object,
        default: null
    },
    product: {
        type: Object,
        default: null
    },
    recipeTags:{
        type: Array,
        default: () => []
    }
});

const router = useRouter();

const recipeImagePath = computed(() => {
    if(props.product && props.product.product_image){
        const cover = props.product.product_image.find(img => img.is_cover);
        return cover ? cover.image_url : props.product.product_image[0].image_url;
    }
    return `img/recipes/${props.recipe.recipe_id}/cover.png`;
});

const displayTitle = computed(() => {
    return props.product?.product_name || props.recipe?.recipe_title;
});

const displayDescription = computed(() => {
    return props.product?.product_description || props.recipe?.recipe_descreption || '';
})

const goToRecipeDetail = () => {
    if(!props.recipe) return; 
    router.push({
        name: 'workspace-recipe-detail',
        params: { id: props.recipe.recipe_id }
    })
}
const goToProductDetail = () => {
    if(!props.product) return;
    router.push({
        name: 'product-detail',
        params: { id: props.product.product_id }
    })
}
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
                        v-if="product?.product_category"
                        :text="product.product_category"
                        class="tag-item"
                    />
                    <BaseTag 
                        v-for="tag in recipeTags"
                        :key="tag.tag_id"
                        :text="tag.tag_name"
                        class="tag-item"/>
                </div>
                <p class="p-p2">{{ recipe.recipe_descreption }}</p>
            </div>
            <div class="btn-group">
                <BaseBtn 
                    title="食譜詳情" 
                    :variant="recipe ? 'solid' : 'outline'"
                    :disabled="!recipe"
                    @click="goToRecipeDetail" />
                <BaseBtn 
                    title="料理包詳情" 
                    :variant="product ? 'solid' : 'outline'"
                    :disabled="!product"
                    @click="goToProductDetail"/>
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