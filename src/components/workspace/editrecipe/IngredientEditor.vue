<script setup>
const props = defineProps({
    ingredients: { type: Array, required: true },
    isEditing: { type: Boolean, default: false }
});

const addItem = () => {
    props.ingredients.push({ id: 'id' + Date.now(), name: '', amount: '', unit: '', note: '' });
};

const removeItem = (id) => {
    const index = props.ingredients.findIndex(i => i.id === id);
    if (index !== -1) props.ingredients.splice(index, 1);
};
</script>

<template>
    <section class="ingredient-editor-container">
        <div class="section-header">
            <h2 class="header-title zh-h4-bold">食材列表</h2>
        </div>

        <div class="ingredient-list">
            <div v-for="ing in ingredients" :key="ing.id" class="ingredient-item" :class="{ 'is-view': !isEditing }">
                <button v-if="isEditing" class="remove-btn" @click="removeItem(ing.id)">✕</button>

                <div class="input-row main-row">
                    <input v-model="ing.name" type="text" class="custom-input name-field p-p1"
                        placeholder="食材名稱 (如: 雞蛋)" :readonly="!isEditing" />
                </div>

                <div class="input-row split-row">
                    <div class="amount-group p-p2">
                        <input v-model="ing.amount" type="text" class="custom-input amount-field p-p2" placeholder="分量"
                            :readonly="!isEditing" />
                        <div class="unit-box">
                            <span class="label">單位：</span>
                            <input v-model="ing.unit" type="text" class="custom-input unit-field p-p2" placeholder="顆"
                                :readonly="!isEditing" />
                        </div>
                    </div>
                </div>

                <div class="input-row note-row">
                    <input v-model="ing.note" type="text" class="custom-input note-field p-p3"
                        placeholder="新增備註 (如: 需冷藏)..." :readonly="!isEditing" />
                </div>
            </div>
        </div>

        <div v-if="isEditing" class="add-action-wrapper">
            <button class="add-ingredient-btn p-p2" @click="addItem">+ 新增食材</button>
        </div>
    </section>
</template>

<style lang="scss" scoped>
/* 僅保留佈局、邊框、間距與顏色變數 */

.ingredient-editor-container {
    width: 100%;
    margin-bottom: 30px;
}

.section-header {
    margin-bottom: 24px;

    .header-title {
        color: $primary-color-800;
        padding-bottom: 12px;
        border-bottom: 1.5px solid $primary-color-400;
        margin: 0;
    }
}

.ingredient-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.ingredient-item {
    position: relative;
    background: $neutral-color-white;
    border: 1px solid $neutral-color-100;
    border-radius: 12px;
    padding: 12px 16px;
    transition: all 0.2s ease;

    &:hover {
        border-color: $primary-color-400;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.02);
    }

    &.is-view {
        border-color: transparent;
        background: $primary-color-100; // 使用主色 100 做為背景
        padding: 8px 12px;
    }

    .remove-btn {
        position: absolute;
        top: 10px;
        right: 12px;
        background: none;
        border: none;
        color: $secondary-color-danger-400; // 輔助色 danger
        cursor: pointer;
        z-index: 2;

        &:hover {
            color: $secondary-color-danger-700;
        }
    }
}

.input-row {
    border-bottom: 1px solid $neutral-color-100;
    padding: 6px 0;
    display: flex;
    align-items: center;

    &:last-child {
        border-bottom: none;
    }

    .custom-input {
        border: none;
        outline: none;
        background: transparent;
        color: $neutral-color-800;
        width: 100%;
        padding: 4px 0;

        &::placeholder {
            color: $neutral-color-400;
        }

        &:read-only {
            color: $neutral-color-black;
            cursor: default;
        }
    }
}

.main-row .name-field {
    color: $neutral-color-black;
}

.amount-group {
    display: flex;
    align-items: center;
    width: 100%;

    .amount-field {
        flex: 1;
    }

    .unit-box {
        display: flex;
        align-items: center;
        white-space: nowrap;
        color: $neutral-color-700;
        margin-left: 12px;

        .unit-field {
            width: 50px;
            text-align: left;
            border-bottom: 1px dashed $neutral-color-100;
        }
    }
}

.note-field {
    color: $neutral-color-700 !important;
}

.add-action-wrapper {
    margin-top: 20px;

    .add-ingredient-btn {
        width: 100%;
        height: 44px;
        background: $neutral-color-white;
        border: 1.5px solid $primary-color-400;
        border-radius: 10px;
        color: $primary-color-800;
        cursor: pointer;
        transition: all 0.2s;

        &:hover {
            background: $primary-color-100;
            transform: translateY(-1px);
        }
    }
}
</style>