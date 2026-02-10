<script setup>
import { useRouter } from 'vue-router';
import { ref, computed, watch } from 'vue';
import { useAuthStore } from '@/stores/authStore';
import { useFavoritesStore } from '@/stores/favoritesStore';
import AddToFolderModal from '@/components/workspace/recipedetail/modals/AddToFolderModal.vue';
import AuthorInfo from '@/components/workspace/modifyrecipe/AuthorInfo.vue';

const props = defineProps({
    recipe: {
        type: Object,
        required: true
    },
    // 是否禁用點擊跳轉功能
    disableNavigation: {
        type: Boolean,
        default: false
    }
});

const router = useRouter();

// 定義向父組件發出的事件
const emit = defineEmits(['favoriteUpdated']);

const authStore = useAuthStore();
const showAddToFolderModal = ref(false);
const recipeId = computed(() => props.recipe.id);
const favoritesStore = useFavoritesStore();
const userId = computed(() => authStore.user?.id || authStore.user?.user_id || null);
const isFavorited = computed(() => favoritesStore.isFavorited(recipeId.value));

// 彈窗關閉時自動刷新收藏狀態
const handleModalSubmit = () => {
    showAddToFolderModal.value = false;
    if (userId.value) {
        favoritesStore.refetchFavorites(userId.value);
    }
    // 通知父組件收藏已更新
    emit('favoriteUpdated');
};

const handleHeartClick = (e) => {
    e.stopPropagation();
    if (!authStore.user) {
        authStore.isLoginLightboxOpen = true;
        return;
    }
    showAddToFolderModal.value = true;
};

const goToDetail = () => {
    // 如果禁用導航，則不執行跳轉
    if (props.disableNavigation) return;

    router.push({
        name: 'workspace-recipe-detail',
        params: { id: props.recipe.id }
    });
};

</script>
<template>
    <div class="recipe-card-sm" @click="goToDetail">
        <header class="card-header">
            <!-- 收藏按鈕，根據收藏狀態顯示激活 -->
            <div class="icon-group" @click.stop="handleHeartClick" style="cursor: pointer;">
                <i-material-symbols-Favorite v-if="isFavorited" style="color: #e74c3c" />
                <i-material-symbols-Favorite-outline v-else />
            </div>
            <img :src="recipe.image_url" :alt="recipe.recipe_name">
        </header>
        <div class="card-body">
            <div class="title">
                <h5 class="zh-h5">{{ recipe.recipe_name }}</h5>
            </div>
        </div>
        <footer>
            <div class="personal-info">
                <AuthorInfo v-if="recipe" 
                    :user-id="recipe.author?.id || 0"
                    :name="recipe.author_name || recipe.author?.name || 'Recimo'"
                    :handle="recipe.author?.handle || `user_${recipe.author?.id || 0}`"
                    :avatar-url="recipe.user_url || ''" />
            </div>
        </footer>
        <AddToFolderModal v-model="showAddToFolderModal" :commentData="{}" :recipe-id="recipeId"
            @submit="handleModalSubmit" />
    </div>
</template>
<style lang="scss" scoped>
.recipe-card-sm {
    border: 1px solid $neutral-color-400;
    border-radius: $radius-base;
    overflow: hidden;
    background-color: $neutral-color-white;
    cursor: pointer;
    transition: all 0.3s ease;

    &:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 20px rgba($neutral-color-black, 0.08);
        border-color: $primary-color-400;
    }

    .card-header {
        overflow: hidden;
        position: relative;
        height: 150px;
        width: 100%;

        .icon-group {
            position: absolute;
            top: 10px;
            right: 10px;
            z-index: 3;

            &:hover {
                color: $secondary-color-danger-700;
            }

            .favorite-animate {
                animation: heart-bounce 0.4s;
            }
        }

        img {
            width: fit-content;
            object-fit: cover;
            display: block;
            width: 100%;
            height: 100%;
            transition: .3s ease;

            &:hover {
                scale: 1.1;
            }
        }
    }

    .card-body {
        padding: 16px 16px 4px 16px;

        .title {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 6px;
            color: $primary-color-700;
        }


        .tag {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
        }
    }

    footer {
        padding: 0 16px 16px 16px;
        justify-content: space-between;
        display: flex;

        .btn-group {
            display: flex;
            gap: 8px;
        }

        .personal-info {
            display: flex;
            align-items: center;

            .p-p1 {
                margin-right: 6px;
            }

            .en-h3 {
                margin-left: 6px;
            }
        }

        .personal-img {
            width: 24px;
            height: 24px;
            margin-right: 8px;
            border-radius: $radius-pill;
            border: 1px solid $neutral-color-700;
            overflow: hidden;
            display: flex;
            justify-content: center;

            img {
                width: 20px;

            }
        }
    }
}

@keyframes heart-bounce {
    0% {
        transform: scale(1);
    }

    30% {
        transform: scale(1.3);
    }

    60% {
        transform: scale(0.9);
    }

    100% {
        transform: scale(1);
    }
}

@media screen and (max-width: 1300px) {
    .recipe-card-lg {
        footer {
            .btn {
                width: 85px;
            }
        }
    }
}
</style>