// 收藏 API 封裝，提供加入、移除、查詢、取得收藏清單功能
// 使用 axios 發送請求，請根據實際 API 路徑調整 API_URL
import { phpApi } from '@/utils/publicApi';

// API 路徑由 phpApi 實例管理，僅需指定 endpoint
const API_ENDPOINT = 'social/favorites.php';

/**
 * 加入收藏
 * @param {number} user_id - 使用者ID
 * @param {number} recipe_id - 食譜ID
 * @param {number|null} folder_id - 收藏夾ID（可選）
 * @returns {Promise}
 */
export const addFavorite = (user_id, recipe_id, folder_id = null) => {
    const formData = new FormData();
    formData.append('user_id', user_id);
    formData.append('recipe_id', recipe_id);
    if (folder_id) formData.append('folder_id', folder_id);
    // 預設 action 為 add
    return phpApi.post(API_ENDPOINT, formData);
};

/**
 * 取消收藏
 * @param {number} user_id - 使用者ID
 * @param {number} recipe_id - 食譜ID
 * @returns {Promise}
 */
export const removeFavorite = (user_id, recipe_id) => {
    const formData = new FormData();
    formData.append('user_id', user_id);
    formData.append('recipe_id', recipe_id);
    formData.append('action', 'remove');
    return phpApi.post(API_ENDPOINT, formData);
};

/**
 * 查詢是否已收藏
 * @param {number} user_id - 使用者ID
 * @param {number} recipe_id - 食譜ID
 * @returns {Promise}
 */
export const checkFavorite = (user_id, recipe_id) => {
    return phpApi.get(API_ENDPOINT, { params: { user_id, recipe_id } });
};

/**
 * 取得收藏清單
 * @param {number} user_id - 使用者ID
 * @returns {Promise}
 */
export const getFavorites = (user_id) => {
    return phpApi.get(API_ENDPOINT, { params: { user_id } });
};
