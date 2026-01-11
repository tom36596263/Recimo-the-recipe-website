<script setup></script>
<template>
    <div class="card">
        <header><img >圖片</header>

        <div>
            <p>內容<slot></slot></p>
        </div>
        
        <footer>可以插入btn</footer>
    </div>
</template>
<style lang="scss" scoped>
    .card{
        border: 1px solid #444;
    }
</style>