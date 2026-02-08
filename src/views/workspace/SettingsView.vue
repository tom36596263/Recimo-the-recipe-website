<script setup>
import { ref, computed, onMounted, watch } from 'vue';
// 引用 Pinia Store (權限狀態管理)
import { useAuthStore } from '@/stores/authStore';
const authStore = useAuthStore();
// 引用input
import BaseInput from '@/components/login/BaseInput.vue';
// 引用彈窗
import BaseModal from '@/components/BaseModal.vue';
// 引用聯絡我們表單
import ContactForm from '@/components/site/benefits/ContactForm-workspace.vue';
// 呼叫Api
import { phpApi, base } from '@/utils/publicApi.js';


const activeTab = ref('account');
const isPasswordVisible = ref(false);

const togglePassword = () => {
    isPasswordVisible.value = !isPasswordVisible.value;
};

// 帳號設定的資料物件
const accountData = ref({
    user_id: '',
    user_name: '',
    user_email: '',
    user_phone: '',
    user_address: '',
    user_password: '',
    confirm_password: ''
});

// 判斷是否為 LINE 登入 (根據 Email 格式)
const isLineUser = computed(() => {
    return accountData.value.user_email && accountData.value.user_email.endsWith('@line.com');
});

// ==========================================
// 彈窗
// ==========================================
// 控制彈窗狀態
const isModalOpen = ref(false);
const modalConfig = ref({
    type: 'info',
    iconClass: 'fa-solid fa-circle-info',
    title: '',
    description: ''
});

// 封裝彈窗呼叫方法
const showAlert = (title, description = '', type = 'info', icon = 'fa-solid fa-circle-info') => {
    modalConfig.value = {
        title,
        description, // 將傳入的描述存入 config
        type,
        iconClass: icon,
    };
    isModalOpen.value = true;
};

// ==========================================
// 資料初始化與同步邏輯
// ==========================================
const initUserData = () => {
    const user = authStore.user;
    if (user) {
        // ID: 嘗試抓 user_id 或 id
        accountData.value.user_id = user.user_id || user.id;

        // 姓名: authStore 裡正規化過可能是 name，原始資料可能是 user_name
        accountData.value.user_name = user.user_name || user.name || '';

        // Email
        accountData.value.user_email = user.user_email || user.email || '';

        // 手機與地址: 如果登入時後端沒回傳這些，這裡會是空字串
        accountData.value.user_phone = user.user_phone || user.phone || '';
        accountData.value.user_address = user.user_address || user.address || '';
    }
};

// 畫面載入時執行一次
onMounted(() => {
    initUserData();
});

// 監聽 store 變化 (防止重新整理瞬間 store 還沒準備好)
watch(() => authStore.user, (newVal) => {
    if (newVal) {
        initUserData();
    }
}, { deep: true });

// ==========================================
// 密碼驗證邏輯
// ==========================================
const passwordRules = computed(() => {
    const pwd = accountData.value.user_password;
    // 防呆：如果 user_password 為 undefined，給空字串
    if (!pwd) return { length: false, hasUpper: false, hasLower: false };

    return {
        length: pwd.length >= 8,
        hasUpper: /[A-Z]/.test(pwd),
        hasLower: /[a-z]/.test(pwd),
    };
});

// ==========================================
// 通知與主題設定
// ==========================================
const settings = ref({
    notifications: {
        sharing: true,
        comments: true,
        likes: true
    },
    theme: 'default'
});

// ==========================================
// 手機號碼輸入過濾
// ==========================================
const handlePhoneInput = (value) => {
    // 1. 只留數字
    let formatted = value.replace(/[^\d]/g, '');

    // 2. JS 強制截斷：這行是為了處理「貼上」或是特殊狀況
    if (formatted.length > 10) {
        formatted = formatted.slice(0, 10);
    }

    // 3. 強制 09 開頭
    if (formatted.length >= 1 && formatted[0] !== '0') {
        formatted = '';
    } else if (formatted.length >= 2 && formatted[1] !== '9') {
        formatted = '0';
    }

    // 4. 更新
    accountData.value.user_phone = formatted;
};

// ==========================================
// 送出更新邏輯
// ==========================================
const handleUpdateAccount = async () => {
    // 手機號碼嚴格驗證開始
    const phone = accountData.value.user_phone;

    // 如果有填寫手機（非必填則維持 if，必填則拿掉 if）
    if (phone) {
        // 檢查 1：長度必須是 10 碼
        // 檢查 2：必須全部是數字 (使用正規表達式 \D 代表非數字)
        const isAllNumbers = /^\d+$/.test(phone);

        if (phone.length !== 10 || !isAllNumbers) {
            // alert('手機號碼格式錯誤：請輸入 10 碼純數字（範例：0912345678）');
            showAlert('手機號碼格式錯誤', '請輸入 10 碼純數字（範例：0912345678）', 'danger', 'fa-solid fa-exclamation');
            return;
        }

        if (!phone.startsWith('09')) {
            // alert('手機號碼格式錯誤：必須以 09 開頭');
            showAlert('手機號碼格式錯誤', '必須以 09 開頭', 'danger', 'fa-solid fa-exclamation');
            return;
        }
    }
    // 密碼驗證邏輯
    if (accountData.value.user_password) {
        const allRulesMet = Object.values(passwordRules.value).every(v => v);
        if (!allRulesMet) {
            // alert('密碼強度不足'); 
            showAlert('密碼強度不足', '請參考下方密碼規定', 'danger', 'fa-solid fa-exclamation');
            return;
        }
        if (accountData.value.user_password !== accountData.value.confirm_password) {
            showAlert('兩次密碼輸入不一致', '請再試一次歐', 'danger', 'fa-solid fa-exclamation');
            // alert('兩次密碼輸入不一致'); 
            return;
        }
    }
    if (!accountData.value.user_id) {
        // alert('錯誤：抓不到會員編號，請重新整理頁面');
        alert('錯誤：請重新整理頁面');
        return;
    }

    // console.log("準備送出的 ID:", accountData.value.user_id); // 這裡要確認有值

    try {
        const payload = {
            user_id: accountData.value.user_id,
            user_name: accountData.value.user_name,
            user_phone: accountData.value.user_phone,
            user_address: accountData.value.user_address,
            user_password: accountData.value.user_password
        };

        const response = await phpApi.post('auth/update_user_self.php', payload);
        // console.log("更新成功後回傳的資料：", response.data.data); // 檢查這裡的 user_email

        if (response.data.status === 'success') {
            // alert('更新成功！');
            showAlert('更新成功！', '', 'success', 'fa-solid fa-check');
            // 更新成功後，清空前端的密碼輸入框，避免下次重複送出舊密碼
            accountData.value.user_password = '';
            accountData.value.confirm_password = '';
            // PHP 現在有回傳 data 了，這裡就不會報錯
            if (response.data.data) {
                authStore.updateUserInfo(response.data.data);
            }

        } else if (response.data.status === 'info') {
            // alert('資料沒有變動喔！');
            showAlert('資料沒有變動喔！', 'info');
        } else {
            // alert(response.data.message);
            showAlert(response.data.message || '更新失敗', 'danger', 'fa-solid fa-exclamation');
        }
    } catch (error) {
        // console.error(error);
        alert('伺服器連線失敗');
    }
};
</script>

<template>
    <div class="settings-wrapper">
        <div class="tabs-container">
            <button class="tab-item zh-h5" :class="{ active: activeTab === 'account' }" @click="activeTab = 'account'">
                帳號設定
            </button>
            <button class="tab-item zh-h5" :class="{ active: activeTab === 'notifications' }"
                @click="activeTab = 'notifications'">
                通知與主題設定
            </button>
            <button class="tab-item zh-h5" :class="{ active: activeTab === 'contact' }" @click="activeTab = 'contact'">
                聯絡我們
            </button>
        </div>

        <div class="content-body">
            <form v-if="activeTab === 'account'" class="account-pane" @submit.prevent="handleUpdateAccount">
                <div class="info-row">
                    <label class="p-p1">會員編號</label>
                    <span class="static-text p-p1">{{ accountData.user_id }}</span>
                </div>

                <div class="info-row">
                    <label class="p-p1">會員姓名</label>
                    <BaseInput v-model="accountData.user_name" placeholder="請輸入姓名" />
                </div>

                <div class="info-row">
                    <label class="p-p1">電子信箱</label>
                    <div class="static-text p-p1">
                        <template v-if="accountData.user_email && accountData.user_email.endsWith('@line.com')">
                            <span class="line-mail-hint">
                                <i class="fab fa-line"></i> LINE 帳號快速登入
                            </span>
                        </template>
                        <template v-else>
                            {{ accountData.user_email }}
                        </template>
                    </div>
                </div>

                <div class="info-row">
                    <label class="p-p1">會員手機</label>
                    <BaseInput v-model="accountData.user_phone" placeholder="請輸入您的手機" maxlength="10" inputmode="numeric"
                        @input="handlePhoneInput(accountData.user_phone)" autocomplete="tel" />
                </div>

                <div class="info-row">
                    <label class="p-p1">會員地址</label>
                    <BaseInput v-model="accountData.user_address" placeholder="請輸入您的地址" autocomplete="street-address" />
                </div>

                <div v-if="!isLineUser" class="info-row align-top">
                    <label class="p-p1">更改密碼</label>
                    <div class="password-group">
                        <BaseInput v-model="accountData.user_password" :type="isPasswordVisible ? 'text' : 'password'"
                            placeholder="請輸入新密碼" autocomplete="new-password">
                            <template #suffix>
                                <i :class="isPasswordVisible ? 'fas fa-eye' : 'fas fa-eye-slash'"
                                    @click="togglePassword" style="cursor: pointer; color: #666;"></i>
                            </template>
                        </BaseInput>
                        <div class="password-requirements">
                            <p class="requirements-title p-p3">密碼規定：</p>
                            <ul>
                                <li class="p-p3" :class="{ 'met': passwordRules.length }">
                                    <i
                                        :class="passwordRules.length ? 'fa-solid fa-circle-check' : 'fa-solid fa-circle-exclamation'"></i>
                                    至少含八個字元
                                </li>
                                <li class="p-p3" :class="{ 'met': passwordRules.hasUpper }">
                                    <i
                                        :class="passwordRules.hasUpper ? 'fa-solid fa-circle-check' : 'fa-solid fa-circle-exclamation'"></i>
                                    含一大寫英文字母
                                </li>
                                <li class="p-p3" :class="{ 'met': passwordRules.hasLower }">
                                    <i
                                        :class="passwordRules.hasLower ? 'fa-solid fa-circle-check' : 'fa-solid fa-circle-exclamation'"></i>
                                    含一小寫英文字母
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>

                <div v-if="!isLineUser" class="info-row">
                    <label class="p-p1">確認密碼</label>
                    <BaseInput v-model="accountData.confirm_password" :type="isPasswordVisible ? 'text' : 'password'"
                        placeholder="請再輸入一次新密碼" autocomplete="new-password" />
                </div>

                <div class="btn-center">
                    <BaseBtn title="更新資料" :width="180" :height="40" @click="handleUpdateAccount" />
                </div>
            </form>

            <div v-else-if="activeTab === 'notifications'" class="notify-pane">
                <div class="notify-item p-p1" v-for="(val, key) in { sharing: '分享通知', comments: '留言通知', likes: '按讚通知' }"
                    :key="key">
                    <div class="text p-p1">
                        <div class="title">{{ val }}</div>
                        <div class="desc">💡 如有其他使用者{{ key === 'sharing' ? '分享您的食譜' : key === 'comments' ? '在您的食譜下留言' :
                            '對您的食譜按讚'
                        }}，則傳送通知給您</div>
                    </div>
                    <label class="switch">
                        <input type="checkbox" v-model="settings.notifications[key]" disabled>
                        <span class="slider"></span>
                    </label>
                </div>

                <hr class="divider">

                <div class="theme-section p-p1">
                    <div class="theme-option"
                        v-for="t in [{ id: 'default', n: '系統預設', d: '官方配色' }, { id: 'light', n: '淺色介面', d: '適合白天使用' }, { id: 'dark', n: '深色介面', d: '適合夜間使用' }]"
                        :key="t.id">
                        <div class="text">
                            <div class="title">{{ t.n }}</div>
                            <div class="desc">💡 {{ t.d }}</div>
                        </div>
                        <input type="radio" name="theme" :value="t.id" v-model="settings.theme" disabled>
                    </div>
                </div>

                <div class="btn-center">
                    <BaseBtn title="更新設定" :width="180" :height="40" disabled
                        style="opacity: 0.5; cursor: not-allowed;" />
                </div>
            </div>

            <div v-else-if="activeTab === 'contact'" class="contact-pane">
                <ContactForm :preName="accountData.user_name" :preEmail="accountData.user_email" />
            </div>
        </div>
    </div>

    <BaseModal :isOpen="isModalOpen" :type="modalConfig.type" :title="modalConfig.title"
        :iconClass="modalConfig.iconClass" :description="modalConfig.description" @close="isModalOpen = false" />
</template>

<style lang="scss" scoped>
.settings-wrapper {
    margin: 15px auto;

    .tabs-container {
        display: flex;
        padding: 0 10px; // 增加一點內縮讓邊框不要切齊最外圍
        justify-content: space-between;

        .tab-item {
            margin: 0 10px;
            flex: 1;
            padding: 12px;
            border: 1px solid $primary-color-700;
            border-bottom: none;
            border-radius: 10px 10px 0 0;
            background: $neutral-color-white;
            color: $primary-color-700;
            cursor: pointer;
            transition: 0.2s;

            &.active {
                background: $primary-color-700;
                color: $neutral-color-white;
            }
        }
    }

    .content-body {
        border: 1px solid $primary-color-700;
        border-radius: 0 0 10px 10px;
        margin: auto 20px;
        padding: 40px;
    }
}

.info-row {
    display: flex;
    // 由子項目自行決定對齊方式
    align-items: flex-start;
    margin-bottom: 20px;

    label {
        min-width: 80px;
        margin-right: 40px;
        white-space: nowrap;

        // 給 Label 一個跟 Input 高度一樣的 line-height，這樣文字就會剛好在 Input 的水平中線上
        height: 40px;
        display: flex;
        align-items: center;
    }

    // 讓右側內容撐滿
    .static-text,
    .password-group,
    :deep(.base-input-wrapper) {
        flex: 1;
        width: 100%;
    }

    // 靜態文字（Email、編號）也要維持 40px 高度來置中對齊
    .static-text {
        height: 40px;
        display: flex;
        align-items: center;
        padding-left: 12px;
    }
}

.password-group {
    display: flex;
    flex-direction: column;
    width: 100%; // 確保寬度跟上面的一樣

    // 確保密碼 Input 元件本身是 100% 寬
    :deep(.base-input-wrapper) {
        width: 100%;
    }
}

.password-requirements {
    width: 100%;
    margin-bottom: 5px;
    padding-left: 5px;

    .requirements-title {
        color: $neutral-color-700;
    }

    li {
        display: flex;
        align-items: center;
        color: $secondary-color-danger-700; // 未通過
        transition: color 0.3s ease;
        margin-top: 5px;

        i {
            font-size: 12px;
        }

        &.met {
            color: $secondary-color-success-700; // 通過後變綠色
        }
    }
}

.btn-center {
    display: flex;
    justify-content: center;
    margin-top: 40px;
}

/* line的email亂碼改成這些 */
.line-mail-hint {
    color: #06C755; // LINE 綠
    font-weight: 500;
    display: flex;
    align-items: center;
    gap: 8px;

    i {
        font-size: 1.2rem;
    }

    &::after {
        content: "(已通過第三方授權保護)";
        color: $neutral-color-700;
        font-size: 12px;
        font-weight: normal;
    }
}

// 確保內容靠左對齊且有足夠空間
.static-text {
    height: 40px;
    display: flex;
    align-items: center;
    padding-left: 12px;
    color: $neutral-color-800;
}

// 通知與切換樣式
.notify-item,
.theme-option {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 25px;
}

.divider {
    border: none;
    border-top: 1px solid $primary-color-700;
    margin: 30px 0;
}
</style>