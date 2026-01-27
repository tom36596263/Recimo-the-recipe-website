<script setup>
import { ref, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router'; // 1. 補上 useRoute
import { publicApi } from '@/utils/publicApi';     // 2. 補上 publicApi (路徑請依你專案調整)
import { useCookingStore } from '@/stores/useCookingStore';

import LogTime from '../../components/workspace/cookinglog/LogTime.vue';
import LogRating from '../../components/workspace/cookinglog/LogRating.vue';
import LogDifficulty from '../../components/workspace/cookinglog/LogDifficulty.vue';
import LogStepcard from '../../components/workspace/cookinglog/LogStepcard.vue';

const route = useRoute();
const router = useRouter();
const cookingStore = useCookingStore();

const recipeId = Number(route.params.id);
const allSteps = ref([]);

const fetchData = async () => {
    try {
        const res = await publicApi.get('data/recipe/steps.json');
        allSteps.value = res.data.filter(step => step.recipe_id === recipeId);
    } catch (error) {
        console.error('抓取步驟失敗:', error);
    }
};

const saveAndGoLab = () => {
    router.push({ name: 'cooking-lab' });
};

onMounted(async () => {
    await fetchData();
});
</script>

<template>
    <div class="log container">
        <div class="log__header row">
            <div class="log__title zh-h1-bold col-12">美味上桌!烹飪完成</div>
        </div>

        <div class="log__body row">
            <div class="log__upload col-10">
                <label for="file-upload" class="log__upload-text">
                    <p>點擊上傳圖片</p>
                </label>

                <input type="file" id="file-upload" accept="image/*" style="display: none;">
            </div>

            <div class="log__dashboard col-10">
                <LogTime />
                <LogRating />
                <LogDifficulty />
            </div>

            <div class="log__note col-10">
                <div class="log__note-title zh-h2">
                    <i-material-symbols-edit-document />
                    筆記回顧
                </div>
                <LogStepcard v-for="(step, index) in allSteps" :key="step.step_id" :order="index + 1"
                    :initialNote="cookingStore.tempLogData.stepNotes[step.step_id]"
                    :initialImage="cookingStore.tempLogData.noteImages[step.step_id]" />
            </div>

            <div class="log__summary col-10">
                <div class="log__summary-title zh-h2">
                    <i-material-symbols-edit-document />
                    心得回顧
                </div>
                <input type="text" class="log__summary-text" placeholder="點擊添加筆記...">
            </div>
        </div>

        <div class="log__footer row">
            <div class="log__btn-wrapper col-10">

                <div class="log__back-btn p-p1">
                    返回步驟播放
                </div>
                <div class="log__finished-btn p-p1" @click="saveAndGoLab">
                    儲存
                </div>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.log {
    display: flex;
    flex-direction: column;
    gap: 20px;
    padding: 20px 0;

    &__header {
        display: flex;
        justify-content: center;
        width: 100%;
    }

    &__title {
        color: $primary-color-800;
        display: flex;
        justify-content: center;
    }

    &__body {
        width: 100%;
        display: flex;
        justify-content: center;
        background-color: $neutral-color-100;
        padding: 30px 0;
        gap: 20px;
        border-radius: 10px;
    }

    &__upload {
        height: 200px;
        border-radius: 10px;
        border: 1px dashed $neutral-color-400;

    }

    &__upload-text {
        width: 100%;
        height: 100%;
        display: flex;
        justify-content: center;
        align-items: center;
        cursor: pointer;
    }

    &__dashboard {
        display: flex;
        flex-wrap: nowrap;
        justify-content: space-between;
        gap: 1%;
    }

    &__note,
    &__summary {
        display: flex;
        flex-direction: column;
        gap: 10px;
    }

    &__note-title,
    &__summary-title {
        display: flex;
        align-items: center;
        color: $primary-color-800;
    }

    &__summary-text {
        width: 100%;
        border: none;
        height: 200px;
        border-radius: 10px;
        padding: 20px;
        border: 1px solid $primary-color-800;

        &:focus {
            outline: none;
            box-shadow: none;
        }
    }

    &__footer {
        display: flex;
        justify-content: center;
    }

    &__btn-wrapper {
        display: flex;
        flex-wrap: wrap;
        justify-content: flex-end;
        gap: 10px;
    }


    &__back-btn,
    &__finished-btn {
        width: auto;
        padding: 5px 10px;
        border-radius: 10px;
        cursor: pointer;
    }

    &__back-btn {
        background-color: $neutral-color-white;
        border: 1px solid $primary-color-800;
    }

    &__finished-btn {
        background-color: $primary-color-800;
        color: $neutral-color-white;
    }
}
</style>