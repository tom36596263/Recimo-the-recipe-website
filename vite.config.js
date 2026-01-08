// import { defineConfig } from 'vite'
// import vue from '@vitejs/plugin-vue'

// // https://vite.dev/config/
// export default defineConfig({
//   plugins: [vue()],
// })

import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import path from "path"; // 這是 Node.js 處理路徑的內建工具

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      // 1. 設定 @ 符號指向 src 資料夾
      "@": path.resolve(__dirname, "./src"),
    },
  },
  css: {
    preprocessorOptions: {
      scss: {
        // 2. 自動引入你的變數檔案（請確認你有建立 src/assets/scss/_variables.scss）
        // 注意：使用 modern 編譯器寫法
        additionalData:
        `@use "@/assets/scss/abstracts/_color.scss" as *;
        @use "@/assets/scss/abstracts/_font.scss" as *;`

      },
    },
  },
});
