import axios from 'axios'

// 優先抓取 .env.prod 裡的 VITE_BASE，若抓不到則用系統預設，最後保底為 '/'
const rawBase = import.meta.env.VITE_BASE || import.meta.env.BASE_URL || '/';

// 防呆：確保路徑結尾一定有 / (避免變成 ...recimodata/...)
export const base = rawBase.endsWith('/') ? rawBase : `${rawBase}/`;

export const publicApi = axios.create({
    baseURL: base,
    timeout: 5000
})

console.log('目前的 API 基準路徑為:', base); // 打開控制台可以看到目前抓到的路徑