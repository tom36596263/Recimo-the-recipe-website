<script setup>
import { ref, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { phpApi } from '@/utils/publicApi';
import { useCookingStore } from '@/stores/useCookingStore';

import LogTime from '../../components/workspace/cookinglog/LogTime.vue';
import LogRating from '../../components/workspace/cookinglog/LogRating.vue';
import LogDifficulty from '../../components/workspace/cookinglog/LogDifficulty.vue';
import LogStepcard from '../../components/workspace/cookinglog/LogStepcard.vue';

const route = useRoute();
const router = useRouter();
const cookingStore = useCookingStore();

const recipeId = Number(route.params.recipeId);
const allSteps = ref([]);

// 🟢 修正 1：補上難度對照表，否則 saveAndGoLab 會報錯
const difficultyMap = {
    '簡單': 1,
    '中等': 2,
    '困難': 3
};

const fetchData = async () => {
    try {
        const response = await phpApi.get(`guide/get_guide_details.php?id=${recipeId}`);
        if (response.data.status === 'success') {
            allSteps.value = response.data.steps || [];
        }
    } catch (error) {
        console.error('抓取步驟失敗:', error);
    }
};

const handleMainImageUpload = (event) => {
    const file = event.target.files[0];
    if (file) {
        cookingStore.tempLogData.mainImage = URL.createObjectURL(file);
        // 確保 Store 有存入檔案物件
        cookingStore.tempLogData.mainImageFile = file;
    }
};

const saveAndGoLab = async () => {
    try {
        const formData = new FormData();

        // 1. 基本資料
        formData.append('recipe_id', recipeId);
        formData.append('user_id', 1); // ⚠️ 正式上線記得改為動態 user_id

        // 時間轉換
        const hours = Math.floor(cookingStore.tempLogData.totalTime / 60);
        const mins = cookingStore.tempLogData.totalTime % 60;
        const timeStr = `${String(hours).padStart(2, '0')}:${String(mins).padStart(2, '0')}:00`;
        formData.append('actual_time', timeStr);

        formData.append('satisfaction_rating', cookingStore.tempLogData.rating);

        // 難度轉換 (現在 difficultyMap 存在了，這裡不會報錯)
        const skillVal = difficultyMap[cookingStore.tempLogData.skillDifficulty] || 1;
        const processVal = difficultyMap[cookingStore.tempLogData.processDifficulty] || 1;
        formData.append('technique_rating', skillVal);
        formData.append('complexity_rating', processVal);

        formData.append('log_summary', cookingStore.tempLogData.summary || '');

        // 2. 主圖檔案
        if (cookingStore.tempLogData.mainImageFile) {
            formData.append('main_image', cookingStore.tempLogData.mainImageFile);
        }

        // 3. 步驟筆記
        formData.append('step_notes', JSON.stringify(cookingStore.tempLogData.stepNotes));

        // 4. 步驟圖片
        // ⚠️ 請確保 LogStepcard 有正確寫入 noteImageFiles
        if (cookingStore.tempLogData.noteImageFiles) {
            for (const [stepId, file] of Object.entries(cookingStore.tempLogData.noteImageFiles)) {
                // formData key 必須與後端 PHP 接收的一致 (step_image_ID)
                formData.append(`step_image_${stepId}`, file);
            }
        }

        const response = await phpApi.post('log/create_log.php', formData, {
            headers: { 'Content-Type': 'multipart/form-data' }
        });

        if (response.data.status === 'success') {
            // alert('儲存成功！');
            router.push({ name: 'cooking-lab' });
        } else {
            alert('儲存失敗：' + response.data.message);
        }

    } catch (error) {
        console.error('API Error:', error);
        alert('系統錯誤，請稍後再試');
    }
};

onMounted(async () => {
    if (!recipeId) {
        alert('無效的食譜連結');
        router.push({ name: 'my-recipes' });
        return;
    }
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
                <label for="file-upload" class="log__upload-label">
                    <img v-if="cookingStore.tempLogData.mainImage" :src="cookingStore.tempLogData.mainImage"
                        class="preview-img" />
                    <div v-else class="upload-placeholder">
                        <p>點擊上傳圖片</p>
                    </div>
                </label>

                <input type="file" id="file-upload" accept="image/*" style="display: none;"
                    @change="handleMainImageUpload">
            </div>

            <div class="log__dashboard col-10">
                <LogTime />
                <LogRating v-model="cookingStore.tempLogData.rating" />
                <LogDifficulty />
            </div>

            <div class="log__note col-10">
                <div class="log__note-title zh-h2">
                    <i-material-symbols-edit-document />
                    筆記回顧
                </div>
                <LogStepcard v-for="(step, index) in allSteps" :key="step.step_id" :order="index + 1"
                    :step-id="step.step_id" :initialNote="cookingStore.tempLogData.stepNotes[step.step_id]"
                    :initialImage="cookingStore.tempLogData.noteImages[step.step_id]"
                    :description="step.step_description" />
            </div>

            <div class="log__summary col-10">
                <div class="log__summary-title zh-h2">
                    <i-material-symbols-edit-document />
                    心得回顧
                </div>
                <textarea v-model="cookingStore.tempLogData.summary" class="log__summary-text"
                    placeholder="點擊添加筆記..."></textarea>
            </div>
        </div>

        <div class="log__footer row">
            <div class="log__btn-wrapper col-10">
                <div class="log__back-btn p-p1" @click="router.go(-1)">
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
        overflow: hidden;
        position: relative;
        background-color: #fff;
        padding: 0;

        .log__upload-label {
            display: block;
            width: 100%;
            height: 100%;
            cursor: pointer;
        }

        .preview-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }

        .upload-placeholder {
            width: 100%;
            height: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            color: $neutral-color-400;

            p {
                margin: 0;
            }
        }
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