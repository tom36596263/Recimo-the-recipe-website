import { createApp } from 'vue'
import { createPinia } from 'pinia' // 引入 Pinia
import App from './App.vue'
import router from './router' // 引入路由設定
import '@/assets/scss/base/_reset.scss' //引入全域css reset
import '@/assets/scss/main.scss' // 引入全域樣式
import '@fortawesome/fontawesome-free/css/all.css' // 引入fontawesome
import { parsePublicFile } from '@/utils/parseFile'// 引入圖片路徑的全域變數
import VCalendar from 'v-calendar'; // 引入日期套件
import 'v-calendar/style.css'; // 日期套件的樣式
import GoogleSignInPlugin from 'vue3-google-signin' // 第三方登入(GOOGLE)

const app = createApp(App) // 建立 Vue 應用程式實體
const pinia = createPinia() // 建立 Pinia 全域狀態管理實體

app.use(pinia) // 插件：啟用 Pinia 狀態管理
app.use(router) // 插件：啟用 Vue Router 路由導覽
app.use(VCalendar, {}); // 插件：啟用VCalendar
app.config.globalProperties.$parsePublicFile = parsePublicFile //設定全域屬性

// google登入用
app.use(GoogleSignInPlugin, {
    clientId: import.meta.env.VITE_GOOGLE_CLIENT_ID,
})

// Facebook登入用
function initFacebookSDK() {
    window.fbAsyncInit = function () {
        window.FB.init({
            appId: '25884304981181407',
            cookie: true,
            xfbml: true,
            version: 'v18.0'
        });
    };

    (function (d, s, id) {
        var js, fjs = d.getElementsByTagName(s)[0];
        if (d.getElementById(id)) return;
        js = d.createElement(s); js.id = id;
        js.src = "https://connect.facebook.net/zh_TW/sdk.js";
        fjs.parentNode.insertBefore(js, fjs);
    }(document, 'script', 'facebook-jssdk'));
}

initFacebookSDK();

app.mount('#app') // 將應用程式掛載至 index.html 的 #app 容器，正式啟動渲染