<script setup>
// 1. 接收 v-model 傳進來的數值
const props = defineProps({
    modelValue: {
        type: Number,
        default: 0
    }
});

// 2. 定義更新事件
const emit = defineEmits(['update:modelValue']);

// 3. 點擊星星時觸發
const setRating = (star) => {
    emit('update:modelValue', star);
};
</script>

<template>
    <div class="rating">
        <div class="rating__title p-p1">
            <i-material-symbols-thumb-up />
            成品滿意度
        </div>

        <div class="rating__score zh-h3-bold">
            {{ modelValue }}/5
        </div>

        <div class="rating__stars p-p1">
            <i-material-symbols-star v-for="n in 5" :key="n" class="star-icon" :class="{ 'is-active': n <= modelValue }"
                @click="setRating(n)" />
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
        gap: 4px;
        /* 微調圖示與文字間距 */
    }

    &__score {
        color: $neutral-color-black;
        margin: 10px 0;
        /* 增加一點間距讓版面不擁擠 */
    }

    &__stars {
        /* 預設星星顏色改為灰色 (未選取狀態) */
        color: $neutral-color-400;
        cursor: pointer;
        display: flex;
        gap: 2px;
        /* 星星之間的間距 */

        .star-icon {
            transition: color 0.2s ease, transform 0.1s;

            /* 滑鼠經過時的效果 (選擇性) */
            &:hover {
                transform: scale(1.1);
            }

            /* 核心：當星星被激活 (is-active) 時，變成黃色 */
            &.is-active {
                color: $secondary-color-warning-700;
            }
        }
    }
}
</style>