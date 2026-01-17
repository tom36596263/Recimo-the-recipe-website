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
@import '@/assets/scss/abstracts/_color.scss';

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

.table-header {
    display: flex;
    background-color: $primary-color-700; 
    padding: 12px 20px;

    .cell {
        color: $neutral-color-white; 
        font-weight: 500;
        margin: 0;
        flex: 1;

        
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
    padding: 8px 0; 

    .table-row {
        display: flex;
        padding: 12px 20px;
        transition: background-color 0.2s;

        &:hover {
            background-color: $neutral-color-100;
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
                color: $neutral-color-black;
            }

            .p-p2 {
                margin: 0;
                line-height: 1.5;
                
            }
        }
    }
}


@media screen and (max-width: 576px) {

    .table-header,
    .table-row {
        padding: 10px 12px;
    }
}
</style>