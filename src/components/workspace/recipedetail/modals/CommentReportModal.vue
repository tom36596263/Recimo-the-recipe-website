<script setup>
import { ref } from 'vue';


const props = defineProps({
    modelValue: Boolean,
    commentData: {
        type: Object,
        default: () => ({
            content: '載入中...',
            userName: '未知用戶',
            time: ''
        })
    }
});


const emit = defineEmits(['update:modelValue', 'submit']);

const reasons = [
    '垃圾訊息 / 廣告',
    '仇恨或攻擊言論',
    '色情或不當內容',
    '不實資訊',
    '其他原因'
];
const selectedReason = ref('垃圾訊息 / 廣告');
const reportNote = ref('');

const handleClose = () => {
    emit('update:modelValue', false);

};

const handleSubmit = () => {
    emit('submit', {
        reason: selectedReason.value,
        note: reportNote.value
    });
    alert("已送出檢舉");
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


                        <BaseBtn title="取消" variant="outline" height="40" width="100%" @click="handleClose">
                        </BaseBtn>

                        <BaseBtn title="送出檢舉" width="100%" height="40" @click="handleSubmit" />


                    </div>
                </div>
            </div>
        </div>
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
    /* 已將紅色改掉，如需偵錯可改回 red */
    width: 100%;
    height: 40px;
    flex-shrink: 0;
    display: flex;
    justify-content: space-between;
    gap: 16px;
    /* 稍微縮小間隙確保按鈕有足夠空間撐開 */
    margin-top: 16px;

    :deep(.base-btn) {
        flex: 1 !important;
        /* 強制平分空間 */
        max-width: none !important;
        /* 破除內置最大寬度限制 */
        width: 100% !important;
        /* 強制撐滿 */

        button,
        a {
            width: 100% !important;
            /* 確保內部原生標籤也撐滿 */
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

    /* 1. 確保斷行，禁止底部卷軸 */
    white-space: pre-wrap;
    word-wrap: break-word;
    overflow-x: hidden;
    overflow-y: auto;

    /* 2. 美化側邊卷軸 (Firefox) */
    scrollbar-width: thin;
    scrollbar-color: $primary-color-100 transparent;

    /* 3. 美化側邊卷軸 (Chrome, Edge, Safari) */
    &::-webkit-scrollbar {
        width: 6px;
        /* 卷軸寬度 */
    }

    &::-webkit-scrollbar-track {
        background: transparent;
        /* 軌道顏色 */
    }

    &::-webkit-scrollbar-thumb {
        background-color: $primary-color-100;
        /* 卷軸顏色 */
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