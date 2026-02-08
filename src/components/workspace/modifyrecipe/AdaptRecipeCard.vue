<script setup>
import { useRouter } from 'vue-router';
import { computed } from 'vue';
import { useAuthStore } from '@/stores/authStore';
import LikeButton from '@/components/common/LikeButton.vue'
import AuthorInfo from '@/components/workspace/modifyrecipe/AuthorInfo.vue';

const props = defineProps({
    recipe: {
        type: Object,
        required: true
    },
    readonly: {
        type: Boolean,
        default: false
    }
});

const router = useRouter();
const authStore = useAuthStore();

// 判斷是否為本人
const isOwner = computed(() => {
    const currentUserId = authStore.user?.id || authStore.user?.user_id;
    return currentUserId === props.recipe.author_id;
});

const goToDetail = () => {
    if (!props.readonly) {
        const targetId = props.recipe.id || props.recipe.recipe_id;
        if (targetId) {
            router.push(`/workspace/recipe-detail/${targetId}`);
        }
    }
};

const handleLikeChange = (val, recipe) => {
    console.log('讚數更新:', val);
};

const emit = defineEmits(['upload-image']);

const handleUploadImage = () => {
    emit('upload-image');
};
</script>

<template>
    <div v-if="recipe" class="recipe-card-sm" :class="{ 'is-readonly': readonly }" @click="goToDetail">
        <header class="card-header" :style="{
            backgroundImage: recipe.coverImg ? `url(${recipe.coverImg})` : '',
            backgroundSize: 'cover',
            backgroundPosition: 'center'
        }">
            <div v-if="recipe.keyChangeTag" class="key-change-badge">
                <span class="badge-dot"></span>
                <span class="badge-text">{{ recipe.keyChangeTag }}</span>
            </div>

            <div v-if="!readonly" class="change-hint-overlay" @click.stop="handleUploadImage">
                <span class="p-p2">+ 更換成品照</span>
            </div>
        </header>

        <div class="card-body">
            <div class="input-group title-input">
                <input type="text" :value="recipe.adaptation_title || recipe.recipe_title || recipe.title || '未命名食譜'"
                    placeholder="改編版本標題..." readonly>
            </div>

            <div v-if="recipe.ingredients" class="ingredients-section">
            </div>

            <div class="input-group content-input" :class="{ 'has-tag': recipe.keyChangeTag }">
                <i-material-symbols-arrow-right-alt-rounded class="arrow-icon" />
                <textarea class="adaptation-textarea" :value="recipe.adaptation_note" placeholder="關鍵更改內容..."
                    readonly></textarea>
            </div>
        </div>

        <footer>
            <div class="personal-info-wrapper">
                <div @click.stop>
                    <AuthorInfo
                        :user-id="isOwner ? (authStore.user?.id || authStore.user?.user_id) : (recipe.author_id || recipe.author?.author_id)"
                        :name="isOwner ? (authStore.user?.user_name || authStore.user?.name) : ((recipe.author && typeof recipe.author === 'object') ? (recipe.author.author_name || recipe.author.name) : (recipe.author_name || recipe.author || 'Recimo User'))"
                        :handle="isOwner
                            ? (authStore.user?.user_email || authStore.user?.email)
                            : (recipe.user_email || recipe.author?.user_email || recipe.author?.email || `user_${recipe.author_id}`)"
                        :time="recipe.created_at"
                        :avatar-url="isOwner ? (authStore.user?.user_url || authStore.user?.avatarUrl) : (recipe.author?.author_image || recipe.author_image)" />
                </div>

                <div @click.prevent.stop>
                    <LikeButton :initial-likes="recipe.likes || 0"
                        @update:liked="(val) => handleLikeChange(val, recipe)" />
                </div>
            </div>
        </footer>
    </div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.recipe-card-sm {
    border: 1px solid $neutral-color-400;
    border-radius: 12px;
    overflow: hidden;
    background-color: $neutral-color-white;
    min-height: 320px;
    display: flex;
    flex-direction: column;
    transition: all 0.3s ease;
    position: relative;

    &.is-readonly {
        cursor: pointer;

        &:hover {
            transform: translateY(-8px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.08);
        }
    }

    .card-header {
        isolation: isolate;
        position: relative;
        height: 160px;
        background-color: $neutral-color-100;
        overflow: hidden;
        flex-shrink: 0;
    }

    .key-change-badge {
        position: absolute;
        top: 8px;
        left: 8px;
        max-width: calc(100% - 16px);
        z-index: 20;
        background: rgba($primary-color-700, 0.9);
        backdrop-filter: blur(4px);
        color: white;
        padding: 4px 10px;
        border-radius: 12px;
        display: flex;
        align-items: flex-start;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
        pointer-events: none;

        .badge-dot {
            width: 6px;
            height: 6px;
            background-color: #52c41a;
            border-radius: 50%;
            margin-right: 6px;
            margin-top: 5px;
            flex-shrink: 0;
        }

        .badge-text {
            font-size: 11px;
            font-weight: 500;
            line-height: 1.5;
            white-space: normal;
            word-break: break-all;
            flex: 1;
        }
    }

    .change-hint-overlay {
        position: absolute;
        inset: 0;
        background: rgba(0, 0, 0, 0.4);
        color: white;
        display: flex;
        align-items: center;
        justify-content: center;
        opacity: 0;
        transition: opacity 0.2s;
        z-index: 10;
    }

    &:not(.is-readonly) .card-header:hover .change-hint-overlay {
        opacity: 1;
    }

    .card-body {
        padding: 12px 16px;
        flex-grow: 1;
        display: flex;
        flex-direction: column;

        @media (max-width: 768px) {
            display: grid;
            grid-template-columns: 1fr;

            .title-input {
                order: 1;
            }

            .ingredients-section,
            .nutrition-list {
                order: 2;
            }

            .content-input {
                order: 3;
            }
        }

        .input-group {
            display: flex;
            margin-bottom: 8px;

            input {
                width: 100%;
                border: none;
                outline: none;
                background: transparent;
                color: $neutral-color-700;
                padding: 4px 0;
            }
        }

        .title-input input {
            font-weight: 600;
            font-size: 16px;
        }

        .content-input {
            align-items: flex-start;

            .arrow-icon {
                font-size: 20px;
                margin-right: 6px;
                margin-top: 2px;
                color: $primary-color-700;
                flex-shrink: 0;
            }

            .adaptation-textarea {
                width: 100%;
                border: none;
                outline: none;
                background: transparent;
                color: $neutral-color-400;
                font-size: 14px;
                line-height: 1.5;
                resize: none;
                padding: 0;
                height: 4.5em;
                font-family: inherit;
                cursor: default;
                scrollbar-width: none;

                &::-webkit-scrollbar {
                    display: none;
                }
            }

            &.has-tag {
                opacity: 0.7;

                .adaptation-textarea {
                    font-size: 13px;
                    font-style: italic;
                }

                .arrow-icon {
                    color: $primary-color-400;
                    transform: scale(0.9);
                }
            }
        }
    }

    footer {
        padding: 0 16px 16px;
        flex-shrink: 0;

        .personal-info-wrapper {
            display: flex;
            align-items: center;
            justify-content: space-between;
            width: 100%;
        }
    }
}
</style>