<script setup>
import { ref, onMounted, computed } from 'vue';
import { phpApi } from '@/utils/publicApi';
import { useAuthStore } from '@/stores/authStore';
import PlanFileCard from '@/components/workspace/mealplan/PlanFileCard.vue';

const authStore = useAuthStore();
const plans = ref([]);
const coverTemplates = ref([]);
const isLoading = ref(true);

// --- 核心功能：從 PHP 撈取資料 ---
const fetchPlans = async () => {
  // 檢查是否有登入 ID
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
  const end = new Date(plan.end_date);

  if (now < start) return 'upcoming';
  if (now >= start && now <= end) return 'active';
  return 'closed';
};

const filteredPlans = computed(() => {
  if (!filterStatus.value) return plans.value;
  return plans.value.filter(plan => getPlanStatus(plan) === filterStatus.value);
});
</script>

<template>
  <div class="overview container">
    <div class="overview__header row">
      <div class="overview__tag-wrapper col-6">
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

      <div class="col-3 overview__card">
        <div class="overview__empty-card">
          <i class="fa-solid fa-plus"></i>
          <p class="p-p1">創建計畫</p>
        </div>
      </div>

      <div v-for="plan in filteredPlans" :key="plan.plan_id" class="col-3 overview__card">
        <PlanFileCard :plan="plan" :cover-templates="coverTemplates" />
      </div>

      <div v-if="filteredPlans.length === 0" class="col-9 p-p1 text-muted">
        目前沒有符合此狀態的計畫。
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
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
    // justify-content: space-between;
    gap: 10px;

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

      // color: $primary-color-800;
      i {
        color: $primary-color-800;
      }
    }
  }


}
</style>