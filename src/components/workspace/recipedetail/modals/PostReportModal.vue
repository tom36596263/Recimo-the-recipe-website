<script setup>
import { ref } from 'vue';

const props = defineProps({
    modelValue: Boolean,
    commentData: {
        type: Object,
        default: () => ({
            content: '載入中...',
            userName: '未知用戶',
            time: '',
            image: '' 
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
                    <div class="modal-title zh-h4-bold ">檢舉這張照片</div>
                    <div class="green-divider"></div>
                </div>

                <div class="report-content">
                    <div class="comment-box photo-mode">
                        <div class="photo-fixed">
                            <img :src="commentData.image || 'https://via.placeholder.com/150'" alt="成品照" />
                        </div>

                        <div class="text-scroll-area">
                            <p class="comment-text p-p2">{{ commentData.content }}</p>
                        </div>

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
                        <BaseBtn title="取消" variant="outline" height="0" class="w-auto" @click="handleClose" />
                        <BaseBtn title="送出檢舉" @click="handleSubmit" class="w-auto" />
                    </div>
                </div>
            </div>
        </div>
    </Teleport>
</template>

<style scoped lang="scss">
/* 保留你原本的所有基礎樣式... */

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
        z-index: 2;
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
    width: 100%;
}

.comment-box.photo-mode {
    background: $neutral-color-100;
    border-radius: 10px;
    padding: 16px;
    margin-bottom: 16px;
    height: 140px;
    display: grid;
    grid-template-columns: 120px 1fr;
    grid-template-rows: 1fr auto;
    gap: 12px;
    flex-shrink: 0;

    .photo-fixed {
        grid-column: 1;
        grid-row: 1;
        width: 120px;
        height: 100%;
        background: $neutral-color-400;
        border-radius: 6px;
        overflow: hidden;

        img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
    }

    .text-scroll-area {
        grid-column: 2;
        grid-row: 1;
        overflow-y: auto;
        padding-right: 4px;

        &::-webkit-scrollbar {
            width: 4px;
        }

        &::-webkit-scrollbar-thumb {
            background: $neutral-color-400;
            border-radius: 4px;
        }

        .comment-text {
            margin: 0;
            line-height: 1.5;
            word-break: break-all;
            white-space: pre-wrap;
            font-weight: 500;
        }
    }

    .user-meta {
        grid-column: 1 / 3;
        grid-row: 2;
        margin-top: 4px;
        color: $neutral-color-400;
        border-top: 1px solid $neutral-color-400;
        padding-top: 6px;
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
    min-height: 80px;
    border-radius: 10px;
    border: 1px solid $neutral-color-400;
    padding: 10px 12px;
    resize: none;
    box-sizing: border-box;

    &:focus {
        border-color: $primary-color-700;
        outline: none;
    }
}

.btn-group {
    margin-top: 16px;
    display: flex;
    justify-content: center;
    gap: 30px;
    height: 40px;
}
</style>