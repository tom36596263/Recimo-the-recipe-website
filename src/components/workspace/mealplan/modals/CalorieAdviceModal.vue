<script setup>
import { ref } from 'vue';

const props = defineProps({
    modelValue: Boolean
});

const emit = defineEmits(['update:modelValue', 'apply']);

const userData = ref({
    gender: 'female', // 性別可以留一個預設，因為這必選其一
    age: null,
    height: null,
    weight: null,
    activity: '1.2',
    goal: '0'
});

const calculatedResult = ref(null);
const isSubmitted = ref(false); // 用於驗證狀態顯示

const handleClose = () => {
    emit('update:modelValue', false);
};

const handleCalculate = () => {
    isSubmitted.value = true;
    const { gender, age, height, weight, activity, goal } = userData.value;

    // 必填檢查
    if (!age || !height || !weight) {
        // 可以在這裡加入一個簡單的 toast 提示
        return;
    }

    // 數值合理性
    if (age < 1 || age > 110 || height < 50 || weight < 10) {
        alert("請輸入合理的身體數據");
        return;
    }

    // 執行 BMR 計算
    let bmr = (gender === 'male')
        ? (10 * Number(weight) + 6.25 * Number(height) - 5 * Number(age) + 5)
        : (10 * Number(weight) + 6.25 * Number(height) - 5 * Number(age) - 161);

    //計算總消耗量 (TDEE) 與 目標調整
    const total = (bmr * Number(activity)) + Number(goal);

    // 確保熱量不會低於基礎生存需求
    calculatedResult.value = Math.max(1000, Math.round(total));
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
                            <div class="field-item gender-field">
                                <span class="label">性別：</span>
                                <div class="radio-list horizontal">
                                    <label class="radio-item">
                                        <input type="radio" v-model="userData.gender" value="female"> 女
                                    </label>
                                    <label class="radio-item">
                                        <input type="radio" v-model="userData.gender" value="male"> 男
                                    </label>
                                </div>
                            </div>
                            <div class="field-item">
                                <span class="label">年齡：</span>
                                <input type="number" v-model="userData.age" class="form-input p-p1"
                                    :class="(isSubmitted && !userData.age) ? 'is-error' : 'is-success'"
                                    placeholder="年齡" />
                            </div>
                            <div class="field-item">
                                <span class="label">身高：</span>
                                <input type="number" v-model="userData.height" class="form-input p-p1"
                                    :class="(isSubmitted && !userData.height) ? 'is-error' : 'is-success'"
                                    placeholder="CM" />
                            </div>
                            <div class="field-item">
                                <span class="label">體重：</span>
                                <input type="number" v-model="userData.weight" class="form-input p-p1"
                                    :class="(isSubmitted && !userData.weight) ? 'is-error' : 'is-success'"
                                    placeholder="KG" />
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
                        <BaseBtn title="採用建議" width="40%" height="40" @click="handleApply" />
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
    background: $neutral-color-white;
    width: 95%;
    max-width: 650px;
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
    transition: color 0.2s ease;

    &:hover {
            color: $neutral-color-black;
        }
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
        font-size: clamp(18px, 4.5vw, 24px);
        line-height: 1.4;
        white-space: normal;
        word-break: break-all;
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
    font-size: clamp(13px, 3.2vw, 16px);
    white-space: normal;
    word-break: break-all;
}

.calculator-fields {
    .row {
        display: flex;
        align-items: center;
        gap: 20px;
        flex-wrap: nowrap;
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
        flex-shrink: 0;

        .label {
            font-size: 14px;
            color: $neutral-color-800;
            font-weight: 500;
            white-space: nowrap;
        }

        .form-input {
            width: 70px;
        }
    }

    .radio-list {
        display: flex;
        gap: 12px;

        &.horizontal {
            flex-direction: row;
            align-items: center;
        }

        .radio-item {
            display: flex;
            align-items: center;
            gap: 6px;
            cursor: pointer;
            font-size: 14px;

            input {
                accent-color: $primary-color-700;
                width: 18px;
                height: 18px;
            }
        }
    }

    .form-input {
        height: 38px;
        border-radius: 12px;
        border: 1px solid $neutral-color-400;
        text-align: center;
        outline: none;
        transition: border-color 0.2s;

        &.is-success {
            border-color: $neutral-color-400;

            &:focus {
                border-color: $primary-color-700;
            }
        }

        &.is-error {
            border-color: $secondary-color-danger-400;
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
        background: $neutral-color-white;
        font-size: 14px;
        appearance: none;

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
}

.result-content {
    width: 110%;
    margin-left: -5%;
    height: 110%;
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
    color: $neutral-color-white;

    .res-label {
        font-size: 18px;
        margin-bottom: 8px;
    }

    .res-value {
        font-size: 56px;
        font-weight: 700;
        margin-bottom: 20px;

        .unit {
            font-size: 22px;
            margin-left: 8px;
        }
    }
}

/* =========================
   RWD - Mobile
   ========================= */
@media (max-width: 580px) {
    .modal-card {
        width: 92%;
        border-radius: 24px;
    }

    .form-container {
        padding: 35px 25px 25px;
    }

    .calculator-fields {
        .row {
            flex-direction: column;
            gap: 15px;
            flex-wrap: wrap;
        }

        .field-item {
            width: 100%;
            /* 改為靠左排列，標籤與輸入框分站兩側 */
            justify-content: flex-start;
            flex-shrink: 1;

            /* 輸入框佔滿剩餘空間 */
            .form-input {
                flex: 1;
                width: auto !important;
                text-align: left;
                padding-left: 15px;
            }

            /* 性別靠左，與標籤保持間距 */
            &.gender-field {
                justify-content: flex-start;
                gap: 15px;
                padding: 5px 0;
            }
        }

        /* 下拉選單佔滿剩餘空間 */
        .select-wrapper {
            flex: 1;
            width: auto;
        }

    }

    .result-section {
        height: 220px;
    }

    .result-content {
        border-radius: 0 0 24px 24px;

        .res-value {
            font-size: 48px;
        }
    }
}
</style>