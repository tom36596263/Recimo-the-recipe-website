<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/authStore';
import { publicApi, phpApi } from '@/utils/publicApi';
import DayColumn from '@/components/workspace/mealplan/DayColumn.vue';
import ColumnTitle from '@/components/workspace/mealplan/ColumnTitle.vue';
import PlanPanel from '@/components/workspace/mealplan/PlanPanel.vue';
import RecipePicker from '@/components/workspace/mealplan/RecipePicker.vue';

// --- 登入狀態處理 ---
const authStore = useAuthStore();

// --- 路由處理 ---
const route = useRoute();
const router = useRouter();

const planId = computed(() => Number(route.params.id));

// --- 資料狀態 ---
const planData = ref({});
const mealPlanItems = ref([]);
const allRecipes = ref([]);
const mealTemplates = ref([]);
const mealTemplateItems = ref([]);
const coverTemplates = ref([]);
const dailyTargets = ref([]);

// --- UI 控制 ---
const showPanel = ref(false);
const selectedDate = ref(null);

// --- API 請求函數 ---
const fetchData = async () => {
  // 先判斷是否有登入
  if (!authStore.userId) {
    authStore.openLoginAlert();
    return;
  }

  try {
    const [
      planRes,
      itemsRes,
      targetsRes,
      recipesRes,
      templatesRes,
      templateItemsRes,
      coverTemplatesRes
    ] = await Promise.all([
      phpApi.get(`mealplans/get_meal_plan.php?plan_id=${planId.value}&user_id=${authStore.userId}`),
      phpApi.get(`mealplans/get_plan_items.php?plan_id=${planId.value}`),
      phpApi.get(`mealplans/get_daily_targets.php?plan_id=${planId.value}`),
      phpApi.get('mealplans/get_all_recipes.php'),
      phpApi.get('mealplans/get_meal_templates.php'),
      phpApi.get('mealplans/get_template_items.php'),
      phpApi.get('mealplans/get_cover_templates.php')
    ]);

    planData.value = planRes.data || {};
    mealPlanItems.value = itemsRes.data || [];
    dailyTargets.value = targetsRes.data || [];
    allRecipes.value = recipesRes.data;
    mealTemplates.value = templatesRes.data;
    mealTemplateItems.value = templateItemsRes.data;
    coverTemplates.value = coverTemplatesRes.data;

  } catch (err) {
    console.error('資料讀取失敗：', err.message);
  }
};

onMounted(fetchData);

watch(() => route.params.id, (newId) => {
  if (newId) fetchData();
});

// --- 計算屬性 ---
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

// ------ 處理從 RecipePicker 傳來的切換日期請求 -------
const handleDateChangeRequest = (newDate) => {
  if (!planData.value.start_date || !planData.value.end_date) return;

  // 1. 建立邊界檢查 (確保不會切換到計畫範圍外)
  const start = new Date(planData.value.start_date);
  const end = new Date(planData.value.end_date);

  // 💡 將時間部分歸零，確保比對時只看日期
  start.setHours(0, 0, 0, 0);
  end.setHours(0, 0, 0, 0);
  newDate.setHours(0, 0, 0, 0);

  // 2. 如果新日期在範圍內，更新 selectedDate，這會驅動 RecipePicker 更新內容
  if (newDate >= start && newDate <= end) {
    selectedDate.value = newDate;
  } else {
    console.warn('已到達計畫日期的邊界，無法繼續切換');
  }
};

// --- 計畫資訊變更（含標題與日期範圍） ---
const handleUpdatePlanInfo = async (newInfo) => {
  // 1. 強化版日期格式化：避免重複轉換導致的 Invalid Date
  const formatDate = (date) => {
    if (!date) return null;
    // 如果已經是 YYYY-MM-DD 字串，直接回傳，不要再進 new Date()
    if (typeof date === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(date)) return date;

    const d = new Date(date);
    if (isNaN(d.getTime())) return null; // 檢查是否為有效日期

    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${y}-${m}-${day}`;
  };

  // 🔴 關鍵：確保這三個變數絕對不會變成 null
  const updatedStart = formatDate(newInfo.start) || planData.value.start_date;
  const updatedEnd = formatDate(newInfo.end) || planData.value.end_date;
  const updatedTitle = (newInfo.title !== undefined) ? newInfo.title : planData.value.title;

  // 如果標題為空，不執行更新
  if (!updatedTitle.trim()) return;

  try {
    const res = await phpApi.post('mealplans/update_plan_info.php', {
      plan_id: Number(planId.value), // 確保是數字
      user_id: Number(authStore.userId), // 確保是數字
      title: updatedTitle,
      start_date: updatedStart,
      end_date: updatedEnd
    });

    if (res.data.success) {
      // ✅ 成功才更新本地狀態
      // 使用展開運算子確保響應式完整
      planData.value = {
        ...planData.value,
        title: updatedTitle,
        start_date: updatedStart,
        end_date: updatedEnd
      };
      console.log('資料庫更新成功');
    } else {
      console.error('後端回報更新失敗:', res.data.error);
      alert('更新失敗：' + (res.data.error || '原因未知'));
    }
  } catch (err) {
    console.error('網路請求出錯:', err.message);
  }
};

// 預設方案套用
const handleApplyTemplate = async (templateId) => {
  if (!confirm('套用方案將會清空目前已安排的食譜，確定要執行嗎？')) return;

  try {
    // 1. 呼叫後端一鍵處理 API
    const res = await phpApi.post('mealplans/apply_template.php', {
      plan_id: planId.value,
      template_id: templateId,
      user_id: authStore.userId
    });

    if (res.data.success) {
      // 2. 套用成功後，直接重新執行 fetchData 重新撈取所有資料
      // 這樣 planData (新日期) 和 mealPlanItems (新食譜) 就會同步更新到最新狀態
      await fetchData();

      console.log('方案套用成功！天數與食譜已同步更新');
    }
  } catch (err) {
    console.error('套用方案失敗：', err.message);
    alert('套用失敗，請確認模板資料正確性');
  }
};

// 以日期抓備餐計畫明細
const getItemsByDate = (date) => {
  const dateStr = date.toISOString().split('T')[0];
  return mealPlanItems.value
    .filter(item => item.planned_date.includes(dateStr))
    .map(item => {
      const recipeDetail = item.detail || allRecipes.value.find(r => r.recipe_id === item.recipe_id);
      return { ...item, detail: recipeDetail };
    });
};

// 處理「新增食譜」事件
const handleAddRecipe = async (payload) => {
  try {
    const res = await phpApi.post('mealplans/add_meal_item.php', {
      plan_id: planData.value.plan_id,
      recipe_id: payload.recipe_id,
      date: payload.date,
      meal_type: payload.meal_type
    });

    if (res.data.success) {
      const itemsRes = await phpApi.get(`mealplans/get_plan_items.php?plan_id=${planId.value}`);
      mealPlanItems.value = itemsRes.data;
    }
  } catch (err) {
    console.error('新增食譜失敗：', err.message);
  }
};

// 處理「刪除食譜」事件
const handleRemoveRecipe = async (itemId) => {
  // if (!confirm('確定要移除這道食譜嗎？')) return;

  try {
    const res = await phpApi.post('mealplans/remove_meal_item.php', {
      item_id: itemId,
      user_id: authStore.userId
    });

    if (res.data.success) {
      const index = mealPlanItems.value.findIndex(item => item.item_id === itemId);
      if (index !== -1) {
        mealPlanItems.value.splice(index, 1);
      }
    }
  } catch (err) {
    console.error('刪除失敗：', err.message);
  }
};

//處理子元件傳上來的目標熱量
// 當前選中日期的目標熱量
const currentDayTargetKcal = computed(() => {
  if (!selectedDate.value) return 2000; // 週視圖模式預設

  const dateStr = selectedDate.value.toISOString().split('T')[0];
  const found = dailyTargets.value.find(t => t.target_date === dateStr);

  // 如果資料庫有設定就用設定值，沒有就給預設 2000
  return found ? Number(found.target_kcal) : 2000;
})

const updateTargetKcal = async (newKcal) => {
  if (!selectedDate.value || !planId.value) return;

  const dateStr = selectedDate.value.toISOString().split('T')[0];

  try {
    // 1. 呼叫 PHP API (你寫好的 update_daily_target.php)
    await phpApi.post('mealplans/update_daily_target.php', {
      plan_id: planId.value,
      user_id: authStore.userId,
      date: dateStr,
      target_kcal: newKcal
    });

    // 2. 同步更新本地 dailyTargets 陣列，這樣畫面（如圖表）才會立刻變
    const index = dailyTargets.value.findIndex(t => t.target_date === dateStr);
    if (index !== -1) {
      dailyTargets.value[index].target_kcal = newKcal;
    } else {
      dailyTargets.value.push({ target_date: dateStr, target_kcal: newKcal });
    }
  } catch (err) {
    console.error('更新熱量目標失敗：', err.message);
  }
};

// 批量更新目標熱量
const handleBatchUpdateTargetKcal = async (newKcal) => {
  console.log('準備批量更新，熱量：', newKcal);

  try {
    const res = await phpApi.post('mealplans/batch_update_daily_targets.php', {
      plan_id: planId.value,
      user_id: authStore.userId,
      target_kcal: newKcal
    });

    console.log('API 回傳結果：', res.data);

    if (res.data.success) {
      // 重新抓取資料
      const targetsRes = await phpApi.get(`mealplans/get_daily_targets.php?plan_id=${planId.value}`);
      dailyTargets.value = targetsRes.data || [];
      console.log('全計畫熱量目標已同步至前端');
    } else {
      alert('更新失敗：' + res.data.error);
    }
  } catch (err) {
    // 🔴 除錯點 3：顯示更詳細的錯誤
    console.error('批量更新請求出錯：', err.response?.data || err.message);
    alert('網路請求失敗，請檢查控制台');
  }
};

// UI 切換方法保持不變 ...
const handleDateSelect = (date) => { selectedDate.value = date; };
const closeDetail = () => { selectedDate.value = null; };
const openPanel = () => { showPanel.value = true; };
const closePanel = () => { showPanel.value = false; };

// 模板與日期更新邏輯 ...
const handleUpdatePlanCover = async (updatedData, isUpload = false) => {
  if (isUpload) {
    // 🔴 關鍵：必須重新賦值一個新物件 {}，不要只改屬性
    planData.value = { ...updatedData };
    console.log('上傳成功，畫面已同步更新');
    return;
  }

  // 藍色區塊（切換模板 API）保持不變 ...
  const payload = {
    plan_id: planId.value,
    user_id: authStore.userId,
    cover_type: updatedData.cover_type,
    cover_template_id: updatedData.cover_template_id,
    custom_cover_url: updatedData.custom_cover_url
  };

  try {
    const res = await phpApi.post('mealplans/update_plan_cover.php', payload);
    if (res.data.success) {
      planData.value = { ...updatedData }; // 🔴 同樣要使用展開運算子
    }
  } catch (err) {
    console.error('更新失敗', err);
  }
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
            :target-calories="currentDayTargetKcal" :start-date="planData.start_date" :end-date="planData.end_date"
            @update-target="updateTargetKcal" @back="closeDetail" @add="handleAddRecipe" @remove="handleRemoveRecipe"
            @change-date="handleDateChangeRequest" @apply-all-target="handleBatchUpdateTargetKcal" />
        </div>
      </Transition>
    </div>

    <Transition name="slide-fade">
      <PlanPanel v-if="showPanel" :target-calories="currentDayTargetKcal" :plan-data="planData"
        :meal-plan-items="mealPlanItems" :all-recipes="allRecipes" :initial-date="selectedDate"
        :meal-templates="mealTemplates" :cover-templates="coverTemplates" @apply-template="handleApplyTemplate"
        @update-plan-info="handleUpdatePlanInfo" @update-plan="handleUpdatePlanCover" @close="closePanel" />
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