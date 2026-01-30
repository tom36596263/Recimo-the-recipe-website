import axios from 'axios';

const request = axios.create({
    baseURL: 'http://localhost:8888/recimo_api/',
});

// 🏆 確保這裡使用 export const，並且函式能接收 action 參數
export const commentAPI = {
    // 取得留言 (GET)
    getComments: (recipeId) => request.get(`social/comment_get.php?recipe_id=${recipeId}`),

    // 新增留言 (POST)
    postComment: (data) => request.post('social/comment_post.php', data),

    // 按讚留言 + 取消按讚留言
    likeComment: (data) => request.post('social/comment_like.php', data),

    //刪除留言
    deleteComment: (data) => request.post('social/comment_delete.php', data)
};