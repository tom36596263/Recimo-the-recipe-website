<script setup>
import { defineProps, defineEmits } from 'vue';
import BaseModal from '@/components/BaseModal.vue';
import BaseBtn from '@/components/common/BaseBtn.vue';

const props = defineProps({
    isOpen: {
        type: Boolean,
        default: false
    },
    // 新增 mode 判定，或是直接傳標題進來
    mode: {
        type: String, // 'create' 或 'fork' (改編)
        default: 'create'
    }
});

const emit = defineEmits(['close']);

// 根據模式顯示不同文字
const content = computed(() => {
    return props.mode === 'fork'
        ? { title: '食譜改編成功！', desc: '你已成功將這份靈感轉化為自己的美味食譜。' }
        : { title: '食譜發布成功！', desc: '太棒了！你的食譜已經正式上架分享。' };
});
</script>

<template>
    <BaseModal :is-open="isOpen" type="success" icon-class="fa-solid fa-circle-check" :title="content.title"
        :description="content.desc" @close="$emit('close')">
        <template #actions>
            <BaseBtn title="太好了！" width="100%" height="40" @click="$emit('close')" />
        </template>
    </BaseModal>
</template>