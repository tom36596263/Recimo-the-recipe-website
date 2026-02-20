<script setup>
import { ref, onMounted, computed } from 'vue';
import { phpApi } from '@/utils/publicApi';
import { useAuthStore } from '@/stores/authStore';
import { useRouter } from 'vue-router';
import CreatePlanModal from '@/components/workspace/mealplan/modals/CreatePlanModal.vue';
import PlanFileCard from '@/components/workspace/mealplan/PlanFileCard.vue';
import BaseModal from '@/components/BaseModal.vue';

const authStore = useAuthStore();
const plans = ref([]);
const coverTemplates = ref([]);
const isLoading = ref(true);

// --- 核心功能：從 PHP 撈取資料 ---
const fetchPlans = async () => {
  if (!authStore.userId) {
    isLoading.value = false;
    return;
  }

  try {
    const [plansRes, coversRes] = await Promise.all([
      phpApi.get(`mealplans/get_user_plans.php?user_id=${authStore.userId}`),
      phpApi.get('mealplans/get_cover_templates.php')
    ]);
    plans.value = plansRes.data || [];
    coverTemplates.value = coversRes.data || [];
  } catch (err) {
    console.error('讀取計畫清單失敗：', err.message);
  } finally {
    isLoading.value = false;
  }
};

onMounted(fetchPlans);

// --- 篩選Tag ---
const filterStatus = ref('');
const getPlanStatus = (plan) => {
  const now = new Date();
  now.setHours(0, 0, 0, 0);
  const start = new Date(plan.start_date);
  start.setHours(0, 0, 0, 0);
  const end = new Date(plan.end_date);
  start.setHours(0, 0, 0, 0);

  if (now < start) return 'upcoming';
  if (now >= start && now <= end) return 'active';
  return 'closed';
};

const filteredPlans = computed(() => {
  if (!filterStatus.value) return plans.value;
  return plans.value.filter(plan => getPlanStatus(plan) === filterStatus.value);
});

// --- 點擊卡片導向編輯頁 ---
const router = useRouter();
const showCreateModal = ref(false);
const handleCreatePlan = async (data) => {
  const formatDate = (d) => d.toISOString().split('T')[0];

  try {
    const res = await phpApi.post('mealplans/create_plan.php', {
      user_id: authStore.userId,
      title: data.title,
      start_date: formatDate(data.range.start),
      end_date: formatDate(data.range.end)
    });

    if (res.data.success) {
      router.push({
        name: 'edit-meal-plan',
        params: { id: res.data.plan_id }
      });
    }
  } catch (err) {
    console.error('建立失敗', err);
  }
};

// --- 彈窗狀態管理 ---
const showDeleteModal = ref(false);
const deleteTargetId = ref(null);
const showCopyModal = ref(false);

// --- 處理刪除 ---
// --- 1. 點擊刪除按鈕時，只負責開啟彈窗 ---
const onPlanDelete = (id) => {
  deleteTargetId.value = id;   // 記錄要刪除誰
  showDeleteModal.value = true; // 開啟彈窗
};

// --- 2. 使用者在彈窗按「確認」後，才真正執行刪除 ---
const confirmDelete = async () => {
  if (!deleteTargetId.value) return;

  try {
    const res = await phpApi.post('mealplans/delete_plan.php', {
      plan_id: deleteTargetId.value,
      user_id: authStore.userId
    });

    if (res.data.success) {
      plans.value = plans.value.filter(p => p.plan_id !== deleteTargetId.value);
      showDeleteModal.value = false;
      deleteTargetId.value = null;
    }
  } catch (err) {
    console.error('刪除失敗', err);
  }
};

// --- 處理複製 ---
const onPlanCopy = async (id) => {
  try {
    const res = await phpApi.post('mealplans/duplicate_plan.php', {
      plan_id: id,
      user_id: authStore.userId
    });

    if (res.data.success) {
      fetchPlans();
      showCopyModal.value = true;
    }
  } catch (err) {
    console.error('複製失敗', err);
  }
};
</script>

<template>
  <div class="overview container">
    <div class="overview__header row">
      <div class="overview__tag-wrapper col-6 col-md-12">
        <div class="status-tag upcoming" :class="{ 'is-selected': filterStatus === 'upcoming' }"
          @click="filterStatus = filterStatus === 'upcoming' ? null : 'upcoming'">未開始</div>
        <div class="status-tag active" :class="{ 'is-selected': filterStatus === 'active' }"
          @click="filterStatus = filterStatus === 'active' ? null : 'active'">進行中</div>
        <div class="status-tag closed" :class="{ 'is-selected': filterStatus === 'closed' }"
          @click="filterStatus = filterStatus === 'closed' ? null : 'closed'">已結束</div>
      </div>
    </div>

    <div v-if="isLoading" class="overview__loading-state row">載入計畫中...</div>

    <div v-else class="overview__plan-grid row">

      <div class="col-3 col-lg-4 col-md-6 col-sm-12 overview__card" @click="showCreateModal = true">
        <div class="overview__empty-card">
          <i class="fa-solid fa-plus"></i>
          <p class="p-p1">創建計畫</p>
        </div>
      </div>

      <CreatePlanModal v-model="showCreateModal" @create="handleCreatePlan" />

      <div v-for="plan in filteredPlans" :key="plan.plan_id" class="col-3 col-lg-4 col-md-6 col-sm-12 overview__card">
        <PlanFileCard :plan="plan" :cover-templates="coverTemplates" @delete="onPlanDelete" @copy="onPlanCopy" />
      </div>

      <div v-if="filteredPlans.length === 0" class="col-9 col-md-12 p-p1 text-muted">
        目前沒有符合此狀態的計畫。
      </div>
    </div>
    <BaseModal :is-open="showDeleteModal" type="danger" icon-class="fa-solid fa-triangle-exclamation" title="確認刪除"
      description="確定要刪除這個計畫嗎？此動作無法復原。" @close="showDeleteModal = false">
      <template #actions>
        <button class="modal-btn cancel" @click="showDeleteModal = false">取消</button>
        <button class="modal-btn confirm" @click="confirmDelete">確認刪除</button>
      </template>
    </BaseModal>

    <BaseModal :is-open="showCopyModal" type="success" icon-class="fa-solid fa-circle-check" title="複製成功"
      description="計畫已成功複製！" @close="showCopyModal = false" />
  </div>
</template>

<style lang="scss" scoped>
/* 🔴 強制修正 Grid 系統 RWD */

/* 1. 當螢幕小於 810px 時，強制改為 50% (兩欄) */
@media screen and (max-width: 810px) {
  .overview__card {
    width: 50% !important;
    max-width: 50% !important;
    flex: 0 0 50% !important;
  }
}

/* 2. 當螢幕小於 390px 時，強制改為 100% (一欄) */
/* 注意：這個要在 810px 的設定之後，才能覆蓋它 */
@media screen and (max-width: 390px) {
  .overview__card {
    width: 100% !important;
    max-width: 100% !important;
    flex: 0 0 100% !important;
  }
}

.overview {
  padding: 20px 0;

  &__header {
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
    margin-bottom: 30px;
  }

  &__tag-wrapper {
    display: flex;
    gap: 10px;

    // RWD: 手機版可以左右滑動標籤
    @media (max-width: 810px) {
      overflow-x: auto;
      white-space: nowrap;
      padding-bottom: 5px;

      &::-webkit-scrollbar {
        display: none;
      }
    }

    .status-tag {
      background-color: $neutral-color-100;
      border-radius: 10px;
      height: 32px;
      padding: 2px 10px;
      display: flex;
      justify-content: center;
      align-items: center;
      cursor: pointer;
      transition: all 0.2s ease;
      border: 1px solid transparent;
      white-space: nowrap;

      &:hover {
        background-color: $accent-color-100;
      }

      &.is-selected {
        border-color: currentColor;
        font-weight: bold;
        background-color: color-mix(in srgb, currentColor, transparent 80%);
      }
    }

    .upcoming {
      color: $secondary-color-info-700;
    }

    .active {
      color: $secondary-color-success-700;
    }

    .closed {
      color: $secondary-color-danger-700;
    }
  }

  &__loading-state {
    text-align: center;
    padding: 100px;
    color: $neutral-color-400;
  }

  &__plan-grid {
    margin-top: 10px;
  }

  &__card {
    margin-bottom: 20px;
  }

  &__empty-card {
    height: 100%;
    min-height: 250px;
    border: 2px dashed $neutral-color-400;
    border-radius: 10px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    gap: 12px;
    color: $neutral-color-400;
    cursor: pointer;
    transition: all 0.3s ease;

    i {
      font-size: 48px;
      transition: all 0.3s ease;
    }

    span {
      font-weight: bold;
    }

    &:hover {
      background-color: $primary-color-100;
      border-color: $primary-color-400;

      i {
        color: $primary-color-800;
      }
    }
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
      background-color: $secondary-color-danger-700;
      color: white;

      &:hover {
        background-color: $secondary-color-danger-400;
      }
    }
  }
}
</style>