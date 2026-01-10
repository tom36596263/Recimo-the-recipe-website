<script setup></script>
<template>
    <header class="hero">
        <h2>你的食譜，由你重新定義</h2>
        <h1>讓食譜隨你的靈感進化</h1>
        <h3>Recipe Inspiration evolution</h3>
        <p>這裡沒有標準答案，只有你對美食的熱情<br>
            隨手記下每一次烹飪的小發現，看見每一天自己的成長<br>
            把煮飯變成最療癒的創作</p>
        <button>尋找食譜</button>
        <img src="@/assets/images/site/hero.png" alt="首頁圖片">
    </header>
</template>
<style lang="scss" scoped>

        .hero{
            width:100%;
            height: 100vh;
            z-index: -1;
            display: flex;
            flex-direction: column;
            img{
                height:100vh;
                width:100%;
                z-index: -1;
                position: absolute;
                top:0;
                left:0;
                object-fit: cover;
            }
        }
    

</style>