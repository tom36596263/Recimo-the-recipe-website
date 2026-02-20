<script setup>
import { ref, computed, onMounted } from 'vue';

const props = defineProps({
  templates: { type: Array, default: () => [] } // 接收動態資料
});

const emit2 = defineEmits(['select']);

// 控制手風琴開關的狀態，預設關閉
const isOpen = ref(false);

// 切換開關的函式
const toggleAccordion = () => {
  isOpen.value = !isOpen.value;
};

// 點擊卡片觸發
const selectPlan = (id) => {
  emit2('select', id);
};
</script>

<template>
  <div class="accordion">
    <div class="accordion__header" @click="toggleAccordion">
      <div class="accordion__text p-p1">選擇預設方案</div>
      <div class="accordion__arrow p-p1" :class="{ rotated: isOpen }">
        <i-material-symbols-keyboard-arrow-down />
      </div>
    </div>

    <div class="accordion__content" v-show="isOpen">
      <div v-for="plan in templates" :key="plan.template_id" class="plan-card" @click="selectPlan(plan.template_id)">
        <h4 class="plan-card__title">{{ plan.title }}</h4>
        <p class="plan-card__desc">{{ plan.description }}</p>
      </div>

      <div v-if="templates.length === 0" class="p-p1" style="color:#999">
        載入模板中...
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.accordion {
  width: 100%;
  color: $primary-color-800;
  border-top: 1px solid $neutral-color-100;
  border-bottom: 1px solid $neutral-color-100;
  max-height: 400px;
  overflow-y: auto;

  &::-webkit-scrollbar {
    display: none;
  }

  &__header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 0;
    cursor: pointer;
    transition: background-color 0.2s;

    &:hover {
      color: $primary-color-700;
    }
  }

  &__text {
    font-weight: bold;
  }

  &__arrow {
    transition: transform 0.3s ease;
    display: flex;
    align-items: center;

    &.rotated {
      transform: rotate(180deg);
    }
  }

  &__content {
    padding-bottom: 20px;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
}

.plan-card {
  border-radius: 8px;
  padding: 16px;
  background-color: $neutral-color-100;
  transition: transform 0.2s, box-shadow 0.2s;
  cursor: pointer;

  &:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 12px $neutral-color-100;
    background-color: $accent-color-100;
  }

  &__title {
    margin: 0 0 8px 0;
    font-size: 1rem;
    color: $primary-color-800;
  }

  &__desc {
    margin: 0;
    font-size: 0.9rem;
    color: $neutral-color-800;
    line-height: 1.5;
  }
}
</style>
