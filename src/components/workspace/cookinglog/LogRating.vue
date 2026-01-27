<script setup>
import { ref, computed, onMounted } from 'vue';

</script>

<template>
    <div class="rating">
        <div class="rating__title p-p1">
            <i-material-symbols-thumb-up />
            成品滿意度
        </div>

        <div class="rating__score zh-h3-bold">
            3.6
        </div>

        <div class="rating__stars p-p1">
            <i-material-symbols-star />
            <i-material-symbols-star />
            <i-material-symbols-star />
            <i-material-symbols-star />
            <i-material-symbols-star />
        </div>

    </div>
</template>

<style lang="scss" scoped>
.rating {
    flex-shrink: 0;
    flex: 1;
    min-width: 150px;
    height: 150px;
    background-color: $neutral-color-white;
    border-radius: 10px;
    padding: 30px 20px;
    border: 1px solid $primary-color-800;

    &__title {
        display: flex;
        align-items: center;
        color: $neutral-color-800;
    }

    &__score {
        color: $neutral-color-black;
    }

    &__stars {
        color: $secondary-color-warning-700;
        cursor: pointer;
    }
}
</style>