<script setup>
import { ref } from 'vue';
import { useAuthStore } from '@/stores/authStore'; // 🏆 獲取登入資訊
import { phpApi } from '@/utils/phpApi.js';     // 🏆 使用封裝好的 Axios 實體
// 🏆 關鍵修改：改為引入你剛才大改過的 ReportSuccessModal
import ReportSuccessModal from '@/components/workspace/recipedetail/modals/ReportSuccessModal.vue';

const props = defineProps({
    modelValue: Boolean,
    commentData: {
        type: Object,
        default: () => ({
            comment_id: null,
            content: '載入中...',
            userName: '未知用戶',
            time: ''
        })
    }
});

const emit = defineEmits(['update:modelValue']);

const authStore = useAuthStore();

const reasons = [
    '垃圾訊息 / 廣告',
    '仇恨或攻擊言論',
    '色情或不當內容',
    '不實資訊',
    '其他原因'
];

const selectedReason = ref('垃圾訊息 / 廣告');
const reportNote = ref('');
const isSuccessOpen = ref(false); // 🏆 控制成功燈箱開關

// 關閉燈箱並重置
const handleClose = () => {
    reportNote.value = '';
    selectedReason.value = '垃圾訊息 / 廣告';
    emit('update:modelValue', false);
};

// 送出檢舉
const handleSubmit = async () => {
    // 1. 權限檢查：確保有登入 ID
    const reporterId = authStore.user?.user_id || authStore.user?.id;
    if (!reporterId) {
        alert("請先登入才能進行檢舉");
        return;
    }

    // 2. 檢查目標 ID 是否存在
    if (!props.commentData.comment_id) {
        alert("找不到檢舉目標，請稍後再試");
        return;
    }

    // 3. 封裝資料 (對應 PHP 欄位)
    const payload = {
        reporter_id: reporterId,
        target_type: 'comment',
        target_id: props.commentData.comment_id,
        reason: selectedReason.value,
        note: reportNote.value
    };

    try {
        // 4. 使用 phpApi 發送 POST 請求 (路徑對應 social/submit_report.php)
        const response = await phpApi.post('social/submit_report.php', payload);

        // Axios 自動解析 JSON 資料在 response.data 中
        if (response.data.status === 'success') {
            // 🏆 關閉目前的檢舉燈箱，並開啟成功燈箱
            emit('update:modelValue', false);
            isSuccessOpen.value = true;

            // 重置內容
            reportNote.value = '';
            selectedReason.value = '垃圾訊息 / 廣告';
        } else {
            alert("檢舉失敗：" + (response.data.message || "伺服器忙碌中"));
        }
    } catch (error) {
        console.error("API Error:", error);
        alert("連線伺服器失敗，請確認網路或 PHP 環境。");
    }
};
</script>

<template>
    <Teleport to="body">
        <div v-if="modelValue" class="black-mask" @click.self="handleClose">
            <div class="modal-card">
                <button class="close-x" @click="handleClose" aria-label="關閉">
                    ×
                </button>

                <div class="modal-header">
                    <div class="modal-title zh-h4-bold ">檢舉這則留言</div>
                    <div class="green-divider"></div>
                </div>

                <div class="report-content">
                    <div class="comment-box">
                        <p class="comment-text p-p2">{{ commentData.content }}</p>
                        <div class="user-meta p-p3">
                            @{{ commentData.userName }} · {{ commentData.time }}
                        </div>
                    </div>

                    <div class="input-section">
                        <p class="section-title zh-h5-bold">請選擇檢舉原因：</p>
                        <div class="radio-list">
                            <label v-for="item in reasons" :key="item" class="radio-item">
                                <input type="radio" :value="item" v-model="selectedReason" />
                                <span class="radio-text p-p2">{{ item }}</span>
                            </label>
                        </div>
                    </div>

                    <div class="input-section">
                        <p class="section-title zh-h5-bold">補充說明（選填）：</p>
                        <textarea v-model="reportNote" placeholder="請說明具體情況..." class="p-p3"></textarea>
                    </div>

                    <div class="btn-group">
                        <BaseBtn title="取消" variant="outline" height="40" width="100%" @click="handleClose" />
                        <BaseBtn title="送出檢舉" width="100%" height="40" @click="handleSubmit" />
                    </div>
                </div>
            </div>
        </div>

        <ReportSuccessModal :isOpen="isSuccessOpen" @close="isSuccessOpen = false" />
    </Teleport>
</template>

<style scoped lang="scss">
.black-mask {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 100;
    padding: 20px;
}

.modal-card {
    display: flex;
    flex-direction: column;
    height: auto;
    background: $neutral-color-white;
    width: 450px;
    max-width: calc(100% - 40px);
    border-radius: 12px;
    padding: 24px 30px;
    position: relative;
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
    max-height: 90vh;
    overflow: hidden;
    text-align: left;

    .close-x {
        position: absolute;
        top: 20px;
        right: 20px;
        background: none;
        border: none;
        font-size: 26px;
        color: $neutral-color-700;
        cursor: pointer;
        line-height: 1;
        padding: 5px;
        transition: color 0.2s;
        z-index: 2;

        &:hover {
            color: $neutral-color-black;
        }
    }
}

.modal-header {
    flex-shrink: 0;
    margin-bottom: 16px;

    .modal-title {
        color: $primary-color-700;
        margin: 0 0 10px 0;
    }

    .green-divider {
        height: 1px;
        background: $primary-color-400;
        width: 100%;
    }
}

.report-content {
    flex: 1;
    overflow-y: auto;
    padding-right: 0;
    width: 100%;
    box-sizing: border-box;

    &::-webkit-scrollbar {
        width: 4px;
    }

    &::-webkit-scrollbar-thumb {
        background: $neutral-color-100;
        border-radius: 4px;
    }
}

.comment-box {
    background: $neutral-color-100;
    border-radius: 10px;
    padding: 12px 16px;
    margin-bottom: 16px;
    height: 100px;
    display: flex;
    flex-direction: column;
    flex-shrink: 0;

    .comment-text {
        flex: 1;
        overflow-y: auto;
        word-break: break-all;
        white-space: pre-wrap;
        background: transparent;
        line-height: 1.5;
        font-weight: 500;

        &::-webkit-scrollbar {
            width: 4px;
        }

        &::-webkit-scrollbar-thumb {
            background: $neutral-color-400;
            border-radius: 4px;
        }
    }

    .user-meta {
        margin-top: 6px;
        color: $neutral-color-400;
        border-top: 1px solid $neutral-color-400;
        padding-top: 6px;
        flex-shrink: 0;
    }
}

.btn-group {
    margin: 0;
    background-color: transparent;
    width: 100%;
    height: 40px;
    flex-shrink: 0;
    display: flex;
    justify-content: space-between;
    gap: 16px;
    margin-top: 16px;

    :deep(.base-btn) {
        flex: 1 !important;
        max-width: none !important;
        width: 100% !important;

        button,
        a {
            width: 100% !important;
        }
    }

    @media (max-width: 480px) {
        gap: 12px;

        :deep(.base-btn) {
            flex: 1 !important;
        }
    }
}

.input-section {
    margin-bottom: 16px;

    .section-title {
        margin-bottom: 8px;
    }
}

.radio-list {
    display: flex;
    flex-direction: column;
    gap: 8px;

    .radio-item {
        display: flex;
        align-items: center;
        gap: 10px;
        cursor: pointer;

        input {
            accent-color: $primary-color-700;
            width: 18px;
            height: 18px;
        }
    }
}

textarea {
    width: 100%;
    min-height: 110px;
    border-radius: 10px;
    border: 1px solid $primary-color-400;
    padding: 10px 12px;
    resize: none;
    box-sizing: border-box;
    white-space: pre-wrap;
    word-wrap: break-word;
    overflow-x: hidden;
    overflow-y: auto;
    scrollbar-width: thin;
    scrollbar-color: $primary-color-100 transparent;

    &::-webkit-scrollbar {
        width: 6px;
    }

    &::-webkit-scrollbar-track {
        background: transparent;
    }

    &::-webkit-scrollbar-thumb {
        background-color: $primary-color-100;
        border-radius: 10px;

        &:hover {
            background-color: $primary-color-400;
        }
    }

    &:focus {
        border-color: $primary-color-700;
        outline: none;
    }
}
</style>