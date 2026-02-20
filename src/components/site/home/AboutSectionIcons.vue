<script setup>
    import { ref, markRaw } from 'vue';
    import CircleIcon from '@/components/common/CircleIcon.vue';
    import IconWandStars from '~icons/material-symbols/Wand-Stars-outline';
    import IconLocalFireDepartment from '~icons/material-symbols/Local-Fire-Department-outline';
    import IconInboxTextPerson from '~icons/material-symbols/Inbox-Text-Person-outline';
    import IconHistoryEdu from '~icons/material-symbols/History-Edu-outline';

    const features = ref([
        { icon: markRaw(IconWandStars), text: '將官方食譜進化為<br>您的私房秘笈' },
        { icon: markRaw(IconLocalFireDepartment), text: '透過熱量計算<br>做有效的健康管理' },
        { icon: markRaw(IconInboxTextPerson), text: '告別選擇困難<br>輕鬆找尋合適的食譜' },
        { icon: markRaw(IconHistoryEdu), text: '食譜份量換算功能<br>客製化自己的菜餚' }
    ]);
</script>
<template>
    <div v-for="item in features" :key="item.text" class="col-3 col-lg-6 about-feature-item">
        <CircleIcon size="lg">
            <component :is="item.icon" />
        </CircleIcon>
        <p class="p-p1" v-html="item.text"></p>
    </div>
</template>

<style lang="scss" scoped>
    .about-feature{
        &-item{
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            margin: 30px 0;
            gap: 1rem;
        }
    }
</style>