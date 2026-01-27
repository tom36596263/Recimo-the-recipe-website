<script setup>
import { ref, computed, onMounted } from 'vue';

</script>

<template>
    <div class="difficulty">

        <div class="difficulty__title p-p1">
            <i-material-symbols-neurology />
            製作難易度
        </div>

        <div class="difficulty__skill p-p3">
            <span class="difficulty__skill-text">烹飪技法：</span>
            <div class="difficulty__skill-level">
                <span class="easy">簡單</span>
                <span class="mid">中等</span>
                <span class="hard">困難</span>
            </div>
        </div>

        <div class="difficulty__process p-p3">
            <span class="difficulty__process-text">製作流程：</span>
            <div class="difficulty__process-level">
                <span class="easy">簡單</span>
                <span class="mid">中等</span>
                <span class="hard">困難</span>
            </div>

        </div>

    </div>
</template>

<style lang="scss" scoped>
.difficulty {
    flex-shrink: 0;
    flex: 1;
    min-width: 150px;
    height: 150px;
    background-color: $neutral-color-white;
    border-radius: 10px;
    padding: 30px 20px;
    display: flex;
    flex-direction: column;
    gap: 3px;
    margin-right: -10px;
    border: 1px solid $primary-color-800;

    &__title {
        display: flex;
        align-items: center;
        color: $neutral-color-800;
    }

    &__skill,
    &__process {
        display: flex;
        color: $neutral-color-black;
        display: flex;
        align-items: center;
    }

    &__skill-level,
    &__process-level {
        width: 150px;
        display: flex;
        justify-content: space-around;
        background-color: $primary-color-100;
        border-radius: 10px;

        .easy,
        .mid,
        .hard {
            width: 50px;
            height: 30px;
            display: flex;
            justify-content: center;
            align-items: center;
            border-radius: 10px;
        }

        .easy {
            color: $neutral-color-white;
            background-color: $primary-color-800;
            cursor: pointer;
        }
    }

}
</style>