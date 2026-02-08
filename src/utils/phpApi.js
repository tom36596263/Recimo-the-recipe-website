import axios from 'axios';

// 🏆 彈性關鍵：從環境變數抓取後端地址
const apiBase = import.meta.env.VITE_API_BASE;

export const phpApi = axios.create({
    baseURL: apiBase, // 打包時會自動切換成伺服器地址
    timeout: 15000
});