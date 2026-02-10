<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { publicApi, phpApi } from '@/utils/publicApi';
import { parsePublicFile } from '@/utils/parseFile';
import { useRecipeStore } from '@/stores/recipeEditor';
import { useAuthStore } from '@/stores/authStore';
import { useFavoritesStore } from '@/stores/favoritesStore';

// 元件引用
import RecipeSteps from '../../components/workspace/recipedetail/RecipeSteps.vue';
import NutritionCard from '../../components/workspace/recipedetail/NutritionCard.vue';
import RecipeIngredients from '../../components/workspace/recipedetail/RecipeIngredients.vue';
import RecipeComments from '../../components/workspace/recipedetail/RecipeComments.vue';
import CookSnap from '../../components/workspace/recipedetail/CookSnap.vue';
import RecipeIntro from '../../components/workspace/recipedetail/RecipeIntro.vue';
import RecipeReportModal from '@/components/workspace/recipedetail/modals/RecipeReportModal.vue';
import RelatedRecipes from '@/components/workspace/recipedetail/RelatedRecipes.vue';
import AuthorInfo from '@/components/workspace/modifyrecipe/AuthorInfo.vue';
import DeleteAdaptationBtn from '@/components/workspace/modifyrecipe/DeleteAdaptationBtn.vue';

const route = useRoute();
const router = useRouter();
const recipeStore = useRecipeStore();
const authStore = useAuthStore();
const favoritesStore = useFavoritesStore();

// --- 1. 響應式資料狀態 ---
const rawRecipe = ref(null);
const rawIngredients = ref([]);
const rawSteps = ref([]);
const servings = ref(1);
const isLoading = ref(true);

const isLiked = ref(false);
const localLikesOffset = ref(0); // 本地模擬按讚增減

const isHubOpen = ref(false); // 用來控制選單展開/收合

const isPreviewMode = computed(() => route.query.mode === 'preview');
const isReportModalOpen = ref(false);

const getSmartImageUrl = (url) => {
  if (!url) return '';
  const urlStr = String(url);
  if (
    urlStr.startsWith('data:') ||
    urlStr.startsWith('blob:') ||
    urlStr.startsWith('http')
  )
    return urlStr;
  return parsePublicFile(urlStr);
};

const snapsData = ref([]);
const commentList = ref([]);

const cookSnapRef = ref(null);

// 控制刪除確認燈箱
const isDeleteConfirmOpen = ref(false);
const deleteTargetId = ref(null); // 用來暫存要刪除的 ID

// 真正的刪除 API 執行
const handleActualDelete = async () => {
  const cleanId = String(rawRecipe.value.recipe_id).replace(/[^\d]/g, '');

  try {
    const res = await phpApi.post('recipes/recipe_adaptation_delete.php', {
      recipe_id: cleanId,
      user_id: authStore.user?.id || authStore.user?.user_id
    });

    if (res.data.success) {
      isDeleteConfirmOpen.value = false; // 關閉燈箱
      onDeleteSuccess(cleanId); // 執行原本的跳轉邏輯
    } else {
      alert('刪除失敗：' + res.data.message);
    }
  } catch (err) {
    console.error('刪除出錯:', err);
  }
};

// --- 核心抓取邏輯 ---
const fetchData = async (quiet = false) => {
  if (!quiet) isLoading.value = true;
  console.log('🔍 [路由偵錯] route.params:', route.params);
  const recipeId = Number(route.params.id);
  console.log('🔍 [路由偵錯] 轉換後的 recipeId:', recipeId);

  
  // --- 1. 預覽模式優先處理 ---
  if (isPreviewMode.value) {
    const preview = recipeStore.previewData;

    if (preview) {
      try {
        // 同步抓取食材母表以校正營養係數 (保留你原本這段邏輯)
        const resIngMaster = await publicApi.get('data/recipe/ingredients.json');
        const masterIng = resIngMaster.data || [];

        // 份數捕獲：與編輯頁傳過來的 key 對齊
        const previewServings = Math.max(1, Number(preview.recipe_servings || 1));

        // 【關鍵修正】映射為與正式 API 格式完全一致的 rawRecipe
        rawRecipe.value = {
          ...preview,
          recipe_id: 0,
          recipe_title: preview.recipe_title || '未命名食譜',
          recipe_description: preview.recipe_description || '',
          recipe_image_url: preview.recipe_cover_image, // 對齊編輯頁傳來的 key
          recipe_difficulty: Number(preview.recipe_difficulty || 1),
          recipe_total_time: preview.recipe_total_time || '0:30',
          recipe_servings: previewServings, // 用於 computed 裡的 originalServings 計算
          recipe_likes: 0,
          author_name: authStore.user?.user_name || '您的預覽',
          tags: preview.recipe_tags || [],
          created_at: '',
        };

        // 處理食材 (保持你原本的 amount 運算，但確保 Key 對齊)
        rawIngredients.value = (preview.ingredients || []).map((ing) => {
          const name = (ing.ingredient_name || '').trim();
          const master = masterIng.find((m) => String(m.ingredient_name).trim() === name);
          const unit = ing.unit_name || master?.unit_name || '份';
          const isWeightUnit = ['g', '克', 'ml', '毫升'].includes(unit.toLowerCase());

          return {
            ...ing,
            ingredient_name: name,
            amount: Number(ing.amount || 0), // 保持原始數值，由 computed 處理份數縮放
            unit_name: unit,
            gram_conversion: isWeightUnit ? 1 : Number(ing.gram_conversion || master?.gram_conversion || 1),
            kcal_per_100g: Number(ing.kcal_per_100g || master?.kcal_per_100g || 0),
            protein_per_100g: Number(ing.protein_per_100g || master?.protein_per_100g || 0),
            fat_per_100g: Number(ing.fat_per_100g || master?.fat_per_100g || 0),
            carbs_per_100g: Number(ing.carbs_per_100g || master?.carbs_per_100g || 0)
          };
        });

        // 處理步驟
        rawSteps.value = (preview.steps || []).map((s, idx) => ({
          ...s,
          step_order: s.step_order || idx + 1
        })).sort((a, b) => Number(a.step_order) - Number(b.step_order));

        // 設為 1 份顯示模式
        servings.value = 1;

        if (!quiet) isLoading.value = false;
        return;
      } catch (err) {
        console.error('預覽資料解析失敗:', err);
      }
    }
  }
  const currentUid = authStore.user?.user_id || authStore.user?.id || 0;

  // --- 2. 正式模式：從伺服器抓取資料 ---
  console.log('🏠 [偵錯] 進入正式模式，請求 API 中...');
  try {
    const [resDetail, resG, resU, resC] = await Promise.all([
      phpApi.get(`recipes/recipe_detail_get.php?recipe_id=${recipeId}&user_id=${currentUid}`),
      phpApi.get(`social/gallery.php?recipe_id=${recipeId}`), // 改成你的 PHP 路徑
      publicApi.get('data/user/users.json'),
      recipeId
        ? phpApi.get(`social/comment.php?recipe_id=${recipeId}`)
        : Promise.resolve({ data: [] })
    ]);

    console.log('📥 [API 偵錯] PHP 回傳原始內容:', resDetail.data);

    if (resDetail.data && resDetail.data.success) {
      const serverData = resDetail.data.data;
      const mainData = serverData.main;

      rawRecipe.value = {
        ...serverData.main,
        // 🏆 關鍵修正：確保作者名稱有被存入 rawRecipe
        // 根據一般 API 慣例，嘗試從 main 裡面抓取可能的名字欄位
        author_name: mainData.author_name || 'Recimo 用戶',
        author_id: mainData.author_id,
        recipe_likes: Number(mainData.recipe_like_count || 0),
        created_at: mainData.recipe_created_at || mainData.created_at || '剛剛',
        recipe_description:
          serverData.main.recipe_descreption ||
          serverData.main.recipe_description ||
          '',
        tags: serverData.tags || []
      };

      isLiked.value = !!mainData.is_liked;
      localLikesOffset.value = 0; // 重置位移量

      rawIngredients.value = (serverData.ingredients || []).map((ing) => {
        const unit = ing.unit_name || '份';
        const isWeightUnit = ['g', '克', 'ml', '毫升'].includes(
          unit.toLowerCase()
        );
        return {
          ...ing,
          ingredient_name: ing.ingredient_name,
          unit_name: unit,
          gram_conversion: isWeightUnit ? 1 : Number(ing.gram_conversion || 1),
          kcal_per_100g: Number(ing.kcal_per_100g || 0),
          protein_per_100g: Number(ing.protein_per_100g || 0),
          fat_per_100g: Number(ing.fat_per_100g || 0),
          carbs_per_100g: Number(ing.carbs_per_100g || 0)
        };
      });

      rawSteps.value = (serverData.steps || []).sort(
        (a, b) => (Number(a.step_order) || 0) - (Number(b.step_order) || 0)
      );

      servings.value = 1; // 強制預設顯示為 1 份 (即整份食譜)
    }

    // --- 3. 處理成品照 ---
    if (resG.data && resG.data.success) {
      // 🏆 直接引用 axios 實例的 baseURL，確保開發與生產環境一致
      const API_BASE_URL = phpApi.defaults.baseURL.endsWith('/')
        ? phpApi.defaults.baseURL
        : `${phpApi.defaults.baseURL}/`;

      snapsData.value = resG.data.data
        .filter((item) => Number(item.recipe_id) === recipeId)
        .map((item) => {
          let finalImg = '';
          const rawUrl = item.gallery_url || '';

          if (rawUrl.startsWith('http')) {
            finalImg = rawUrl;
          } else if (rawUrl.includes(':\\')) {
            // 處理 Windows 實體路徑備案
            const parts = rawUrl.split('recimo_api\\');
            const relativePath = parts[1] ? parts[1].replace(/\\/g, '/') : '';
            finalImg = `${API_BASE_URL}${relativePath}`;
          } else {
            // 🏆 核心修正：移除路徑開頭的斜線，確保拼接正確
            const cleanPath = rawUrl.replace(/^\/+/, '');
            finalImg = `${API_BASE_URL}${cleanPath}`;
          }

          // 🔍 診錯日誌：如果還是破圖，請在瀏覽器控制台看這個輸出的網址
          console.log(`🖼️ 成品照 ID ${item.gallery_id} 最終路徑:`, finalImg);

          return {
            id: item.gallery_id,
            url: finalImg,
            comment: item.gallery_text,
            createdAt: item.upload_at,
            userId: item.user_id,
            userName: item.user_name || '熱心用戶'
          };
        });

      console.log('✅ 成功抓取成品照:', snapsData.value);
    }

    // --- 4. 處理留言 ---
    if (resC.data && Array.isArray(resC.data)) {
      commentList.value = resC.data.map((c) => {
        // 🏆 直接從 c (PHP 回傳的每一筆資料) 裡面拿資料
        return {
          comment_id: c.comment_id,
          userId: c.user_id,
          // 這裡要對齊 PHP 回傳的欄位名稱
          userName: c.userName || 'Recimo用戶',
          handle: c.handle ? c.handle : `user_${c.user_id}`,
          // 這裡建議對齊你組件用的變數名稱
          userAvatar: getSmartImageUrl(c.user_avatar),
          content: c.comment_text,
          time: c.comment_at,
          likes: Number(c.like_count || 0)
        };
      });
    }
    console.log('✅ [正式模式] 資料加載完成');
  } catch (err) {
    console.error('正式資料抓取失敗:', err);
  } finally {
    if (!quiet) isLoading.value = false;
  }
};

// --- 新增瀏覽紀錄 ---
const addBrowsingHistory = async () => {
  // 確認條件：使用者已登入、非預覽模式、有有效的 recipe_id
  if (!authStore.userId || isPreviewMode.value) {
    return;
  }

  const recipeId = Number(route.params.id);
  if (!recipeId) {
    return;
  }

  try {
    const formData = new URLSearchParams();
    formData.append('user_id', authStore.userId);
    formData.append('recipe_id', recipeId);

    await phpApi.post('personal/history.php', formData, {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    });

    console.log('✅ 瀏覽紀錄已新增');
  } catch (err) {
    console.error('❌ 新增瀏覽紀錄失敗:', err);
    // 不影響主要功能，靜默處理錯誤
  }
};

const isFromWorkspace = computed(() => {
  return route.path.includes('/workspace/recipe-detail');
});

const isAdaptation = computed(() => {
  // 根據你提供的 JSON，關鍵在於 parent_recipe_id 是否有值
  return !!rawRecipe.value?.parent_recipe_id;
});

const isMyRecipe = computed(() => {
  const currentUserId = Number(authStore.user?.user_id || authStore.user?.id);
  const authorId = Number(rawRecipe.value?.author_id || rawRecipe.value?.user_id);

  if (!currentUserId || !authorId) return false;
  return currentUserId === authorId;
});

const displayRecipeLikes = computed(() => {
  // 🏆 確保這裡是 recipe_likes，跟你在 toggleRecipeLike 賦值的地方一樣
  const baseLikes = Number(rawRecipe.value?.recipe_likes || 0);
  return baseLikes + localLikesOffset.value;
});

const ingredientsData = computed(() => {
  if (!rawRecipe.value || !rawIngredients.value.length) return [];

  const originalServings = Math.max(1, Number(rawRecipe.value.recipe_servings || 1));
  const currentServings = Math.max(1, Number(servings.value || 1));

  let scale = 1;

  if (isPreviewMode.value) {
    // 預覽模式：食材已經是「整份」了，顯示單份時要除回原始份數
    scale = currentServings;
  } else {
    // 正式模式：API 給的是「單份」食材數據，直接乘上當前想看的份數
    // 既然你 fetchData 強制 servings.value = 1，這裡算出來就是正確的 1 份
    scale = currentServings;
  }

  return rawIngredients.value.map((item) => ({
    INGREDIENT_NAME: item.ingredient_name,
    amount: (Number(item.amount || 0) * scale).toFixed(1),
    unit_name: item.unit_name,
    note: item.remark || item.note || ''
  }));
});
const nutritionWrapper = computed(() => {
  if (!rawRecipe.value || rawIngredients.value.length === 0) return [];

  // 1. 計算食材陣列裡的基礎總量
  let baseKcal = 0, baseP = 0, baseF = 0, baseC = 0;

  rawIngredients.value.forEach((ing) => {
    const amt = Number(ing.amount) || 0;
    const conv = Number(ing.gram_conversion) || 1;
    const weight = amt * conv;

    baseKcal += (Number(ing.kcal_per_100g) || 0) * (weight / 100);
    baseP += (Number(ing.protein_per_100g) || 0) * (weight / 100);
    baseF += (Number(ing.fat_per_100g) || 0) * (weight / 100);
    baseC += (Number(ing.carbs_per_100g) || 0) * (weight / 100);
  });

  // 🏆 關鍵修正：統一放大倍率
  // 不管預覽還是正式模式，直接乘以當前份數 (servings.value)
  // 因為你前面已經強制 servings.value = 1，所以這裡會精準顯示「一整份」的熱量
  const multiplier = Math.max(1, Number(servings.value || 1));

  // 3. 回傳最終計算結果
  return [
    {
      calories_per_100g: Math.round(baseKcal * multiplier),
      protein_per_100g: Number((baseP * multiplier).toFixed(1)),
      fat_per_100g: Number((baseF * multiplier).toFixed(1)),
      carbs_per_100g: Number((baseC * multiplier).toFixed(1)),
      amount: 1,
      unit_weight: 1
    }
  ];
});

// 同時，在 fetchData 成功後，強制將 servings 設為 1
// 找這行：servings.value = Number(rawRecipe.value.recipe_servings || 1);
// 改成：
servings.value = 1;

const recipeIntroData = computed(() => {
  if (!rawRecipe.value) return null;
  const r = rawRecipe.value;
  return {
    id: r.recipe_id,
    title: r.recipe_title,
    image: getSmartImageUrl(r.recipe_image_url),
    time: formatTime(r.recipe_total_time),
    difficulty: r.recipe_difficulty || 1,
    description: r.recipe_description || '暫無簡介',
    tags: r.tags || []
  };
});

const stepsData = computed(() => {
  return rawSteps.value.map((s, index) => ({
    id: s.step_id || `s-${index}`,
    title: s.step_title || `步驟 ${index + 1}`,
    content: s.step_content || '',
    image: getSmartImageUrl(s.step_image_url),
    time: s.step_total_time || ''
  }));
});

// --- 4. 互動函式 ---
const onReportSubmit = (reportForm) => {
  console.log('收到檢舉內容:', reportForm);
  isReportModalOpen.value = false;
  // alert('感謝您的回饋，我們已收到檢舉。');
};

const handleShare = () => {
  if (isPreviewMode.value) return;
  const shareData = {
    title: rawRecipe.value?.recipe_title,
    text: rawRecipe.value?.recipe_description,
    url: window.location.href
  };
  if (navigator.share) {
    navigator.share(shareData).catch((err) => console.log('分享失敗', err));
  } else {
    navigator.clipboard.writeText(window.location.href);
    alert('網址已複製到剪貼簿！');
  }
};

const backToEdit = () => {
  const editId = route.query.editId || recipeStore.previewData?.recipe_id;
  const action = route.query.action;
  if (action === 'adapt' && editId) {
    router.push({
      path: '/workspace/edit-recipe',
      query: { editId: editId, action: 'adapt' }
    });
  } else if (editId && editId !== '0') {
    router.push({ path: '/workspace/edit-recipe', query: { editId: editId } });
  } else {
    router.push('/workspace/edit-recipe');
  }
};

const handleServingsChange = (newVal) => {
  servings.value = Math.max(1, newVal);
};

const formatTime = (timeVal) => {
  if (!timeVal || timeVal === 0) return '30 分鐘';
  const timeStr = String(timeVal);
  if (timeStr.includes(':')) {
    const [h, m] = timeStr.split(':').map((n) => parseInt(n, 10) || 0);
    return h === 0 ? `${m} 分鐘` : `${h} 小時 ${m} 分鐘`;
  }
  return `${timeStr} 分鐘`;
};

const toggleRecipeLike = async () => {
  if (isPreviewMode.value) return;
  if (!authStore.user) {
    alert('請先登入！');
    return;
  }

  const recipeId = rawRecipe.value.recipe_id;

  // 🏆 關鍵：根據目前愛心是否亮燈，決定下一步是 plus 還是 minus
  const currentAction = isLiked.value ? 'minus' : 'plus';

  try {
    const response = await phpApi.post('social/like_toggle.php', {
      recipe_id: recipeId,
      user_id: authStore.user.user_id || authStore.user.id,
      action: currentAction // 🚀 告訴後端要加還是減
    });

    if (response.data.success) {
      // 更新燈號與數字
      isLiked.value = response.data.is_liked;
      rawRecipe.value.recipe_likes = response.data.new_count;
      localLikesOffset.value = 0;
    }
  } catch (err) {
    console.error('API 錯誤:', err.response?.data?.message || err.message);
    alert('操作失敗，請檢查資料庫連結');
  }
};
const handleGoToEdit = () => {
  const currentId = isPreviewMode.value
    ? route.query.editId
    : rawRecipe.value?.recipe_id;

  if (!currentId) return;

  if (isMyRecipe.value) {
    // 1. 如果是我自己的食譜
    if (isAdaptation.value) {
      // 這是已經存檔過的改編作品，使用你指定的 action 名稱
      router.push({
        path: '/workspace/edit-recipe',
        query: {
          editId: currentId,
          action: 'edit_adaptation'  // 👈 這裡改成你指定的字串
        }
      });
    } else {
      // 這是原創作品
      router.push({
        path: '/workspace/edit-recipe',
        query: { editId: currentId }
      });
    }
  } else {
    // 2. 如果是別人的食譜 -> 第一次改編
    router.push({
      path: '/workspace/edit-recipe',
      query: {
        editId: currentId,
        action: 'adapt'
      }
    });
  }
};

// 處理刪除成功後的跳轉
const onDeleteSuccess = (deletedId) => {
  console.log(`食譜 ${deletedId} 已刪除`);
  // 這裡導向你的工作區食譜列表頁面
  router.push('/workspace/my-recipes');
};

const toggleWorkspaceTopBar = (show) => {
  const topBar = document.querySelector('.workspace-top-bar');
  if (topBar) topBar.style.display = show ? '' : 'none';
};

// --- 修改 handlePostComment ---
const handlePostComment = async (content) => {
  if (!authStore.user) return alert('請先登入');
  if (!content || !content.trim()) return;
  const userId = authStore.user.user_id || authStore.user.id;
  try {
    const payload = {
      action: 'post',
      recipe_id: Number(route.params.id),
      user_id: userId,
      content: content
    };
    const response = await phpApi.post('social/comment.php', payload);
    if (response.data.success) {
      await fetchData(true); // 靜默刷新資料

      // 🏆 觸發黑條提示
      commentToastMsg.value = '留言已成功發佈';
      isCommentToastShow.value = true;
      setTimeout(() => { isCommentToastShow.value = false; }, 3000);
    } else {
      alert('失敗：' + response.data.message);
    }
  } catch (err) {
    alert('發佈失敗，請稍後再試');
  }
};

const handleLikeComment = async (commentId, type) => {
  if (!authStore.user) return alert('登入後即可點讚');
  try {
    await phpApi.post('social/comment.php', {
      action: 'like',
      comment_id: commentId,
      type: type
    });
    const target = commentList.value.find((c) => c.comment_id === commentId);
    if (target) {
      target.likes =
        type === 'like' ? target.likes + 1 : Math.max(0, target.likes - 1);
    }
  } catch (err) {
    console.error('點讚失敗:', err);
  }
};

// --- 修改 handleDeleteComment ---
const handleDeleteComment = async (commentId) => {
  if (!authStore.user) return alert('請先登入');
  const userId = authStore.user.user_id || authStore.user.id;
  try {
    const response = await phpApi.delete(`social/comment.php`, {
      params: { comment_id: commentId, user_id: userId }
    });
    if (response.data.success) {
      await fetchData(true); // 靜默刷新資料

      // 🏆 觸發黑條提示
      commentToastMsg.value = '留言已成功移除';
      isCommentToastShow.value = true;
      setTimeout(() => { isCommentToastShow.value = false; }, 3000);
    } else {
      alert('刪除失敗：' + (response.data.message || '未知錯誤'));
    }
  } catch (err) {
    alert('刪除失敗，請檢查網路或權限');
  }
};

const isSnapSuccessOpen = ref(false); // 🏆 補上這一行！

const handlePostSnap = async (payload) => {
  if (!authStore.user) return alert('請先登入');

  const userId = authStore.user.user_id || authStore.user.id;
  const recipeId = route.params.id;

  const formData = new FormData();
  formData.append('recipe_id', recipeId);
  formData.append('user_id', userId);
  formData.append('gallery_text', payload.note || '');

  if (payload.image instanceof File) {
    formData.append('image', payload.image);
  } else {
    alert('圖片讀取異常，請重新選取');
    return;
  }

  try {
    const response = await phpApi.post('social/gallery.php', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    });

    if (response.data.success) {
      // 🏆 修正策略：先呼叫顯示燈箱
      isSnapSuccessOpen.value = true;
      if (cookSnapRef.value) {
        cookSnapRef.value.showSuccess();

        // 💡 重點：我們先手動把新照片「推」進 list，讓畫面立刻有感
        // 而不是直接 fetchData() 導致組件重刷
        await fetchData(true);
      }
    } else {
      alert('上傳失敗：' + response.data.message);
    }
  } catch (err) {
    console.error('API 出錯:', err);
  }
};

const isDeleteToastShow = ref(false); // 控制刪除提示
const isCommentToastShow = ref(false); // 🏆 控制留言提示開關
const commentToastMsg = ref('');       // 🏆 儲存留言提示文字

const handleDeleteSnap = async (galleryId) => {
  const userId = authStore.user?.user_id || authStore.user?.id;

  try {
    const response = await phpApi.delete('social/gallery.php', {
      data: { gallery_id: galleryId, user_id: userId }
    });

    if (response.data.success) {
      // 1. 先悄悄刷新後台數據
      await fetchData(true);

      // 2. 數據刷新完後，再顯示 Toast，這樣它就不會被 isLoading 蓋掉
      isDeleteToastShow.value = true;

      // 3. 3秒後消失
      setTimeout(() => {
        isDeleteToastShow.value = false;
      }, 3000);
    }
  } catch (err) {
    console.error('刪除失敗', err);
  }
};

onMounted(async () => {
  // 統一載入收藏狀態
  const userId = authStore.user?.id || authStore.user?.user_id;
  if (userId) {
    await favoritesStore.fetchFavorites(userId);
  }

  await fetchData();
  // 資料載入完成後，新增瀏覽紀錄
  addBrowsingHistory();
  if (isPreviewMode.value) toggleWorkspaceTopBar(false);
});
onUnmounted(() => toggleWorkspaceTopBar(true));

watch(
  () => [route.params.id, route.query.mode],
  async () => {
    await fetchData();
    // 切換食譜時也要記錄瀏覽紀錄
    addBrowsingHistory();
  }
);
</script>

<template>
  <div v-if="isPreviewMode" class="preview-sticky-bar">
    <div class="container">
      <div class="row">
        <div class="col-12">
          <div class="bar-content">
            <span class="p-p1">✨ 正在預覽食譜草稿（尚未儲存）</span>
            <button class="exit-preview-btn p-p2" @click="backToEdit">
              返回編輯
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div
    class="recipe-container-root"
    v-if="!isLoading && rawRecipe"
    :class="{ 'preview-padding': isPreviewMode }"
  >
    <main class="container">
      <div class="title-content fade-up" style="--delay: 1">
        <div class="title-group">
          <h2 class="zh-h2">
            <i-material-symbols-restaurant-rounded class="main-icon" />
            {{ recipeIntroData?.title }}
          </h2>
          <span v-if="isAdaptation" class="badge-adaptation">改編版本</span>
        </div>

        <div class="meta-wrapper">
          <AuthorInfo v-if="!isPreviewMode && rawRecipe" :user-id="rawRecipe.author_id" :name="rawRecipe.author_name"
            :handle="rawRecipe.user_email || `user_${rawRecipe.author_id}`" :time="rawRecipe.created_at"
            :avatar-url="rawRecipe.author_image" />

          <div v-else-if="isPreviewMode" class="preview-badge">
            ✨ 正在預覽您的食譜草稿
          </div>

          <DeleteAdaptationBtn v-if="isMyRecipe && !isPreviewMode" :recipe-id="rawRecipe.recipe_id" :is-db-data="true"
            @click="isDeleteConfirmOpen = true" />

            <Teleport to="body">
            <BaseModal :is-open="isDeleteConfirmOpen" type="info" icon-class="fa-regular fa-trash-can"
              title="確定要刪除您的食譜嗎？" description="此操作將無法復原，您將失去這份編輯紀錄。" @close="isDeleteConfirmOpen = false">
              <template #actions>
                <div style="
    display: flex; 
    gap: 16px; 
    width: 100%; 
    justify-content: center; 
    align-items: center; 
    margin-top: 15px; 
    margin-bottom: 10px;
  ">
                  <BaseBtn title="確定刪除" variant="solid" style="width: 130px;" @click="handleActualDelete" />
                  <BaseBtn title="取消" variant="outline" style="width: 130px;" @click="isDeleteConfirmOpen = false" />
                </div>
              </template>
            </BaseModal>
          </Teleport>

          <div v-if="!isPreviewMode" class="adapt-btn-wrapper">
            <router-link
              v-if="isAdaptation"
              :to="`/workspace/recipe-detail/${rawRecipe.parent_recipe_id}`"
            >
              <BaseBtn title="查看原食譜" variant="outline" class="w-auto" />
            </router-link>
            <router-link
              v-else
              :to="`/workspace/modify-recipe/${rawRecipe.recipe_id}`"
            >
              <BaseBtn title="改編一覽" variant="outline" class="w-auto" />
            </router-link>
          </div>
        </div>
      </div>

      <div class="row">
        <div class="col-7 col-lg-12">
          <RecipeIntro
            :info="recipeIntroData"
            :is-preview="isPreviewMode"
            class="fade-up"
            style="--delay: 2"
          />

          <div class="d-lg-none">
            <section class="mb-10 fade-up" style="--delay: 3">
              <RecipeIngredients :servings="servings" :list="ingredientsData" />
            </section>

            <section class="mb-10 fade-up" style="--delay: 4">
                           <NutritionCard :servings="servings" :ingredients="nutritionWrapper"
                            :base-servings="rawRecipe?.recipe_servings" @change-servings="handleServingsChange" />
          
            </section>
          </div>

          <section class="mb-10 steps-section fade-up" style="--delay: 5">
            <RecipeSteps :steps="stepsData" />
          </section>
        </div>

        <div class="col-5 col-lg-12">
          <div class="d-none-lg">
                       <section class="mb-10 fade-up" style="--delay: 3">
                            <NutritionCard :servings="servings" :ingredients="nutritionWrapper"
                                :base-servings="rawRecipe?.recipe_servings" @change-servings="handleServingsChange" />
                        </section>
          
            <section class="mb-10 fade-up" style="--delay: 4">
              <RecipeIngredients :servings="servings" :list="ingredientsData" />
            </section>
          </div>
          <section
            v-if="!isPreviewMode"
            class="mb-10 fade-up"
            style="--delay: 6"
          >
            <section
              v-if="!isPreviewMode && !isAdaptation"
              class="mb-10 fade-up"
              style="--delay: 6"
            >
              <RecipeComments
                :list="commentList"
                @post-comment="handlePostComment"
                @like-comment="handleLikeComment"
                @delete-comment="handleDeleteComment"
              />
            </section>
          </section>
        </div>

        <div
          v-if="!isPreviewMode && !isAdaptation"
          class="col-12 cook-snap-full fade-up"
          style="--delay: 7"
        >
          <section class="mb-10 content-wrapper">
            <CookSnap ref="cookSnapRef" :list="snapsData" @post-snap="handlePostSnap" @delete-snap="handleDeleteSnap" />
          </section>
        </div>
      </div>
    </main>
  </div>

  <div v-if="isHubOpen" class="hub-overlay" @click="isHubOpen = false"></div>

  <div v-if="!isLoading && rawRecipe && !isPreviewMode" class="recipe-action-hub" :class="{ active: isHubOpen }">
    <button class="main-hub-btn custom-tooltip" :data-tooltip="isLiked ? '取消讚' : '這份食譜很讚'" @click="toggleRecipeLike">
      <i-material-symbols-thumb-up-rounded v-if="isLiked" />
      <i-material-symbols-thumb-up-outline-rounded v-else />

      <span v-if="displayRecipeLikes > 0" class="badge">
        {{ displayRecipeLikes }}
      </span>

      <div class="indicator" :class="{ rotate: isHubOpen }" @click.stop="isHubOpen = !isHubOpen">
        <i-material-symbols-add-rounded />
      </div>
    </button>

    <div class="sub-actions">
      <button v-if="isMyRecipe || !isAdaptation" class="sub-btn custom-tooltip" @click="handleGoToEdit"
        :data-tooltip="isMyRecipe ? (isAdaptation ? '編輯改編內容' : '編輯食譜') : '改編這份食譜'">
        <i-material-symbols-edit v-if="isMyRecipe" />
        <i-material-symbols-edit-note-outline-rounded v-else />
      </button>

      <button class="sub-btn custom-tooltip" @click="handleShare" data-tooltip="分享網址">
        <i-material-symbols-share-outline />
      </button>

      <button class="sub-btn report custom-tooltip" @click="isReportModalOpen = true" data-tooltip="檢舉食譜">
        <i-material-symbols-error-outline-rounded />
      </button>
    </div>
  </div>

  <div v-else-if="isLoading" class="loading-state">
    <p>正在為您準備食譜資料...</p>
  </div>
  <div v-else class="error-state">
    <p>抱歉，找不到該食譜資料 (ID: {{ route.params.id }})。</p>
    <router-link to="/">返回首頁</router-link>
  </div>

  <RecipeReportModal
    v-model="isReportModalOpen"
    :targetData="{
      recipe_id: rawRecipe?.recipe_id,
      title: recipeIntroData?.title,
      content: recipeIntroData?.description,

      // 🏆 多重保險：嘗試抓取所有可能的作者欄位名稱
      userName: rawRecipe?.author_name || rawRecipe?.user_name || '未知作者',

      // 🏆 這裡也一樣，相容大小寫與不同命名
      author_id:
        rawRecipe?.author_id || rawRecipe?.AUTHOR_ID || rawRecipe?.user_id,

      image: recipeIntroData?.image
    }"
    @submit="onReportSubmit"
  />

  <div
    v-if="!isPreviewMode && !isAdaptation"
    class="col-12 fade-up"
    style="--delay: 8"
  >
    <RelatedRecipes :currentId="route.params.id" :excludeAdapted="true" />
  </div>
  <Teleport to="body">
    <SnapFinishedSuccessModal :isOpen="isSnapSuccessOpen" @close="isSnapSuccessOpen = false" />
  </Teleport>

  <Teleport to="body">
    <Transition name="toast">
      <div v-if="isDeleteToastShow" class="delete-toast">
        <i-material-symbols-check-circle-rounded class="toast-icon" />
        <span>作品已成功移除</span>
      </div>
    </Transition>

    <Teleport to="body">
      <Transition name="toast">
        <div v-if="isCommentToastShow" class="delete-toast">
          <i-material-symbols-check-circle-rounded class="toast-icon" />
          <span>{{ commentToastMsg }}</span>
        </div>
      </Transition>
    </Teleport>

    <Teleport to="body">
      <Transition name="toast">
        <div v-if="isDeleteToastShow" class="delete-toast">
          <i-material-symbols-check-circle-rounded class="toast-icon" />
          <span>作品已成功移除</span>
        </div>
      </Transition>
    </Teleport>

  </Teleport>

</template>

<style lang="scss" scoped>
/* 原有的樣式保持不變... */
@import '@/assets/scss/abstracts/_color.scss';

.fade-up {
  opacity: 0;
  animation: fadeUpIn 0.8s cubic-bezier(0.2, 0.6, 0.35, 1) forwards;
  animation-delay: calc(var(--delay) * 0.12s);
}

@keyframes fadeUpIn {
  from {
    opacity: 0;
    transform: translateY(25px);
  }

  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.preview-sticky-bar {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  z-index: 110;
  padding: 12px 0;
  pointer-events: none;
  transition: all 0.3s ease;

  @media screen and (min-width: 810px) {
    left: 260px;
    width: calc(100% - 260px);
    background: transparent;
  }

  @media screen and (max-width: 809px) {
    left: 0;
    width: 100%;
    background: rgba(255, 255, 255, 0.7);
    backdrop-filter: blur(8px);
    padding: 8px 0;
  }

  .container {
    max-width: 1000px;
    margin: 0 auto;
    padding: 0 16px;
  }

  .bar-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background-color: $primary-color-400;
    color: $neutral-color-white;
    padding: 10px 20px;
    border-radius: 12px;
    pointer-events: auto;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);

    @media screen and (max-width: 480px) {
      padding: 8px 12px;

      span {
        font-size: 11px;
      }
    }

    span {
      font-weight: 500;
      font-size: 14px;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .exit-preview-btn {
      flex-shrink: 0;
      background-color: $neutral-color-white;
      color: $primary-color-700;
      border: none;
      padding: 6px 16px;
      border-radius: 50px;
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      margin-left: 12px;
      white-space: nowrap;
      transition: transform 0.2s ease;

      &:hover {
        background-color: $primary-color-100;
        transform: scale(1.05);
      }
    }
  }
}

.recipe-container-root {
  background-color: $neutral-color-white;
  min-height: 100vh;
  padding: 0 0 100px 0;

  &.preview-padding {
    padding-top: 90px;

    @media screen and (max-width: 768px) {
      padding-top: 0px;
    }
  }
}

.title-content {
  display: flex;
  align-items: center;
  justify-content: flex-start;
  padding: 20px 0;
  border-bottom: 1px solid $neutral-color-100;
  margin-bottom: 20px;

  .zh-h2 {
    flex-shrink: 0;
    display: flex;
    align-items: center;

    .main-icon {
      margin-right: 15px;
      font-size: 24px;
      color: $neutral-color-black;
      transform: translateY(4px);

      @media screen and (min-width: 769px) {
        transform: translateY(3px) !important;
      }
    }
  }

  .meta-wrapper {
    margin-left: auto;
    display: flex;
    align-items: center;
    gap: 16px;

    @media screen and (max-width: 768px) {
      margin-left: 0;
      width: 100%;
      justify-content: space-between;
    }
  }

  .icon-group {
    display: flex;
    align-items: center;
    gap: 20px;
    color: $primary-color-700;

    @media screen and (max-width: 768px) {
      gap: 16px;
      width: 100%;
      justify-content: flex-start;
    }

    &.is-preview {
      opacity: 0.6;

      .action-item {
        cursor: not-allowed;
        pointer-events: none;
      }
    }

    .action-item {
      display: flex;
      align-items: center;
      gap: 6px;
      cursor: pointer;
      transition: color 0.2s ease;

      &.active {
        color: $primary-color-700;

        .action-icon {
          fill: $primary-color-700;
        }
      }

      &:hover {
        color: $primary-color-400;
      }
    }

    .count-text {
      font-size: 16px;
      font-weight: 500;
    }

    .action-icon {
      font-size: 24px;
    }

    .adapt-btn-wrapper {
      @media screen and (max-width: 768px) {
        margin-left: auto;
      }

      :deep(.base-btn) {
        padding: 0 10px;
        font-size: 13px;
        border-radius: 6px;
      }
    }
  }
}

.cook-snap-full {
  display: flex;
  justify-content: center;
  width: 100%;
  margin-top: 40px;
  background-color: $neutral-color-100;
  padding: 40px 0;

  .content-wrapper {
    width: 100%;
    max-width: 800px;
  }
}

.steps-section {
  margin-top: 40px;
}

.loading-state,
.error-state {
  text-align: center;
  padding: 100px 0;
  color: $primary-color-700;
}

.d-lg-none {
  @media screen and (min-width: 1024px) {
    display: none !important;
  }
}

.d-none-lg {
  @media screen and (max-width: 1023.98px) {
    display: none !important;
  }
}

/* --- [區塊 A] 詳情頁彈窗專用 --- */
.fixed-floating-bar {
  position: fixed;
  bottom: 30px;
  right: 40px;
  display: flex;
  flex-direction: row;
  gap: 12px;
  z-index: 1000;
  background: rgba(255, 255, 255, 0.4);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  padding: 10px;
  border-radius: 50px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;

  @media (max-width: 768px) {
    bottom: 20px;
    right: 20px;
    gap: 8px;
    padding: 8px;
  }

  &.is-preview {
    opacity: 0.5;
    pointer-events: none;
  }

  .action-circle-btn {
    width: 46px;
    height: 46px;
    border-radius: 50%;
    background: white;
    border: none;
    display: flex;
    align-items: center;
    justify-content: center;
    color: $primary-color-700 !important;
    font-size: 22px;
    cursor: pointer;
    transition: all 0.2s ease;
    position: relative;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);

    svg,
    :deep(svg) {
      fill: currentColor;
    }

    &:hover {
      transform: translateY(-3px);
      background: $primary-color-100;
    }

    &.active {
      background: $primary-color-700 !important;
      color: white !important;

      svg,
      :deep(svg) {
        fill: white;
      }
    }

    &.report {
      color: #ff7875 !important;

      &:hover {
        background: #fff1f0;
      }

      svg,
      :deep(svg) {
        fill: #ff7875;
      }
    }

    .badge {
      position: absolute;
      top: -5px;
      right: -5px;
      background: #ff4d4f;
      color: white;
      font-size: 10px;
      padding: 2px 6px;
      border-radius: 10px;
      border: 2px solid white;
    }
  }
}

/* --- [區塊 B] 頁面通用食譜按鈕 Hub (修正後的順序與樣式) --- */
.recipe-action-hub {
  position: fixed;
  z-index: 1000;
  display: flex;
  align-items: center;
  transition: all 0.3s ease;

  /* 桌機版：讚 -> 編輯 -> 分享 -> 檢舉 (橫向) */
  @media (min-width: 992px) {
    bottom: 30px;
    right: 30px;
    flex-direction: row; // 確保按讚在最左，檢舉在最右
    gap: 12px;
    background: rgba(255, 255, 255, 0.6);
    backdrop-filter: blur(12px);
    padding: 10px 16px;
    border-radius: 50px;
    border: 1px solid rgba(255, 255, 255, 0.3);
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);

    .sub-actions {
      display: flex !important;
      flex-direction: row;
      gap: 12px;
      opacity: 1 !important;
      pointer-events: auto !important;
      transform: none !important;
    }

    .indicator {
      display: none !important;
    }
  }

  /* 手機版：展開後 編輯/分享/檢舉 在 讚 的上方 */
  @media (max-width: 991px) {
    bottom: 100px;
    right: 24px;
    flex-direction: column;
    gap: 12px;

    .sub-actions {
      display: flex;
      flex-direction: column;
      gap: 12px;
      opacity: 0;
      transform: translateY(20px);
      pointer-events: none;
      transition: 0.3s cubic-bezier(0.18, 0.89, 0.32, 1.28);
      order: -1; // 讓子按鈕群組在 column 模式下出現在主按鈕上方
    }

    &.active .sub-actions {
      opacity: 1;
      transform: translateY(0);
      pointer-events: auto;
    }
  }

  /* 按鈕顏色邏輯 */
  .main-hub-btn {
    background: $neutral-color-white;
    color: $primary-color-700 !important;
    width: 44px;
    height: 44px;
    border-radius: 50%;
    border: none;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 22px;
    cursor: pointer;
    position: relative;

    svg,
    :deep(svg) {
      fill: $neutral-color-white;
    }
  }

  .sub-btn {
    width: 44px;
    height: 44px;
    border-radius: 50%;
    border: none;
    background: $neutral-color-white;
    color: $primary-color-700 !important;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 22px;
    cursor: pointer;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);

    svg,
    :deep(svg) {
      fill: currentColor;
    }

    &:hover {
      background: $primary-color-100;
    }

    &.report {
      color: $accent-color-700 !important;

      svg,
      :deep(svg) {
        fill: $accent-color-700;
      }

      &:hover {
        background: $neutral-color-100;
      }
    }
  }

  .badge {
    position: absolute;
    top: -5px;
    right: -5px;
    background: $primary-color-400;
    color: white;
    font-size: 10px;
    padding: 2px 6px;
    border-radius: 10px;
    border: 2px solid white;
  }

  .indicator {
    position: absolute;
    bottom: -4px;
    right: -4px;
    background: $primary-color-700;
    color: $neutral-color-white;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;

    &.rotate {
      transform: rotate(45deg);
    }
  }
}

.hub-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.2);
  z-index: 999;

  @media (min-width: 992px) {
    display: none;
  }
}

.title-content .icon-group .adapt-btn-wrapper {
  margin-left: 0;
}

.title-group {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}

.badge-adaptation {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  height: 26px;
  background: $primary-color-100;
  color: $primary-color-700;
  padding: 0 14px;
  border-radius: 99px;
  font-weight: 600;
  font-size: 14px;
  white-space: nowrap;
  line-height: 1;
}

/* --- 自定義漂亮的提示框 --- */
.custom-tooltip {
  position: relative; // 必須為 relative 以便定位提示框

  &::before {
    content: attr(data-tooltip); // 自動抓取 HTML 上的文字
    position: absolute;
    bottom: 120%; // 電腦版預設：顯示在按鈕上方
    left: 50%;
    transform: translateX(-50%) translateY(10px);

    // 樣式設計
    background-color: $primary-color-700;
    color: $neutral-color-white;
    padding: 6px 12px;
    border-radius: 8px;
    font-size: 12px;
    white-space: nowrap;

    // 動態效果
    opacity: 0;
    visibility: hidden;
    transition: all 0.3s cubic-bezier(0.18, 0.89, 0.32, 1.28);
    pointer-events: none;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    z-index: 100;

    // 🏆 手機版調整：改為向左彈出
    @media screen and (max-width: 809px) {
      bottom: auto;
      left: auto; // 取消電腦版的 left: 50%
      right: 125%; // 定位在按鈕左側
      top: 50%; // 垂直置中
      transform: translateY(-50%) translateX(10px); // 初始位移從右往左移回
    }
  }

  // 小箭頭
  &::after {
    content: '';
    position: absolute;
    bottom: 105%;
    left: 50%;
    transform: translateX(-50%);
    border: 6px solid transparent;
    border-top-color: $primary-color-700;
    opacity: 0;
    visibility: hidden;
    transition: all 0.3s ease;

    // 🏆 手機版調整：箭頭轉向右邊（指回按鈕）
    @media screen and (max-width: 809px) {
      bottom: auto;
      left: auto;
      right: 105%; // 定位在提示框與按鈕之間
      top: 50%;
      transform: translateY(-50%);
      border-top-color: transparent; // 取消向下的顏色
      border-left-color: $primary-color-700; // 改為向左的尖角顏色（視覺上是提示框右側指出的箭頭）
    }
  }

    /* 父層的 style */
    .global-delete-toast {
      position: fixed;
      top: 40px;
      left: 50%;
      transform: translateX(-50%);
      z-index: 20000;
      /* 確保絕對最高 */
      background-color: #323232;
      color: white;
      padding: 14px 28px;
      border-radius: 50px;
      display: flex;
      align-items: center;
      gap: 12px;
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.25);
      pointer-events: none;
    }
  
    .toast-enter-active,
    .toast-leave-active {
      transition: all 0.4s ease;
    }
  
    .toast-enter-from,
    .toast-leave-to {
      opacity: 0;
      transform: translate(-50%, -40px);
    }


  // 滑鼠移入時顯示
  &:hover {
    &::before {
      opacity: 1;
      visibility: visible;

      @media screen and (min-width: 810px) {
        transform: translateX(-50%) translateY(0);
      }

      @media screen and (max-width: 809px) {
        transform: translateY(-50%) translateX(0);
      }
    }

    &::after {
      opacity: 1;
      visibility: visible;
    }
  }
}

// 針對檢舉按鈕
.sub-btn.report.custom-tooltip {
  &::before {
    background-color: $accent-color-700;
  }

  &::after {
    @media screen and (min-width: 810px) {
      border-top-color: $accent-color-700;
    }

    @media screen and (max-width: 809px) {
      border-left-color: $accent-color-700;
    }
  }
}


@media screen and (max-width: 768px) {
  .title-content {
    flex-direction: column !important;
    align-items: flex-start !important;
    gap: 16px;
    padding: 15px 0;

    .title-group {
      width: 100%;
      flex-wrap: wrap;

      .zh-h2 {
        font-size: 1.5rem;
        line-height: 1.4;
      }
    }

    .meta-wrapper {
      margin-left: 0 !important;
      width: 100% !important;
      display: flex !important;
      align-items: center !important;
      justify-content: space-between !important;

      :deep(.author-info-container) {
        flex-shrink: 0;
      }

      .adapt-btn-wrapper,
      .delete-btn-wrapper,
      :deep(.delete-adaptation-btn) {
        margin-left: auto !important;
        display: flex !important;
        justify-content: flex-end;
        gap: 8px;
      }

      :deep(button) {
        white-space: nowrap;
      }
    }
  }
}

/* 貼在 RecipeDetail.vue 的 style 裡面 */
/* 覆蓋掉剛才的測試樣式 */
.delete-toast {
  position: fixed !important;
  top: 60px !important;
  /* 稍微往下移一點 */
  left: 50% !important;
  transform: translateX(-50%) !important;
  z-index: 999999 !important;

  background-color: #2c3e50 !important;
  /* 深藍灰，比較高級 */
  color: #ffffff !important;
  padding: 12px 28px !important;
  border-radius: 50px !important;

  display: flex !important;
  align-items: center !important;
  gap: 10px !important;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3) !important;
}

.toast-icon {
  color: #2ecc71 !important;
  /* 亮綠色勾勾 */
  font-size: 20px !important;
}

.toast-enter-active,
.toast-leave-active {
  transition: all 0.4s cubic-bezier(0.18, 0.89, 0.32, 1.28);
}

.toast-enter-from,
.toast-leave-to {
  opacity: 0;
  transform: translate(-50%, -40px);
}
</style>
