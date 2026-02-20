<script setup>
import { ref, computed, onMounted } from 'vue';
const props = defineProps({
    list: {
        type: Array,
        default: () => []
    }
});
const emit = defineEmits(['noshow']);
</script>

<template>
    <div class="overlay" @click="emit('noshow')">
        <div class="modal" @click.stop>
            <div class="modal__header">
                <span class="modal__title p-p2">全部食材清單</span>
                <span class="modal__close-btn p-p2" @click="emit('noshow')">
                    <i-material-symbols-close />
                </span>
            </div>

            <div class="table">
                <div class="table__header">
                    <div class="cell name p-p1">食材</div>
                    <div class="cell amount p-p1">份量</div>
                    <div class="cell note p-p1">備註</div>
                </div>

                <div class="table__body">
                    <div class="table__row" v-for="item in props.list" :key="item.recipe_ingredient_id">
                        <div class="cell name p-p1">{{ item.ingredient_name }}</div>
                        <div class="cell amount p-p1">{{ item.amount }} {{ item.unit_name }}</div>
                        <div class="cell note p-p1">{{ item.remark }}</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.overlay {
    position: fixed;
    /* 🟢 修改：將層級提高到比手機版畫面 (9999) 還高 */
    z-index: 10000;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background-color: rgba($neutral-color-black, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
}

.modal {
    width: 95%;
    max-width: 650px;
    height: auto;
    min-height: 50%;
    max-height: 60%;
    background-color: $neutral-color-white;
    position: relative;
    /* z-index 需要定位屬性 */
    border-radius: 10px;
    padding: 20px;
    display: flex;
    flex-direction: column;
    gap: 10px;

    /* 🟢 新增手機版優化 */
    @media screen and (max-width: 810px) and (orientation: landscape) {
        width: 80%;
        /* 寬度稍微縮小，避免貼邊 */
        height: 90%;
        /* 高度拉高，因為手機橫向高度有限 */
        max-height: 90%;
        /* 允許佔用更多垂直空間 */
        padding: 15px;
        /* 減少內距 */
    }

    &__header {
        width: 100%;
        display: flex;
        justify-content: space-between;
        align-items: center;
        /* 確保垂直置中 */
    }

    &__title {
        color: $primary-color-800;
        text-align: center;
        font-weight: bold;
        /* 增加標題辨識度 */
    }

    &__close-btn {
        cursor: pointer;
        display: flex;
        justify-content: center;
        align-items: center;
        font-size: 1.2rem;
        /*稍微放大關閉按鈕*/
        padding: 5px;
        /* 增加點擊範圍 */
    }

    // ----表格----
    $flex-name: 0.8;
    $flex-amount: 0.8;
    $flex-note: 1.8;

    .table {
        border-radius: 10px;
        overflow: hidden;
        display: flex;
        flex-direction: column;
        flex: 1;
        min-height: 0;
        border: 1px solid $neutral-color-100;
        /* 增加邊框讓表格更清晰 */

        // 表格共同樣式
        &__header,
        &__row {
            display: flex;
            align-items: center;
            padding: 12px 20px;

            /* 手機版減少內距以容納更多內容 */
            @media screen and (max-width: 810px) {
                padding: 10px 12px;
            }
        }

        .cell {
            min-width: 0;
            word-break: break-all;
            overflow-wrap: break-word;
            font-size: 1rem;

            /* 手機版縮小字體 */
            @media screen and (max-width: 810px) {
                font-size: 0.9rem;
            }

            &.name {
                flex: $flex-name;
                text-align: left;
            }

            &.amount {
                flex: $flex-amount;
                padding-left: 12px;
                text-align: center;
            }

            &.note {
                flex: $flex-note;
                text-align: left;
                padding-left: 10px;
            }
        }

        // 表頭樣式
        &__header {
            background-color: $primary-color-700;

            .cell {
                color: $neutral-color-white;
                white-space: nowrap;
                text-overflow: ellipsis;
                overflow: hidden;
            }
        }

        // 表格內容樣式
        &__body {
            flex: 1;
            overflow-y: auto;
            min-height: 0;
            background-color: #fff;
            /* 確保背景色 */

            &::-webkit-scrollbar {
                width: 6px;
            }

            &::-webkit-scrollbar-thumb {
                background-color: $neutral-color-400;
                border-radius: 10px;
            }
        }

        &__row {
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

                    /* 手機版備註字體再小一點 */
                    @media screen and (max-width: 810px) {
                        font-size: 0.8rem;
                    }
                }
            }
        }
    }
}
</style>