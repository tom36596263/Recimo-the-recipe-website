<script setup></script>
<template>
    <div class="hero-banner">
        <img src="@/assets/images/about/about-bg.jpg" 
        alt="about banner"
        />
        <div class="content-overlay">
            <div class="title">
                <h1 class="zh-h2">關於Recimo</h1>
            </div>
            
        </div>
    </div>
</template>
<style lang="scss" scoped>
    .hero-banner{
        position: relative;
        .title{
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: $neutral-color-white;
        }
    }
    
</style>