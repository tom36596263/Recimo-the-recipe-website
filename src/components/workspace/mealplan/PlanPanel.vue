<script setup>
import { ref, computed, onMounted } from 'vue'; // 1. 務必匯入 onMounted
import DefaultPlanAccordion from './DefaultPlanAccordion.vue';
import DateTabs from './DateTabs.vue';
import NutritionChart from './NutritionChart.vue';
import PanelMiniRecipeCard from './PanelMiniRecipeCard.vue';
import PlanCoverPanel from './PlanCoverPanel.vue';

const props = defineProps({
  planData: { type: Object, required: true },
  mealPlanItems: { type: Array, default: () => [] },
  allRecipes: { type: Array, default: () => [] },
  initialDate: { type: [Date, Object], default: null },
  mealTemplates: { type: Array, default: () => [] },
  targetCalories: { type: Number, default: 2000 },
  coverTemplates: { type: Array, default: () => [] }
});

const emit = defineEmits(['close', 'apply-template', 'update-plan-date', 'update-plan']);
const onSelectTemplate = (id) => {
  emit('apply-template', id); // 向上轉發
};

// ------封面圖選單------
const showCoverPanel = ref(false);
const openCoverPanel = () => {
  showCoverPanel.value = true;
}
const closeCoverPanel = () => {
  showCoverPanel.value = false;
}
// 封面選擇函式
const handleCoverSelect = (payload) => {
  emit('update-plan', {
    ...props.planData, // 保留舊資料
    cover_type: payload.type,
    cover_template_id: payload.id
  });
  closeCoverPanel();
  // 如果要存回後端，可以在這裡 emit 事件給最外層
  // emit('update-cover', payload); 
};


// ------日誌頁籤------
// --- 1. 根據計畫日期產生日誌頁籤 ---
const dateTabsData = computed(() => {
  if (!props.planData.start_date) return [];
  const start = new Date(props.planData.start_date);
  const end = new Date(props.planData.end_date);
  const list = [];
  const weekDays = ['日', '一', '二', '三', '四', '五', '六'];

  let idCounter = 1;
  // 使用備用變數跑迴圈，避免修改原始 start 物件
  let current = new Date(start);
  while (current <= end) {
    list.push({
      id: idCounter++,
      day: weekDays[current.getDay()],
      date: current.getDate().toString(),
      // 建議使用更穩定的日期字串化方式
      fullDate: `${current.getFullYear()}-${String(current.getMonth() + 1).padStart(2, '0')}-${String(current.getDate()).padStart(2, '0')}`
    });
    current.setDate(current.getDate() + 1);
  }
  return list;
});

// --- 2. 狀態：當前選中的頁籤 ID ---
const activeTabId = ref(1);

// --- 3. 核心邏輯：計算「當前選中日期」的營養總和 (保持不變) ---
const currentNutritionData = computed(() => {
  const activeTab = dateTabsData.value.find(tab => tab.id === activeTabId.value);
  if (!activeTab) return { calories: 0, protein: 0, carbs: 0, starch: 0, fat: 0 };

  const todaysItems = props.mealPlanItems.filter(item =>
    item.planned_date.includes(activeTab.fullDate)
  );

  return todaysItems.reduce((acc, item) => {
    const recipe = props.allRecipes.find(r => r.recipe_id === item.recipe_id);
    if (recipe) {
      acc.calories += recipe.recipe_kcal_per_100g || 0;
      acc.protein += recipe.recipe_protein_per_100g || 0;
      acc.carbs += recipe.recipe_carbs_per_100g || 0;
      acc.fat += recipe.recipe_fat_per_100g || 0;
      acc.starch += (recipe.recipe_carbs_per_100g * 0.7) || 0;
    }
    return acc;
  }, { calories: 0, protein: 0, carbs: 0, starch: 0, fat: 0 });
});

// --- 4. 核心邏輯：獲取「當前選中日期」的不重複食譜詳情 (保持不變) ---
const currentRecipes = computed(() => {
  const activeTab = dateTabsData.value.find(tab => tab.id === activeTabId.value);
  if (!activeTab) return [];

  const todaysItems = props.mealPlanItems.filter(item =>
    item.planned_date.includes(activeTab.fullDate)
  );

  const uniqueRecipesMap = new Map();
  todaysItems.forEach(item => {
    const recipe = props.allRecipes.find(r => r.recipe_id === item.recipe_id);
    if (recipe && !uniqueRecipesMap.has(recipe.recipe_id)) {
      uniqueRecipesMap.set(recipe.recipe_id, recipe);
    }
  });
  return Array.from(uniqueRecipesMap.values());
});

// --- 5. 同步日期邏輯修正 ---
onMounted(() => {
  if (props.initialDate) {
    // 使用與 dateTabsData 相同的格式化邏輯進行比對
    const d = props.initialDate;
    const targetDateStr = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;

    const foundTab = dateTabsData.value.find(tab => tab.fullDate === targetDateStr);
    if (foundTab) {
      activeTabId.value = foundTab.id;
    }
  }
});

// 處理範圍更新，轉發給 EditMealPlan
const onUpdateRange = (range) => {
  emit('update-plan-date', range);
};

const closePanel = () => { emit('close'); };
</script>

<template>
  <div class="plan-panel">
    <div class="plan-panel__header">
      <div class="plan-panel__field p-p1">
        計畫名稱：
        <input type="text" :placeholder="planData.title || '載入中...'" class="plan-panel__input p-p1" />
      </div>
      <div class="plan-panel__close" @click="closePanel">
        <i-material-symbols-close />
      </div>
    </div>

    <div class="plan-panel__accordion p-p1">
      <DefaultPlanAccordion :templates="mealTemplates" @select="onSelectTemplate" />
    </div>

    <div class="plan-panel__cover" @click="openCoverPanel">
      <template v-if="planData.cover_type === 1">
        <img :src="`img/plan-covers/template/${planData.cover_template_id}.svg`" class="cover-img" />
      </template>
      <template v-else-if="planData.custom_cover_url">
        <img :src="planData.custom_cover_url" class="cover-img" />
      </template>
      <template v-else>
        <i-material-symbols-camping-outline />
        <span class="cover-hint">更換封面圖片</span>
      </template>
    </div>

    <PlanCoverPanel v-if="showCoverPanel" :templates="props.coverTemplates" @select="handleCoverSelect"
      @close="closeCoverPanel" />

    <div class="plan-panel__tabs">
      <DateTabs v-if="planData.start_date" v-model="activeTabId" :tabs="dateTabsData" :start-date="planData.start_date"
        :end-date="planData.end_date" @update-range="onUpdateRange" />
      <div v-else class="loading-hint p-p1">
        資料載入中...
      </div>
    </div>

    <div class="plan-panel__chart">
      <h3 class="plan-panel__chart-title p-p1">單日營養總計</h3>

      <NutritionChart :data="currentNutritionData" :target="targetCalories" />
    </div>

    <div class="plan-panel__recipe-overview">
      <h4 class="plan-panel__overview-title p-p1">單日食譜預覽</h4>

      <div class="plan-panel__recipe-list">
        <PanelMiniRecipeCard v-for="recipe in currentRecipes" :key="recipe.recipe_id" :recipe="recipe" />

        <div v-if="currentRecipes.length === 0" class="plan-panel__empty-recipes p-p1">
          今日尚未安排食譜
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.plan-panel {
  width: 510px;
  height: 100vh;
  position: fixed;
  top: 0;
  right: 0;
  background-color: $neutral-color-white;
  padding: 30px 20px 0;
  display: flex;
  flex-direction: column;
  gap: 20px;
  overflow-y: auto;
  z-index: 999;
  box-shadow: -5px 0 15px rgba($neutral-color-black, 0.1);

  &__header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-shrink: 0;
  }

  &__field {
    display: flex;
    align-items: center;
    gap: 8px;
    color: $primary-color-800;
    font-weight: bold;
  }

  &__input {
    border: 0;
    border-bottom: 1px solid transparent;
    outline: none;
    background-color: transparent;
    padding: 4px 0;
    color: inherit;
    transition: border-bottom 0.3s;

    &:focus {
      border-bottom: 1px solid $primary-color-800;
    }
  }

  &__close {
    cursor: pointer;
    font-size: 1.5rem;
    color: $neutral-color-400;
    transition: color 0.2s;

    &:hover {
      color: $primary-color-800;
    }
  }

  &__cover {
    background-color: $accent-color-100;
    width: 100%;
    height: 225px;
    border-radius: 12px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    color: $accent-color-800;
    cursor: pointer;
    flex-shrink: 0;
    transition: background-color 0.3s;

    svg {
      font-size: 80px;
    }

    .cover-hint {
      font-size: 0.8rem;
      margin-top: 10px;
      font-weight: bold;
    }

    &:hover {
      background-color: mix($accent-color-100, $neutral-color-white, 80%);
    }
  }

  &__tabs {
    margin-top: 10px;
  }

  .loading-hint {
    text-align: center;
    color: $neutral-color-400;
    padding: 10px;
    font-size: 0.9rem;
  }

  &__chart {
    padding-bottom: 40px;
  }

  &__chart-title,
  &__overview-title,
  &__empty-recipes {
    color: $primary-color-800;
    font-weight: bold;
  }

  &__empty-recipes {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 100%;
    height: 100px;
    // background-color: $neutral-color-100;
    border-radius: 10px;
    border: 1px solid $neutral-color-100;
  }

  &__recipe-list {
    display: flex;
    width: 100%;
    flex-wrap: wrap;

  }

  &::-webkit-scrollbar {
    width: 6px;
  }

  &::-webkit-scrollbar-thumb {
    background-color: $neutral-color-100;
    border-radius: 10px;
  }
}
</style>