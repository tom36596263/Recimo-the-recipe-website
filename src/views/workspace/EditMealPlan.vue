<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/authStore';
import { publicApi, phpApi } from '@/utils/publicApi';
import DayColumn from '@/components/workspace/mealplan/DayColumn.vue';
import ColumnTitle from '@/components/workspace/mealplan/ColumnTitle.vue';
import PlanPanel from '@/components/workspace/mealplan/PlanPanel.vue';
import RecipePicker from '@/components/workspace/mealplan/RecipePicker.vue';
import BaseModal from '@/components/BaseModal.vue';

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

const handleDateChangeRequest = (newDate) => {
  if (!planData.value.start_date || !planData.value.end_date) return;
  const start = new Date(planData.value.start_date);
  const end = new Date(planData.value.end_date);
  start.setHours(0, 0, 0, 0);
  end.setHours(0, 0, 0, 0);
  newDate.setHours(0, 0, 0, 0);

  if (newDate >= start && newDate <= end) {
    selectedDate.value = newDate;
  }
};

const handleUpdatePlanInfo = async (newInfo) => {
  const formatDate = (date) => {
    if (!date) return null;
    if (typeof date === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(date)) return date;
    const d = new Date(date);
    if (isNaN(d.getTime())) return null;
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${y}-${m}-${day}`;
  };

  const updatedStart = formatDate(newInfo.start) || planData.value.start_date;
  const updatedEnd = formatDate(newInfo.end) || planData.value.end_date;
  const updatedTitle = (newInfo.title !== undefined) ? newInfo.title : planData.value.title;

  if (!updatedTitle.trim()) return;

  try {
    const res = await phpApi.post('mealplans/update_plan_info.php', {
      plan_id: Number(planId.value),
      user_id: Number(authStore.userId),
      title: updatedTitle,
      start_date: updatedStart,
      end_date: updatedEnd
    });

    if (res.data.success) {
      planData.value = { ...planData.value, title: updatedTitle, start_date: updatedStart, end_date: updatedEnd };
    }
  } catch (err) {
    console.error('網路請求出錯:', err.message);
  }
};

// ------ 處理套用方案的彈窗邏輯 ------
const showApplyConfirmModal = ref(false); // 控制確認彈窗
const showApplySuccessModal = ref(false); // 控制成功彈窗
const pendingTemplateId = ref(null);      // 暫存要套用的模板 ID

// 🟢 步驟 1: 觸發按鈕時，只打開確認彈窗
const handleApplyTemplateRequest = (templateId) => {
  pendingTemplateId.value = templateId;
  showApplyConfirmModal.value = true;
};

// 🟢 步驟 2: 使用者點擊彈窗的「確認」後，執行 API
const confirmApplyTemplate = async () => {
  if (!pendingTemplateId.value) return;

  try {
    const res = await phpApi.post('mealplans/apply_template.php', {
      plan_id: planId.value,
      template_id: pendingTemplateId.value,
      user_id: authStore.userId
    });

    if (res.data.success) {
      await fetchData(); // 重新抓取資料

      // 關閉確認彈窗，開啟成功彈窗
      showApplyConfirmModal.value = false;
      showApplySuccessModal.value = true;
    }
  } catch (err) {
    console.error('套用方案失敗：', err.message);
    alert('套用失敗，請稍後再試'); // 錯誤處理保留簡單 alert 或另外做錯誤彈窗
  }
};

const getItemsByDate = (date) => {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  const dateStr = `${y}-${m}-${d}`;

  return mealPlanItems.value
    .filter(item => item.planned_date.includes(dateStr))
    .map(item => {
      const recipeDetail = item.detail || allRecipes.value.find(r => r.recipe_id === item.recipe_id);
      return { ...item, detail: recipeDetail };
    });
};

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

const handleRemoveRecipe = async (itemId) => {
  try {
    const res = await phpApi.post('mealplans/remove_meal_item.php', {
      item_id: itemId,
      user_id: authStore.userId
    });
    if (res.data.success) {
      const index = mealPlanItems.value.findIndex(item => item.item_id === itemId);
      if (index !== -1) mealPlanItems.value.splice(index, 1);
    }
  } catch (err) {
    console.error('刪除失敗：', err.message);
  }
};

const currentDayTargetKcal = computed(() => {
  if (!selectedDate.value) return 2000;
  const dateStr = selectedDate.value.toISOString().split('T')[0];
  const found = dailyTargets.value.find(t => t.target_date === dateStr);
  return found ? Number(found.target_kcal) : 2000;
});

const updateTargetKcal = async (newKcal) => {
  if (!selectedDate.value || !planId.value) return;
  const dateStr = selectedDate.value.toISOString().split('T')[0];
  try {
    await phpApi.post('mealplans/update_daily_target.php', {
      plan_id: planId.value,
      user_id: authStore.userId,
      date: dateStr,
      target_kcal: newKcal
    });
    const index = dailyTargets.value.findIndex(t => t.target_date === dateStr);
    if (index !== -1) dailyTargets.value[index].target_kcal = newKcal;
    else dailyTargets.value.push({ target_date: dateStr, target_kcal: newKcal });
  } catch (err) {
    console.error('更新熱量目標失敗：', err.message);
  }
};

const handleBatchUpdateTargetKcal = async (newKcal) => {
  try {
    const res = await phpApi.post('mealplans/batch_update_daily_targets.php', {
      plan_id: planId.value,
      user_id: authStore.userId,
      target_kcal: newKcal
    });
    if (res.data.success) {
      const targetsRes = await phpApi.get(`mealplans/get_daily_targets.php?plan_id=${planId.value}`);
      dailyTargets.value = targetsRes.data || [];
    }
  } catch (err) {
    console.error('批量更新請求出錯：', err.message);
  }
};

const handleDateSelect = (date) => { selectedDate.value = date; };
const closeDetail = () => { selectedDate.value = null; };
const openPanel = () => { showPanel.value = true; };
const closePanel = () => { showPanel.value = false; };

const handleUpdatePlanCover = async (updatedData, isUpload = false) => {
  if (isUpload) {
    planData.value = { ...planData.value, cover_type: 2, cover_template_id: null, custom_cover_url: updatedData.custom_cover_url };
    return;
  }
  const payload = { plan_id: planId.value, user_id: authStore.userId, cover_type: updatedData.cover_type, cover_template_id: updatedData.cover_template_id, custom_cover_url: updatedData.custom_cover_url };
  try {
    const res = await phpApi.post('mealplans/update_plan_cover.php', payload);
    if (res.data.success) planData.value = { ...updatedData };
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
          <div class="meal-plan-scroll-wrapper">
            <ColumnTitle class="sticky-column" />
            <div class="meal-plan-container__columns">
              <DayColumn v-for="date in datelist" :key="date.getTime()" :current-date="date"
                :items="getItemsByDate(date)" @click="handleDateSelect(date)" />
            </div>
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
        :meal-templates="mealTemplates" :cover-templates="coverTemplates" @apply-template="handleApplyTemplateRequest"
        @update-plan-info="handleUpdatePlanInfo" @update-plan="handleUpdatePlanCover" @close="closePanel" />
    </Transition>

    <Transition name="fade">
      <div v-if="showPanel" class="panel-overlay" @click="closePanel"></div>
    </Transition>

    <BaseModal :is-open="showApplyConfirmModal" type="info" icon-class="fa-solid fa-triangle-exclamation" title="確認套用方案"
      description="套用方案將會清空目前已安排的食譜，確定要執行嗎？" @close="showApplyConfirmModal = false">
      <template #actions>
        <button class="modal-btn cancel" @click="showApplyConfirmModal = false">取消</button>
        <button class="modal-btn confirm" @click="confirmApplyTemplate">確認套用</button>
      </template>
    </BaseModal>

    <BaseModal :is-open="showApplySuccessModal" type="success" icon-class="fa-solid fa-circle-check" title="套用成功"
      description="天數與食譜已同步更新！" @close="showApplySuccessModal = false" />
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

      @media (max-width: 390px) {
        font-size: 1rem;
      }
    }
  }

  &__info-btn {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background-color: $neutral-color-100;
    color: $primary-color-800;
    cursor: pointer;
    flex-shrink: 0;

    &:hover {
      background-color: $accent-color-100;
      color: $accent-color-700;
      border: 1px solid $accent-color-800;
    }
  }
}

.meal-plan-container {
  min-width: 0;
  padding: 0;
}

.meal-plan-scroll-wrapper {
  display: flex;
  position: relative;
  overflow: hidden; // 避免外層溢出
}

.sticky-column {
  position: sticky;
  left: 0;
  z-index: 10;
  background-color: $neutral-color-white;

}

.meal-plan-container__columns {
  flex-grow: 1;
  display: flex;
  flex-wrap: nowrap;
  gap: 12px;
  overflow-x: auto;
  padding-bottom: 10px;
  -webkit-overflow-scrolling: touch;

  :deep(.day-column) {
    flex-shrink: 0;
  }

  &::-webkit-scrollbar {
    height: 12px;
  }

  &::-webkit-scrollbar-track {
    background: transparent;
  }

  &::-webkit-scrollbar-thumb {
    background-color: $neutral-color-400;
    border-radius: 10px;
    border: 3px solid transparent;
    background-clip: content-box;

    &:hover {
      background-color: $accent-color-400;
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

/* 動畫 */
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

.modal-btn {
  padding: 8px 24px;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  font-weight: bold;
  transition: all 0.2s ease;

  &.cancel {
    background-color: $neutral-color-100;
    color: $neutral-color-800;

    &:hover {
      background-color: $neutral-color-400;
      color: $neutral-color-white;
    }
  }

  &.confirm {
    background-color: $secondary-color-info-700;
    color: $neutral-color-white;

    &:hover {
      background-color: $secondary-color-info-400;
    }
  }
}
</style>