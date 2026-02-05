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
  <div class="overview__container container">
    <div class="overview__header row">
      <div class="overview__tag-wrapper col-6">
        <div class="folder-tag">過年年菜</div>
        <div class="folder-tag">三月苗栗露營</div>
        <div class="folder-tag">其他</div>
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

      <div v-for="plan in plans" :key="plan.plan_id" class="col-3 overview__card">
        <PlanFileCard :plan="plan" />
      </div>


    </div>
  </div>
</template>

<style lang="scss" scoped>
.overview {
  padding: 20px;

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

    .folder-tag {
      background-color: $neutral-color-100;
      border-radius: 10px;
      height: 32px;
      padding: 2px 10px;
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