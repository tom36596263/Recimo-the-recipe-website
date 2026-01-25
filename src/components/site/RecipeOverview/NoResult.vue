<script setup>
    import BaseBtn from '@/components/common/BaseBtn.vue';

    const props = defineProps({
        title: {
            type: String,
            default: '找不到符合條件的食譜'
        },
        description: {
            type: String,
            default: '推薦您前往「靈感廚房」用食材找食譜喔!'
        },
        buttons: {
            type: Array,
            default: () => [
                { title: '返回首頁', variant: 'outline', height: '40', emit: 'click-main' }
            ]
        }
    });
    const emit = defineEmits(['button-click']);
    const handleAction = (emitName) => {
        emit('button-click', emitName);
    };
</script>
<template>
    <div class="empty-content">
        <h3 class="zh-h3">{{title}}</h3>
        <p class="p-p1">{{description}}</p>
        <div class="btn-group">
            <BaseBtn 
            v-for="(btn, index) in buttons"
            :key="index"
            :title="btn.title"
            :variant="btn.variant || 'outline'"
            :height="btn.height || 40"
            @click="handleAction(btn.emit)"/>
        </div>
        
    </div>
</template>
<style lang="scss" scoped>
    .empty-content{
        text-align: center;
        margin: 30px 0 60px 0;
        .p-p1{
            margin-bottom: 12px;
        }
        .btn-group{
            display: flex;
            justify-content: center;
            gap: 10px;
        }
    }
</style>