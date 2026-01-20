<script setup>
    import { useRouter } from 'vue-router';

    import BaseTag from '@/components/common/BaseTag.vue';
    import BaseBtn from '@/components/common/BaseBtn.vue';
    import LikeButton from '@/components/common/LikeButton.vue'
    const props = defineProps({
        recipe: {
            type: Object,
            required: true
        }
    });

    const router = useRouter();

    const goToDetail = () => {
        router.push({ 
            name: 'workspace-recipe-detail', 
            params: { id: props.recipe.id } 
        });
    };

</script>
<template>
    <div class="recipe-card-lg">
        <header class="card-header">
            <img :src="recipe.image_url" alt="recipe.recipe_name">
        </header>

        <div class="card-body">
            <div class="title">
                <h5 class="zh-h5">{{ recipe.recipe_name }}</h5>
                <div class="icon-group">
                    <i-material-symbols-Favorite-outline />
                </div>
                
            </div>
            
        </div>
        
        <footer>
            <div class="personal-info">
                <div class="personal-img">
                    <img :src="$parsePublicFile('img/site/Recimo-logo-black.svg')" alt="logo" >
                </div>
                <p class="p-p1">Recimo</p>
                <LikeButton 
                :initial-likes="recipe.author.likes || 0" 
                @update:liked="(val) => handleLikeChange(val, item)"
                />
            </div>
            
        </footer>
    </div>
</template>
<style lang="scss" scoped>
    .recipe-card-lg{
        border: 1px solid $neutral-color-400;
        border-radius: $radius-base;
        overflow: hidden;
        background-color: $neutral-color-white;
        .card-header{
            overflow: hidden;
            height: 150px;
            width: 100%;
            img{
                width:fit-content;
                object-fit: cover;
                display: block;
                width: 100%;
                height: 100%;
                transition: .3s ease;
                &:hover{
                    scale: 1.1;
                }
            }
        }
        .card-body{
            padding: 16px 16px 4px 16px;
            
            .title{
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 6px;
                color: $primary-color-700;
            }
            .icon-group{
                display: flex;
                gap: 12px;
            }
            .tag{
                display: flex;
                gap: 6px;
                flex-wrap: wrap;
            }
        }
        footer{
            padding: 0 16px 16px 16px;
            justify-content: space-between;
            display: flex;
            .btn-group{
                display: flex;
                gap: 8px;
            }
            .personal-info{
                display: flex;
                align-items: center;
                .p-p1{
                    margin-right: 6px;
                }
                .en-h3{
                    margin-left: 6px;
                }
            }
            .personal-img{
                width: 24px;
                height: 24px;
                margin-right: 8px;
                border-radius: $radius-pill;
                border: 1px solid $neutral-color-700;
                overflow: hidden;
                display: flex;
                justify-content: center;
                img{
                    width: 20px;
                    
                }
            }
        }
    }
    @media screen and (max-width: 1300px){
        .recipe-card-lg{
            footer{
                .btn{
                    width: 85px;
                }
            }
        }
    }
</style>