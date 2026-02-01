<script setup>
import { ref, provide, onMounted, computed, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useRecipeStore } from '@/stores/recipeEditor';
import { publicApi } from '@/utils/publicApi';
import { parsePublicFile } from '@/utils/parseFile';

import EditorHeader from '@/components/workspace/editrecipe/EditorHeader.vue';
import IngredientEditor from '@/components/workspace/editrecipe/IngredientEditor.vue';
import StepEditor from '@/components/workspace/editrecipe/StepEditor.vue';
import TagModal from '@/components/workspace/editrecipe/modals/TagModal.vue';

const router = useRouter();
const route = useRoute();
const recipeStore = useRecipeStore();

const isEditing = ref(true);
const isPublished = ref(false);

const ingredientsMasterList = ref([]);
const tagsMasterList = ref([]);
const isTagModalOpen = ref(false); // 在 <script setup> 頂部加入

// --- 1. 食譜表單資料 (確保 tags 初始存在) ---
const recipeForm = ref({
  recipe_id: null,
  parent_recipe_id: null,
  title: '',
  description: '',
  coverImg: null,
  difficulty: 1,
  totalTime: 0,
  ingredients: [],
  steps: [],
  tags: [], // ✨ 必須在這裡預設，Vue 才能監聽變動
  original_title: '',
  adapt_title: '',
  adapt_description: '',
  recipe_servings: 1
});

// --- 2. 監聽步驟時間自動加總 ---
watch(
  () => recipeForm.value.steps,
  (newSteps) => {
    if (!newSteps || !isEditing.value) return;
    const autoSum = newSteps.reduce((sum, s) => sum + (Number(s.time) || 0), 0);
    if (Number(recipeForm.value.totalTime) === 0) {
      recipeForm.value.totalTime = autoSum;
    }
  },
  { deep: true }
);

// ✨ 監聽食材變動補齊營養係數
watch(
  () => recipeForm.value.ingredients,
  (newIngs) => {
    newIngs.forEach(ing => {
      if (ing.id && (ing.kcal_per_100g === undefined || ing.kcal_per_100g === null)) {
        const master = ingredientsMasterList.value.find(m => Number(m.ingredient_id) === Number(ing.id));
        if (master) {
          ing.kcal_per_100g = master.kcal_per_100g || 0;
          ing.protein_per_100g = master.protein_per_100g || 0;
          ing.fat_per_100g = master.fat_per_100g || 0;
          ing.carbs_per_100g = master.carbs_per_100g || 0;
          ing.gram_conversion = master.gram_conversion || 1.0;
          if (!ing.unit) ing.unit = master.unit_name || '份';
        }
      }
    });
  },
  { deep: true }
);

const isAdaptModeActive = computed(() => {
  const hasParentId = !!recipeForm.value.parent_recipe_id;
  const hasAdaptQuery = route.query.action === 'adapt';
  return hasParentId || hasAdaptQuery;
});

const fileToBase64 = (file) => {
  return new Promise((resolve, reject) => {
    if (!file) return resolve(null);
    if (typeof file === 'string') return resolve(file);
    if (file instanceof File) {
      const reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onload = () => resolve(reader.result);
      reader.onerror = (error) => reject(error);
    } else {
      resolve(null);
    }
  });
};

onMounted(async () => {
  const rawId = route.query.editId || route.params.id;
  const editIdFromUrl = rawId ? Number(rawId) : null;
  const isAdapt = route.query.action === 'adapt';

  try {
    // 1. 載入 Master Data
    const [resIng, resTag] = await Promise.all([
      publicApi.get('data/recipe/ingredients.json'),
      publicApi.get('data/recipe/tags.json')
    ]);
    ingredientsMasterList.value = resIng.data || [];
    tagsMasterList.value = resTag.data || [];

    if (recipeStore.rawEditorData) {
      recipeForm.value = { ...recipeStore.rawEditorData };
      // ✨ [關鍵修正]：確保「改編模式」的狀態被正確維持
      if (isAdapt) {
        // 如果是改編，必須確保 parent_recipe_id 是網址上的那個 ID
        // 這樣 handleSave 的 isAdaptModeActive 判斷才不會失效
        recipeForm.value.parent_recipe_id = editIdFromUrl;
        recipeForm.value.recipe_id = null; // 改編不應該有自己的舊 ID
      }

      // 清空暫存，避免污染下次開啟
      recipeStore.rawEditorData = null;
      console.log('🔄 已從暫存恢復資料，並同步改編狀態');
      return; // 這裡可以結束，因為內容已經恢復，不需要再讀取 JSON
    }
    

    if (!editIdFromUrl) return;

    // 2. 載入食譜主資訊
    const resR = await publicApi.get('data/recipe/recipes.json');
    const found = resR.data.find(r => Number(r.recipe_id) === editIdFromUrl);

    if (found) {
      if (isAdapt) {
        recipeForm.value.recipe_id = null;
        recipeForm.value.parent_recipe_id = editIdFromUrl;
        recipeForm.value.original_title = found.recipe_title;
        recipeForm.value.adapt_title = found.recipe_title + ' (改編版)';
        recipeForm.value.title = found.recipe_title;
        recipeForm.value.adapt_description = '';
      } else {
        recipeForm.value.recipe_id = editIdFromUrl;
        recipeForm.value.title = found.recipe_title;
      }
      recipeForm.value.description = found.recipe_description || found.recipe_descreption || '';
      recipeForm.value.difficulty = found.recipe_difficulty || 1;
      recipeForm.value.recipe_servings = found.recipe_servings || 1;
      recipeForm.value.coverImg = parsePublicFile(found.recipe_image_url || found.recipe_cover_image || '');

      const tTime = String(found.recipe_total_time || '30');
      recipeForm.value.totalTime = tTime.includes(':')
        ? (p => parseInt(p[0], 10) * 60 + parseInt(p[1], 10))(tTime.split(':'))
        : parseInt(tTime, 10) || 30;
    }

    // 3. 載入標籤 (Tags) - 加強匹配邏輯
    // 3. 載入標籤 (Tags) - 加強匹配邏輯與過濾
    try {
      const resRTags = await publicApi.get('data/recipe/recipe_tag.json');
      const allTagLinks = Array.isArray(resRTags.data) ? resRTags.data : [];

      // 1. 先過濾出屬於這個食譜的關聯
      const myLinks = allTagLinks.filter(rt => Number(rt.recipe_id) === Number(editIdFromUrl));

      console.log('原始關聯資料 (myLinks):', myLinks);
      console.log('目前標籤定義表 (tagsMasterList):', tagsMasterList.value);

      // 2. 進行匹配
      const matchedTags = myLinks.map(link => {
        // 🏆 強制兩邊都轉為數字進行比較，避免 "1" !== 1 的問題
        const tagDetail = tagsMasterList.value.find(t => Number(t.tag_id) === Number(link.tag_id));

        if (tagDetail) {
          return {
            tag_id: tagDetail.tag_id,
            tag_name: tagDetail.tag_name
          };
        }
        return null;
      }).filter(t => t !== null);

      // 3. 賦值
      recipeForm.value.tags = matchedTags;

      console.log('✅ 最後生成的標籤陣列:', recipeForm.value.tags);

    } catch (e) {
      console.error('標籤讀取或匹配失敗', e);
    }

    // 4. 載入食材
    const resRIng = await publicApi.get('data/recipe/recipe_ingredient.json');
    const ingLinks = (resRIng.data || []).filter(i => Number(i.recipe_id) === Number(editIdFromUrl));
    recipeForm.value.ingredients = ingLinks.map(link => {
      const master = ingredientsMasterList.value.find(m => Number(m.ingredient_id) === Number(link.ingredient_id));
      return {
        id: link.ingredient_id,
        name: master?.ingredient_name || '',
        amount: link.amount,
        unit: link.unit_name || master?.unit_name || '份',
        note: link.remark || '',
        kcal_per_100g: master?.kcal_per_100g || 0,
        protein_per_100g: master?.protein_per_100g || 0,
        fat_per_100g: master?.fat_per_100g || 0,
        carbs_per_100g: master?.carbs_per_100g || 0,
        gram_conversion: master?.gram_conversion || 1.0
      };
    });

    // 5. 載入步驟
    const [resS, resSIng] = await Promise.all([
      publicApi.get('data/recipe/steps.json'),
      publicApi.get('data/recipe/step_ingredients.json')
    ]);
    const sData = (resS.data || []).filter(s => Number(s.recipe_id) === Number(editIdFromUrl)).sort((a, b) => a.step_order - b.step_order);
    recipeForm.value.steps = sData.map((s, idx) => ({
      id: isAdapt ? `adapt-s-${idx}` : (s.step_id || `s-${idx}`),
      title: s.step_title || `步驟 ${idx + 1}`,
      content: s.step_content || '',
      image: parsePublicFile(s.step_image_url || s.image || ''),
      time: s.step_total_time?.toString().includes(':')
        ? (p => parseInt(p[0], 10) * 60 + parseInt(p[1], 10))(s.step_total_time.split(':'))
        : parseInt(s.step_total_time, 10) || 0,
      tags: (resSIng.data || []).filter(si => Number(si.step_id) === Number(s.step_id)).map(si => si.ingredient_id)
    }));

  } catch (err) {
    console.error('❌ 載入失敗:', err);
  }
});

const handleSave = async () => {
  const finalTitle = isAdaptModeActive.value
    ? (recipeForm.value.adapt_title || `${recipeForm.value.original_title} (改編版)`)
    : recipeForm.value.title;

  // 取得來源 ID (如果是改編，這就是原食譜 ID)
  const sourceId = route.query.editId || route.params.id;

  if (isPublished.value) {
    try {
      const coverBase64 = await fileToBase64(recipeForm.value.coverImg);
      const processedSteps = await Promise.all(
        recipeForm.value.steps.map(async (s) => ({ ...s, image: await fileToBase64(s.image) }))
      );

      const localRevisions = JSON.parse(localStorage.getItem('user_revisions') || '[]');

      const saveData = {
        ...recipeForm.value,
        id: Date.now(),
        title: finalTitle,
        coverImg: coverBase64,
        steps: processedSteps,
        description: isAdaptModeActive.value ? recipeForm.value.adapt_description : recipeForm.value.description,
        publishDate: new Date().toLocaleDateString(),
        is_local: true,
        is_mine: true
      };

      localRevisions.unshift(saveData);
      localStorage.setItem('user_revisions', JSON.stringify(localRevisions));

      alert(`🎉「${finalTitle}」已發布！`);

      // ✨✨✨ 關鍵跳轉邏輯 ✨✨✨
      if (isAdaptModeActive.value && sourceId) {
        // 🚀 如果是改編模式：回到原本食譜的「改編一覽」頁面
        router.push(`/workspace/modify-recipe/${sourceId}`);
      } else {
        // 📝 如果是全新創建：回到「我的食譜」
        router.push('/workspace/my-recipes');
      }

    } catch (err) {
      console.error("儲存失敗:", err);
    }
  } else {
    // 儲存草稿的情況 (非公開發布)
    alert('草稿儲存成功！');
    router.push('/workspace/my-recipes');
  }

  recipeStore.rawEditorData = null;
};

const handlePreview = () => {
  recipeStore.rawEditorData = { ...recipeForm.value };
  recipeStore.setPreviewFromEditor(JSON.parse(JSON.stringify(recipeForm.value)));

  // 🚀 加上 query 參數，這樣預覽頁返回時才會知道自己還在 'adapt' 模式
  router.push({
    path: `/workspace/recipe-detail/${route.params.id || 0}`,
    query: {
      mode: 'preview',
      editId: route.query.editId || route.params.id,
      action: route.query.action
    }
  });
};

// 處理 Modal 傳回來的標籤
const handleAddTags = (newTags) => {
  // 使用解構賦值將新標籤塞進 recipeForm
  // Modal 內部已經處理過「重複選取」的過濾，所以這裡可以直接 push
  recipeForm.value.tags.push(...newTags);
};

provide('isEditing', isEditing);
</script>

<template>
  <div :class="['recipe-editor-page', { 'is-editing': isEditing }]">
    <main class="editor-main-layout container">
      <div class="header-section">
        <EditorHeader v-model="recipeForm" :is-editing="isEditing" :is-adapt-mode="isAdaptModeActive"
        @open-tag-modal="isTagModalOpen = true" />
      </div>

      <div class="recipe-main-content">
        <div class="row custom-row-fit">
          <aside class="ingredient-sidebar col-5 col-md-12">
            <IngredientEditor :ingredients="recipeForm.ingredients" :is-editing="isEditing" />
          </aside>
          <section class="step-content col-7 col-md-12">
            <StepEditor v-model:steps="recipeForm.steps" :ingredients="recipeForm.ingredients"
              :is-editing="isEditing" />
          </section>
        </div>
      </div>

      <footer class="editor-footer">
        <div class="footer-center-group">
          <BaseBtn title="預覽" variant="outline" :width="100" @click="handlePreview" class="preview-btn" />
          <BaseBtn :title="isPublished ? '確認發布' : '完成編輯'" :width="200" @click="handleSave" class="save-btn" />
          <div class="publish-toggle">
            <input type="checkbox" id="publish-check" v-model="isPublished" />
            <label for="publish-check" class="p-p2">公開發布</label>
          </div>
        </div>
      </footer>
    </main>
      <TagModal v-model="isTagModalOpen" :selected-list="recipeForm.tags" @add-multiple="handleAddTags" />
  </div>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

.recipe-editor-page {
  min-height: 100vh;
  padding: 40px 0 80px;
  background-color: $neutral-color-white;
}

.recipe-main-content {
  width: 100%;
  margin-top: 20px;
  border: 1px solid $primary-color-400;
  border-radius: 12px;
  background: $neutral-color-white;
  box-sizing: border-box;
  overflow: hidden;

  .custom-row-fit {
    margin: 0;

    >[class*="col-"] {
      padding: 32px 24px;
    }
  }
}

.editor-footer {
  width: 100%;
  display: flex;
  justify-content: center;
  margin-top: 60px;

  .footer-center-group {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 20px;
    width: 100%;
    max-width: 600px;

    @media screen and (max-width: 1024px) {
      gap: 12px;
      transform: scale(0.9);
    }
  }

  .publish-toggle {
    display: flex;
    align-items: center;
    gap: 8px;
    white-space: nowrap;

    input {
      width: 18px;
      height: 18px;
      accent-color: $primary-color-800;
      cursor: pointer;
    }

    label {
      cursor: pointer;
      color: $neutral-color-700;
    }
  }
}

.preview-btn,
.save-btn {
  height: 48px !important;
  display: inline-flex !important;
  align-items: center;
  justify-content: center;
  border-radius: 8px !important;
}

.preview-btn {
  width: 100px !important;
  min-width: 100px !important;
  border: 1px solid $primary-color-400 !important;
  color: $primary-color-400 !important;

  &:hover {
    background-color: $primary-color-100 !important;
  }
}

.save-btn {
  width: 200px !important;
}
</style>