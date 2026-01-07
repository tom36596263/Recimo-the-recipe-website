// // src/stores/authStore.js
// import { defineStore } from 'pinia';

// export const useAuthStore = defineStore('auth', {
//     state: () => ({
//         isLoggedIn: localStorage.getItem('isLoggedIn') === 'true', // 從本地讀取登入狀態
//         isLoginModalOpen: false // 控制登入燈箱的顯示/隱藏
//     }),
//     actions: {
//         // 開啟登入燈箱
//         openLoginModal() {
//             this.isLoginModalOpen = true;
//         },
//         // 關閉登入燈箱
//         closeLoginModal() {
//             this.isLoginModalOpen = false;
//         },
//         // 登入成功
//         login() {
//             this.isLoggedIn = true;
//             localStorage.setItem('isLoggedIn', 'true');
//             this.closeLoginModal();
//         }
//     }
// });