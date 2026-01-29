// const base = import.meta.env.BASE_URL
// export const parsePublicFile = (imgURL) => {
//     return `${base}${imgURL}`
// }

const fileBase = import.meta.env.VITE_FILE_URL;

export const parsePublicFile = (imgURL) => {
    if (!imgURL) return '';
    
    // 如果路徑已經是 http 開頭（完整網址），則直接回傳
    if (imgURL.startsWith('http')) return imgURL;

    // 否則拼接後端圖片存放目錄
    return `${fileBase}${imgURL}`;
}