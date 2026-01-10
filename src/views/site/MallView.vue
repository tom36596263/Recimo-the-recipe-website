<script setup>
import { ref } from 'vue';
import BaseModal from '@/components/BaseModal.vue'; // 假設元件路徑

// 控制各個 Modal 的變數
const showUnsaved = ref(false);
const showLoginFail = ref(false);
const showDelete = ref(false);
const showSuccess = ref(false);

const handleAddToCart = () => {
  // 做一些邏輯...
  showSuccess.value = true;
};
</script>

<template>
  <div style="padding: 50px">
    <h2>彈窗測試按鈕</h2>
    <button
      class="btn h-40 btn-outline"
      style="width: 200px"
      @click="showUnsaved = true"
    >
      1. 尚未儲存 (Danger)
    </button>
    <button
      class="btn h-40 btn-outline"
      style="width: 200px"
      @click="showLoginFail = true"
    >
      2. 登入失敗 (Danger)
    </button>
    <button
      class="btn h-40 btn-outline"
      style="width: 200px"
      @click="showDelete = true"
    >
      3. 刪除確認 (Info)
    </button>
    <button
      class="btn h-40 btn-outline"
      style="width: 200px"
      @click="handleAddToCart"
    >
      4. 加入購物車
    </button>

    <BaseModal
      :isOpen="showUnsaved"
      type="danger"
      iconClass="fa-solid fa-exclamation"
      title="尚未儲存"
      description="您剛才編輯的內容尚未儲存，離開後這些變動將會遺失"
      @close="showUnsaved = false"
    >
      <template #actions>
        <button class="btn-solid" @click="showUnsaved = false">留在頁面</button>
        <button class="btn-outline">捨棄並離開</button>
      </template>
    </BaseModal>

    <BaseModal
      :isOpen="showLoginFail"
      type="danger"
      iconClass="fa-solid fa-exclamation"
      title="登入失敗"
      @close="showLoginFail = false"
    >
      <template #actions>
        <button class="btn-solid">重新登入</button>
        <button class="btn-outline">忘記密碼</button>
      </template>
    </BaseModal>

    <BaseModal
      :isOpen="showDelete"
      type="info"
      iconClass="fa-regular fa-trash-can"
      title="商品是否要從購物車刪除"
      @close="showDelete = false"
    >
      <template #actions>
        <button class="btn-solid">確定刪除</button>
        <button class="btn-outline" @click="showDelete = false">取消</button>
      </template>
    </BaseModal>

    <BaseModal
      :isOpen="showSuccess"
      type="success"
      iconClass="fa-solid fa-check"
      title="已加入購物車"
      @close="showSuccess = false"
    >
    </BaseModal>
  </div>

  <div style="width: 150px">
    <input type="text" class="form-input is-error" placeholder="輸入文字" />
  </div>
  <div style="width: 200px">
    <button class="btn h-40 btn-solid">加入購物車</button>
  </div>
</template>

<style lang="scss" scoped>
//  lang="scss": 告訴 Vue 這裡要用 Scss 編譯
//  scoped: 確保這裡寫的 CSS 只會影響目前這個頁面，不會「跑去污染」到其他頁面的樣式。
</style>
