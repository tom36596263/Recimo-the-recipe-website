<script setup>
    import { markRaw, computed } from 'vue';
    import { useRouter } from 'vue-router';

    import BaseTag from '@/components/common/BaseTag.vue';
    import BaseBtn from '@/components/common/BaseBtn.vue';
    import LikeButton from '@/components/common/LikeButton.vue'

    import IconLocalFireDepartment from '~icons/material-symbols/Local-Fire-Department-outline';
    import IconramenDining from '~icons/material-symbols/Ramen-Dining-outline';
    import IconAlarm from '~icons/material-symbols/Alarm-outline';

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

    const recipeInfo = computed(() => [
        {
            icon: markRaw(IconLocalFireDepartment),
            label: '熱量',
            value: props.recipe.nutritional_info.calories.replace('kcal', ''),
            unit: 'kcal'
        },
        {
            icon: markRaw(IconramenDining),
            label: '份量',
            value: props.recipe.nutritional_info.serving_size,
            unit: '人份'
        },
        {
            icon: markRaw(IconAlarm),
            label: '製作時間',
            value: props.recipe.nutritional_info.cooking_time.replace('分鐘', ''),
            unit: '分鐘'
        }
    ]);

    const handleLikeChange = (isLiked, item) => {
        console.log(`用戶對 ${item.userName} 的留言點讚狀態：`, isLiked);
        // 這裡可以呼叫 API 更新後端數據
    };
</script>
<template>
    <div class="recipe-card-lg">
        <header class="card-header">
            <img :src="$parsePublicFile(recipe.image_url)" alt="recipe.recipe_name">
        </header>

        <div class="card-body">
            <div class="title">
                <h3 class="zh-h3">{{ recipe.recipe_name }}</h3>
                <i-material-symbols-Favorite-outline @click.prevent.stop />
            </div>
            <div class="tag">
                <BaseTag v-for="tag in recipe.tags" :key="tag" :text="tag" />
            </div>
            <div class="recipe-info">
                <div 
                v-for="(item, index) in recipeInfo" 
                :key="index" 
                class="recipe-info-item p-p3"
                >
                    <span class="label">
                        <component :is="item.icon" />{{ item.label }}
                    </span>
                    <span class="value en-h2">{{ item.value }}<span class="p-p1">{{ item.unit }}</span></span>
                </div>
            </div>
        </div>
        
        <footer>
            <div class="personal-info">
                <div class="personal-img">
                    <img :src="$parsePublicFile('img/site/Recimo-logo-black.svg')" alt="logo" >
                </div>
                <p class="p-p1">Recimo</p>
                <div @click.prevent.stop>
                    <LikeButton 
                    :initial-likes="recipe.author.likes || 0" 
                    @update:liked="(val) => handleLikeChange(val, item)"
                    />
                </div>
                
            </div>
            
            <!-- <div class="btn-group">
                <BaseBtn title="食譜詳情" variant="solid" height="30" @click="goToDetail" class="btn" />
            </div> -->
            
        </footer>
    </div>
</template>
<style lang="scss" scoped>
    .recipe-card-lg{
        border: 1px solid $neutral-color-400;
        border-radius: $radius-base;
        overflow: hidden;
        background-color: $neutral-color-white;
        transition: all 0.3s ease;
        &:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba($neutral-color-black, 0.08);
            border-color: $primary-color-400;
        }
        .card-header{
            overflow: hidden;
            height: 320px;
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
            padding: 16px;
            
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
            }
            .recipe-info{
                display: flex;
                justify-content: space-around;
                background-color: $neutral-color-100;
                margin-top: 10px;
                padding: 10px;
                border-radius: $radius-base;
                .recipe-info-item{
                    text-align: center;
                    .label{
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        margin-bottom: 6px;
                    }
                }
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
            // .btn-group{
            //     .btn{
            //         width: 100px;
            //     }
            // }
        }
    }
</style>