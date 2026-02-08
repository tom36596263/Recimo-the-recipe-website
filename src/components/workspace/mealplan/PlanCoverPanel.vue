<script setup>
import { ref, computed, onMounted } from 'vue';
import { phpApi } from '@/utils/publicApi';
import { parsePublicFile } from '@/utils/parseFile.js';
import { useAuthStore } from '@/stores/authStore';

const authStore = useAuthStore();

const props = defineProps({
    templates: { type: Array, default: () => [] },
    planId: { type: [Number, String], required: true },
    currentCustomUrl: { type: String, default: null }
});

const emit = defineEmits(['close', 'select', 'uploaded']);
const closePanel = () => { emit("close") };

const fileInput = ref(null);

const triggerUpload = () => {
    if (fileInput.value) {
        fileInput.value.click();
    }
};

const onFileChange = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const formData = new FormData();
    formData.append('cover_image', file);
    // 轉型為字串傳送，確保後端接收正確
    formData.append('plan_id', String(props.planId));
    formData.append('user_id', String(authStore.userId));

    try {
        // 🟢 關鍵點：顯式設定 Content-Type 為 undefined
        // 這會移除預設的 application/json，讓瀏覽器自動生成 multipart/form-data boundary
        const res = await phpApi.post('mealplans/upload_plan_cover.php', formData, {
            headers: {
                'Content-Type': undefined
            }
        });

        if (res.data.success) {
            emit('uploaded', res.data.url);
            emit('close');
        } else {
            console.error('後端錯誤:', res.data);
            alert('上傳失敗: ' + (res.data.error || '未知錯誤'));
        }
    } catch (err) {
        console.error('上傳請求失敗', err);
        // 顯示更詳細的錯誤資訊
        const msg = err.response?.data?.error || err.message;
        alert('網路錯誤：' + msg);
    } finally {
        e.target.value = ''; // 清空 input 確保可重複選取
    }
};

const selectTemplate = (item) => {
    emit('select', { type: 1, id: item.cover_template_id });
};

const selectCustom = () => {
    emit('select', { type: 2, id: null });
};
</script>

<template>
    <Teleport to="body">
        <div class="overlay" @click.self="emit('close')">
            <div class="cover-panel">
                <div class="cover-panel__body">
                    <div class="grid-container">
                        <div class="cover-card cover-card--special" @click="triggerUpload">
                            <i-material-symbols-add-rounded />
                            <input type="file" ref="fileInput" hidden accept="image/*" @change="onFileChange" />
                        </div>

                        <div v-if="currentCustomUrl" class="cover-card cover-card--uploaded" @click="selectCustom">
                            <img :src="parsePublicFile(currentCustomUrl)" alt="Custom Cover" />
                            <div class="cover-card__name">我的圖片</div>
                        </div>

                        <div v-for="item in templates" :key="item.cover_template_id" class="cover-card"
                            @click="selectTemplate(item)">
                            <img :src="parsePublicFile(item.template_url)" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </Teleport>
</template>

<style lang="scss" scoped>
.overlay {
    z-index: 1000;
    position: fixed;
    bottom: 0;
    right: 0;
    width: 510px;
    height: 100vh;
    background-color: rgba($neutral-color-black, 0.3);
    display: flex;
    justify-content: center;
    align-items: flex-end;
}

.cover-panel {
    bottom: 0;
    width: 450px;
    height: 80vh;
    background-color: $neutral-color-white;
    border-radius: 10px 10px 0 0;
    padding: 20px;

    &__header {
        display: flex;
        justify-content: space-between;
    }

    &__title {
        color: $primary-color-800;
    }

    &__close-btn {
        color: $neutral-color-700;
    }
}

.grid-container {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 15px;
    margin-top: 20px;
    max-height: 60vh;
    overflow-y: auto;
    padding-right: 5px;
}

.cover-card {
    aspect-ratio: 1 /1;
    background-color: $neutral-color-100;
    border-radius: 12px;
    cursor: pointer;
    position: relative;
    overflow: hidden;
    border: 2px solid transparent;
    transition: 0.3s;

    img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    &__name {
        position: absolute;
        bottom: 0;
        width: 100%;
        background: rgba($neutral-color-black, 0.4);
        color: #fff;
        font-size: 12px;
        text-align: center;
        padding: 2px 0;
        opacity: 0;
        transition: 0.3s;
    }

    &:hover {
        border-color: $primary-color-400;

        .cover-card__name {
            opacity: 1;
        }
    }

    &--special,
    &--system {
        display: flex;
        justify-content: center;
        align-items: center;
        color: $neutral-color-400;
        background: $neutral-color-100;
        border: 2px dashed $neutral-color-400;

        svg {
            font-size: 30px;
        }
    }
}
</style>