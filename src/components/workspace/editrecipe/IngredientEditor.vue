<script setup>
import { ref } from 'vue';
import IngredientSearchModal from './modals/IngredientSearchModal.vue';

const props = defineProps({
    ingredients: { type: Array, required: true },
    isEditing: { type: Boolean, default: false }
});

const showSearchModal = ref(false);

const openSearchModal = () => {
    showSearchModal.value = true;
};

const validateAmount = (item) => {
    if (/[^\d.]/.test(item.amount)) {
        item.isInvalid = true;
        setTimeout(() => { item.isInvalid = false; }, 1500);
    }
    let val = item.amount.replace(/[^\d.]/g, "");
    const dotCount = (val.match(/\./g) || []).length;
    if (dotCount > 1) {
        val = val.slice(0, val.lastIndexOf("."));
    }
    item.amount = val;
};

const handleAddMultiple = (items) => {
    items.forEach(item => {
        const isDuplicate = props.ingredients.some(ing => ing.name === item.ingredient_name);
        if (!isDuplicate) {
            props.ingredients.push({
                id: 'id' + Date.now() + Math.floor(Math.random() * 1000),
                name: item.ingredient_name,
                amount: '',
                unit: item.unit_name || '',
                note: '',
                fromDB: true,
                isInvalid: false,
                kcal_per_100g: item.kcal_per_100g || 0,
                protein_per_100g: item.protein_per_100g || 0,
                fat_per_100g: item.fat_per_100g || 0,
                carbs_per_100g: item.carbs_per_100g || 0
            });
        }
    });
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
                    <input v-model="ing.name" type="text" class="custom-input name-field p-p1" placeholder="食材名稱"
                        :readonly="!isEditing || ing.fromDB" />
                </div>

                <div class="input-row split-row">
                    <div class="amount-group p-p2">
                        <div class="amount-input-wrapper">
                            <input v-model="ing.amount" type="text" inputmode="decimal"
                                class="custom-input amount-field p-p2" :class="{ 'error-shake': ing.isInvalid }"
                                placeholder="分量" :readonly="!isEditing" @input="validateAmount(ing)" />
                            <span v-if="ing.isInvalid" class="number-hint">僅限數字</span>
                        </div>

                        <div class="unit-box">
                            <span class="label">單位：</span>
                            <input v-model="ing.unit" type="text" class="custom-input unit-field p-p2" placeholder="顆"
                                readonly tabindex="-1" />
                        </div>
                    </div>
                </div>

                <div class="input-row note-row">
                    <textarea v-model="ing.note" class="custom-input note-field p-p3" placeholder="新增備註 (限30字)..."
                        :readonly="!isEditing" maxlength="30" rows="2"></textarea>
                </div>
            </div>
        </div>

        <div v-if="isEditing" class="add-action-wrapper">
            <button class="add-ingredient-btn p-p2" @click="openSearchModal">+ 新增食材</button>
        </div>

        <IngredientSearchModal v-model="showSearchModal" :selectedList="ingredients"
            @add-multiple="handleAddMultiple" />
    </section>
</template>

<style lang="scss" scoped>
/* 其他樣式保持不變 */
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

.name-field {
    pointer-events: none;
}

.ingredient-item {
    position: relative;
    background: $neutral-color-white;
    border: 0.5px solid $neutral-color-400;
    border-radius: 12px;
    padding: 12px 16px;
    transition: all 0.2s ease;

    &:hover {
        border-color: $primary-color-400;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.02);
    }

    &.is-view {
        border-color: transparent;
        background: $primary-color-100;
        padding: 8px 12px;
    }

    .remove-btn {
        position: absolute;
        top: 10px;
        right: 12px;
        background: none;
        border: none;
        color: $secondary-color-danger-400;
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
            pointer-events: none; // 核心修正：讓 readonly 徹底無法點擊
        }
    }
}

.note-row {
    align-items: flex-start;
    padding-top: 8px;

    .note-field {
        color: $neutral-color-700 !important;
        resize: none;
        height: 52px;
        line-height: 1.4;
        font-family: inherit;
        overflow: hidden;
        word-break: break-all;
    }
}

.amount-group {
    display: flex;
    align-items: center;
    width: 100%;

    .amount-input-wrapper {
        flex: 1;
        position: relative;

        .amount-field {
            border-bottom: 1px solid transparent;

            &:focus {
                border-bottom-color: $primary-color-400;
            }
        }

        .number-hint {
            position: absolute;
            left: 0;
            bottom: -12px;
            font-size: 10px;
            color: $secondary-color-danger-400;
            pointer-events: none;
        }
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

            // 核心修正：解決單獨針對 unit-field 的唯讀樣式
            &:read-only {
                border-bottom: none !important;
            }
        }
    }
}

.error-shake {
    color: $secondary-color-danger-400 !important;
    animation: shake 0.4s ease-in-out;
}

@keyframes shake {

    0%,
    100% {
        transform: translateX(0);
    }

    25% {
        transform: translateX(-4px);
    }

    75% {
        transform: translateX(4px);
    }
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