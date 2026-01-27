<script setup>
import { ref } from 'vue';
import StepOrder from './StepOrder.vue';

const props = defineProps({
    order: Number,
    initialNote: String,
    initialImage: String
});

// 建立一個本地的圖片路徑，初始值設為從 RecipeGuide 傳來的圖片
const localImage = ref(props.initialImage);

// 處理檔案上傳
const handleFileChange = (event) => {
    const file = event.target.files[0];
    if (file) {
        // 產生一個暫時的預覽 URL
        localImage.value = URL.createObjectURL(file);

        // 【進階建議】如果之後要儲存，可以在這裡 emit 給父元件，或者直接更新 Store
        // emit('update:image', file); 
    }
};
</script>

<template>
    <div class="card">
        <StepOrder :order="order" />

        <div class="card__note-wrapper">
            <input type="text" class="card__note-text" :value="initialNote" placeholder="點擊添加筆記...">

            <div class="card__note-pic-upload">
                <input type="file" :id="'file-' + order" accept="image/*" @change="handleFileChange"
                    style="display: none;">

                <label :for="'file-' + order" class="upload-label">
                    <img v-if="localImage" :src="localImage" class="preview-img">

                    <div v-else class="log__upload-text">
                        <i-material-symbols-image-outline />
                    </div>
                </label>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.card {
    display: flex;
    gap: 5px;


    &__note-wrapper {
        display: flex;
        height: 100px;
        width: 100%;
        background-color: $neutral-color-white;
        justify-content: center;
        padding: 5px 10px;
        border-radius: 10px;
        gap: 10px;
        border: 1px solid $primary-color-800;

    }

    &__note-text {
        display: block;
        flex: 1;
        border: none;

        &:focus {
            outline: none;
            box-shadow: none;
        }
    }

    &__note-pic-upload {
        width: 96px;
        height: 80px;
        border: 1px dashed $neutral-color-400;
        border-radius: 10px;
        flex-shrink: 0;
        overflow: hidden;

        .upload-label {
            width: 100%;
            height: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            cursor: pointer;
        }

        .preview-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }

        .log__upload-text {
            color: $neutral-color-400;
            font-size: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        p {
            display: flex;
            justify-content: center;
            align-items: center;
        }
    }
}
</style>