<script setup>
import { defineProps, defineEmits } from 'vue';
import BaseModal from '@/components/BaseModal.vue';
import BaseBtn from '@/components/common/BaseBtn.vue';

const props = defineProps({
    isOpen: {
        type: Boolean,
        default: false
    }
});

const emit = defineEmits(['close']);
</script>

<template>
    <BaseModal :is-open="isOpen" type="success" icon-class="fa-solid fa-circle-check" title="成品圖上傳成功！"
        description="太棒了！你的料理成果已經成功分享。" @close="$emit('close')">
        <template #actions>
            <BaseBtn title="太好了！" width="100%" height="40" @click="$emit('close')" />
        </template>
    </BaseModal>
</template>

<style scoped lang="scss">
@import '@/assets/scss/abstracts/_color.scss';

:deep(.modal-card) {
    /* 調整為適合展示成功的比例 */
    height: auto !important;
    min-height: 250px;
    padding-bottom: 60px;
}

/* 讓圖示顏色更明亮一點（選用） */
:deep(.modal-icon) {
    color: $primary-color-100;
    margin-bottom: 20px;
}

:deep(.btn-group) {
    margin-top: 25px;
}
</style>