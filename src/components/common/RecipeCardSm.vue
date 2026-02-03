<script setup>
import { useRouter } from 'vue-router';
import LikeButton from '@/components/common/LikeButton.vue'
import { ref, onMounted, computed } from 'vue';
import { useAuthStore } from '@/stores/authStore';
import { useFavoritesStore } from '@/stores/favoritesStore';
const favoritesStore = useFavoritesStore();

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

// 收藏功能狀態
const authStore = useAuthStore();
const userId = authStore.user?.id ?? 0;
const recipeId = props.recipe.id;
const isFavorited = computed(() => favoritesStore.isFavorited(recipeId));
const loadingFavorite = ref(false);
const heartAnimate = ref(false);

// 查詢是否已收藏
const fetchFavoriteStatus = async () => {
    await favoritesStore.fetchFavorites(userId);
};

// 切換收藏
const toggleFavorite = async (e) => {
    e.stopPropagation();
    if (!userId || !recipeId) {
        authStore.isLoginLightboxOpen = true;
        return;
    }
    loadingFavorite.value = true;
    heartAnimate.value = true;
    setTimeout(() => heartAnimate.value = false, 400);
    let res;
    if (isFavorited.value) {
        res = await favoritesStore.removeFavorite(userId, recipeId);
    } else {
        res = await favoritesStore.addFavorite(userId, recipeId);
    }
    loadingFavorite.value = false;
};

onMounted(fetchFavoriteStatus);

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
            <!-- 收藏按鈕，已收藏顯示紅色，未收藏顯示預設色 -->
            <div class="icon-group" @click.stop="toggleFavorite"
                :style="{ cursor: loadingFavorite ? 'not-allowed' : 'pointer' }">
                <i-material-symbols-Favorite v-if="isFavorited" style="color: #e74c3c"
                    :class="{ 'favorite-animate': heartAnimate }" />
                <i-material-symbols-Favorite-outline v-else :class="{ 'favorite-animate': heartAnimate }" />
            </div>
            <img :src="recipe.image_url" alt="recipe.recipe_name">
        </header>
        <div class="card-body">
            <div class="title">
                <h5 class="zh-h5">{{ recipe.recipe_name }}</h5>

            </div>
        </div>
        <footer>
            <div class="personal-info">
                <div class="personal-img">
                    <img :src="$parsePublicFile('img/site/Recimo-logo-black.svg')" alt="logo">
                </div>
                <p class="p-p1">Recimo</p>
                <div @click.prevent.stop>
                    <LikeButton :initial-likes="recipe.author.likes || 0"
                        @update:liked="(val) => handleLikeChange(val, item)" />
                </div>
            </div>

        </footer>
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