
const publicBase = import.meta.env.VITE_BASE || import.meta.env.BASE_URL || '/';
const fileBase = import.meta.env.VITE_FILE_URL;

/**
 * @param {string} imgURL - 圖片路徑或檔名
 * @param {boolean} isStatic - 是否為前端 public 資料夾下的資源 (預設 false)
 */
export const parsePublicFile = (imgURL, isStatic = false) => {
    if (!imgURL) return '';
    if (imgURL.startsWith('http')) return imgURL;

    if (isStatic) {
        // 處理前端 public 路徑
        return `${fileBase}/${imgURL}`.replace(/\/+/g, '/');
    }

    // 處理後端 PHP 圖片路徑
    return `${fileBase}${imgURL}`;
}

// const base = import.meta.env.BASE_URL
// export const parsePublicFile = (imgURL) => {
//     return `${base}${imgURL}`
// }

// const fileBase = import.meta.env.VITE_FILE_URL;

// export const parsePublicFile = (imgURL) => {
//     if (!imgURL) return '';
    
//     // 如果路徑已經是 http 開頭（完整網址），則直接回傳
//     if (imgURL.startsWith('http')) return imgURL;

//     // 否則拼接後端圖片存放目錄
//     return `${fileBase}${imgURL}`;
// }

// const fileBase = import.meta.env.VITE_FILE_URL; // 後端路徑
// const publicBase = import.meta.env.BASE_URL;    // 前端 public 路徑

// export const parsePublicFile = (imgURL, isStatic = false) => {
//     if (!imgURL) return '';
//     if (imgURL.startsWith('http')) return imgURL;

//     // 如果 isStatic 為 true，走前端 public 路線
//     if (isStatic) {
//         // Vite 規範中，public 下的檔案直接用 /filename 即可
//         return `${publicBase}${imgURL}`.replace(/\/+/g, '/'); 
//     }

//     // 否則走後端 API 圖片路線
//     return `${fileBase}${imgURL}`;
// }