<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router'; // 引入vue內建的useRoute和useRouter
import { publicApi } from '@/utils/publicApi'; // 引入路徑變數
import GuideStepCard from '../../components/workspace/recipeguide/GuideStepCard.vue';
import StepContentCard from '../../components/workspace/recipeguide/StepContentCard.vue';

// 把vue內建的useRoute和useRouter裝進變數，就不用每次都跑一次函數的邏輯
const route = useRoute(); // 獲取當前網址資訊
const router = useRouter(); // 切換、導航網址

// route獲取網址，再用Number()把網址中的id變成數字，方便稍後進行邏輯比對
const recipeId = computed(() => Number(route.params.id));

// 宣告變數，存放json抓過來的資料
const foundRecipe = ref({}); // 存取食譜
const allSteps = ref([]); // 存取步驟
const allIngredients = ref([]); // 存取食材
const stepIngredientItems = ref([]); //存取步驟+食材關聯資料表

// API 請求函數
const fetchData = async () => {
    try {
        const [recipesRes, stepsRes, itemsRes, ingredientsRes] = await Promise.all([
            publicApi.get('data/recipe/recipes.json'),
            publicApi.get('data/recipe/steps.json'),
            publicApi.get('data/recipe/step_ingredients.json'),
            publicApi.get('data/recipe/ingredients.json')
        ]);

        //API請來的資料存到變數
        // 根據路徑id找出對應的食譜資訊(recipes.json裡的recipe_id欄位對比路徑的食譜id)
        foundRecipe.value = recipesRes.data.find(r => r.recipe_id === recipeId.value) || {}; // 因為find()只會回傳第一個符合條件的項目，如果沒找到符合的條件就會回傳undefined來取代原本的{}，網頁就會有崩潰的風險，因此須加上|| {}來避免崩潰
        // 篩選出屬於此食譜的步驟(以steps.json裡的recipe_id欄位對比路徑的食譜id)
        allSteps.value = stepsRes.data.filter(step => step.recipe_id === recipeId.value); // 因為filter()無論如何都會回傳陣列，就算沒找到資料的也會回傳空的[]，所以結尾不需要加上|| []

        // 篩選出屬於這個步驟的食材
        // 先用map把陣列中所有的id取出來放到變數中
        const stepIds = allSteps.value.map(s => s.step_id);
        // 再用includes把符合step_id的item抓出來
        stepIngredientItems.value = itemsRes.data.filter(item => stepIds.includes(item.step_id));
        //再以步驟+食材關聯資料表(step_ingredients.json)的ingredient_id對比ingredients.json的ingredient_id
        const ingredientIds = stepIngredientItems.value.map(i => i.ingredient_id);
        allIngredients.value = ingredientsRes.data.filter(i => ingredientIds.includes(i.ingredient_id));
    } catch (error) {
        console.error('資料讀取失敗', error.message);
    }
};
// 呼叫fetchData
//此行負責在網頁載入時呼叫fetchData(在生命週期中的onMounted階段，因為進行到此階段時，網頁上的物件都已經掛載好了，這時再載入，才不會因為在物件掛載好時，資料還在路上)
onMounted(fetchData);
// 此行負責監聽路徑id，id變化時會去抓一次資料
watch(() => route.params.id, (newId) => {
    if (newId) fetchData();
});

const currentStepIndex = ref(0); // 預設顯示第一步 (索引為 0)
const stepNotes = ref({}); // 用來儲存每個步驟的筆記，格式如 { step_id: '筆記內容' }

// 計算屬性：獲取目前顯示的步驟資料
const currentStepData = computed(() => allSteps.value[currentStepIndex.value] || {});

// 計算屬性：獲取目前步驟對應的食材（包含名稱、份量、單位）
const currentStepIngredients = computed(() => {
    const stepId = currentStepData.value.step_id;
    return stepIngredientItems.value
        .filter(item => item.step_id === stepId)
        .map(item => {
            const detail = allIngredients.value.find(ing => ing.ingredient_id === item.ingredient_id);
            return { ...detail, ...item }; // 合併食材名稱與份量資訊
        });
});

// 分類步驟
const finishedSteps = computed(() => allSteps.value.slice(0, currentStepIndex.value));
const currentStep = computed(() => allSteps.value[currentStepIndex.value] ? [allSteps.value[currentStepIndex.value]] : []);
const comingSteps = computed(() => allSteps.value.slice(currentStepIndex.value + 1));

// 切換步驟的函式
const changeStep = (index) => {
    currentStepIndex.value = index;
};

// 計時器
const timeLeft = ref(0); // 剩餘秒數
const timerInterval = ref(null);
const isTimerRunning = ref(false);

// 將 "HH:MM:SS" 轉換為總秒數
const timeToSeconds = (timeStr) => {
    if (!timeStr) return 0;
    const [hrs, mins, secs] = timeStr.split(':').map(Number);
    return (hrs * 3600) + (mins * 60) + secs;
};

// 格式化秒數為 MM:SS
const formatTime = computed(() => {
    const m = Math.floor(timeLeft.value / 60).toString().padStart(2, '0');
    const s = (timeLeft.value % 60).toString().padStart(2, '0');
    return `${m}:${s}`;
});

// 開始/暫停計時
const toggleTimer = () => {
    if (isTimerRunning.value) {
        clearInterval(timerInterval.value);
    } else {
        timerInterval.value = setInterval(() => {
            if (timeLeft.value > 0) {
                timeLeft.value--;
            } else {
                clearInterval(timerInterval.value);
                alert("時間到！");
            }
        }, 1000);
    }
    isTimerRunning.value = !isTimerRunning.value;
};

// 監聽步驟切換，自動重置計時時間
watch(currentStepData, (newStep) => {
    clearInterval(timerInterval.value);
    isTimerRunning.value = false;
    timeLeft.value = timeToSeconds(newStep.step_total_time);
}, { immediate: true });

// 筆記圖片上傳
const noteImages = ref({}); // 存放每個步驟的預覽圖 { step_id: 'blob_url' }
const fileInput = ref(null);

const triggerUpload = () => fileInput.value.click();

const handleFileUpload = (event) => {
    const file = event.target.files[0];
    if (file && currentStepData.value.step_id) {
        // 產生預覽路徑
        const previewUrl = URL.createObjectURL(file);
        noteImages.value[currentStepData.value.step_id] = previewUrl;
    }
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
                    第 {{ currentStepIndex + 1 }} / {{ allSteps.length }} 步
                </div>

                <StepContentCard :step="currentStepData" :ingredients="currentStepIngredients" />

                <h2 class="guide__note-title zh-h2">我的筆記</h2>
                <div class="guide__note">
                    <textarea v-model="stepNotes[currentStepData.step_id]" class="guide__note-input"
                        placeholder="輸入此步驟的筆記..."></textarea>
                    <div class="guide__img-upload" @click="triggerUpload">
                        <input type="file" ref="fileInput" @change="handleFileUpload" style="display: none"
                            accept="image/*">

                        <img v-if="noteImages[currentStepData.step_id]" :src="noteImages[currentStepData.step_id]"
                            class="preview-img">
                        <span v-else>點擊上傳圖片</span>
                    </div>
                </div>
            </div>

            <aside class="guide__sidebar col-3">
                <div class="guide__timer zh-h1">
                    {{ formatTime }}

                    <button @click="toggleTimer" class="guide__start-btn p-p1">
                        {{ isTimerRunning ? '暫停' : '開始' }}
                    </button>
                </div>

                <div class="guide__tab-header">

                    <div class="guide__tab-header-title p-p1">

                        <i-material-symbols-chef-hat />步驟總覽

                    </div>



                    <button class="guide__allIngredients-btn p-p1">全部食材</button>

                </div>

                <div class="guide__tab-area">
                    <div class="guide__finished-step p-p1">
                        已完成步驟
                        <GuideStepCard v-for="(step, index) in finishedSteps" :key="step.step_id" :step="step"
                            @click="changeStep(index)" />
                    </div>
                    <div class="guide__current-step p-p1">
                        當前步驟
                        <GuideStepCard v-for="step in currentStep" :key="step.step_id" :step="step" class="is-active" />
                    </div>
                    <div class="guide__coming-step p-p1">
                        即將到來步驟
                        <GuideStepCard v-for="(step, index) in comingSteps" :key="step.step_id" :step="step"
                            @click="changeStep(currentStepIndex + 1 + index)" />
                    </div>
                </div>
            </aside>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.guide {
    display: flex;
    flex-wrap: nowrap;
    gap: 20px;

    // main-content區
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

    // sidebar區
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

    &__finished-step,
    &__current-step,
    &__coming-step {
        min-height: 100px;
        max-height: 200px;
        overflow-y: auto;

        &::-webkit-scrollbar {
            display: none;
        }
    }
}
</style>