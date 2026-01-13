<script setup>
    
</script>

<template>
    <div class="tips-btn">
        <div class="icon-circle">
            <i-material-symbols-Note-Stack-outline />
        </div>
        <div class="tips-text">
            <h4 class="zh-h4">隨心編寫靈活筆記</h4>
            <p class="p-p1">在實作中隨手記下，同步筆記美味步驟永不遺失</p>
        </div>
        
    </div>
</template>

<style lang="scss" scoped>
    @mixin flex-center($direction: row){
        display: flex;
        flex-direction: $direction;
        align-items: center;
        justify-content: center;
    }
    .tips-btn{
        display: flex;
        .icon-circle{
            @include flex-center;
            width: 70px;
            height: 70px; 
            background-color: $neutral-color-white;
            border-radius: $radius-pill;
            font-size: 32px;
            color: $primary-color-700;
            transition: transform 0.3s ease;
            &:hover{
                transform: scale(1.1);
            }
        } 
    }
</style>