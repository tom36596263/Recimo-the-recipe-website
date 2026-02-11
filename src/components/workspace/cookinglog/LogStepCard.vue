<script setup>
import { ref } from 'vue';
import { useCookingStore } from '@/stores/useCookingStore';
import StepOrder from './StepOrder.vue';

const props = defineProps({
    stepId: Number,
    order: Number,
    initialNote: String,
    initialImage: String,
    description: String
});

const emit = defineEmits(['open-desc']);

const cookingStore = useCookingStore();
const localImage = ref(props.initialImage);

const handleFileChange = (event) => {
    const file = event.target.files[0];
    if (file) {
        const url = URL.createObjectURL(file);
        localImage.value = url;
        cookingStore.tempLogData.noteImages[props.stepId] = url;


        if (!cookingStore.tempLogData.noteImageFiles) {
            cookingStore.tempLogData.noteImageFiles = {};
        }
        cookingStore.tempLogData.noteImageFiles[props.stepId] = file;
    }
};

const handleNoteInput = (event) => {
    cookingStore.tempLogData.stepNotes[props.stepId] = event.target.value;
};

const openModal = () => {
    emit('open-desc', {
        order: props.order,
        description: props.description
    });
};
</script>

<template>
    <div class="card">
        <div class="step-btn-wrapper" @click.stop="openModal">
            <StepOrder :order="order" />
        </div>

        <div class="card__note-wrapper">
            <input type="text" class="card__note-text" :value="initialNote" @input="handleNoteInput"
                placeholder="點擊添加筆記...">

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

    // .step-btn-wrapper {
    //     cursor: pointer;
    //     transition: transform 0.3s;
    //     flex-shrink: 0;

    //     &:hover {
    //         scale: 1.1;
    //     }
    // }

    &__note-wrapper {
        display: flex;
        height: 100px;
        width: 100%;
        background-color: $neutral-color-white;
        justify-content: center;
        padding: 5px 10px;
        border-radius: 10px;
        gap: 10px;
        border: 1px solid $neutral-color-400;
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
    }
}
</style>