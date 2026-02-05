/**
* 編輯個人檔案彈窗組件
*/
<script setup>
import { ref, watch } from 'vue';
import BaseBtn from '@/components/common/BaseBtn.vue';

const props = defineProps({
    show: Boolean,
    userProfile: Object
});

const emit = defineEmits(['close', 'save']);

const formData = ref({
    username: '',
    role: '',
    coverImage: '',
    avatar: '',
    coverImageFile: null,  // 新增：儲存封面圖檔案
    avatarFile: null       // 新增：儲存頭像檔案
});

const maxRoleLength = 30;
const coverImageInput = ref(null);
const avatarInput = ref(null);

// 圖片驗證設定
const ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/png', 'image/webp'];
const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB

/**
 * 驗證圖片檔案
 */
const validateImage = (file) => {
    // 檢查檔案類型
    if (!ALLOWED_IMAGE_TYPES.includes(file.type)) {
        alert('請上傳 JPG、PNG 或 WebP 格式的圖片');
        return false;
    }

    // 檢查檔案大小
    if (file.size > MAX_FILE_SIZE) {
        alert('圖片大小不可超過 5MB');
        return false;
    }

    return true;
};

watch(() => props.userProfile, (newVal) => {
    if (newVal) {
        formData.value = {
            username: newVal.username || '',
            role: newVal.role || '',
            coverImage: newVal.coverImage || '',
            avatar: newVal.avatar || '',
            coverImageFile: null,
            avatarFile: null
        };
    }
}, { immediate: true });

const handleClose = () => {
    // 重置為原始資料
    if (props.userProfile) {
        formData.value = {
            username: props.userProfile.username || '',
            role: props.userProfile.role || '',
            coverImage: props.userProfile.coverImage || '',
            avatar: props.userProfile.avatar || '',
            coverImageFile: null,
            avatarFile: null
        };
    }

    // 清空檔案 input
    if (coverImageInput.value) coverImageInput.value.value = '';
    if (avatarInput.value) avatarInput.value.value = '';

    emit('close');
};

const handleSave = () => {
    emit('save', { ...formData.value });
    handleClose();
};

const handleEditCover = () => {
    coverImageInput.value?.click();
};

const handleCoverChange = (event) => {
    const file = event.target.files?.[0];
    if (file) {
        // 驗證圖片
        if (!validateImage(file)) {
            event.target.value = ''; // 清空 input
            return;
        }

        // 儲存檔案物件供上傳使用
        formData.value.coverImageFile = file;

        // 產生預覽圖
        const reader = new FileReader();
        reader.onload = (e) => {
            formData.value.coverImage = e.target.result;
        };
        reader.readAsDataURL(file);
    }
};

const handleEditAvatar = () => {
    avatarInput.value?.click();
};

const handleAvatarChange = (event) => {
    const file = event.target.files?.[0];
    if (file) {
        // 驗證圖片
        if (!validateImage(file)) {
            event.target.value = ''; // 清空 input
            return;
        }

        // 儲存檔案物件供上傳使用
        formData.value.avatarFile = file;

        // 產生預覽圖
        const reader = new FileReader();
        reader.onload = (e) => {
            formData.value.avatar = e.target.result;
        };
        reader.readAsDataURL(file);
    }
};
</script>

<template>
    <div v-if="show" class="edit-profile-modal-overlay" @click="handleClose">
        <div class="edit-profile-modal-container" @click.stop>
            <!-- 封面 -->
            <div class="cover-section">
                <img :src="formData.coverImage" alt="封面" class="cover-image">
                <input ref="coverImageInput" type="file" accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp"
                    @change="handleCoverChange" style="display: none;">
                <BaseBtn @click="handleEditCover" class="edit-cover-btn">編輯封面照</BaseBtn>
            </div>

            <!-- 頭像 -->
            <div class="avatar-section">
                <div class="avatar-wrapper" @click="handleEditAvatar">
                    <img :src="formData.avatar" alt="頭像" class="avatar-image">
                    <div class="avatar-overlay">
                        <span class="avatar-edit-text">更換頭像</span>
                    </div>
                </div>
                <input ref="avatarInput" type="file" accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp"
                    @change="handleAvatarChange" style="display: none;">
            </div>

            <!-- 表單 -->
            <div class="modal-content">
                <h3 class="modal-title">個人簡介</h3>

                <div class="form-group">
                    <label class="form-label">暱稱</label>
                    <input v-model="formData.username" type="text" class="form-input" placeholder="請輸入暱稱">
                </div>

                <div class="form-group">
                    <label class="form-label">狀態消息</label>
                    <div class="textarea-wrapper">
                        <textarea v-model="formData.role" class="form-textarea" placeholder="請輸入狀態消息"
                            :maxlength="maxRoleLength"></textarea>
                        <span class="char-count">{{ formData.role.length }}/{{ maxRoleLength }}</span>
                    </div>
                </div>

                <div class="button-group">
                    <BaseBtn @click="handleClose" class="cancel-btn">取消</BaseBtn>
                    <BaseBtn @click="handleSave" class="save-btn">儲存</BaseBtn>
                </div>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.edit-profile-modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.7);
    z-index: 9999;
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 20px;
    opacity: 1;
    visibility: visible;
}

.edit-profile-modal-container {
    background: white;
    border-radius: 16px;
    width: 100%;
    max-width: 600px;
    max-height: 90vh;
    overflow-y: auto;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
}

.cover-section {
    position: relative;
    width: 100%;
    height: 200px;
    overflow: hidden;
}

.cover-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.edit-cover-btn {
    position: absolute;
    bottom: 16px;
    right: 16px;
    font-size: 14px;
    font-weight: 500;
    z-index: 10;
}

.avatar-section {
    position: relative;
    margin-top: -60px;
    padding: 0 32px;
}

.avatar-wrapper {
    position: relative;
    width: 120px;
    height: 120px;
    cursor: pointer;

    &:hover .avatar-overlay {
        opacity: 1;
    }
}

.avatar-image {
    width: 120px;
    height: 120px;
    border-radius: 50%;
    border: 4px solid white;
    object-fit: cover;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    display: block;
}

.avatar-overlay {
    position: absolute;
    top: 0;
    left: 0;
    width: 120px;
    height: 120px;
    border-radius: 50%;
    background: rgba(0, 0, 0, 0.6);
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0;
    transition: opacity 0.3s ease;
}

.avatar-edit-text {
    color: white;
    font-size: 14px;
    font-weight: 500;
}

.modal-content {
    padding: 24px 32px 32px;
}

.modal-title {
    margin-bottom: 24px;
    color: #1A1A1A;
    font-size: 20px;
    font-weight: 600;
}

.form-group {
    margin-bottom: 20px;

    &:last-of-type {
        margin-bottom: 32px;
    }
}

.form-label {
    display: block;
    margin-bottom: 8px;
    color: #4A4A4A;
    font-size: 14px;
    font-weight: 500;
}

.form-input {
    width: 100%;
    padding: 12px 16px;
    border: 1px solid #E0E0E0;
    border-radius: 8px;
    font-size: 14px;
    color: #1A1A1A;
    transition: all 0.3s ease;
    box-sizing: border-box;

    &:focus {
        outline: none;
        border-color: #6B46C1;
        box-shadow: 0 0 0 3px rgba(107, 70, 193, 0.1);
    }

    &::placeholder {
        color: #999;
    }
}

.textarea-wrapper {
    position: relative;
}

.form-textarea {
    width: 100%;
    padding: 12px 16px 32px 16px;
    border: 1px solid #E0E0E0;
    border-radius: 8px;
    font-size: 14px;
    color: #1A1A1A;
    resize: vertical;
    min-height: 80px;
    font-family: inherit;
    transition: all 0.3s ease;
    box-sizing: border-box;

    &:focus {
        outline: none;
        border-color: #6B46C1;
        box-shadow: 0 0 0 3px rgba(107, 70, 193, 0.1);
    }

    &::placeholder {
        color: #999;
    }
}

.char-count {
    position: absolute;
    bottom: 8px;
    right: 12px;
    font-size: 12px;
    color: #999;
    pointer-events: none;
}

.button-group {
    display: flex;
    gap: 12px;
    justify-content: flex-end;
}

.save-btn,
.cancel-btn {
    min-width: 100px;
}

@media screen and (max-width: 810px) {
    .modal-container {
        max-width: 100%;
        border-radius: 12px;
    }

    .modal-content {
        padding: 20px 16px 24px;
    }

    .avatar-section {
        padding: 0 16px;
    }

    .avatar-image {
        width: 100px;
        height: 100px;
    }

    .cover-section {
        height: 160px;
    }
}
</style>