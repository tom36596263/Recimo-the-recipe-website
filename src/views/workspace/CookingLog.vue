<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { phpApi } from '@/utils/publicApi';
import { useCookingStore } from '@/stores/useCookingStore';
import { useAuthStore } from '@/stores/authStore';
import { parsePublicFile } from '@/utils/parseFile';

import LogTime from '../../components/workspace/cookinglog/LogTime.vue';
import LogRating from '../../components/workspace/cookinglog/LogRating.vue';
import LogDifficulty from '../../components/workspace/cookinglog/LogDifficulty.vue';
import LogStepcard from '../../components/workspace/cookinglog/LogStepcard.vue';
import StepDescriptionModal from '../../components/workspace/cookinglog/StepDescriptionModal.vue';

// 🟢 引入旋轉提示圖
import rotateToPortraitImg from '@/assets/images/guide/mobile-landscape.png';

const authStore = useAuthStore();
const route = useRoute();
const router = useRouter();
const cookingStore = useCookingStore();

const recipeId = Number(route.params.recipeId);
const logId = Number(route.params.logId);
const isViewMode = computed(() => !!logId);

const allSteps = ref([]);

const difficultyMap = {
    '簡單': 1,
    '中等': 2,
    '困難': 3
};

const reverseDifficultyMap = {
    1: '簡單',
    2: '中等',
    3: '困難'
};

const fetchRecipeData = async () => {
    try {
        const response = await phpApi.get(`guide/get_guide_details.php?id=${recipeId}`);
        if (response.data.status === 'success') {
            allSteps.value = response.data.steps || [];
        }
    } catch (error) {
        console.error('抓取步驟失敗:', error);
    }
};

const fetchLogDetail = async () => {
    try {
        const response = await phpApi.get(`log/get_log_details.php?log_id=${logId}`);
        if (response.data.status === 'success') {
            const { main, steps } = response.data.data;

            cookingStore.tempLogData.rating = Number(main.satisfaction_rating);
            cookingStore.tempLogData.summary = main.log_summary;
            cookingStore.tempLogData.skillDifficulty = reverseDifficultyMap[main.technique_rating];
            cookingStore.tempLogData.processDifficulty = reverseDifficultyMap[main.complexity_rating];

            const [h, m] = main.actual_time.split(':');
            cookingStore.tempLogData.totalTime = (parseInt(h) * 60) + parseInt(m);

            if (main.log_image_url) {
                cookingStore.tempLogData.mainImage = parsePublicFile(main.log_image_url);
            }

            allSteps.value = steps.map(s => ({
                step_id: s.step_id,
                step_order: s.step_order,
                step_title: s.step_title,
                step_content: s.step_note
            }));

            steps.forEach(s => {
                cookingStore.tempLogData.stepNotes[s.step_id] = s.step_note;
                if (s.step_image_url) {
                    cookingStore.tempLogData.noteImages[s.step_id] = parsePublicFile(s.step_image_url);
                }
            });
        }
    } catch (error) {
        console.error('抓取日誌詳情失敗:', error);
    }
};

const handleMainImageUpload = (event) => {
    if (isViewMode.value) return;
    const file = event.target.files[0];
    if (file) {
        cookingStore.tempLogData.mainImage = URL.createObjectURL(file);
        cookingStore.tempLogData.mainImageFile = file;
    }
};

const saveAndGoLab = async () => {
    if (isViewMode.value) return;

    try {
        const formData = new FormData();
        formData.append('recipe_id', recipeId);
        const currentUserId = authStore.userId || 1;
        formData.append('user_id', currentUserId);

        const totalTime = Number(cookingStore.tempLogData.totalTime) || 0;
        const hours = Math.floor(totalTime / 60);
        const mins = totalTime % 60;
        const timeStr = `${String(hours).padStart(2, '0')}:${String(mins).padStart(2, '0')}:00`;
        formData.append('actual_time', timeStr);

        formData.append('satisfaction_rating', cookingStore.tempLogData.rating);
        const skillVal = difficultyMap[cookingStore.tempLogData.skillDifficulty] || 1;
        const processVal = difficultyMap[cookingStore.tempLogData.processDifficulty] || 1;
        formData.append('technique_rating', skillVal);
        formData.append('complexity_rating', processVal);

        formData.append('log_summary', cookingStore.tempLogData.summary || '');
        if (cookingStore.tempLogData.mainImageFile) {
            formData.append('main_image', cookingStore.tempLogData.mainImageFile);
        }

        formData.append('step_notes', JSON.stringify(cookingStore.tempLogData.stepNotes));
        if (cookingStore.tempLogData.noteImageFiles) {
            for (const [sId, file] of Object.entries(cookingStore.tempLogData.noteImageFiles)) {
                formData.append(`step_image_${sId}`, file);
            }
        }

        const response = await phpApi.post('log/create_log.php', formData, {
            headers: { 'Content-Type': 'multipart/form-data' }
        });

        if (response.data.status === 'success') {
            cookingStore.resetLogData();
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
    if (isViewMode.value) {
        await fetchLogDetail();
    } else {
        if (!recipeId) {
            alert('無效的食譜連結');
            router.push({ name: 'my-recipes' });
            return;
        }
        await fetchRecipeData();
    }
});

const isModalOpen = ref(false);
const currentModalData = ref({ order: 1, description: '' });

const handleOpenDescModal = (data) => {
    currentModalData.value = data;
    isModalOpen.value = true;
};
</script>

<template>
    <div class="log container">
        <div class="log__header row">
            <div class="log__title zh-h1-bold col-12">
                {{ isViewMode ? '烹飪日誌詳情' : '美味上桌!烹飪完成' }}
            </div>
        </div>

        <div class="log__body row" :style="isViewMode ? 'pointer-events: none;' : ''">
            <div class="log__upload col-10">
                <label for="file-upload" class="log__upload-label">
                    <img v-if="cookingStore.tempLogData.mainImage" :src="cookingStore.tempLogData.mainImage"
                        class="preview-img" />
                    <div v-else class="upload-placeholder">
                        <p>{{ isViewMode ? '未上傳主圖' : '點擊上傳圖片' }}</p>
                    </div>
                </label>
                <input type="file" id="file-upload" accept="image/*" style="display: none;"
                    @change="handleMainImageUpload" :disabled="isViewMode">
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
                    :initialImage="cookingStore.tempLogData.noteImages[step.step_id]" :description="step.step_content"
                    @open-desc="handleOpenDescModal" />
            </div>

            <div class="log__summary col-10">
                <div class="log__summary-title zh-h2">
                    <i-material-symbols-edit-document />
                    心得回顧
                </div>
                <textarea v-model="cookingStore.tempLogData.summary" class="log__summary-text"
                    :placeholder="isViewMode ? '' : '點擊添加筆記...'" :readonly="isViewMode"></textarea>
            </div>
        </div>

        <div class="log__footer row">
            <div class="log__btn-wrapper col-10">
                <div class="log__back-btn p-p1" @click="router.go(-1)">
                    {{ isViewMode ? '返回' : '返回步驟播放' }}
                </div>
                <div v-if="!isViewMode" class="log__finished-btn p-p1" @click="saveAndGoLab">
                    儲存
                </div>
            </div>
        </div>

        <StepDescriptionModal :is-open="isModalOpen" :order="currentModalData.order"
            :description="currentModalData.description" @close="isModalOpen = false" />
    </div>

    <Teleport to="body">
        <div class="orientation-reminder">
            <div class="reminder-content">
                <img :src="rotateToPortraitImg" alt="請旋轉手機至直向" class="rotate-img" />
            </div>
        </div>
    </Teleport>
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

        &:read-only {
            background-color: transparent;
            cursor: default;
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

        &:hover {
            background-color: $accent-color-100;
            border-color: $accent-color-800;
            color: $accent-color-700;
        }
    }

    &__finished-btn {
        background-color: $primary-color-800;
        color: $neutral-color-white;

        &:hover {
            background-color: $accent-color-700;
            color: $neutral-color-white;
        }
    }
}

/* 🟢 RWD: 810px 以下修正對齊 */
@media screen and (max-width: 1024px) {
    .col-10 {
        width: 92%;
        flex: 0 0 92%;
    }

    .log {
        &__body {
            padding: 20px 0;
        }

        &__dashboard {
            display: flex;
            flex-direction: column;
            justify-content: center;
            gap: 15px;
        }

        &__btn-wrapper {
            justify-content: center;
            width: 100%;

            &>* {
                flex: 1;
                text-align: center;
            }
        }
    }
}
</style>

<style lang="scss">
.orientation-reminder {
    display: none;
}

@media screen and (max-width: 1024px) and (orientation: landscape) {
    .orientation-reminder {
        display: flex !important;
        position: fixed;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        background-color: rgba(255, 255, 255, 0.98);
        z-index: 2147483647;
        justify-content: center;
        align-items: center;

        .reminder-content {
            text-align: center;

            .rotate-img {
                width: 70%;
                max-width: 280px;
                animation: rotateIcon 2s infinite ease-in-out;
            }
        }
    }
}

@keyframes rotateIcon {
    0% {
        transform: rotate(-90deg);
    }

    50% {
        transform: rotate(0deg);
    }

    100% {
        transform: rotate(0deg);
    }
}
</style>