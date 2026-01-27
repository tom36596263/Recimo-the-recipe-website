<script setup>
import { ref, computed, onMounted } from 'vue';

</script>

<template>
    <div class="time">
        <div class="time__title p-p1">
            <i-material-symbols-alarm />
            製作時間
        </div>

        <div class="time__total-time zh-h3-bold">
            45分鐘
        </div>

        <div class="time__bar">
            <div class="used-time"></div>
            <div class="estimate-time"></div>
            <span class="estimate-time__text">+0.125%</span>
        </div>
        <div class="estimate-time-desc p-p2">預估時間：40分鐘</div>
    </div>
</template>

<style lang="scss" scoped>
.time {
    flex-shrink: 0;
    flex: 1;
    min-width: 150px;
    height: 150px;
    background-color: $neutral-color-white;
    border-radius: 10px;
    padding: 30px 20px;
    margin-left: -10px;
    border: 1px solid $primary-color-800;

    &__title {
        display: flex;
        align-items: center;
        color: $neutral-color-800;
    }

    &__total-time {
        color: $neutral-color-black;
    }

    &__bar {
        position: relative;
        display: flex;

        .used-time {
            height: 15px;
            width: 135px;
            border-radius: 10px;
            background-color: $secondary-color-danger-700;
        }

        .estimate-time {
            height: 15px;
            width: 120px;
            border-radius: 10px;
            background-color: $primary-color-100;
            position: absolute;


            &__text {
                color: $secondary-color-danger-700;
            }
        }

    }
}
</style>