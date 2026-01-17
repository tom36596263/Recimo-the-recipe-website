<script setup>
import { computed } from 'vue';

const props = defineProps({
    servings: {
        type: Number,
        default: 1
    },
    list: {
        type: Array,
        default: () => []
    }
});

const computedIngredients = computed(() => {
    return props.list.map(item => ({
        ...item,
        displayAmount: parseFloat((Number(item.amount) * props.servings).toFixed(1))
    }));
});

</script>

<template>

    <section class="ingredients-container">
        <div class="table-wrapper">
            <div class="table-header">
                <p class="cell p-p2">食材</p>
                <p class="cell p-p2">份量</p>
                <p class="cell p-p2">備註</p>
            </div>

            <div class="table-body">

                <div 
                    v-for="(item, index) in computedIngredients" 
                    :key="index"
                    class="table-row"
                >
                    <div class="cell name">
                        <p class="p-p2">{{ item.INGREDIENT_NAME }}</p>
                    </div>

                    <div class="cell amount">
                        <p class="p-p2">
                            {{ item.displayAmount }} {{ item.unit_name }}
                        </p>
                    </div>

                    <div class="cell note">
                        <p class="p-p2">{{ item.note || '' }}</p>
                    </div>
                </div>

            </div>
        </div>

    </section>
</template>

<style lang="scss" scoped>

.ingredients-container {
    padding: 20px 0;
}

.table-wrapper {
    border: 1px solid $primary-color-700;
    border-radius: 10px; 
    overflow: hidden;   
    background-color: $neutral-color-white;
}

.table-header {
    background-color: $primary-color-700;
    display: grid;
    grid-template-columns: 1.2fr 1fr 2fr; // 調整比例：食材/份量/備註
    padding: 10px 0;
    
    .cell {
        color: $neutral-color-white;
        text-align: center;

        p.p-p2 {
            margin: 0;
        }
    }
}

.table-body {
    .table-row {
        display: grid;
        grid-template-columns: 1.2fr 1fr 2fr;
        padding: 10px 0;
        border-bottom: 0px; // 圖片中行與行之間沒有線

        .cell {
            display: flex;
            align-items: center;

            &.name {
                padding-left: 30px; // 第一欄左側縮排
            }

            &.amount {
                justify-content: flex-start; // 份量靠左對齊
            }

        }
    }
}

.servings-hint {
    margin-top: 12px;
    font-size: 12px;
    color: #888;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 5px;

    .info-icon {
        width: 14px;
        height: 14px;
    }
}
</style>