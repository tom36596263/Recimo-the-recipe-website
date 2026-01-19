<script setup>
import { ref } from 'vue';

const props = defineProps({
    modelValue: Boolean
});

const emit = defineEmits(['update:modelValue', 'apply']);

// 1. 資料狀態
const userData = ref({
    gender: 'female',
    age: 25,
    height: 170,
    weight: 65,
    activity: '1.2',
    goal: '0'
});

const calculatedResult = ref(null);

const handleClose = () => {
    emit('update:modelValue', false);
};

// 2. 計算邏輯
const handleCalculate = () => {
    const { gender, age, height, weight, activity, goal } = userData.value;
    let bmr = (gender === 'male')
        ? (10 * weight + 6.25 * height - 5 * age + 5)
        : (10 * weight + 6.25 * height - 5 * age - 161);

    const total = (bmr * Number(activity)) + Number(goal);
    calculatedResult.value = Math.round(total);
};

const handleApply = () => {
    emit('apply', calculatedResult.value);
    handleClose();
};
</script>

<template>
    <Teleport to="body">
        <div v-if="modelValue" class="black-mask" @click.self="handleClose">
            <div class="modal-card">
                <button class="close-x" @click="handleClose">×</button>

                <div class="form-container">
                    <div class="modal-header">
                        <div class="modal-title zh-h4-bold">計算我的專屬能量配額 ~</div>
                        <div class="green-divider"></div>
                    </div>

                    <div class="advice-text p-p2">
                        想維持好體態，不需要盲目少吃。<br>
                        這份計畫結合了你的基礎代謝 (BMR) 與活動量，為你算出精準的『能量配額』。
                    </div>

                    <div class="calculator-fields">
                        <div class="row">
                            <div class="field-item">
                                <span class="label">性別：</span>
                                <div class="radio-group">
                                    <label><input type="radio" v-model="userData.gender" value="female"> 女</label>
                                    <label><input type="radio" v-model="userData.gender" value="male"> 男</label>
                                </div>
                            </div>
                            <div class="field-item">
                                <span class="label">年齡：</span>
                                <input type="number" v-model="userData.age" class="round-input">
                            </div>
                            <div class="field-item">
                                <span class="label">身高：</span>
                                <input type="number" v-model="userData.height" class="round-input">
                            </div>
                            <div class="field-item">
                                <span class="label">體重：</span>
                                <input type="number" v-model="userData.weight" class="round-input">
                            </div>
                        </div>

                        <div class="row mt-15">
                            <div class="field-item flex-1">
                                <span class="label">活動等級：</span>
                                <div class="select-wrapper">
                                    <select v-model="userData.activity" class="round-select">
                                        <option value="1.2">久坐 (幾乎不運動)</option>
                                        <option value="1.375">輕度 (每週 1-3 天)</option>
                                        <option value="1.55">中度 (每週 3-5 天)</option>
                                        <option value="1.725">高度 (每週 6-7 天)</option>
                                    </select>
                                </div>
                            </div>
                            <div class="field-item flex-1">
                                <span class="label">期望達成目標：</span>
                                <div class="select-wrapper">
                                    <select v-model="userData.goal" class="round-select">
                                        <option value="0">維持體重</option>
                                        <option value="-400">減重</option>
                                        <option value="300">增肌</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <div class="btn-row">
                            <BaseBtn title="開始計算" variant="outline" height="40" width="50%" @click="handleCalculate">
                            </BaseBtn>
                        </div>
                    </div>
                </div>

                <div class="result-section" v-if="calculatedResult">
                    <div class="result-content">
                        <p class="res-label">建議熱量：</p>
                        <h2 class="res-value">{{ calculatedResult }} <span class="unit">kcal</span></h2>

                        <BaseBtn title="採用建議" width="50%" height="40" @click="handleApply" />
                    </div>
                </div>
            </div>
        </div>
    </Teleport>
</template>

<style scoped lang="scss">
/* --- 基礎遮罩與卡片 --- */
.black-mask {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.4);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1000;
}

.modal-card {
    background: #fff;
    width: auto;
    max-width: 600px;
    height: auto;
    border-radius: 30px;
    position: relative;
    overflow: hidden;
    -webkit-mask-image: -webkit-radial-gradient(white, black);
    box-shadow: 0 15px 50px rgba(0, 0, 0, 0.15);
    display: flex;
    flex-direction: column;
}

.close-x {
    position: absolute;
    top: 20px;
    right: 25px;
    background: none;
    border: none;
    font-size: 28px;
    color: $neutral-color-400;
    cursor: pointer;
    z-index: 10;
}

/* --- 表單內容區 --- */
.form-container {
    padding: 45px 50px 30px 50px;
    flex: 1;
}

.modal-header {
    margin-bottom: 20px;

    .modal-title {
        color: $primary-color-700;
        margin-bottom: 10px;
    }

    .green-divider {
        height: 1.5px;
        background: $primary-color-400;
        width: 100%;
    }
}

.advice-text {
    color: $neutral-color-800;
    margin-bottom: 30px;
    line-height: 1.7;
}

.calculator-fields {
    .row {
        display: flex;
        align-items: center;
        gap: 15px;
    }

    .mt-15 {
        margin-top: 15px;
    }

    .flex-1 {
        flex: 1;
    }

    .field-item {
        display: flex;
        align-items: center;
        gap: 8px;

        .label {
            font-size: 14px;
            color: $neutral-color-800;
            font-weight: 500;
            white-space: nowrap;
        }
    }

    .radio-group {
        display: flex;
        gap: 12px;

        label {
            display: flex;
            align-items: center;
            gap: 4px;
            cursor: pointer;
            font-size: 14px;
        }
    }

    .round-input {
        width: 75px;
        height: 38px;
        border-radius: 15px;
        border: 1px solid $neutral-color-400;
        text-align: center;
        outline: none;

        &:focus {
            border-color: $primary-color-700;
        }
    }

    .select-wrapper {
        flex: 1;
        position: relative;

        &::after {
            content: '▼';
            font-size: 10px;
            color: $neutral-color-400;
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            pointer-events: none;
        }
    }

    .round-select {
        width: 100%;
        height: 42px;
        border-radius: 15px;
        border: 1px solid $neutral-color-400;
        padding: 0 30px 0 15px;
        outline: none;
        appearance: none;
        background: #fff;
        cursor: pointer;
        font-size: 14px;

        &:focus {
            border-color: $primary-color-700;
        }
    }

    .btn-row {
        display: flex;
        justify-content: center;
        margin-top: 25px;
    }
}

/* --- 結果顯示區 --- */
.result-section {
    width: 100%;
    height: 240px;
    position: relative;
    flex-shrink: 0;
    margin-bottom: -1px;
}

.result-content {
    position: relative;
    z-index: 5;
    width: 100%;
    height: 105%;
    background-image: url('@/assets/images/recipe/cam.jpg');
    background-size: cover;
    background-position: center;
    border-radius: 0 0 30px 30px;
    background-blend-mode: multiply;
    background-color: rgba(0, 0, 0, 0.45);

    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    color: #fff;

    .res-label {
        font-size: 18px;
        margin-bottom: 8px;
        font-weight: 300;
    }

    .res-value {
        font-size: 56px;
        font-weight: 700;
        margin-bottom: 20px;

        .unit {
            font-size: 22px;
            margin-left: 8px;
            font-weight: 400;
        }
    }
}

/* =========================
   RWD - Mobile Only
   不影響 desktop
   ========================= */
@media (max-width: 480px) {
    .modal-card {
        width: calc(100% - 24px);
        max-width: none;
        border-radius: 20px;
    }

    .form-container {
        padding: 28px 20px 24px;
    }

    .advice-text {
        font-size: 14px;
        margin-bottom: 22px;
    }

    .calculator-fields {
        .row {
            flex-direction: column;
            align-items: stretch;
            gap: 12px;
        }

        .field-item {
            width: 100%;
            justify-content: space-between;
        }

        .round-input {
            width: 100%;
            text-align: left;
            padding-left: 14px;
        }

        .radio-group {
            justify-content: flex-end;
        }
    }

    .result-section {
        height: 200px;
    }

    .result-content {
        border-radius: 0 0 20px 20px;

        .res-value {
            font-size: 44px;
        }
    }
}
</style>