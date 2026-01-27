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
                <span class="modal__close-btn p-p2" @click="emit('noshow')"><i-material-symbols-close /></span>
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
    z-index: 999;
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
    z-index: 1000;
    position: fixed;
    border-radius: 10px;
    padding: 20px;
    display: flex; // 若父容器只有單純加上高度而沒有給flex配置，就算有設定至少50%的高度，子物件預設會認為「展示完整內容」比「服從父層高度」重要，因而撐破父容器
    flex-direction: column;
    gap: 10px;

    &__header {
        width: 100%;
        display: flex;
        justify-content: space-between;
    }

    &__title {
        color: $primary-color-800;
        text-align: center;
    }

    &__close-btn {
        cursor: pointer;
        display: flex;
        justify-content: center;
        align-items: center;
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

        // 表格共同樣式
        &__header,
        &__row {
            display: flex;
            align-items: center;
            padding: 12px 20px;
        }

        .cell {
            min-width: 0;
            word-break: break-all;
            overflow-wrap: break-word;

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
                white-space: nowrap; // 強制文字在一行內顯示
                text-overflow: ellipsis; // 超出部分顯示 ...
                overflow: hidden; // 隱藏超出的部分
            }
        }

        // 表格內容樣式
        &__body {
            flex: 1;
            overflow-y: auto;
            min-height: 0;

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
                }
            }
        }

    }


}
</style>