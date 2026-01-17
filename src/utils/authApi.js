import axios from 'axios'
import Cookies from 'js-cookie'

export const base = import.meta.env.BASE_URL

// 建立實例
const authApi = axios.create({
    baseURL: base,
    timeout: 5000
})

// 請求攔截器：自動加上 token
authApi.interceptors.request.use(
    config => {
        const token = Cookies.get('token')
        if (token) {
            config.headers.Authorization = `Bearer ${token}`
        }

        // 可以加入 loading 狀態處理
        // loadingStore.setLoading(true)

        return config
    },
    error => {
        return Promise.reject(error)
    }
)

// 回應攔截器：統一錯誤處理
authApi.interceptors.response.use(
    response => {
        // loadingStore.setLoading(false)
        return response
    },
    error => {
        // loadingStore.setLoading(false)

        const status = error.response?.status

        if (status === 401) {
            alert('登入過期，請重新登入')
            // 清除 token、跳轉登入頁
            Cookies.remove('token')
            window.location.href = '/login'
        } else if (status === 500) {
            alert('伺服器錯誤，請稍後再試')
        }

        return Promise.reject(error)
    }
)

export default authApi