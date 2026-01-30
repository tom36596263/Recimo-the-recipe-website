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

                    <div class="amount-group p-p3">
                        <div class="amount-input-wrapper">
                            <input v-model="ing.amount" type="text" inputmode="decimal"
                                class="custom-input amount-field p-p3" :class="{ 'error-shake': ing.isInvalid }"
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
@import "@/assets/scss/abstracts/_color.scss";

.ingredient-editor-container {
    width: 100%;
    margin-bottom: 30px;
}

.section-header {
    margin-bottom: 24px;

    .header-title {
        color: $primary-color-800;
        padding-bottom: 12px;
        border-bottom: 2px solid $primary-color-400;
        margin: 0;
    }
}

.ingredient-list {
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.ingredient-item {
    position: relative;
    background: $neutral-color-white;
    border: 1px solid $neutral-color-400;
    border-radius: 12px;
    padding: 10px 20px;
    transition: all 0.3s ease;
    overflow: hidden;

    // ✨ 左側裝飾條：增加專業感
    &::before {
        content: '';
        position: absolute;
        left: 0;
        top: 0;
        bottom: 0;
        width: 5px;
        background: $primary-color-700;
        opacity: 0.7;
    }

    &:hover {
        border-color: $primary-color-700;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
    }

    &.is-view {
        background: $primary-color-100;
        border-color: transparent;

        &::before {
            background: $neutral-color-400;
        }
    }

    // ❌ 叉叉按鈕：維持妳原本的純粹設計
    .remove-btn {
        position: absolute;
        top: 10px;
        right: 12px;
        background: none;
        border: none;
        color: $secondary-color-danger-400;
        cursor: pointer;
        z-index: 2;
        font-size: 16px; // 稍微調整大小方便點擊

        &:hover {
            color: $secondary-color-danger-700;
        }
    }
}

.input-row {
    padding: 4px 0;
    display: flex;
    align-items: center;

    .custom-input {
        border: none;
        outline: none;
        background: transparent;
        color: $neutral-color-800;
        width: 100%;

        &::placeholder {
            color: $neutral-color-400;
        }
    }
}

// 食材標題
.name-field {
    font-weight: bold;
    font-size: 1.1rem !important;
    color: $neutral-color-800 !important;
}

.amount-group {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    margin: 8px 0;

    .amount-input-wrapper {
        flex: 1;
        max-width: 300px;
        width: auto;

        .amount-field {
            font-weight: 500;
            font-size: 0.8rem;
            border-bottom: 1.5px solid $neutral-color-100;

            &::placeholder {
                font-size: 0.9rem;
                color: $neutral-color-400;
            }

            &:focus {
                border-bottom-color: $primary-color-400;
            }
        }
    }


    .unit-box {
        padding: 4px 12px;
        display: flex;
        align-items: center;
        color: $neutral-color-700;
        font-size: 14px;
        white-space: nowrap;

        .label {
            margin-right: 2px;
        }

        .unit-field {
            width: 40px;
            font-weight: 600;
            color: $neutral-color-800;
        }
    }
}

// 備註區域
.note-row {
    margin-top: 12px;
    padding: 8px 12px;
    background: $neutral-color-100;
    border-radius: 8px;
    border-top: none;

    .note-field {
        color: $neutral-color-700 !important;
        font-size: 14px !important;
        line-height: 1.5;
        resize: none;
        min-height: 40px;
        padding: 0;

        &::placeholder {
            color: $neutral-color-400;
        }
    }
}



// 錯誤動畫
.error-shake {
    color: $secondary-color-danger-700 !important;
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

// 新增按鈕 
.add-action-wrapper {
    margin-top: 24px;

    .add-ingredient-btn {
        width: 100%;
        height: 48px;
        background: $neutral-color-white;
        border: 1px solid $primary-color-400;
        border-radius: 12px;
        color: $primary-color-700;
        cursor: pointer;
        transition: all 0.2s ease;

        &:hover {
            background: $primary-color-100;
            color: $primary-color-800;
            border-color: $primary-color-700;
        }
    }
}
</style>