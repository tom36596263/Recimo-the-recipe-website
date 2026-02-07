<script setup>
import { ref, provide, onMounted, computed, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useRecipeStore } from '@/stores/recipeEditor';
import { useAuthStore } from '@/stores/authStore';
import { publicApi } from '@/utils/publicApi';
import { parsePublicFile } from '@/utils/parseFile';
import { phpApi } from '@/utils/phpApi';

import EditorHeader from '@/components/workspace/editrecipe/EditorHeader.vue';
import IngredientEditor from '@/components/workspace/editrecipe/IngredientEditor.vue';
import StepEditor from '@/components/workspace/editrecipe/StepEditor.vue';
import TagModal from '@/components/workspace/editrecipe/modals/TagModal.vue';

const router = useRouter();
const route = useRoute();
const recipeStore = useRecipeStore();
const authStore = useAuthStore();

const isEditing = ref(true);
const isPublished = ref(true);

const ingredientsMasterList = ref([]);
const tagsMasterList = ref([]);
const isTagModalOpen = ref(false);

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
  tags: [],
  original_title: '',
  adapt_title: '',
  adapt_description: '',
  recipe_servings: 1
});

const isAdaptModeActive = computed(() => {
  const hasParentId = !!recipeForm.value.parent_recipe_id;
  const hasAdaptQuery = route.query.action === 'adapt' || route.query.action === 'edit_adaptation';
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

watch(() => recipeForm.value.steps, (newSteps) => {
  if (!newSteps || !isEditing.value) return;
  const autoSum = newSteps.reduce((sum, s) => sum + (Number(s.time) || 0), 0);
  recipeForm.value.totalTime = autoSum;
}, { deep: true });

watch(() => recipeForm.value.ingredients, (newIngs) => {
  newIngs.forEach(ing => {
    if (ing.id && (ing.kcal_per_100g === undefined || ing.kcal_per_100g === null)) {
      // 加上 ?. 確保 master 存在才讀取，避免噴錯
      const master = ingredientsMasterList.value.find(m => Number(m.ingredient_id) === Number(ing.id));
      if (master) {
        ing.kcal_per_100g = Number(master.kcal_per_100g) || 0;
        ing.protein_per_100g = Number(master.protein_per_100g) || 0;
        ing.fat_per_100g = Number(master.fat_per_100g) || 0;
        ing.carbs_per_100g = Number(master.carbs_per_100g) || 0;
        ing.gram_conversion = Number(master.gram_conversion) || 1.0;
        if (!ing.unit) ing.unit = master.unit_name || '份';
      }
    }
  });
}, { deep: true });

onMounted(async () => {
  const rawId = route.query.editId || route.params.id;
  const editIdFromUrl = rawId ? Number(rawId) : null;
  const isAdapt = route.query.action === 'adapt';
  const isEditAdaptation = route.query.action === 'edit_adaptation';

  if (isAdapt || isEditAdaptation) isPublished.value = true;

  try {
    const [resIng, resTag] = await Promise.all([
      phpApi.get('recipes/admin_get_ingredients.php'),
      phpApi.get('recipes/recipe_tags_get.php')
    ]);
    ingredientsMasterList.value = resIng.data || [];
    tagsMasterList.value = resTag.data || [];

    if (recipeStore.rawEditorData) {
      recipeForm.value = { ...recipeStore.rawEditorData };
      if (isAdapt) {
        recipeForm.value.parent_recipe_id = editIdFromUrl;
        recipeForm.value.recipe_id = null;
      }
      recipeStore.rawEditorData = null;
      return;
    }

    if (!editIdFromUrl) return;

    const response = await phpApi.get(`recipes/recipe_detail_get.php?recipe_id=${editIdFromUrl}`);
    if (response.data && response.data.success) {
      const { main, ingredients, steps, tags } = response.data.data;

      if (isAdapt) {
        recipeForm.value.recipe_id = null;
        recipeForm.value.parent_recipe_id = editIdFromUrl;
        recipeForm.value.original_title = main.recipe_title;
        recipeForm.value.adapt_title = main.recipe_title + ' (改編版)';
        recipeForm.value.title = main.recipe_title;
        recipeForm.value.description = main.recipe_description || '';
      } else if (isEditAdaptation) {
        recipeForm.value.recipe_id = editIdFromUrl;
        recipeForm.value.parent_recipe_id = main.parent_recipe_id;
        recipeForm.value.title = main.recipe_title;
        recipeForm.value.description = main.recipe_description || '';
        recipeForm.value.adapt_title = main.adaptation_title || main.recipe_title;
        recipeForm.value.adapt_description = main.adaptation_note || '';
      } else {
        recipeForm.value.recipe_id = editIdFromUrl;
        recipeForm.value.title = main.recipe_title;
        recipeForm.value.description = main.recipe_description || '';
      }

      recipeForm.value.difficulty = Number(main.recipe_difficulty) || 1;
      recipeForm.value.recipe_servings = Number(main.recipe_servings) || 1;
      recipeForm.value.coverImg = parsePublicFile(main.recipe_image_url || '');
      recipeForm.value.totalTime = parseInt(main.recipe_total_time, 10) || 0;
      recipeForm.value.tags = tags.map(t => ({ tag_id: t.tag_id, tag_name: t.tag_name }));

      recipeForm.value.ingredients = ingredients.map(ing => ({
        id: Number(ing.ingredient_id),
        name: ing.ingredient_name,
        amount: ing.amount,
        unit: ing.unit_name || '份',
        note: ing.remark || '',
        color_tag: ing.color_tag || '',
        kcal_per_100g: Number(ing.kcal_per_100g),
        protein_per_100g: Number(ing.protein_per_100g),
        fat_per_100g: Number(ing.fat_per_100g),
        carbs_per_100g: Number(ing.carbs_per_100g),
        gram_conversion: Number(ing.gram_conversion)
      }));

      recipeForm.value.steps = steps.map((s, idx) => ({
        id: (isAdapt) ? `adapt-s-${idx}` : (s.step_id || `s-${idx}`),
        title: s.step_title || `步驟 ${idx + 1}`,
        content: s.step_content || '',
        image: parsePublicFile(s.step_image_url || ''),
        time: s.total_seconds ? Math.round(Number(s.total_seconds) / 60) : 0,
        tags: s.step_ingredients ? s.step_ingredients.map(id => Number(id)) : []
      }));
    }
  } catch (err) {
    console.error('❌ 載入失敗:', err);
  }
});

const publishToDb = async () => {
  if (!authStore.isLoggedIn) {
    authStore.openLoginAlert();
    return;
  }

  // 🏆 核心修正：使用 Store 提供的 userId 計算屬性
  // 這樣不論你的 LocalStorage 存的是 id 還是 user_id，都能正確抓到
  const currentUserId = authStore.userId;

  console.log('當前登入用戶資訊:', authStore.user);
  console.log('準備傳給 API 的 ID:', currentUserId);

  if (!currentUserId) {
    alert('找不到您的用戶資訊，請嘗試重新登入。');
    return;
  }

  try {
    // 🔥 圖片處理邏輯
    const handleImage = async (img) => {
      if (!img) return null;
      if (img instanceof File) {
        return await fileToBase64(img);
      }
      if (typeof img === 'string') {
        return img;
      }
      return null;
    };

    const coverData = await handleImage(recipeForm.value.coverImg);

    const processedSteps = await Promise.all(
      recipeForm.value.steps.map(async (s) => {
        const totalMinutes = Number(s.time) || 0;
        const hrs = Math.floor(totalMinutes / 60);
        const mins = totalMinutes % 60;
        const timeString = `${String(hrs).padStart(2, '0')}:${String(mins).padStart(2, '0')}:00`;

        return {
          step_title: s.title,
          step_content: s.content || '',
          step_image_url: await handleImage(s.image),
          step_total_time: timeString,
          step_ingredients: s.tags
        };
      })
    );

    const payload = {
      recipe_id: recipeForm.value.recipe_id || null,
      parent_recipe_id: recipeForm.value.parent_recipe_id || null,
      author_id: currentUserId, // 這裡現在保證能拿到正確的 ID 數字
      recipe_title: isAdaptModeActive.value ? (recipeForm.value.adapt_title || recipeForm.value.title) : recipeForm.value.title,
      recipe_description: recipeForm.value.description || '暫無詳細說明',
      adaptation_note: isAdaptModeActive.value ? (recipeForm.value.adapt_description || '') : '',
      adaptation_title: isAdaptModeActive.value ? (recipeForm.value.adapt_title || recipeForm.value.title) : '',
      recipe_image_url: coverData,
      recipe_difficulty: recipeForm.value.difficulty,
      total_time: recipeForm.value.totalTime,
      recipe_servings: recipeForm.value.recipe_servings,
      ingredients: recipeForm.value.ingredients.map(ing => {
        const isTempId = typeof ing.id === 'string' && ing.id.startsWith('id');
        return {
          ingredient_id: isTempId ? null : ing.id,
          ingredient_name: ing.name,
          amount: ing.amount,
          remark: ing.note,
          unit_name: ing.unit || '份',
          color_tag: ing.color_tag || null
        };
      }),
      steps: processedSteps,
      tags: recipeForm.value.tags.map(t => t.tag_id)
    };

    const apiUrl = recipeForm.value.recipe_id ? 'recipes/recipe_adaptation_update.php' : 'recipes/recipe_adaptation_add.php';
    const response = await phpApi.post(apiUrl, payload);

    if (response.data && response.data.success) {
      const msg = recipeForm.value.recipe_id ? '🎉 食譜已更新！' : '🎉 感謝分享！改編版本已正式發布。';
      alert(msg);

      if (isAdaptModeActive.value) {
        const parentId = recipeForm.value.parent_recipe_id;
        router.push(`/workspace/modify-recipe/${parentId}`);
      } else {
        router.push('/workspace/my-recipes');
      }
    } else {
      alert(`發布失敗：${response.data?.message || '資料庫寫入失敗'}`);
    }
  } catch (err) {
    console.error('❌ 發布過程發生異常:', err);
    const errorDetail = err.response?.data?.message || err.message;
    alert(`發布異常：${errorDetail}`);
  }
};
//   if (!authStore.isLoggedIn) {
//     authStore.openLoginAlert();
//     return;
//   }

//   // 🏆 核心修正：使用 Store 提供的 userId 計算屬性
//   // 這樣不論你的 LocalStorage 存的是 id 還是 user_id，都能正確抓到
//   const currentUserId = authStore.userId;

//   console.log('當前登入用戶資訊:', authStore.user);
//   console.log('準備傳給 API 的 ID:', currentUserId);

//   if (!currentUserId) {
//     alert('找不到您的用戶資訊，請嘗試重新登入。');
//     return;
//   }

//   try {
//     // 🔥 圖片處理邏輯
//     const handleImage = async (img) => {
//       if (!img) return null;
//       if (img instanceof File) {
//         return await fileToBase64(img);
//       }
//       if (typeof img === 'string') {
//         return img;
//       }
//       return null;
//     };

//     const coverData = await handleImage(recipeForm.value.coverImg);

//     const processedSteps = await Promise.all(
//       recipeForm.value.steps.map(async (s) => {
//         const totalMinutes = Number(s.time) || 0;
//         const hrs = Math.floor(totalMinutes / 60);
//         const mins = totalMinutes % 60;
//         const timeString = `${String(hrs).padStart(2, '0')}:${String(mins).padStart(2, '0')}:00`;

//         return {
//           title: s.title,
//           content: s.content || '',
//           image: await handleImage(s.image),
//           time: timeString,
//           tags: s.tags
//         };
//       })
//     );

//     const payload = {
//       recipe_id: recipeForm.value.recipe_id, // 若有 id 則傳入
//       mode: recipeForm.value.recipe_id ? 'update' : 'create', // 明確告知 PHP 是更新還是創建
//       author_id: currentUserId, // 這裡現在保證能拿到正確的 ID 數字
//       title: recipeForm.value.title,
//       recipe_description: recipeForm.value.description || '暫無詳細說明',
//       // adaptation_note: isAdaptModeActive.value ? (recipeForm.value.adapt_description || '') : '',
//       // adaptation_title: isAdaptModeActive.value ? (recipeForm.value.adapt_title || recipeForm.value.title) : '',
//       coverImg: coverData,
//       recipe_difficulty: recipeForm.value.difficulty,
//       totalTime: recipeForm.value.totalTime,
//       servings: recipeForm.value.recipe_servings,
//       status: isPublished.value ? 1 : 0,
//       ingredients: recipeForm.value.ingredients.map(ing => ({
//         id: (typeof ing.id === 'string' && ing.id.startsWith('id')) ? null : ing.id,
//         amount: ing.amount,
//         unit: ing.unit || '份',
//         note: ing.note || ''
//       })),
//       steps: processedSteps,
//       tags: recipeForm.value.tags.map(t => t.tag_id)
//     };

//     const response = await phpApi.post('recipes/recipe_post.php', payload);

//     if (response.data && response.data.success) {
//       alert('🎉 食譜發布成功！');
//       router.push('/workspace/my-recipes');
//     } else {
//       alert(`發布失敗：${response.data?.message}`);
//     }

//   } catch (err) {
//     console.error('❌ 創建失敗:', err);
//     alert('系統發生異常，請稍後再試');
//   }
// };
const publishNewRecipeToDb = async () => {
  if (!authStore.isLoggedIn) {
    authStore.openLoginAlert();
    return;
  }

  const currentUserId = authStore.userId;
  if (!currentUserId) {
    alert('找不到您的用戶資訊，請嘗試重新登入。');
    return;
  }

  try {
    // --- 圖片處理 Helper ---
    const handleImage = async (img) => {
      if (!img) return null;
      if (img instanceof File) return await fileToBase64(img);
      if (typeof img === 'string') return img; // 已是 Base64 或路徑
      return null;
    };

    // 1. 處理主圖
    const coverData = await handleImage(recipeForm.value.coverImg);

    // 2. 處理步驟資料 (修正 Key 名稱以匹配 PHP)
    const processedSteps = await Promise.all(
      recipeForm.value.steps.map(async (s) => {
        return {
          title: s.title || '',           // PHP 期待 $step['title']
          content: s.content || '',       // PHP 期待 $step['content']
          image: await handleImage(s.image), // PHP 期待 $step['image']
          time: Number(s.time) || 0,      // PHP 期待 $step['time'] (分鐘數)
          tags: s.tags || []              // PHP 期待 $step['tags'] (食材 ID 陣列)
        };
      })
    );

    // 3. 封裝完整 Payload
    const payload = {
      recipe_id: recipeForm.value.recipe_id || null,
      mode: recipeForm.value.recipe_id ? 'update' : 'create',
      author_id: currentUserId,
      title: recipeForm.value.title,
      description: recipeForm.value.description || '',
      coverImg: coverData,                // PHP 期待 $input['coverImg']
      difficulty: Number(recipeForm.value.difficulty) || 1,
      totalTime: Number(recipeForm.value.totalTime) || 0,
      servings: Number(recipeForm.value.recipe_servings) || 1, // PHP 期待 $input['servings']
      status: 1, // 強制設為 1 (已發布狀態)
      
      // 食材處理 (修正 Key 名稱)
      ingredients: recipeForm.value.ingredients.map(ing => ({
        id: (typeof ing.id === 'string' && ing.id.startsWith('id')) ? null : Number(ing.id),
        amount: ing.amount === '' ? 0 : Number(ing.amount),
        unit: ing.unit || '',             // PHP 期待 $ing['unit']
        note: ing.note || ''              // PHP 期待 $ing['note']
      })),
      
      steps: processedSteps,
      tags: recipeForm.value.tags.map(t => t.tag_id) // 這是食譜總標籤
    };

    console.log('發送至後端的 Payload:', payload);

    // 4. 發送請求
    const response = await phpApi.post('recipes/recipe_post.php', payload);

    if (response.data && response.data.success) {
      alert('🎉 食譜儲存成功！');
      router.push('/workspace/my-recipes');
    } else {
      alert(`儲存失敗：${response.data?.message || '未知錯誤'}`);
    }

  } catch (err) {
    console.error('❌ 儲存過程發生異常:', err);
    alert('系統發生異常，請檢查網路連線或稍後再試');
  }
};
// const handleSave = async () => {
//   if (isAdaptModeActive.value) {
//     await publishToDb();
//     return;
//   }
//   if (isPublished.value) {
//     await publishNewRecipeToDb();
//     return; 
//   } 
//   // 情況 C：一般模式 + 點擊「完成編輯」（未勾選公開）
//   // 這裡通常應該也要呼叫 API 儲存，但 status 設為草稿 (例如 0)，或者直接跳回列表
//   const confirmSave = confirm("確定完成編輯並儲存為草稿嗎？");
//   if (confirmSave) {
//     // 強制觸發一次儲存（確保資料有進資料庫，但 status 為未發布）
//     await publishNewRecipeToDb(); 
//     // 或者如果你只想純跳轉，可以改用：
//     // router.push('/workspace/my-recipes');
//   }
//   console.log('Save Clicked', isPublished.value)
// };
const handleSave = async () => {
  // 1. 基礎驗證
  if (!recipeForm.value.title && !isAdaptModeActive.value) {
    alert('請輸入食譜標題');
    return;
  }

  // 2. 根據模式執行不同的儲存函式
  // 我們在呼叫前強制確保 status 邏輯（或在函式內寫死為 1）
  isPublished.value = true; 

  try {
    if (isAdaptModeActive.value) {
      // 改編模式：呼叫 publishToDb (對應 recipe_adaptation_add.php)
      await publishToDb();
    } else {
      // 一般模式：呼叫 publishNewRecipeToDb (對應 recipe_post.php)
      await publishNewRecipeToDb();
    }
  } catch (err) {
    console.error('儲存失敗:', err);
  }
};

const handlePreview = async () => {
  // 1. 處理圖片轉 Base64
  const coverBase64 = await fileToBase64(recipeForm.value.coverImg);
  const processedSteps = await Promise.all(
    recipeForm.value.steps.map(async (s, idx) => ({
      ...s,
      step_id: s.id || `s-${idx}`,
      step_title: s.title || `步驟 ${idx + 1}`,
      step_content: s.content || s.step_content || '',
      step_total_time: s.time ? `${s.time} 分鐘` : '0 分鐘',
      step_order: idx + 1,
      step_image_url: await fileToBase64(s.image)
    }))
  );

  // 2. 處理食材標籤狀態與營養係數
  const tagToStatus = { 'tag-green': 'add', 'tag-orange': 'mod', 'tag-blue': 'rep' };
  const processedIngredients = recipeForm.value.ingredients.map(ing => ({
    ...ing,
    ingredient_id: ing.id,
    ingredient_name: ing.name,
    unit_name: ing.unit || '份',
    status: tagToStatus[ing.color_tag] || '',
    kcal_per_100g: Number(ing.kcal_per_100g || 0),
    protein_per_100g: Number(ing.protein_per_100g || 0),
    fat_per_100g: Number(ing.fat_per_100g || 0),
    carbs_per_100g: Number(ing.carbs_per_100g || 0),
    gram_conversion: Number(ing.gram_conversion || 1.0)
  }));

  // 3. 封裝 Preview 資料 (確保 Key 與詳情頁 fetchData 讀取的名稱一致)
  const previewData = {
    // 這裡先展開原始資料，再覆寫詳情頁需要的特定 Key
    ...JSON.parse(JSON.stringify(recipeForm.value)),
    recipe_title: isAdaptModeActive.value ? (recipeForm.value.adapt_title || recipeForm.value.title) : recipeForm.value.title,
    recipe_description: isAdaptModeActive.value ? (recipeForm.value.adapt_description || recipeForm.value.description) : recipeForm.value.description,
    recipe_cover_image: coverBase64, // 詳情頁 read 此 Key
    recipe_servings: Number(recipeForm.value.recipe_servings || 1),
    ingredients: processedIngredients,
    steps: processedSteps,
    recipe_tags: recipeForm.value.tags, // 對齊詳情頁 serverData.tags 邏輯
    totalTime: Number(recipeForm.value.totalTime || 0)
  };

  // 4. 同步回 Store 並跳轉
  // 先存原始編輯狀態供「返回」使用
  recipeStore.rawEditorData = JSON.parse(JSON.stringify(recipeForm.value));
  // 再存預覽用資料
  recipeStore.setPreviewFromEditor(previewData);

  router.push({
    path: `/workspace/recipe-detail/${route.query.editId || route.params.id || 0}`,
    query: {
      mode: 'preview',
      editId: route.query.editId || route.params.id,
      action: route.query.action
    }
  });
};

const handleAddTags = (newTags) => {
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
            <IngredientEditor v-model:ingredients="recipeForm.ingredients" :is-editing="isEditing"
              :is-adapt-mode="isAdaptModeActive" />
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
          <BaseBtn 
            :title="isAdaptModeActive ? '分享我的版本' : '確認發布'" 
            :width="200"
            @click="handleSave" 
            class="save-btn" 
          />
          <!-- <div v-if="!isAdaptModeActive" class="publish-toggle">
            <input type="checkbox" id="publish-check" v-model="isPublished" />
            <label for="publish-check" class="p-p2">公開發布</label>
          </div> -->
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
  }

  .publish-toggle {
    display: flex;
    align-items: center;
    gap: 8px;

    input {
      width: 18px;
      height: 18px;
      cursor: pointer;
    }

    label {
      cursor: pointer;
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