<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { parsePublicFile } from '@/utils/parseFile.js';

const props = defineProps({
  recipe: {
    type: Object,
    required: true
  }
})

// 跳轉至詳情頁
const router = useRouter();
const goToDetail = () => {
  if (props.recipe && props.recipe.recipe_id) {
    // 使用相對路徑跳轉，避免硬編碼 http://localhost:5173
    router.push(`/workspace/recipe-detail/${props.recipe.recipe_id}`);
  }
};
</script>

<template>
  <div class="card" @click="goToDetail">
    <img :src="$parsePublicFile(recipe.recipe_image_url)" :alt="recipe.recipe_title" class="card__img">

    <div class="card__img-overlay"></div>

    <div class="card__title p-p1">
      {{ recipe.recipe_title }}
    </div>
  </div>
</template>

<style lang="scss" scoped>
.card {
  width: 100px;
  height: 100px;
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  border-radius: 10px;
  overflow: hidden;
  margin: 5px;
  cursor: pointer;
  flex-shrink: 0;

  &:hover {

    .card__img {
      scale: 1.05;
    }
  }

  &__img {
    width: 100%;
    height: 100%;
    transition: 0.3s all ease;
  }

  &__img-overlay {
    width: 100%;
    height: 100%;
    background-color: rgba($neutral-color-black, 0.2);
    position: absolute;
    z-index: 100;

  }

  &__title {
    position: absolute;
    color: $neutral-color-white;
    text-align: center;
    // font-weight: 600;
    z-index: 110;
  }
}
</style>