<script setup>
import { ref, reactive } from 'vue';

//接收控制變數
const props = defineProps({
    isOpen: {
        type: Boolean,
        default: false
    }
});

//emits讓元件可以通知父層
const emit = defineEmits(['close', 'submit']);

//表單資料
const formData = reactive({
    reason: '',
    note: ''
});

//下拉選單
const reasons = [
    '改變心意',
    '重複下單',
    '找到更便宜的價格',
    '配送時間過長',
    '其他原因'
];

//關閉試窗
const handleClose = () => {
    emit('close');
};

// 送出表單
const handleSubmit = () => {
    // 這裡可以做簡單驗證，例如必填理由
    if (!formData.reason) {
        alert('請選擇取消理由');
        return;
    } emit('submit', {
        reason: formData.reason,
        note: formData.note
    });



    // 送出後清空表單 (選用)
    formData.reason = '';
    formData.note = '';
};

</script>
<template>
    <div v-if="isOpen" class="modal-mask" @click.self="handleClose">
        <div class="modal-container">

            <h3 class="modal-title">取消訂單</h3>

            <div class="divider"></div>

            <div class="modal-body">
                <p class="confirm-text">您是否確定要取消這筆訂單？</p>

                <div class="form-group">
                    <label>取消的理由</label>
                    <div class="select-wrapper">
                        <select v-model="formData.reason">
                            <option value="" disabled selected>請選擇理由</option>
                            <option v-for="item in reasons" :key="item" :value="item">{{ item }}</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label>其他</label>
                    <textarea v-model="formData.note" rows="5" placeholder="若有其他原因,請在這輸入"></textarea>
                </div>

                <p class="warning-text">
                    取消完成後,退款會有一週的工作天,請耐心等候
                </p>
            </div>

            <div class="modal-footer">
                <button class="btn btn-submit" @click="handleSubmit">送出</button>
                <button class="btn btn-cancel" @click="handleClose">取消</button>
            </div>

        </div>
    </div>
</template>

<style lang="scss" scoped>
/* 變數設定 (依照你的設計圖顏色) */
$primary-green: #4F8A65;
$danger-red: #FF4D4F;
$border-color: #888;
$bg-white: #ffffff;

/* --- 遮罩層 (全螢幕背景) --- */
.modal-mask {
    position: fixed;
    z-index: 9998;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    /* 半透明黑底 */
    display: flex;
    justify-content: center;
    align-items: center;
    transition: opacity 0.3s ease;
    padding: 20px;
    /* 避免手機版貼邊 */
}

/* --- 彈窗主體 (預設為手機版樣式/窄版) --- */
.modal-container {
    width: 100%;
    max-width: 350px;
    /* 左圖：手機版寬度較窄 */
    background-color: $bg-white;
    border-radius: 8px;
    border: 1px solid $primary-green;
    /* 外框線也是綠色 */
    padding: 24px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.33);
    transition: all 0.3s ease;
    display: flex;
    flex-direction: column;
}

/* 標題 */
.modal-title {
    color: $primary-green;
    font-size: 1.5rem;
    font-weight: bold;
    margin-bottom: 16px;
    margin-top: 0;
}

.divider {
    height: 1px;
    background-color: #ccc;
    margin-bottom: 20px;
}

.confirm-text {
    font-size: 1rem;
    margin-bottom: 20px;
    color: #333;
}

/* 表單元件 */
.form-group {
    margin-bottom: 20px;

    label {
        display: block;
        margin-bottom: 8px;
        font-weight: 500;
        color: #333;
    }

    select,
    textarea {
        width: 100%;
        padding: 10px;
        border: 1px solid #777;
        /* 深一點的邊框 */
        border-radius: 6px;
        font-size: 1rem;
        outline: none;

        &:focus {
            border-color: $primary-green;
        }
    }

    /* 自定義 Select 箭頭 (簡單版) */
    select {
        appearance: none;
        background-color: white;
        background-image: url("data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%23000000%22%20d%3D%22M287%2069.4a17.6%2017.6%200%200%200-13-5.4H18.4c-5%200-9.3%201.8-12.9%205.4A17.6%2017.6%200%200%200%200%2082.2c0%205%201.8%209.3%205.4%2012.9l128%20127.9c3.6%203.6%207.8%205.4%2012.8%205.4s9.2-1.8%2012.8-5.4L287%2095c3.5-3.5%205.4-7.8%205.4-12.8%200-5-1.9-9.2-5.5-12.8z%22%2F%3E%3C%2Fsvg%3E");
        background-repeat: no-repeat;
        background-position: right 10px center;
        background-size: 12px;
    }
}

.warning-text {
    color: $danger-red;
    font-size: 0.9rem;
    margin-top: 10px;
    margin-bottom: 24px;
}

/* --- 按鈕區 (Flex 排版) --- */
.modal-footer {
    display: flex;
    gap: 15px;
    /* 按鈕之間的間距 */
}

.btn {
    padding: 10px 0;
    border-radius: 6px;
    font-size: 1rem;
    cursor: pointer;
    border: 1px solid $primary-green;
    transition: all 0.2s;

    /* 左圖：手機版按鈕看起來是等寬的 (1:1) */
    flex: 1;
}

.btn-submit {
    background-color: $primary-green;
    color: white;

    &:hover {
        background-color: darken($primary-green, 10%);
    }
}

.btn-cancel {
    background-color: white;
    color: $primary-green;

    &:hover {
        background-color: #f0fdf4;
    }
}

/* --- 響應式：桌機版樣式 (右圖) --- */
@media screen and (min-width: 768px) {
    .modal-container {
        max-width: 600px;
        /* 右圖：寬度變寬 */
        padding: 32px;
    }

    /* 調整按鈕比例以符合右圖 */
    .modal-footer {
        /* 右圖中，送出按鈕(綠)非常長，取消按鈕(白)比較短 */
        /* 我們讓送出按鈕佔據更多空間，例如 2:1 或 3:1 */

        .btn-submit {
            flex: 3;
            /* 佔據較大比例 */
        }

        .btn-cancel {
            flex: 1;
            /* 佔據較小比例 */
        }
    }
}
</style>