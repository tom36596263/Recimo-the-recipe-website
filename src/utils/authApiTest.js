import axios from 'axios'

export const base = import.meta.env.BASE_URL

export const authApiTest = axios.create({
    baseURL: base,
    timeout: 5000,
})

// 攔截器