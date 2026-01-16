<script setup>
import { ref } from 'vue';

// 接收父層傳來的顯示狀態與留言資料
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

// 定義事件：更新狀態與送出資料
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
            <div class="modal-title zh-h3-bold ">檢舉這則留言</div>
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
                <textarea
                v-model="reportNote"
                placeholder="請說明具體情況..."
                class="p-p3"
                ></textarea>
            </div>

            <div class="btn-group">
                

                <BaseBtn
                title="取消"
                variant="outline"
                height="0"
                class="w-auto"
                @click="handleClose">
                </BaseBtn>
                
                <BaseBtn 
                title="送出檢舉"
                @click="handleSubmit" 
                class="w-auto"
                />

                
            </div>
            </div>
        </div>
        </div>
    </Teleport>
</template>



<style scoped lang="scss">
$primary-green: #438b64;


.black-mask {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 100;
}
.modal-card {
    height: 630px;
    background: $neutral-color-white;
    width: 90%;
    max-width: 440px;
    border-radius: 12px;
    padding: 30px;
    position: relative; 
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
    max-height: 90vh;
    overflow-y: auto;
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
        &:hover {
            color: $neutral-color-black;
        }
    }
}


.modal-header {
    
    margin-top: -30px;
    margin-bottom: 20px;

    .modal-title {
    color: $primary-color-700;

        margin: 0 0 12px 0;
    }
    .green-divider {
        height: 1px;
        background: $primary-color-400;
        width: 100%;
    }
}


.comment-box {
    background: $neutral-color-100;
    
    border-radius: 10px;
    padding: 16px;
    margin-bottom: 20px;
    .comment-text {
        margin: 0;
        line-height: 1.5;
        font-weight: 500;
    }
    .user-meta {
        margin-top: 10px;
        color: $neutral-color-400;
        border-top: 1px solid $neutral-color-400;
        padding-top: 8px;
    }
}

.input-section {
    margin-bottom: 20px;
    .section-title {
        margin-bottom: 10px;
    }
}

.radio-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
    .radio-item {
        display: flex;
        align-items: center;
        gap: 10px;
        cursor: pointer;
        input {
        accent-color: $primary-green;
        width: 18px;
        height: 18px;
        }
        .radio-text {
        //   font-size: 15px;
        color: #666;
        }
    }
}

textarea {
    width: 100%;
    min-height: 100px;
    border-radius: 10px;
    border: 1px solid $neutral-color-400;
    padding: 12px;
    //   font-size: 14px;
    resize: none;
    box-sizing: border-box;
    &:focus {
        border-color: $primary-green;
        outline: none;
        box-shadow: 0 0 0 2px rgba(67, 139, 100, 0.1);
    }
}

.btn-group {
    display: flex;
    justify-content: center;
    gap: 30px;
    margin-top: 10px;
}
</style>
