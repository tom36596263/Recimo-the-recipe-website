<script setup>
import { ref } from 'vue';
import IngredientSearchModal from './modals/IngredientSearchModal.vue';

const props = defineProps({
    ingredients: { type: Array, required: true },
    isEditing: { type: Boolean, default: false },
    // 🎨 接收來自父組件的模式判斷
    isAdaptMode: { type: Boolean, default: false }
});

// 定義顏色循環邏輯
const toggleIngredientColor = (index) => {
    // 只有在「編輯中」且「改編模式」下才能換顏色
    if (!props.isEditing || !props.isAdaptMode) return;

    const colors = [null, 'tag-green', 'tag-orange', 'tag-blue'];
    const currentColor = props.ingredients[index].color_tag || null;
    const nextIndex = (colors.indexOf(currentColor) + 1) % colors.length;

    props.ingredients[index].color_tag = colors[nextIndex];
};

const emit = defineEmits(['update:ingredients']);
const updateIngredient = (index, field, value) => {
    const newIngredients = [...props.ingredients];
    newIngredients[index][field] = value;
    emit('update:ingredients', newIngredients);
};
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
    const newIngredients = [...props.ingredients];
    items.forEach(item => {
        // 1. 檢查是否已經存在（避免重複新增）
        const isDuplicate = props.ingredients.some(ing => ing.name === item.ingredient_name);

        if (!isDuplicate) {
            newIngredients.push({
                id: item.ingredient_id || ('id' + Date.now() + Math.floor(Math.random() * 1000)),
                name: item.ingredient_name,
                amount: '',
                unit: item.unit_name || '',
                note: '',
                fromDB: true, 
                isInvalid: false,
                color_tag: null,
                kcal_per_100g: item.kcal_per_100g || 0,
                protein_per_100g: item.protein_per_100g || 0,
                fat_per_100g: item.fat_per_100g || 0,
                carbs_per_100g: item.carbs_per_100g || 0
            });
        }
        emit('update:ingredients', newIngredients);
    });
};
const removeItem = (id) => {
    // 1. 建立一個全新的陣列，排除掉該 id 的項目
    // 🏆 這樣做才符合 Vue 的單向數據流 (One-Way Data Flow)
    const newIngredients = props.ingredients.filter(i => i.id !== id);

    // 2. 透過 emit 通知父組件：新的清單長這樣，請幫我更新
    emit('update:ingredients', newIngredients);
};
// const removeItem = (id) => {
//     const index = props.ingredients.findIndex(i => i.id === id);
//     if (index !== -1) props.ingredients.splice(index, 1);
// };
</script>

<template>
    <section class="ingredient-editor-container">
        <div class="section-header">
            <h2 class="header-title zh-h4-bold">食材列表</h2>

            <!-- <div v-if="isEditing && isAdaptMode" class="color-legend p-p3">
                <span class="legend-item"><i class="dot green"></i>新增</span>
                <span class="legend-item"><i class="dot orange"></i>調整</span>
                <span class="legend-item"><i class="dot blue"></i>替換</span>
                <span class="legend-hint">（點擊左側裝飾條切換標記）</span>
            </div> -->
        </div>

        <div class="ingredient-list">
            <div v-for="(ing, index) in ingredients" :key="ing.id" class="ingredient-item" :class="[
                { 'is-view': !isEditing },
                // 只有改編模式才套用 CSS 顏色類別
                isAdaptMode ? ing.color_tag : ''
            ]">
                <div v-if="isEditing && isAdaptMode" class="color-tag-trigger" @click="toggleIngredientColor(index)"
                    title="點擊切換標記顏色">
                    <i-material-symbols-edit-outline-rounded class="edit-hint-icon" />
                </div>

                <button v-if="isEditing" class="remove-btn" @click="removeItem(ing.id)">✕</button>

                <div class="input-row main-row">
                    <input v-model="ing.name" type="text" class="custom-input name-field p-p1" placeholder="食材名稱"
                        :readonly="!isEditing || ing.fromDB"
                        @input="updateIngredient(index, 'name', $event.target.value)" />

                    <div class="amount-group p-p3">
                        <div class="amount-input-wrapper">
                            <input v-model="ing.amount" type="text" inputmode="decimal"
                                class="custom-input amount-field p-p3" :class="{ 'error-shake': ing.isInvalid }"
                                placeholder="分量" :readonly="!isEditing" 
                                @input="(e) => {
                                    updateIngredient(index, 'amount', e.target.value);
                                    validateAmount(ing);}" />
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
                        :readonly="!isEditing" maxlength="30" rows="2"
                        @input="updateIngredient(index, 'note', $event.target.value)"></textarea>
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

// 🎨 顏色圖例樣式
.color-legend {
    display: flex;
    align-items: center;
    gap: 12px;
    color: $neutral-color-700;
    padding: 8px 0;

    .legend-item {
        display: flex;
        align-items: center;
        gap: 6px;
        font-weight: 500;

        .dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            display: inline-block;

            &.green {
                background-color: #74D09C;
            }

            &.orange {
                background-color: #FFCB82;
            }

            &.blue {
                background-color: #90C6FF;
            }
        }
    }

    .legend-hint {
        font-size: 12px;
        color: $neutral-color-400;
        margin-left: 8px;
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
    padding: 10px 20px 10px 30px;
    transition: all 0.3s ease;
    overflow: hidden;

    &::before {
        content: '';
        position: absolute;
        left: 0;
        top: 0;
        bottom: 0;
        width: 6px;
        background: $primary-color-700;
        opacity: 0.7;
        z-index: 1;
    }

    &.tag-green {
        border-color: #74D09C;
        background: rgba(116, 208, 156, 0.05);

        &::before {
            background: #74D09C;
            opacity: 1;
        }
    }

    &.tag-orange {
        border-color: #FFCB82;
        background: rgba(255, 203, 130, 0.05);

        &::before {
            background: #FFCB82;
            opacity: 1;
        }
    }

    &.tag-blue {
        border-color: #90C6FF;
        background: rgba(144, 198, 255, 0.05);

        &::before {
            background: #90C6FF;
            opacity: 1;
        }
    }

    &:hover {
        border-color: $primary-color-700;
    }

    &.is-view {
        background: $primary-color-100;
        border-color: transparent;

        &::before {
            background: $neutral-color-400;
        }
    }

    .remove-btn {
        position: absolute;
        top: 10px;
        right: 12px;
        background: none;
        border: none;
        color: $secondary-color-danger-400;
        cursor: pointer;
        z-index: 5;
        font-size: 18px;

        &:hover {
            color: $secondary-color-danger-700;
        }
    }
}

.color-tag-trigger {
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    width: 30px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    z-index: 10;

    .edit-hint-icon {
        font-size: 14px;
        color: $neutral-color-white;
        opacity: 0;
        transition: opacity 0.2s;
    }

    &:hover .edit-hint-icon {
        opacity: 1;
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

.name-field {
    font-weight: bold;
    font-size: 1.1rem !important;
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

        .amount-field {
            font-weight: 500;
            font-size: 0.8rem;
            border-bottom: 1.5px solid $neutral-color-100;

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

        .unit-field {
            width: 40px;
            font-weight: 600;
            color: $neutral-color-800;
        }
    }
}

.note-row {
    margin-top: 12px;
    padding: 8px 12px;
    background: $neutral-color-100;
    border-radius: 8px;

    .note-field {
        color: $neutral-color-700 !important;
        font-size: 14px !important;
        resize: none;
        min-height: 40px;
    }
}

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
            border-color: $primary-color-700;
        }
    }
}
</style>