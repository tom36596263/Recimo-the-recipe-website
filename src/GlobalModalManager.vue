<!-- 設置全域燈箱元件，在App.vue（最外層）放入這個管理元件，無論在哪一頁，燈箱都能彈出來 -->
<script setup>
import { useAuthStore } from '@/stores/authStore';
import { useRouter } from 'vue-router';

const authStore = useAuthStore();
const router = useRouter();

const handleGoLogin = () => {
    authStore.closeLoginAlert();
    router.push('/loginlightbox'); // 跳轉到登入燈箱
};
</script>
<template>
    <BaseModal :isOpen="authStore.isLoginAlertOpen" type="danger" title="請先登入" description="登入後即可享有完整功能，趕快前往登入吧~"
        iconClass="fa-solid fa-user-lock" @close="authStore.closeLoginAlert">
        <template #actions>
            <button class="btn-outline" @click="authStore.closeLoginAlert">再看看</button>
            <button class="btn-solid" @click="handleGoLogin">前往登入</button>
        </template>
    </BaseModal>
</template>
