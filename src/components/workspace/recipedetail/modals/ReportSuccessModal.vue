<script setup>
import { defineProps, defineEmits } from 'vue';
// 🏆 修正後的路徑
import BaseModal from '@/components/BaseModal.vue';
import BaseBtn from '@/components/common/BaseBtn.vue'; // 👈 加上 common 這一層

const props = defineProps({
    isOpen: {
        type: Boolean,
        default: false
    }
});

const emit = defineEmits(['close']);
</script>

<template>
    <BaseModal :is-open="isOpen" type="success" icon-class="fa-solid fa-circle-check" title="檢舉已提交"
        description="我們將會盡快審核檢舉內容並進行處理。" @close="$emit('close')">
        <template #actions>
            <BaseBtn title="我知道了" width="100%" height="40" @click="$emit('close')" />
        </template>
    </BaseModal>
</template>

<style scoped lang="scss">
/* 使用 :deep 穿透元件邊界 */
:deep(.modal-card) {
    /* 這裡設定你想要的高度 */
    height: 250px !important;
    padding-bottom: 60px;

    /* 如果你希望它是根據內容撐開但有最小高度 */
    min-height: 200px;
}

:deep(.btn-group) {
    margin-top: 15px;
}

</style>