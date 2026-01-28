import axios from 'axios'

const apiBase = import.meta.env.VITE_API_BASE;
// 檢查變數是否真的有抓到
if (!apiBase) {
    console.error('錯誤：找不到 VITE_API_BASE 環境變數，請檢查 .env 檔案並重啟 npm run dev');
}

console.log('目前的 PHP API 基準路徑為:', apiBase);
// 優先抓取 .env.prod 裡的 VITE_BASE，若抓不到則用系統預設，最後保底為 '/'
const rawBase = import.meta.env.VITE_BASE || import.meta.env.BASE_URL || '/';

// 防呆：確保路徑結尾一定有 / (避免變成 ...recimodata/...)
export const base = rawBase.endsWith('/') ? rawBase : `${rawBase}/`;

export const publicApi = axios.create({
    baseURL: base,
    timeout: 5000
})

export const getRemoveBgIngredientsApi = axios.create({
    baseURL: apiBase, // 確保結尾有斜線
    timeout: 5000,
    headers: { 'Content-Type': 'application/json' }
})

console.log('目前的 API 基準路徑為:', base); // 打開控制台可以看到目前抓到的路徑