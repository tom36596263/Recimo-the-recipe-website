<script setup>
import { ref, computed } from 'vue';
import { useAuthStore } from '@/stores/authStore';
import { phpApi } from '@/utils/phpApi.js';

const props = defineProps({
    modelValue: Boolean,
    targetData: {
        type: Object,
        default: () => ({
            recipe_id: null,
            title: '載入中...',
            userName: '未知作者',
            time: '',
            image: '',
            author_id: null
        })
    }
});

const emit = defineEmits(['update:modelValue', 'submit']);
const authStore = useAuthStore();

const displayAuthor = computed(() => {
    if (props.targetData.author_id === 1 || props.targetData.author_id === "1") {
        return 'Recimo 官方';
    }
    if (props.targetData.userName && props.targetData.userName !== '未知作者') {
        return props.targetData.userName;
    }
    if (authStore.user && authStore.user.user_name) {
        return authStore.user.user_name;
    }
    return '未知作者';
});

const reasons = [
    '內容侵權 (盜圖或盜文)',
    '垃圾訊息 / 廣告',
    '不實資訊 / 錯誤的食譜步驟',
    '仇恨或不當言論',
    '其他原因'
];
const selectedReason = ref('內容侵權 (盜圖或盜文)');
const reportNote = ref('');

const handleClose = () => {
    reportNote.value = '';
    emit('update:modelValue', false);
};

const handleSubmit = async () => {
    const reporterId = authStore.user?.user_id || authStore.user?.id;
    const targetId = props.targetData.recipe_id;

    if (!reporterId) {
        alert("請先登入才能進行檢舉");
        return;
    }

    if (!targetId) {
        alert("程式錯誤：找不到食譜 ID，請聯繫管理員");
        return;
    }

    const payload = {
        reporter_id: reporterId,
        target_type: 'recipe',
        target_id: targetId,
        reason: selectedReason.value,
        note: reportNote.value
    };

    try {
        const response = await phpApi.post('social/submit_report.php', payload);
        if (response.data.status === 'success') {
            alert('感謝您的檢舉，我們會盡快審核該食譜。');
            emit('submit', response.data);
            handleClose();
        } else {
            alert('檢舉失敗：' + (response.data.message || '請稍後再試'));
        }
    } catch (error) {
        console.error("API Error:", error);
        alert('連線伺服器失敗，請檢查網路狀況。');
    }
};

const getImageUrl = (url) => {
    if (!url) return 'https://via.placeholder.com/150?text=No+Image';
    return url;
};
</script>

<template>
    <Teleport to="body">
        <div v-if="modelValue" class="black-mask" @click.self="handleClose">
            <div class="modal-card">
                <button class="close-x" @click="handleClose" aria-label="關閉">×</button>

                <div class="modal-header">
                    <div class="modal-title zh-h4-bold ">檢舉這道食譜</div>
                    <div class="green-divider"></div>
                </div>

                <div class="report-content custom-scrollbar">
                    <div class="comment-box photo-mode">
                        <div class="photo-fixed">
                            <img :src="getImageUrl(targetData.image)"
                                @error="(e) => e.target.src = 'https://via.placeholder.com/150?text=Load+Error'"
                                alt="食譜封面" />
                        </div>

                        <div class="text-scroll-area">
                            <p class="zh-h5-bold" style="margin-bottom: 4px;">{{ targetData.title }}</p>
                        </div>

                        <div class="user-meta p-p3">
                            作者：@{{ displayAuthor }} <span v-if="targetData.time">· {{ targetData.time }}</span>
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
                        <textarea v-model="reportNote" placeholder="請說明該食譜違反規範的具體情況..."
                            class="p-p3 custom-scrollbar"></textarea>
                    </div>

                    <div class="btn-group">
                        <BaseBtn title="取消" variant="outline" height="40" width="100%" @click="handleClose" />
                        <BaseBtn title="送出檢舉" height="40" width="100%" @click="handleSubmit" />
                    </div>
                </div>
            </div>
        </div>
    </Teleport>
</template>

<style scoped lang="scss">
@import '@/assets/scss/abstracts/_color.scss';

.black-mask {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background: rgba(0, 0, 0, 0.7);
    /* 稍微加深遮罩 */
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 3000;
    /* 🏆 必須大於外層 Modal 的 2000 */
    padding: 20px;
}

.modal-card {
    display: flex;
    flex-direction: column;
    background: $neutral-color-white;
    width: 450px;
    max-width: calc(100% - 40px);
    max-height: 92vh;
    border-radius: 12px;
    padding: 20px 30px;
    position: relative;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
    height: auto;
    overflow: hidden;
    text-align: left;

    .close-x {
        position: absolute;
        top: 15px;
        right: 15px;
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
    margin-bottom: 12px;

    .modal-title {
        color: $primary-color-700;
        margin: 0 0 8px 0;
    }

    .green-divider {
        height: 1px;
        background: $primary-color-400;
        width: 100%;
    }
}

.report-content {
    overflow: visible;
    width: 100%;
    flex: none;
}

@media (max-height: 700px) {
    .modal-card {
        max-height: 95vh;
    }

    .report-content {
        overflow-y: auto;
        flex: 1 1 auto;
    }
}

.comment-box.photo-mode {
    background: $neutral-color-100;
    border-radius: 10px;
    padding: 12px;
    margin-bottom: 12px;
    height: 130px;
    display: grid;
    grid-template-columns: 110px 1fr;
    grid-template-rows: 1fr auto;
    gap: 12px;
    flex-shrink: 0;

    .photo-fixed {
        grid-column: 1;
        grid-row: 1;
        width: 110px;
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
    }

    .user-meta {
        grid-column: 1 / 3;
        grid-row: 2;
        margin-top: 4px;
        font-size: 12px;
        color: $neutral-color-400;
        border-top: 1px solid $neutral-color-400;
        padding-top: 4px;
    }
}

.input-section {
    margin-bottom: 12px;

    .section-title {
        margin-bottom: 6px;
    }
}

.radio-list {
    display: flex;
    flex-direction: column;
    gap: 6px;

    .radio-item {
        display: flex;
        align-items: center;
        gap: 10px;
        cursor: pointer;

        input {
            accent-color: $primary-color-700;
            width: 16px;
            height: 16px;
        }
    }
}

textarea {
    width: 100%;
    min-height: 120px;
    border-radius: 10px;
    border: 1px solid $primary-color-400;
    padding: 10px 12px;
    resize: none;

    &:focus {
        border-color: $primary-color-700;
        outline: none;
    }
}

.btn-group {
    margin-top: 12px;
    display: flex;
    justify-content: space-between;
    gap: 24px;
    height: 40px;
}

.custom-scrollbar {
    &::-webkit-scrollbar {
        width: 4px;
    }

    &::-webkit-scrollbar-thumb {
        background: $neutral-color-400;
        border-radius: 4px;
    }
}
</style>