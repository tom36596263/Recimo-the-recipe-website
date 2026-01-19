<script setup>
import { ref, computed, onMounted } from 'vue';
import { publicApi } from '@/utils/publicApi';
import DayColumn from '@/components/workspace/mealplan/DayColumn.vue';
import ColumnTitle from '@/components/workspace/mealplan/ColumnTitle.vue';
import PlanPanel from '@/components/workspace/mealplan/PlanPanel.vue';
import RecipePicker from '@/components/workspace/mealplan/RecipePicker.vue';

// --- 資料狀態 ---
const planData = ref({});        // 存放計畫基本資訊
const mealPlanItems = ref([]);   // 存放所有配餐明細
const allRecipes = ref([]);      // 存放食譜資料庫

// --- UI 控制 ---
const showPanel = ref(false);    // 控制右側 PlanPanel 開關
const selectedDate = ref(null);  // 控制是否進入單日編輯模式 (null 為週視圖)

// --- API 請求 ---
const fetchData = async () => {
  try {
    const [planRes, itemsRes, recipesRes] = await Promise.all([
      publicApi.get('data/plan/meal_plans.json'),
      publicApi.get('data/plan/meal_plan_items.json'),
      publicApi.get('data/recipe/recipes.json')
    ]);

    // 取得計畫 ID: 1 的資料
    planData.value = planRes.data.find(p => p.plan_id === 1) || {};
    // 取得計畫 ID: 1 的所有配餐項目
    mealPlanItems.value = itemsRes.data.filter(item => item.plan_id === 1);
    allRecipes.value = recipesRes.data;
  } catch (err) {
    console.error('資料讀取失敗：', err.message);
  }
};

// --- 計算屬性：產生日誌日期陣列 ---
const datelist = computed(() => {
  if (!planData.value.start_date) return []; // 避免 API 未回傳時報錯
  const start = new Date(planData.value.start_date);
  const end = new Date(planData.value.end_date);
  const list = [];
  for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
    list.push(new Date(d));
  }
  return list;
});

// --- 邏輯處理：根據日期獲取該日詳細資料 ---
const getItemsByDate = (date) => {
  const dateStr = date.toISOString().split('T')[0]; // 取得 YYYY-MM-DD
  return mealPlanItems.value
    .filter(item => item.planned_date.includes(dateStr))
    .map(item => {
      const recipeDetail = allRecipes.value.find(r => r.recipe_id === item.recipe_id);
      return { ...item, detail: recipeDetail }; // 注入食譜詳情
    });
};

// --- 事件處理 ---
const handleAddRecipe = (payload) => {
  mealPlanItems.value.push({
    item_id: Date.now(),
    plan_id: planData.value.plan_id,
    recipe_id: payload.recipe_id,
    planned_date: payload.date,
    meal_type: payload.meal_type,
    sort_order: 1
  });
};

const handleDateSelect = (date) => { selectedDate.value = date; };
const closeDetail = () => { selectedDate.value = null; };
const openPanel = () => { showPanel.value = true; };
const closePanel = () => { showPanel.value = false; };
const onWheel = (e) => { e.currentTarget.scrollLeft += e.deltaY * 0.2; };

onMounted(fetchData);
</script>

<template>
  <main class="container">
    <div class="row">
      <div class="btn-bar col-12">
        <div class="btn-bar__bread-crumbs"></div>
        <div class="btn-bar__info-btn" @click="openPanel">
          <i-material-symbols-info-i />
        </div>
      </div>

      <Transition name="fade-scale" mode="out-in">
        <div v-if="!selectedDate" key="week" class="meal-plan-container col-12">
          <ColumnTitle />
          <div class="meal-plan-container__columns" @wheel.prevent="onWheel">
            <DayColumn v-for="date in datelist" :key="date.getTime()" :current-date="date" :items="getItemsByDate(date)"
              @click="handleDateSelect(date)" />
          </div>
        </div>

        <div v-else key="picker" class="meal-detail-view col-12">
          <RecipePicker :date="selectedDate" :current-items="getItemsByDate(selectedDate)" :all-recipes="allRecipes"
            @back="closeDetail" @add="handleAddRecipe" />
        </div>
      </Transition>
    </div>

    <Transition name="slide-fade">
      <PlanPanel v-if="showPanel" :plan-data="planData" :meal-plan-items="mealPlanItems" :all-recipes="allRecipes"
        @close="closePanel" />
    </Transition>

    <Transition name="fade">
      <div v-if="showPanel" class="panel-overlay" @click="closePanel"></div>
    </Transition>
  </main>
</template>

<style lang="scss" scoped>
.container {
  overflow: hidden;
  padding-bottom: 20px;
}

.btn-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;

  &__info-btn {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background-color: $primary-color-100;
    color: $primary-color-800;
    cursor: pointer;

    &:hover {
      background-color: $accent-color-100;
      color: $accent-color-700;
      border: 1px solid $accent-color-800;
    }
  }
}

.meal-plan-container {
  display: flex;
  gap: 10px;
  min-width: 0;

  &__columns {
    flex-grow: 1;
    display: flex;
    flex-wrap: nowrap;
    gap: 12px;
    overflow-x: auto;
    padding-bottom: 10px;

    :deep(.day-column) {
      flex-shrink: 0;
    }

    &::-webkit-scrollbar {
      display: none;
    }
  }
}

.panel-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background-color: rgba($neutral-color-black, 0.3);
  z-index: 998;
}

/* 動畫設定 */
.slide-fade-enter-active,
.slide-fade-leave-active {
  transition: transform 0.4s ease, opacity 0.4s ease;
}

.slide-fade-enter-from,
.slide-fade-leave-to {
  transform: translateX(100%);
  opacity: 0;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.fade-scale-enter-active,
.fade-scale-leave-active {
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.fade-scale-enter-from,
.fade-scale-leave-to {
  opacity: 0;
  transform: scale(0.98);
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }

  to {
    opacity: 1;
  }
}

.meal-detail-view {
  animation: fadeIn 0.4s ease;
}
</style>