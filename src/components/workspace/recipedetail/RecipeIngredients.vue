<script setup>
import { computed } from 'vue';

const props = defineProps({
    servings: { type: Number, default: 1 },
    list: { type: Array, default: () => [] }
});

const computedIngredients = computed(() => {
    return props.list.map(item => ({
        ...item,
        // 優化：數字太大轉科學記號，避免爆版
        displayAmount: ((Number(item.amount) || 0) * props.servings) > 1e12
            ? ((Number(item.amount) || 0) * props.servings).toExponential(2)
            : parseFloat(((Number(item.amount) || 0) * props.servings).toFixed(1))
    }));
});
</script>

<template>
    <section class="ingredients-container">
        <p v-if="list.length === 0" class="debug-msg">偵錯：父組件傳入的食材陣列為空</p>

        <div class="table-wrapper">
            <div class="table-header">
                <div class="cell name">食材</div>
                <div class="cell amount">份量</div>
                <div class="cell note">備註</div>
            </div>

            <div class="table-body">
                <div v-for="(item, index) in computedIngredients" :key="index" class="table-row">
                    <div class="cell name" :title="item.INGREDIENT_NAME">
                        <p class="p-p2">{{ item.INGREDIENT_NAME }}</p>
                    </div>
                    <div class="cell amount" :title="item.displayAmount + ' ' + item.unit_name">
                        <p class="p-p2">{{ item.displayAmount }} {{ item.unit_name }}</p>
                    </div>
                    <div class="cell note" :title="item.note">
                        <p class="p-p2">{{ item.note }}</p>
                    </div>
                </div>
            </div>
        </div>
    </section>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

// 1. 定義統一比例變數，方便維護
$flex-name: 0.8;
$flex-amount: 0.8;
$flex-note: 1.8;

.ingredients-container {
    width: 100%;
    margin-bottom: 2rem;

    .debug-msg {
        color: $secondary-color-danger-700;
        text-align: center;
        padding: 10px;
        font-weight: bold;
    }
}

.table-wrapper {
    margin-top: 20px;
    border: 1px solid $neutral-color-400;
    border-radius: 10px;
    overflow: hidden;
    background-color: $neutral-color-white;
}

// 2. 抽離共用的 Flex 佈局邏輯
.table-header,
.table-row {
    display: flex;
    align-items: center; // 垂直置中
    padding: 12px 20px;

    .cell {
        min-width: 0; // 防止 Flex 子元素被內容撐破
        word-break: break-all;
        overflow-wrap: break-word;

        // 統一比例分配
        &.name {
            flex: $flex-name;
            text-align: left;
        }

        &.amount {
            flex: $flex-amount;
            padding-left: 12px;
            text-align: center; // 讓標題與數字都置中
        }

        &.note {
            flex: $flex-note;
            text-align: left;
            padding-left: 10px; // 備註稍微空出一點距離
        }
    }
}

// .table-header {
//     .cell.amount {
//         text-align: left;
//         padding-left: 12px;
//     }
// }

// 3. 標題專屬樣式
.table-header {
    background-color: $primary-color-700;

    .cell {
        color: $neutral-color-white;
        font-weight: 600;
        // 標題不需要多行斷行
        white-space: nowrap;
        text-overflow: ellipsis;
        overflow: hidden;
    }
}

// 4. 內容列專屬樣式
.table-body {
    .table-row {
        transition: background-color 0.2s;
        border-bottom: 1px solid $neutral-color-100;

        &:last-child {
            border-bottom: none;
        }

        &:hover {
            background-color: $neutral-color-100;
        }

        .cell {
            &.name {
                font-weight: 500;
            }

            &.amount {
                color: $primary-color-700;
                font-weight: 500;
            }

            &.note {
                color: $neutral-color-black;
                font-size: 0.9rem;
            }

            .p-p2 {
                margin: 0;
                line-height: 1.4;
            }
        }
    }
}

// 5. 手機版優化
@media screen and (max-width: 576px) {

    .table-header,
    .table-row {
        padding: 10px 12px;

        .cell.note {
            flex: 1.5; // 手機版縮小備註比例，留給食材名
        }
    }
}
</style>