<script setup>
import { defineProps, defineEmits, computed } from 'vue';
import BaseModal from '@/components/BaseModal.vue';
import BaseBtn from '@/components/common/BaseBtn.vue';

const props = defineProps({
    isOpen: {
        type: Boolean,
        default: false
    },
    mode: {
        type: String, // 'create', 'fork', 'update'
        default: 'create'
    }
});

const emit = defineEmits(['close', 'update:isOpen']);

// 根據模式顯示不同文字
const content = computed(() => {
    switch (props.mode) {
        case 'fork':
            return { title: '食譜改編成功！', desc: '你已成功將這份靈感轉化為自己的美味食譜。' };
        case 'update':
            return { title: '食譜更新成功！', desc: '你的變更已經成功儲存並同步。' };
        default: // 'create'
            return { title: '食譜發布成功！', desc: '太棒了！你的食譜已經正式上架分享。' };
    }
});

const handleClose = () => {
    emit('close');
    emit('update:isOpen', false);
};
</script>

<template>
    <BaseModal :is-open="isOpen" type="success" icon-class="fa-solid fa-circle-check" :title="content.title"
        :description="content.desc" @close="handleClose">
        <template #actions>
            <BaseBtn title="太好了！" width="100%" height="40" @click="handleClose" />
        </template>
    </BaseModal>
</template>

<style scoped lang="scss">
@import '@/assets/scss/abstracts/_color.scss';

:deep(.modal-card) {
    height: auto !important;
    min-height: 250px;
    padding-bottom: 60px;
}

:deep(.modal-icon) {
    color: $primary-color-100;
    margin-bottom: 20px;
}

:deep(.btn-group) {
    margin-top: 25px;
}
</style>