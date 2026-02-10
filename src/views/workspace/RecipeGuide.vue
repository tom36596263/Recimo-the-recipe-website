<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { phpApi } from '@/utils/publicApi';
import { useCookingStore } from '@/stores/useCookingStore';
import GuideStepCard from '@/components/workspace/recipeguide/GuideStepCard.vue';
import StepContentCard from '@/components/workspace/recipeguide/StepContentCard.vue';
import AllIngredientsModal from '@/components/workspace/recipeguide/modals/AllIngredientsModal.vue';
import CompleteStepCard from '@/components/workspace/recipeguide/CompleteStepCard.vue';

const router = useRouter();
const route = useRoute();
const cookingStore = useCookingStore();
const recipeId = computed(() => Number(route.params.id));

const foundRecipe = ref({});
const allSteps = ref([]);
const fetchedRecipeIngredients = ref([]);
const fetchedStepIngredients = ref([]);
const stepNotes = ref({});

const stepTimers = ref({});
const viewingStepIndex = ref(0);
const guideStartTime = ref(Date.now());

const timeToSeconds = (timeStr) => {
    if (!timeStr) return 0;
    const [hrs, mins, secs] = timeStr.split(':').map(Number);
    return (hrs * 3600) + (mins * 60) + secs;
};

const secondsToMinSec = (totalSeconds) => {
    const m = Math.floor(totalSeconds / 60).toString().padStart(2, '0');
    const s = (totalSeconds % 60).toString().padStart(2, '0');
    return `${m}:${s}`;
};

const fetchData = async () => {
    try {
        const response = await phpApi.get(`guide/get_guide_details.php?id=${recipeId.value}`);

        if (response.data.status === 'success') {
            const data = response.data;

            foundRecipe.value = data.recipe || {};
            allSteps.value = data.steps || [];

            allSteps.value.forEach(step => {
                stepTimers.value[step.step_id] = {
                    timeLeft: timeToSeconds(step.step_total_time),
                    isTimerRunning: false,
                    intervalId: null,
                    isFinished: false
                };
            });

            fetchedRecipeIngredients.value = data.recipe_ingredients || [];
            fetchedStepIngredients.value = data.step_ingredients || [];
        }
    } catch (error) {
        console.error(error.message);
    }
};

onMounted(fetchData);

const currentRecipeIngredients = computed(() => {
    return fetchedRecipeIngredients.value;
});

const currentStepData = computed(() => allSteps.value[viewingStepIndex.value] || {});

const currentStepIngredients = computed(() => {
    const stepId = currentStepData.value.step_id;
    if (!stepId) return [];
    return fetchedStepIngredients.value.filter(item => item.step_id === stepId);
});

const formatTime = computed(() => {
    const stepId = currentStepData.value.step_id;
    const timer = stepTimers.value[stepId];
    if (timer?.isFinished) return '時間到';
    return timer ? secondsToMinSec(timer.timeLeft) : '00:00';
});

const isCurrentViewingTimerRunning = computed(() => {
    const stepId = currentStepData.value.step_id;
    return stepTimers.value[stepId]?.isTimerRunning || false;
});

const changeStep = (index) => {
    viewingStepIndex.value = index;
    const stepId = allSteps.value[index]?.step_id;
    if (stepTimers.value[stepId]?.isFinished) {
        stepTimers.value[stepId].isFinished = false;
    }
};

const toggleTimer = () => {
    const stepId = currentStepData.value.step_id;
    const timer = stepTimers.value[stepId];
    if (!timer) return;

    if (timer.isFinished) {
        timer.isFinished = false;
        timer.timeLeft = timeToSeconds(currentStepData.value.step_total_time);
        return;
    }

    if (!timer.isTimerRunning) {
        timer.isFinished = false;
        timer.isTimerRunning = true;
        timer.intervalId = setInterval(() => {
            if (timer.timeLeft > 0) {
                timer.timeLeft--;
            } else {
                clearInterval(timer.intervalId);
                timer.isTimerRunning = false;
                timer.isFinished = true;
            }
        }, 1000);
    } else {
        clearInterval(timer.intervalId);
        timer.isTimerRunning = false;
    }
};

onUnmounted(() => {
    Object.values(stepTimers.value).forEach(timer => {
        if (timer.intervalId) clearInterval(timer.intervalId);
    });
});

const ingredientModalIsOpen = ref(false);
const toggleModal = () => { ingredientModalIsOpen.value = !ingredientModalIsOpen.value };

const noteImages = ref({});
const fileInput = ref(null);
const triggerUpload = () => fileInput.value.click();
const handleFileUpload = (event) => {
    const file = event.target.files[0];
    if (file && currentStepData.value.step_id) {
        noteImages.value[currentStepData.value.step_id] = URL.createObjectURL(file);
    }
};

const handleFinishGuide = () => {
    const durationMs = Date.now() - guideStartTime.value;
    const durationMinutes = Math.floor(durationMs / 1000 / 60);
    const actualTime = durationMinutes > 0 ? durationMinutes : 1;

    const totalEstimateSeconds = allSteps.value.reduce((sum, step) => {
        return sum + timeToSeconds(step.step_total_time);
    }, 0);
    const estimateTimeMinutes = Math.ceil(totalEstimateSeconds / 60);

    cookingStore.setLogData(
        recipeId.value,
        stepNotes.value,
        noteImages.value,
        actualTime,
        estimateTimeMinutes
    );

    router.push({
        name: 'create-cooking-log',
        params: { recipeId: recipeId.value }
    });
};
</script>

<template>
    <div class="container">
        <div class="guide row">
            <div class="guide__main-content col-9">
                <h2 class="guide__recipe-title zh-h2">
                    <i-material-symbols-fork-spoon-rounded />
                    {{ foundRecipe.recipe_title }}
                </h2>

                <div class="guide__sub-title p-p1" v-if="allSteps.length">
                    第 {{ viewingStepIndex + 1 }} / {{ allSteps.length }} 步
                </div>

                <StepContentCard :step="currentStepData" :ingredients="currentStepIngredients" />

                <h2 class="guide__note-title zh-h2">我的筆記</h2>
                <div class="guide__note">
                    <textarea v-if="currentStepData.step_id" v-model="stepNotes[currentStepData.step_id]"
                        class="guide__note-input" placeholder="輸入此步驟的筆記..."></textarea>
                    <div class="guide__img-upload" @click="triggerUpload">
                        <input type="file" ref="fileInput" @change="handleFileUpload" style="display: none"
                            accept="image/*">
                        <img v-if="currentStepData.step_id && noteImages[currentStepData.step_id]"
                            :src="noteImages[currentStepData.step_id]" class="preview-img">
                        <span v-else>點擊上傳圖片</span>
                    </div>
                </div>
            </div>

            <aside class="guide__sidebar col-3">
                <div class="guide__timer zh-h1">
                    {{ formatTime }}
                    <button @click="toggleTimer" class="guide__start-btn p-p1">
                        {{ stepTimers[currentStepData.step_id]?.isFinished ? '確定' : (isCurrentViewingTimerRunning ? '暫停'
                            : '開始') }}
                    </button>
                </div>

                <div class="guide__tab-header">
                    <div class="guide__tab-header-title p-p1">
                        <i-material-symbols-chef-hat />步驟清單
                    </div>
                    <button class="guide__allIngredients-btn p-p1" @click="toggleModal">全部食材</button>
                </div>

                <div class="guide__tab-area">
                    <div class="guide__step-list p-p1">
                        <GuideStepCard v-for="(step, index) in allSteps" :key="step.step_id" :step="step"
                            :class="{ 'is-active': index === viewingStepIndex }"
                            :is-timing="stepTimers[step.step_id]?.isTimerRunning"
                            :is-finished="stepTimers[step.step_id]?.isFinished"
                            :active-time="secondsToMinSec(stepTimers[step.step_id]?.timeLeft || 0)"
                            @click="changeStep(index)" />

                        <CompleteStepCard :recipe-id="recipeId" :step-notes="stepNotes" :note-images="noteImages"
                            @finish="handleFinishGuide" />
                    </div>
                </div>
            </aside>
        </div>
    </div>
    <AllIngredientsModal v-show="ingredientModalIsOpen" @noshow="toggleModal" :list="currentRecipeIngredients" />
</template>

<style lang="scss" scoped>
.guide {
    display: flex;
    flex-wrap: nowrap;
    gap: 20px;

    &__main-content {
        display: flex;
        flex-direction: column;
        gap: 20px;
        padding: 20px 0;
    }

    &__recipe-title {
        display: flex;
        align-items: center;
    }

    &__note {
        display: flex;
        gap: 20px;
        justify-content: end;
    }

    &__note-input {
        flex: 1;
        border-radius: 10px;
        border: 1px solid $neutral-color-400;
        padding: 20px;
    }

    &__img-upload {
        width: 200px;
        height: 200px;
        border: 1px solid $neutral-color-400;
        border-radius: 10px;
        display: flex;
        justify-content: center;
        align-items: center;
        overflow: hidden;
    }

    .preview-img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        display: block;
    }

    &__sidebar {
        background-color: $neutral-color-100;
        height: auto;
        max-height: 760px;
        display: flex;
        flex-direction: column;
        align-items: center;
        padding: 20px 20px;
        gap: 20px;
        overflow: hidden;
    }

    &__timer {
        width: 200px;
        height: 200px;
        border-radius: 50%;
        background-color: $primary-color-100;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        gap: 15px;
        flex-shrink: 0;
    }

    &__start-btn {
        width: 66px;
        height: 41px;
        display: flex;
        justify-content: center;
        align-items: center;
        background-color: $primary-color-700;
        border-radius: 10px;
        color: $neutral-color-white;
        cursor: pointer;
        border: none;
    }

    &__tab-header {
        display: flex;
        justify-content: space-between;
        width: 100%;
    }

    &__tab-header-title {
        display: flex;
        justify-content: center;
        align-items: center;
    }

    &__allIngredients-btn {
        display: flex;
        justify-content: center;
        align-items: center;
        color: $primary-color-700;
        border: 1px solid $primary-color-700;
        border-radius: 10px;
        width: 94px;
        height: 30px;
        cursor: pointer;
    }

    &__tab-area {
        width: 100%;
    }

    &__step-list {
        display: flex;
        flex-direction: column;
        overflow-y: auto;
        max-height: 480px;
        padding-right: 8px;

        &::-webkit-scrollbar {
            width: 6px;
        }

        &::-webkit-scrollbar-thumb {
            background-color: $neutral-color-400;
            border-radius: 10px;
        }
    }
}
</style>