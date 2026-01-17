<script setup>

const props = defineProps({
    ingredients: {
        type: Array,
        required: true
    },
    isEditing: {
        type: Boolean,
        default: false
    }
});

const addItem = () => {
    props.ingredients.push({
        id: 'id' + Date.now(),
        name: '',
        amount: ''
    });
};

const removeItem = (id) => {
    const index = props.ingredients.findIndex(i => i.id === id);
    if (index !== -1) props.ingredients.splice(index, 1);
};
</script>

<template>
    <section class="ingredient-section">

    <!-- 標題 -->
    <header class="ingredient-header">
        <h2 class="zh-h4-bold">食材列表</h2>

    </header>

    <!-- 食材清單 -->
    <div class="ingredient-list">

        <article
            v-for="ing in ingredients"
            :key="ing.id"
            class="ingredient-card"
        >
            <!-- 編輯模式 -->
            <template v-if="isEditing">
            <input
                v-model="ing.name"
                type="text"
                class="ingredient-name-input zh-h5"
                placeholder="食材名稱"
            />

            <input
                v-model="ing.amount"
                type="text"
                class="ingredient-amount-input p-p3"
                placeholder="份量"
            />

            <button
                class="remove-btn p-p3"
                @click="removeItem(ing.id)"
                aria-label="移除食材"
            >
                ✕
            </button>
            </template>

            <!-- 顯示模式 -->
            <template v-else>
            <div class="ingredient-name zh-h5">
                {{ ing.name || '(未命名)' }}
            </div>
            <div class="ingredient-amount p-p3">
                {{ ing.amount }}
            </div>
            </template>
        </article>

        </div>

    <BaseBtn 
        title="+ 新增食材"
        variant="outline" 
        height="40" 
        class="w-auto"
        @click="addItem" 
    />



    </section>
    </template>

    

    <style lang="scss">

        h2 {
            height: 40px;
            color: $primary-color-700;
            border-bottom: 1.5px solid $primary-color-700;
        }
        

    /* ========= 容器 ========= */

    .ingredient-section {
        margin: 10px;
        display: flex;
        flex-direction: column;
        gap: 20px;
    }

    /* ========= 卡片 ========= */

    .ingredient-card {


        position: relative;
        background: $neutral-color-white;
        border-radius: 16px;

        padding: 16px;
        border: 1px solid $neutral-color-400;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.04);

        display: flex;
        flex-direction: column;
        gap: 6px;
    }

    .ingredient-list {
        display: flex;
        flex-direction: column;
        gap: 20px; /* 2. 這裡加大：卡片與卡片之間的垂直距離 */
    }  

    /* ========= 輸入欄 ========= */

    .ingredient-name-input,
    .ingredient-amount-input {
        width: 100%;
        border: none;
        border-bottom: 1px solid $neutral-color-100;
        outline: none;
        padding: 4px 0;

        &:focus {
            border-bottom-color: $primary-color-700;
        }
}

/* ========= 移除按鈕 ========= */

.remove-btn {
    position: absolute;
    top: 12px;
    right: 12px;
    border: none;
    background: none;
    cursor: pointer;
    color: $secondary-color-danger-400;

    &:hover {
        color: $secondary-color-danger-700;
    }
}


</style>
