<script setup>
import { ref, watch } from 'vue';
import axios from 'axios'; // 1. 引入 axios
// 引用 Pinia Store (權限狀態管理)
import { useAuthStore } from '@/stores/authStore';
const authStore = useAuthStore();

const formData = ref({
    name: '',
    email: '',
    category: '',
    subject: '',
    content: ''
});

// ==========================================
// ★ 新增：自動帶入會員資料邏輯
// ==========================================
// 使用 watch 監聽 authStore.user
// immediate: true 代表元件一載入馬上執行一次，不用等資料變動
watch(() => authStore.user, (user) => {
    if (user) {
        // 如果有登入，嘗試抓取 store 裡的資料填入
        // 這裡會依照你 authStore 正規化後的欄位名稱 (name, email)
        formData.value.name = user.user_name || user.name || '';
        formData.value.email = user.user_email || user.email || '';
    }
}, { immediate: true });

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
const handleSave = async () => { // 加上 async
    isSubmitted.value = true;

    if (formData.value.email !== '' && !validateEmail(formData.value.email)) {
        alert('電子信箱格式不正確，請重新檢查。');
        return;
    }

    const colorMap = {
        '【R 幣與商城】': 0xF1C40F, // 金色
        '【Recimo功能】': 0x3498DB, // 藍色
        '【食譜與社群】': 0xE74C3C, // 紅色
        '【其他】': 0x95A5A6      // 灰色
    };

    // 2. 根據目前選擇的分類取得顏色，若沒對應到則給予預設綠色
    const embedColor = colorMap[formData.value.category] || 0x41b883;


    if (checkFormValid()) {

        // --- 串接 Discord ---
        // 你的 Webhook 網址 (建議加上 corsproxy 防止瀏覽器擋掉)
        const webhookUrl = "https://discord.com/api/webhooks/1465609882475692178/kAKFEEDnKELLFerGswWBeBD98yAZvSMYjXEsodOiy-lD2VmcgCUPzCluD7kdmAW1Tn-_";

        const messageData = {
            username: "Recimo 官網客服",
            embeds: [{
                title: `🔔 待處理信件：${formData.value.subject}`,
                // 這裡要改成變數！
                color: embedColor,
                fields: [
                    { name: "姓名", value: formData.value.name, inline: true },
                    { name: "信箱", value: formData.value.email, inline: true },
                    { name: "分類", value: formData.value.category, inline: true },
                    { name: "內容", value: formData.value.content },
                    {
                        name: "快速回覆",
                        value: `[點我立即回信](mailto:${formData.value.email}?subject=Re:${encodeURIComponent(formData.value.subject)})`
                    }
                ],
                footer: { text: "來自 Recimo 官方網站聯絡表單" },
                timestamp: new Date()
            }]
        };

        try {
            await axios.post(webhookUrl, messageData);
            alert('訊息已成功送出！我們會盡快回覆您。');

            // 成功後才清空表單
            formData.value = { name: '', email: '', category: '', subject: '', content: '' };
            isSubmitted.value = false;
        } catch (error) {
            console.error("Discord 傳送失敗:", error);
            alert('抱歉，系統暫時無法送出訊息，請稍後再試。');
        }
        // --- 串接結束 ---

    } else {
        alert('請填寫所有必填欄位。');
    }
};
</script>

<template>
    <div class="contact-section">
        <div class="form-card">
            <div class="form-grid">
                <div class="column">
                    <div class="field">
                        <label class="zh-h5-bold">姓名<span class="required">*</span></label>
                        <div class="input-container">
                            <div v-if="authStore.isLoggedIn" class="readonly-text p-p1">
                                {{ formData.name }}
                            </div>
                            <input v-else v-model.trim="formData.name" class="form-input p-p1"
                                :class="(isSubmitted && !formData.name.trim()) ? 'is-error' : 'is-success'"
                                style="width: 100%" placeholder="請輸入姓名" />
                        </div>
                    </div>

                    <div class="field">
                        <label class="zh-h5-bold">電子信箱<span class="required">*</span></label>
                        <div class="input-container">
                            <div v-if="authStore.isLoggedIn" class="readonly-text p-p1">
                                <span v-if="formData.email.endsWith('@line.com')" class="line-mail-hint">
                                    <i class="fab fa-line"></i> LINE 帳號驗證信箱
                                </span>
                                <span v-else>
                                    {{ formData.email }}
                                </span>
                            </div>

                            <input v-else v-model.trim="formData.email" type="email" class="form-input p-p1"
                                :class="(isSubmitted && (!formData.email || !validateEmail(formData.email))) ? 'is-error' : 'is-success'"
                                style="width: 100%" placeholder="請輸入電子信箱" />
                        </div>
                    </div>

                    <div class="field">
                        <label class="zh-h5-bold">問題分類<span class="required">*</span></label>
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
                        <label class="zh-h5-bold">問題名稱<span class="required">*</span></label>
                        <div class="input-container">
                            <input v-model.trim="formData.subject" class="form-input p-p1"
                                :class="(isSubmitted && !formData.subject.trim()) ? 'is-error' : 'is-success'"
                                style="width: 100%" placeholder="請輸入問題名稱" />
                        </div>
                    </div>

                    <div class="field grow">
                        <label class="zh-h5-bold">問題內容<span class="required">*</span></label>
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

    &[readonly],
    &.is-readonly {
        background-color: $neutral-color-100; // 使用淡灰色背景
        cursor: not-allowed; // 游標變成禁止符號
        color: $neutral-color-700; // 文字顏色轉淡
        border-color: $neutral-color-700; // 邊框顏色固定

        &:focus {
            border-color: $neutral-color-700; // 聚焦時也不要變色
            outline: none;
        }
    }
}

.contact-section {

    .form-card {
        border: 1px solid $primary-color-400;
        border-radius: 10px;
        padding: 40px;
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
                    padding: 5px 15px;
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

.line-mail-hint {
    color: #06C755; // LINE 的官方綠色
    font-weight: 500;
    display: flex;
    align-items: center;
    gap: 5px;

    &::after {
        content: "(已通過第三方授權)";
        color: $neutral-color-700;
        font-size: 0.8rem;
        margin-left: 8px;
        font-weight: normal;
    }
}
</style>