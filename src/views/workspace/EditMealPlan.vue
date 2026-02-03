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
const mealTemplates = ref([]);       // 存放模板清單 (meal_plan_template.json)
const mealTemplateItems = ref([]);  // 存放模板食譜關聯 (meal_plan_template_items.json)
const coverTemplates = ref([]); // 存放封面模板

// --- UI 控制 ---
const showPanel = ref(false);    // 控制右側資訊面板 (PlanPanel)
const selectedDate = ref(null);  // 當前選中的日期 (若為 null 則顯示週視圖)

// --- API 請求函數 ---
const fetchData = async () => {
  try {
    // 同時抓取計畫清單、明細、食譜資料
    const [planRes, itemsRes, recipesRes, templatesRes, templateItemsRes, coverTemplatesRes] = await Promise.all([
      publicApi.get('data/plan/meal_plans.json'),
      publicApi.get('data/plan/meal_plan_items.json'),
      publicApi.get('data/recipe/recipes.json'),
      publicApi.get('data/plan/meal_plan_template.json'),
      publicApi.get('data/plan/meal_plan_template_items.json'),
      publicApi.get('data/plan/meal_plan_cover_template.json')
    ]);

    // 1. 根據路由 ID 找出對應的計畫資訊
    planData.value = planRes.data.find(p => p.plan_id === planId.value) || {};
    // 2. 篩選出屬於此計畫的配餐項目
    mealPlanItems.value = itemsRes.data.filter(item => item.plan_id === planId.value);
    // 3. 儲存食譜資料庫供搜尋使用
    allRecipes.value = recipesRes.data;
    // 儲存預設計畫
    mealTemplates.value = templatesRes.data;
    // 4. 儲存預設計畫明細
    mealTemplateItems.value = templateItemsRes.data;
    // 5. 儲存預設封面圖
    coverTemplates.value = coverTemplatesRes.data;

  } catch (err) {
    console.error('資料讀取失敗：', err.message);
  }
};

// --- 生命週期 ---
onMounted(fetchData);

// 監聽路由 ID 變化：若使用者在網址直接輸入不同 ID，需重新抓取資料
watch(() => route.params.id, (newId) => {
  if (newId) fetchData();
});

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

// 處理從 RecipePicker 傳回來的「刪除食譜」事件
const handleRemoveRecipe = (itemId) => {
  // 透過 itemId 找出索引並移除
  const index = mealPlanItems.value.findIndex(item => item.item_id === itemId);
  if (index !== -1) {
    mealPlanItems.value.splice(index, 1);
    console.log('已刪除項目 ID:', itemId);
  }
};

// UI 切換方法
const handleDateSelect = (date) => { selectedDate.value = date; };
const closeDetail = () => { selectedDate.value = null; };
const openPanel = () => { showPanel.value = true; };
const closePanel = () => { showPanel.value = false; };

// --- 套用模板邏輯 ---
const handleApplyTemplate = (templateId) => {
  if (!planData.value.start_date) return;

  // 1. 找出該模板對應的所有食譜項目
  const sourceItems = mealTemplateItems.value.filter(it => it.template_id === templateId);

  // 2. 轉換邏輯：計算實際日期
  const startDate = new Date(planData.value.start_date);

  const newItems = sourceItems.map(it => {
    const targetDate = new Date(startDate);
    targetDate.setDate(startDate.getDate() + (it.day_number - 1)); // day_number 轉日期

    return {
      item_id: Date.now() + Math.random(), // 隨機 ID
      plan_id: planId.value,
      recipe_id: it.recipe_id,
      planned_date: targetDate.toISOString().split('T')[0],
      meal_type: it.meal_type,
      sort_order: it.sort_order
    };
  });

  // 3. 更新計畫 (可選擇覆蓋或累加，這裡示範累加)
  mealPlanItems.value = [...mealPlanItems.value, ...newItems];
};

// --- 計畫日期變更 ---
const handleUpdatePlanDate = (newRange) => {
  if (!newRange || !newRange.start || !newRange.end) return;

  // 輔助函式：轉成 YYYY-MM-DD 字串
  const formatDate = (d) => {
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${y}-${m}-${day}`;
  };

  // 直接更新 planData，觸發響應式更新
  planData.value.start_date = formatDate(newRange.start);
  planData.value.end_date = formatDate(newRange.end);

  // (選用) 如果需要將變更存回後端，可以在這裡呼叫 API
  // publicApi.post('/plan/update', planData.value)...
};

// ------變更日期-------
const handleDateChangeRequest = (newDate) => {
  // 檢查範圍：確保新日期在計畫的開始與結束日期之間
  const start = new Date(planData.value.start_date);
  const end = new Date(planData.value.end_date);

  // 如果超出範圍，可以選擇不執行，或是跳出提示
  if (newDate >= start && newDate <= end) {
    selectedDate.value = newDate;
  } else {
    console.warn('已到達計畫日期的邊界');
  }
};

// ------存放目標熱量並傳遞資料 ------
const dailyTargetKcal = ref(2000); // 預設值

const updateTargetKcal = (val) => {
  dailyTargetKcal.value = val;
  // 如果需要存回後端： publicApi.post(...)
};

// ------接住封面圖的更新------
const handleUpdatePlanCover = (updatedData) => {
  // 更新本地的 planData，Vue 的響應式會自動通知所有組件
  planData.value = updatedData;

  // (選用) 這裡可以呼叫 API 把封面變更存進資料庫
  // publicApi.put(`data/plan/${planId.value}`, updatedData);
};
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
          <div class="meal-plan-container__columns">
            <DayColumn v-for="date in datelist" :key="date.getTime()" :current-date="date" :items="getItemsByDate(date)"
              @click="handleDateSelect(date)" />
          </div>
        </div>

        <div v-else key="picker" class="meal-detail-view col-12">
          <RecipePicker :date="selectedDate" :current-items="getItemsByDate(selectedDate)" :all-recipes="allRecipes"
            :target-calories="dailyTargetKcal" :start-date="planData.start_date" :end-date="planData.end_date"
            @update-target="updateTargetKcal" @back="closeDetail" @add="handleAddRecipe" @remove="handleRemoveRecipe"
            @change-date="handleDateChangeRequest" />
        </div>
      </Transition>
    </div>

    <Transition name="slide-fade">
      <PlanPanel v-if="showPanel" :target-calories="dailyTargetKcal" :plan-data="planData"
        :meal-plan-items="mealPlanItems" :all-recipes="allRecipes" :initial-date="selectedDate"
        :meal-templates="mealTemplates" :cover-templates="coverTemplates" @apply-template="handleApplyTemplate"
        @update-plan-date="handleUpdatePlanDate" @update-plan="handleUpdatePlanCover" @close="closePanel" />
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
      background: $neutral-color-100;
      border: 1px solid transparent;
      width: 40px;
      height: 40px;
      border-radius: 8px;
      display: flex;
      justify-content: center;
      align-items: center;
      cursor: pointer;
      color: $primary-color-800;

      &:hover {
        background: $accent-color-100;
        border-color: $accent-color-800;
        color: $accent-color-700;
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

    // 1. 設定捲軸「寬度」(垂直時) 或「高度」(水平時)
    &::-webkit-scrollbar {
      height: 15px;
    }

    // 2. 捲軸軌道 (背景)
    &::-webkit-scrollbar-track {
      background: transparent;
      border-radius: 5px;
    }

    // 3. 捲軸本體 (Thumb)
    &::-webkit-scrollbar-thumb {
      background-color: $neutral-color-400;
      border-radius: 5px;
      border: 2px solid transparent;
      background-clip: content-box;
      transition: background-color 0.3s;

      &:hover {
        background-color: $accent-color-400;
      }
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