<script setup>
import { ref } from 'vue';

const formData = ref({
    name: '',
    email: '',
    category: '',
    subject: '',
    content: ''
});

const categories = ['【R 幣與商城】', '【Recimo功能】', '【食譜與社群】', '【其他】'];

// 用來追蹤是否點擊過送出，開啟驗證狀態
const isSubmitted = ref(false);

// 驗證 Email 格式
const validateEmail = (email) => {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
};

// 驗證表單內容是否完整
const checkFormValid = () => {
    const { name, email, category, subject, content } = formData.value;
    return (
        name.trim() !== '' &&
        validateEmail(email) &&
        category !== '' &&
        subject.trim() !== '' &&
        content.trim() !== ''
    );
};

// 處理表單送出
const handleSave = () => {
    isSubmitted.value = true;

    if (formData.value.email !== '' && !validateEmail(formData.value.email)) {
        alert('電子信箱格式不正確，請重新檢查。');
        return;
    }

    // 檢查整體表單
    if (checkFormValid()) {
        alert('訊息已成功送出！我們會盡快回覆您。');
        formData.value = { name: '', email: '', category: '', subject: '', content: '' };
        isSubmitted.value = false;
    } else {
        alert('請填寫所有必填欄位。');
    }
};
</script>

<template>
    <div class="contact-section">
        <div class="main-title zh-h2">聯絡我們</div>

        <div class="form-card">
            <div class="form-grid">
                <div class="column">
                    <div class="field">
                        <label class="p-p1">姓名 <span class="required">*</span></label>
                        <div class="input-container">
                            <input v-model.trim="formData.name" class="form-input p-p1"
                                :class="(isSubmitted && !formData.name.trim()) ? 'is-error' : 'is-success'"
                                style="width: 100%" placeholder="請輸入姓名" />
                        </div>
                    </div>

                    <div class="field">
                        <label class="p-p1">電子信箱 <span class="required">*</span></label>
                        <div class="input-container">
                            <input v-model.trim="formData.email" type="email" class="form-input p-p1"
                                :class="(isSubmitted && (!formData.email || !validateEmail(formData.email))) ? 'is-error' : 'is-success'"
                                style="width: 100%" placeholder="請輸入電子信箱" />
                        </div>
                    </div>

                    <div class="field">
                        <label class="p-p1">問題分類 <span class="required">*</span></label>
                        <div class="input-container">
                            <div class="select-wrapper">
                                <select v-model="formData.category" class="form-input p-p1"
                                    :class="(isSubmitted && !formData.category) ? 'is-error' : 'is-success'"
                                    style="width: 100%">
                                    <option value="" disabled selected>請選擇問題分類</option>
                                    <option v-for="cat in categories" :key="cat" :value="cat">{{ cat }}</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="column">
                    <div class="field">
                        <label class="p-p1">問題名稱 <span class="required">*</span></label>
                        <div class="input-container">
                            <input v-model.trim="formData.subject" class="form-input p-p1"
                                :class="(isSubmitted && !formData.subject.trim()) ? 'is-error' : 'is-success'"
                                style="width: 100%" placeholder="請輸入問題名稱" />
                        </div>
                    </div>

                    <div class="field grow">
                        <label class="p-p1">問題內容 <span class="required">*</span></label>
                        <div class="input-container">
                            <textarea v-model.trim="formData.content" class="form-input p-p1 text-area"
                                :class="(isSubmitted && !formData.content.trim()) ? 'is-error' : 'is-success'"
                                style="width: 100%" placeholder="請輸入問題內容"></textarea>
                        </div>
                    </div>
                </div>
            </div>

            <div class="submit-area">
                <BaseBtn title="傳送" :width="180" @click="handleSave" />
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.required {
    color: $secondary-color-danger-700;
    margin-left: 4px;
}

.form-input {
    border: 1px solid $neutral-color-400;
    transition: all 0.3s ease;

    &:focus {
        border-color: $primary-color-400;
    }

    &.is-error {
        border-color: $secondary-color-danger-700 !important;
        background-color: $neutral-color-100;
    }
}

.contact-section {
    max-width: 1000px;
    margin: 40px auto;
    padding: 0 20px;

    .main-title {
        text-align: center;
        color: $primary-color-800;
        margin-bottom: 40px;
    }

    .form-card {
        border: 1px solid $neutral-color-700;
        border-radius: 12px;
        padding: 40px;
        background-color: $neutral-color-white;
        display: flex;
        flex-direction: column;
    }

    .form-grid {
        display: flex;
        gap: 60px;
        margin-bottom: 40px;

        .column {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 24px;
        }
    }

    .field {
        display: flex;
        flex-direction: column;
        gap: 10px;

        .input-container {
            width: 100%;

            .select-wrapper {
                position: relative;
                width: 100%;

                select {
                    appearance: none;
                    -webkit-appearance: none;
                    padding-right: 40px !important;
                    cursor: pointer;
                    background-color: $neutral-color-100;
                }

                &::after {
                    content: '';
                    position: absolute;
                    right: 15px;
                    top: 50%;
                    transform: translateY(-50%);
                    width: 12px;
                    height: 8px;
                    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 10 6'%3E%3Cpath d='M1 1l4 4 4-4' stroke='%234a7c59' stroke-width='1.5' fill='none' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E");
                    background-repeat: no-repeat;
                    background-size: contain;
                    pointer-events: none;
                }
            }

            .text-area {
                height: 220px;
                resize: none;
                display: block;
            }
        }
    }

    .submit-area {
        display: flex;
        justify-content: center;
    }

    @media (max-width: 768px) {
        .form-card {
            padding: 20px;
        }

        .form-grid {
            flex-direction: column;
            gap: 24px;
            margin-bottom: 24px;
        }
    }
}
</style>