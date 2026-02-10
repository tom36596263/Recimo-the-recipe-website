<script setup>
import { computed } from 'vue';
import { useCookingStore } from '@/stores/useCookingStore';

const cookingStore = useCookingStore();

// 定義選項
const options = ['簡單', '中等', '困難'];

// 綁定 store 中的數據 (使用 get/set 確保雙向綁定)
const skillLevel = computed({
    get: () => cookingStore.tempLogData.skillDifficulty || '簡單',
    set: (val) => cookingStore.tempLogData.skillDifficulty = val
});

const processLevel = computed({
    get: () => cookingStore.tempLogData.processDifficulty || '簡單',
    set: (val) => cookingStore.tempLogData.processDifficulty = val
});

// 切換難度函式
const setSkill = (level) => { skillLevel.value = level; };
const setProcess = (level) => { processLevel.value = level; };
</script>

<template>
    <div class="difficulty">
        <div class="difficulty__title p-p1">
            <i-material-symbols-neurology />
            製作難易度
        </div>

        <div class="difficulty__row p-p3">
            <span class="difficulty__label">烹飪技法：</span>
            <div class="difficulty__options">
                <span v-for="opt in options" :key="'skill-' + opt" class="option-btn"
                    :class="{ 'is-active': skillLevel === opt }" @click="setSkill(opt)">
                    {{ opt }}
                </span>
            </div>
        </div>

        <div class="difficulty__row p-p3">
            <span class="difficulty__label">製作流程：</span>
            <div class="difficulty__options">
                <span v-for="opt in options" :key="'process-' + opt" class="option-btn"
                    :class="{ 'is-active': processLevel === opt }" @click="setProcess(opt)">
                    {{ opt }}
                </span>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.difficulty {
    flex-shrink: 0;
    flex: 1;
    min-width: 150px;
    height: 150px;
    background-color: $neutral-color-white;
    border-radius: 10px;
    padding: 20px 20px;
    /*稍微調整padding讓內容置中*/
    display: flex;
    flex-direction: column;
    justify-content: center;
    /* 垂直置中內容 */
    gap: 12px;
    /* 增加行距 */
    margin-right: -10px;
    border: 1px solid $primary-color-800;

    &__title {
        display: flex;
        align-items: center;
        color: $neutral-color-800;
        gap: 4px;
        margin-bottom: 5px;
    }

    &__row {
        display: flex;
        align-items: center;
        color: $neutral-color-black;
    }

    &__label {
        width: 70px;
        /* 固定標籤寬度 */
        flex-shrink: 0;
    }

    &__options {
        flex: 1;
        display: flex;
        justify-content: space-between;
        background-color: #F0F5F2;
        /* $primary-color-100 的替代色碼，或直接用變數 */
        border-radius: 20px;
        /* 圓角更明顯 */
        padding: 2px;
        /* 內距 */

        .option-btn {
            flex: 1;
            text-align: center;
            padding: 4px 0;
            border-radius: 18px;
            cursor: pointer;
            color: $neutral-color-700;
            font-size: 0.9rem;
            transition: all 0.2s ease;

            &:hover {
                background-color: rgba($primary-color-800, 0.1);
            }

            /* 被選中的樣式 */
            &.is-active {
                background-color: $primary-color-800;
                color: $neutral-color-white;
                font-weight: bold;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            }
        }
    }
}
</style>