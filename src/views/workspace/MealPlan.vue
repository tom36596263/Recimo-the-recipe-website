<script setup>
import { ref, onMounted } from 'vue';
import { publicApi } from '@/utils/publicApi';
import PlanFileCard from '@/components/workspace/mealplan/PlanFileCard.vue';

const plans = ref([]);
const isLoading = ref(true);

const fetchPlans = async () => {
  try {
    const res = await publicApi.get('data/plan/meal_plans.json');
    plans.value = res.data;
  } catch (err) {
    console.error('讀取計畫清單失敗：', err);
  } finally {
    isLoading.value = false;
  }
};

onMounted(fetchPlans);
</script>

<template>
  <div class="overview-container">
    <div class="overview-header">
      <div class="overview-header__text">
        <h1 class="p-h2">我的備餐計畫</h1>
        <p class="p-p2">在這裡管理您所有的自煮與健身配餐規劃。</p>
      </div>
      <button class="create-btn">
        <i-material-symbols-add-rounded />
        建立新計畫
      </button>
    </div>

    <div v-if="isLoading" class="loading-state">載入計畫中...</div>

    <div v-else class="plan-grid row">
      <div v-for="plan in plans" :key="plan.plan_id" class="col-12 col-md-6 col-lg-4 col-xl-3 mb-4">
        <PlanFileCard :plan="plan" />
      </div>

      <div class="col-12 col-md-6 col-lg-4 col-xl-3 mb-4">
        <div class="empty-card">
          <i-material-symbols-add-circle-outline-rounded />
          <span>開始新的規劃</span>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.overview-container {
  padding: 20px;
}

.overview-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  margin-bottom: 30px;

  &__text {
    h1 {
      color: $primary-color-800;
      margin-bottom: 4px;
    }

    p {
      color: $neutral-color-400;
      margin: 0;
    }
  }

  .create-btn {
    display: flex;
    align-items: center;
    gap: 8px;
    background-color: $primary-color-700;
    color: white;
    border: none;
    padding: 10px 24px;
    border-radius: 30px;
    font-weight: bold;
    cursor: pointer;
    transition: 0.3s;

    &:hover {
      background-color: $primary-color-800;
      box-shadow: 0 4px 12px rgba($primary-color-700, 0.3);
    }
  }
}

.plan-grid {
  margin-top: 10px;
}

.empty-card {
  height: 100%;
  min-height: 250px;
  border: 2px dashed $neutral-color-100;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  gap: 12px;
  color: $neutral-color-400;
  cursor: pointer;
  transition: 0.3s;

  svg {
    font-size: 3rem;
  }

  span {
    font-weight: bold;
  }

  &:hover {
    background-color: $primary-color-100;
    border-color: $primary-color-400;
    color: $primary-color-800;
  }
}

.loading-state {
  text-align: center;
  padding: 100px;
  color: $neutral-color-400;
}
</style>