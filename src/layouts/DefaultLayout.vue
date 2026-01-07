<template>
    <div class="default-layout">
        <header class="site-header">
            <div class="container">
                <div class="logo">
                    <router-link to="/">Recimo</router-link>
                </div>
                <nav class="site-nav">
                    <router-link to="/">首頁</router-link>
                    <router-link to="/about">關於Recimo</router-link>
                    <router-link to="/recipes">食譜總覽</router-link>
                    <router-link to="/mall">Recimo商城</router-link>
                    <router-link to="/benefits">會員權益</router-link>
                    <router-link to="/cart">購物車</router-link>

                    <router-link to="/workspace" class="login-btn">進入工作區</router-link>
                </nav>
            </div>
        </header>

        <main class="main-content">
            <router-view />
        </main>

        <footer class="site-footer">
            <div class="container">
                <p>這裡是footer</p>
            </div>
        </footer>
    </div>
</template>

<script setup>
/**
 * 暫時移除 handleLoginClick 邏輯，
 * 等待未來串接登入燈箱與 Pinia。
 */
</script>

<style lang="scss" scoped>
.default-layout {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
}

.site-header {
    background-color: #fff;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
    position: sticky;
    top: 0;
    z-index: 100;

    .container {
        max-width: 1200px;
        margin: 0 auto;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 15px 20px;
    }

    .logo a {
        font-size: 24px;
        font-weight: bold;
        color: $primary-color-800;
        text-decoration: none;
    }
}

.site-nav {
    display: flex;
    gap: 25px;
    align-items: center;

    a {
        text-decoration: none;
        color: #444;
        transition: color 0.3s;

        &:hover {
            color: $primary-color-800;
        }

        &.router-link-active:not(.login-btn) {
            color: $primary-color-800;
            font-weight: bold;
        }
    }

    // 讓 router-link 看起來依然像原本的按鈕
    .login-btn {
        background-color: $primary-color-800;
        color: white;
        padding: 8px 20px;
        border-radius: 20px;
        text-decoration: none;
        font-weight: normal; // 覆蓋 router-link-active 的加粗

        &:hover {
            opacity: 0.9;
            color: white; // 確保 hover 時文字顏色不變
        }
    }
}

.main-content {
    flex: 1;
}

.site-footer {
    background-color: #f9f9f9;
    padding: 40px 0;
    text-align: center;
    border-top: 1px solid #eee;
    color: #888;
}
</style>