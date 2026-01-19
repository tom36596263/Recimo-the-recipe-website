<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { publicApi } from '@/utils/publicApi';
import DayColumn from '@/components/workspace/mealplan/DayColumn.vue';
import ColumnTitle from '@/components/workspace/mealplan/ColumnTitle.vue';
import PlanPanel from '@/components/workspace/mealplan/PlanPanel.vue';
import RecipePicker from '@/components/workspace/mealplan/RecipePicker.vue';

// --- 路由處理 ---
const route = useRoute();
const router = useRouter();

// 使用 computed 確保當路由參數改變時，ID 會同步更新
// 這裡將網址中的 :id 轉為數字，方便與 JSON 的 plan_id 比對
const planId = computed(() => Number(route.params.id));

// --- 資料狀態 ---
const planData = ref({});        // 存放單一計畫的基本資訊 (標題、日期範圍)
const mealPlanItems = ref([]);   // 存放該計畫所有的配餐明細 (包含食譜 ID、餐期)
const allRecipes = ref([]);      // 存放全域食譜庫資料

// --- UI 控制 ---
const showPanel = ref(false);    // 控制右側資訊面板 (PlanPanel)
const selectedDate = ref(null);  // 當前選中的日期 (若為 null 則顯示週視圖)

// --- API 請求函數 ---
const fetchData = async () => {
  try {
    // 同時抓取計畫清單、明細、食譜資料
    const [planRes, itemsRes, recipesRes] = await Promise.all([
      publicApi.get('data/plan/meal_plans.json'),
      publicApi.get('data/plan/meal_plan_items.json'),
      publicApi.get('data/recipe/recipes.json')
    ]);

    // 1. 根據路由 ID 找出對應的計畫資訊
    planData.value = planRes.data.find(p => p.plan_id === planId.value) || {};
    // 2. 篩選出屬於此計畫的配餐項目
    mealPlanItems.value = itemsRes.data.filter(item => item.plan_id === planId.value);
    // 3. 儲存食譜資料庫供搜尋使用
    allRecipes.value = recipesRes.data;
  } catch (err) {
    console.error('資料讀取失敗：', err.message);
  }
};

// --- 計算屬性 ---

// 根據計畫的開始與結束日期，生成一個 Date 物件陣列 (用於週視圖欄位)
const datelist = computed(() => {
  if (!planData.value.start_date) return [];
  const start = new Date(planData.value.start_date);
  const end = new Date(planData.value.end_date);
  const list = [];
  for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
    list.push(new Date(d));
  }
  return list;
});

// --- 邏輯方法 ---

// 根據日期過濾出當天的配餐，並注入食譜詳細內容
const getItemsByDate = (date) => {
  const dateStr = date.toISOString().split('T')[0]; // 取得 YYYY-MM-DD
  return mealPlanItems.value
    .filter(item => item.planned_date.includes(dateStr))
    .map(item => {
      const recipeDetail = allRecipes.value.find(r => r.recipe_id === item.recipe_id);
      return { ...item, detail: recipeDetail }; // 合併明細與食譜詳情
    });
};

// 處理從 RecipePicker 傳回來的「新增食譜」事件
const handleAddRecipe = (payload) => {
  mealPlanItems.value.push({
    item_id: Date.now(), // 前端生成臨時唯一 ID
    plan_id: planData.value.plan_id,
    recipe_id: payload.recipe_id,
    planned_date: payload.date,
    meal_type: payload.meal_type,
    sort_order: 1
  });
};

// UI 切換方法
const handleDateSelect = (date) => { selectedDate.value = date; };
const closeDetail = () => { selectedDate.value = null; };
const openPanel = () => { showPanel.value = true; };
const closePanel = () => { showPanel.value = false; };
const onWheel = (e) => { e.currentTarget.scrollLeft += e.deltaY * 0.2; };

// --- 生命週期 ---
onMounted(fetchData);

// 監聽路由 ID 變化：若使用者在網址直接輸入不同 ID，需重新抓取資料
watch(() => route.params.id, (newId) => {
  if (newId) fetchData();
});
</script>

<template>
  <main class="container">
    <div class="row">
      <div class="btn-bar col-12">
        <div class="btn-bar__left">
          <button class="back-btn" @click="router.push({ name: 'meal-plan' })" title="返回計畫清單">
            <i-material-symbols-arrow-back-ios-new-rounded />
          </button>
          <h2 class="plan-title">{{ planData.title || '讀取中...' }}</h2>
        </div>

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
  margin-bottom: 20px;
  padding: 10px 0;

  &__left {
    display: flex;
    align-items: center;
    gap: 15px;

    .back-btn {
      background: $neutral-color-white;
      border: 1px solid $neutral-color-100;
      width: 40px;
      height: 40px;
      border-radius: 8px;
      display: flex;
      justify-content: center;
      align-items: center;
      cursor: pointer;
      color: $primary-color-800;
      transition: all 0.2s ease;

      &:hover {
        background: $primary-color-100;
        border-color: $primary-color-400;
      }
    }

    .plan-title {
      font-size: 1.25rem;
      font-weight: bold;
      color: $primary-color-800;
      margin: 0;
    }
  }

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
    transition: 0.3s;

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
      display: none; // 隱藏原生捲軸保持美觀
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

/* --- 動畫特效 --- */

// 右側面板滑入滑出
.slide-fade-enter-active,
.slide-fade-leave-active {
  transition: transform 0.4s ease, opacity 0.4s ease;
}

.slide-fade-enter-from,
.slide-fade-leave-to {
  transform: translateX(100%);
  opacity: 0;
}

// 遮罩淡入淡出
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

// 週視圖與編輯器切換縮放
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