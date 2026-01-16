<script setup>
import { computed } from 'vue';

const props = defineProps({
    servings: { type: Number, default: 1 },
    list: { type: Array, default: () => [] }
});

const computedIngredients = computed(() => {
    return props.list.map(item => ({
        ...item,
        displayAmount: parseFloat(((Number(item.amount) || 0) * props.servings).toFixed(1))
    }));
});
</script>

<template>
    <section class="ingredients-container">
        <p v-if="list.length === 0" class="debug-msg">偵錯：父組件傳入的食材陣列為空</p>

        <div class="table-wrapper">
            <div class="table-header">
                <p class="cell">食材</p>
                <p class="cell">份量</p>
                <p class="cell">備註</p>
            </div>

            <div class="table-body">
                <div v-for="(item, index) in computedIngredients" :key="index" class="table-row">
                    <div class="cell name">
                        <p class="p-p2">{{ item.INGREDIENT_NAME }}</p>
                    </div>
                    <div class="cell amount">
                        <p class="p-p2">{{ item.displayAmount }} {{ item.unit_name }}</p>
                    </div>
                    <div class="cell note">
                        <p class="p-p2">{{ item.note }}</p>
                    </div>
                </div>
            </div>
        </div>
    </section>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss'; // 確保引用專案顏色變數

.ingredients-container {
    width: 100%;
    margin-bottom: 2rem;

    .debug-msg {
        color: #e74c3c;
        text-align: center;
        padding: 10px;
        font-weight: bold;
    }
}

.table-wrapper {
    margin-top: 20px;
    border: 1px solid #ccc; // 對應圖片中的灰色細邊框
    border-radius: 12px; // 對應圖片中的圓角
    overflow: hidden; // 確保 header 顏色不會超出圓角
    background-color: #fff;
}

.table-header {
    display: flex;
    background-color: #4a9062; // 對應圖片中的森林綠色
    padding: 12px 20px;

    .cell {
        color: #fff; // 白色文字
        font-weight: 500;
        margin: 0;
        flex: 1;

        // 根據圖片微調寬度比例：食材與份量較窄，備註較寬
        &:nth-child(1) {
            flex: 1.2;
        }

        &:nth-child(2) {
            flex: 1;
        }

        &:nth-child(3) {
            flex: 2;
        }
    }
}

.table-body {
    padding: 8px 0; // 上下留點空隙

    .table-row {
        display: flex;
        padding: 12px 20px;
        transition: background-color 0.2s;

        &:hover {
            background-color: #f9f9f9;
        }

        .cell {
            flex: 1;
            display: flex;
            align-items: center;

            &.name {
                flex: 1.2;
                font-weight: 500;
            }

            &.amount {
                flex: 1;
            }

            &.note {
                flex: 2;
                color: #333;
            }

            .p-p2 {
                margin: 0;
                line-height: 1.5;
                font-size: 16px; // 調整至適合閱讀的大小
            }
        }
    }
}

// 響應式微調：手機版縮小內距
@media screen and (max-width: 576px) {

    .table-header,
    .table-row {
        padding: 10px 12px;
    }
}
</style>