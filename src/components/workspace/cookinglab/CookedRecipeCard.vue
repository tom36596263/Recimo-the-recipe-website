<script setup>
import { computed } from 'vue';
import { parsePublicFile } from '@/utils/parseFile';

const props = defineProps({
    recipe: {
        type: Object,
        required: true
    }
});

const emit = defineEmits(['click']);

// 處理圖片路徑
const recipeImage = computed(() => {
    // 🟢 修正：優先抓取 recipe_image_url (資料庫原始欄位)，如果沒有才抓 image_url
    const rawPath = props.recipe.recipe_image_url || props.recipe.image_url;

    if (!rawPath) return ''; // 如果都沒有，回傳空字串 (或預設圖路徑)

    // 判斷是否為完整網址
    return rawPath.startsWith('http')
        ? rawPath
        : parsePublicFile(rawPath);
});
</script>

<template>
    <div class="cooked-recipe-card" @click="emit('click', recipe)">
        <div class="card-image">
            <img :src="recipeImage" :alt="recipe.recipe_name" loading="lazy" />
            <div class="count-badge">
                <i-material-symbols-history class="icon" />
                {{ recipe.log_count }} 次
            </div>
        </div>
        <div class="card-content">
            <h5 class="recipe-name">{{ recipe.recipe_title }}</h5>
            <div class="card-footer">
                <span class="last-date" v-if="recipe.last_cooked_at">
                    最近：{{ new Date(recipe.last_cooked_at).toLocaleDateString() }}
                </span>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
/* 樣式保持不變 */
.cooked-recipe-card {
    background: $neutral-color-white;
    border-radius: 12px;
    overflow: hidden;
    transition: all 0.3s ease;
    cursor: pointer;
    height: 100%;
    display: flex;
    flex-direction: column;
    border: 1px solid $neutral-color-100;

    &:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 20px rgba($neutral-color-black, 0.08);

        .card-image img {
            transform: scale(1.05);
        }
    }

    .card-image {
        width: 100%;
        padding-top: 75%;
        position: relative;
        overflow: hidden;

        img {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.5s ease;
        }

        .count-badge {
            position: absolute;
            top: 8px;
            right: 8px;
            background: rgba($primary-color-800, 0.9);
            color: white;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 4px;
            backdrop-filter: blur(4px);

            .icon {
                font-size: 14px;
            }
        }
    }

    .card-content {
        padding: 16px;
        flex: 1;
        display: flex;
        flex-direction: column;
        justify-content: space-between;

        .recipe-name {
            font-size: 16px;
            font-weight: 600;
            color: $neutral-color-800;
            margin-bottom: 8px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            line-height: 1.4;
        }

        .card-footer {
            .last-date {
                font-size: 12px;
                color: $neutral-color-400;
            }
        }
    }
}
</style>