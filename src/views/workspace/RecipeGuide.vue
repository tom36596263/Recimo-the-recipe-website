<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { phpApi } from '@/utils/publicApi';
import { useCookingStore } from '@/stores/useCookingStore';
import GuideStepCard from '@/components/workspace/recipeguide/GuideStepCard.vue';
import StepContentCard from '@/components/workspace/recipeguide/StepContentCard.vue';
import AllIngredientsModal from '@/components/workspace/recipeguide/modals/AllIngredientsModal.vue';
import CompleteStepCard from '@/components/workspace/recipeguide/CompleteStepCard.vue';
import rotatePhoneImg from '@/assets/images/guide/mobile-portrait.png';

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
    <div class="container desktop-wrapper">
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

    <Teleport to="body">
        <div class="mobile-portrait-overlay">
            <div class="orientation-content">
                <img :src="rotatePhoneImg" alt="請旋轉手機" class="rotate-img" />
            </div>
        </div>

        <div class="mobile-landscape-fullscreen">
            <div class="mobile-top-nav">
                <div class="step-scroll-area">
                    <div class="nav-step-item" v-for="(step, index) in allSteps" :key="step.step_id"
                        :class="{ 'is-active': index === viewingStepIndex }" @click="changeStep(index)">
                        <span class="step-label">step</span>
                        <span class="step-num">{{ index + 1 }}</span>
                    </div>
                </div>
                <button class="mobile-all-ing-btn" @click="toggleModal">全部食材</button>
            </div>

            <div class="mobile-main-area">
                <div class="mobile-step-content">
                    <StepContentCard :step="currentStepData" :ingredients="currentStepIngredients" />
                </div>

                <div class="mobile-sidebar">
                    <div class="mobile-timer-card">
                        <div class="time-display">{{ formatTime }}</div>
                        <button class="start-btn" @click="toggleTimer">
                            {{ stepTimers[currentStepData.step_id]?.isFinished ? '確定' : (isCurrentViewingTimerRunning ?
                                '暫停' : '開始') }}
                        </button>
                    </div>

                    <div class="mobile-note-card">
                        <div class="note-tabs">
                            <div class="tab active">筆記</div>
                            <div class="tab" @click="triggerUpload">照片</div>
                        </div>
                        <textarea v-if="currentStepData.step_id" v-model="stepNotes[currentStepData.step_id]"
                            class="note-textarea" placeholder="輸入筆記..."></textarea>
                    </div>
                </div>
            </div>
        </div>
    </Teleport>

    <Teleport to="body">
        <AllIngredientsModal v-show="ingredientModalIsOpen" @noshow="toggleModal" :list="currentRecipeIngredients" />
    </Teleport>
</template>

<style lang="scss" scoped>
.desktop-wrapper {
    display: block;
}

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

        &:focus {
            outline: none;
            border-color: $primary-color-800;
        }
    }

    &__img-upload {
        width: 200px;
        height: 200px;
        border: 1px dashed $neutral-color-400;
        border-radius: 10px;
        display: flex;
        justify-content: center;
        align-items: center;
        overflow: hidden;
        cursor: pointer;

        &:hover {
            border-color: $primary-color-800;
            background-color: $neutral-color-100;
        }
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

        &:hover {
            background-color: $accent-color-700;
            color: $neutral-color-white;
        }
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

        &:hover {
            background-color: $accent-color-100;
            color: $accent-color-700;
            border-color: $accent-color-800;
        }
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

            &:hover {
                background-color: $accent-color-400;
            }
        }
    }

    @media screen and (max-width: 810px) {
        .desktop-wrapper {
            display: none !important;
        }
    }
}
</style>

<style lang="scss">
.mobile-portrait-overlay {
    display: none;
}

.mobile-landscape-fullscreen {
    display: none;
}

@media screen and (max-width: 810px) {
    @media (orientation: portrait) {
        .mobile-portrait-overlay {
            display: flex;
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background-color: white;
            z-index: 2147483647;
            justify-content: center;
            align-items: center;

            .orientation-content {
                display: flex;
                flex-direction: column;
                align-items: center;

                .rotate-img {
                    width: 60%;
                    max-width: 250px;
                    animation: rotatePhone 2s ease-in-out infinite;
                }
            }
        }
    }

    @media (orientation: landscape) {
        .mobile-landscape-fullscreen {
            display: flex;
            flex-direction: column;
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background-color: #fafafa;
            z-index: 2147483647;
            padding: 12px 20px;
            box-sizing: border-box;
            overflow: hidden;
        }

        .mobile-top-nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
            height: 50px;
            margin-bottom: 12px;

            .step-scroll-area {
                display: flex;
                overflow-x: auto;
                gap: 8px;
                flex: 1;
                margin-right: 16px;
                padding-bottom: 4px;

                &::-webkit-scrollbar {
                    display: none;
                }

                .nav-step-item {
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    justify-content: center;
                    padding: 4px 16px;
                    border-radius: 8px;
                    color: #999;
                    cursor: pointer;

                    .step-label {
                        font-size: 10px;
                        line-height: 1;
                    }

                    .step-num {
                        font-size: 18px;
                        font-weight: bold;
                        line-height: 1.2;
                    }

                    &.is-active {
                        background-color: #e8f5e9;
                        color: #2e7d32;
                    }
                }
            }

            .mobile-all-ing-btn {
                background: transparent;
                border: 1px solid #2e7d32;
                color: #2e7d32;
                border-radius: 20px;
                padding: 6px 16px;
                font-size: 14px;
                white-space: nowrap;
            }
        }

        .mobile-main-area {
            display: flex;
            flex-direction: row;
            gap: 16px;
            height: calc(100vh - 74px);
        }

        .mobile-step-content {
            flex: 2;
            height: 100%;
            overflow-y: auto;

            &::-webkit-scrollbar {
                width: 4px;
            }

            &::-webkit-scrollbar-thumb {
                background: #ccc;
                border-radius: 4px;
            }
        }

        .mobile-sidebar {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 12px;
            height: 100%;
        }

        .mobile-timer-card {
            background-color: #e8f5e9;
            border-radius: 16px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 16px;
            flex: 1;

            .time-display {
                font-size: 36px;
                font-weight: bold;
                color: #333;
                margin-bottom: 12px;
            }

            .start-btn {
                background-color: #2e7d32;
                color: white;
                border: none;
                border-radius: 8px;
                padding: 8px 24px;
                font-size: 16px;
                cursor: pointer;
            }
        }

        .mobile-note-card {
            background-color: #2e7d32;
            border-radius: 12px;
            display: flex;
            flex-direction: column;
            flex: 1;
            overflow: hidden;

            .note-tabs {
                display: flex;
                background-color: rgba(255, 255, 255, 0.1);

                .tab {
                    flex: 1;
                    text-align: center;
                    padding: 8px 0;
                    color: white;
                    font-size: 13px;
                    opacity: 0.7;
                    cursor: pointer;

                    &.active {
                        opacity: 1;
                        font-weight: bold;
                        background-color: rgba(255, 255, 255, 0.2);
                    }
                }
            }

            .note-textarea {
                flex: 1;
                margin: 0;
                border: none;
                background-color: white;
                padding: 12px;
                font-size: 14px;
                resize: none;

                &:focus {
                    outline: none;
                }
            }
        }
    }
}

@keyframes rotatePhone {
    0% {
        transform: rotate(0deg);
    }

    50% {
        transform: rotate(-90deg);
    }

    100% {
        transform: rotate(-90deg);
    }
}
</style>