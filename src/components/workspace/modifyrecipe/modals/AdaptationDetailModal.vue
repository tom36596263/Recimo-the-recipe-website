<script setup>
import { ref, computed, watch } from 'vue';
import RecipeIntro from '@/components/workspace/recipedetail/RecipeIntro.vue';
import RecipeIngredients from '@/components/workspace/recipedetail/RecipeIngredients.vue';
import RecipeSteps from '@/components/workspace/recipedetail/RecipeSteps.vue';

const props = defineProps({
    modelValue: Boolean,
    recipe: Object
});

const emit = defineEmits(['update:modelValue', 'delete-recipe']);

const currentServings = ref(1);
const closeModal = () => emit('update:modelValue', false);

const getAvatarStyle = (name) => {
    if (!name) return { backgroundColor: '#74D09C' };
    const brandingColors = ['#74D09C', '#FFCB82', '#8FEF60', '#F7F766', '#FF8686', '#90C6FF'];
    const charCodeSum = name.split('').reduce((sum, char) => sum + char.charCodeAt(0), 0);
    return { backgroundColor: brandingColors[charCodeSum % 6], color: '#555555' };
};

watch(() => props.recipe, (newVal) => {
    if (newVal) {
        currentServings.value = Number(newVal.servings) || 1;
    }
}, { immediate: true });

const introData = computed(() => {
    if (!props.recipe) return null;
    const r = props.recipe;

    // 抓取目前登入者
    const loginUser = JSON.parse(localStorage.getItem('user') || '{}');
    const today = new Date().toISOString().split('T')[0];

    // 關鍵判斷：食譜本身有沒有 ID (判斷是資料庫紀錄還是前端草稿)
    const isExistingRecord = !!(r.id || r.recipe_id);

    let displayName = "";
    let displayHandle = "";
    let displayDate = "";
    let isOwner = false;

    if (isExistingRecord) {
        // --- 模式：舊紀錄 (優先顯示原發布者資料) ---
        // 兼容多種可能的使用者名稱 Key
        displayName = r.user_name || r.author_name || r.userName || "未知作者";

        // 兼容多種 Email Key 並處理 Handle
        const rawEmail = r.user_email || r.email || r.author_email || "guest@mail.com";
        displayHandle = rawEmail.split('@')[0];

        // 兼容多種日期格式
        const rawDate = r.created_at || r.user_startdate || r.publish_date || today;
        displayDate = rawDate.split(' ')[0];

        // 【權限判斷】：嚴格比對 ID
        const recordAuthorId = String(r.user_id || r.author_id || "");
        const currentLoginId = String(loginUser.user_id || "");
        isOwner = (recordAuthorId === currentLoginId) && currentLoginId !== "";
    } else {
        // --- 模式：新草稿 (強制顯示目前登入者) ---
        displayName = loginUser.user_name || "新創作者";
        displayHandle = (loginUser.user_email || "guest@mail.com").split('@')[0];
        displayDate = today;
        isOwner = true;
    }

    // 時間與說明的格式化
    const rawTime = r.totalTime || r.time || 30;
    const formattedTime = String(rawTime).includes('分') ? rawTime : `${rawTime} 分鐘`;

    // 修正你之前代碼中的 descreption 拼字錯誤，並增加兼容性
    const finalDescription = r.recipe_description || r.recipe_descreption || r.description || r.desc || '暫無詳細說明';

    return {
        id: r.id || r.recipe_id,
        title: r.adaptation_title || r.title || '新改編食譜',
        image: r.adaptation_image_url || r.coverImg || 'https://placehold.co/800x600?text=No+Image',
        description: finalDescription,
        time: formattedTime,
        difficulty: r.difficulty || 1,
        userName: displayName,
        handle: displayHandle,
        publishTime: displayDate,
        isOwner: isOwner
    };
});

const handleDelete = () => {
    if (!introData.value.id) {
        alert("尚未儲存的內容，關閉視窗即可。");
        return;
    }
    if (confirm("確定要刪除這份食譜紀錄嗎？")) {
        emit('delete-recipe', introData.value.id);
        closeModal();
    }
};

const ingredientsData = computed(() => {
    const list = props.recipe?.ingredients || [];
    return list.map(item => ({
        INGREDIENT_NAME: item.name || item.ingredient_name || '未知食材',
        amount: item.amount,
        unit_name: item.unit || item.unit_name || 'g',
        note: item.note || ''
    }));
});

const stepsData = computed(() => {
    const steps = props.recipe?.steps || [];
    return steps.map((s, idx) => ({
        id: s.id || idx,
        title: s.step_title || s.title || `步驟 ${idx + 1}`,
        content: s.content || s.step_content || '',
        image: s.image || s.step_image_url || '',
        time: s.time || ''
    }));
});
</script>

<template>
    <Transition name="modal-fade">
        <div v-if="modelValue" class="adaptation-modal-overlay" @click.self="closeModal">
            <div class="modal-window">
                <button class="close-x" @click="closeModal">✕</button>

                <div class="modal-scroll-body">
                    <div class="container-fluid">
                        <div class="modal-title-bar mb-32">
                            <div class="title-group">
                                <h2 class="zh-h2">
                                    <i-material-symbols-restaurant-rounded class="mr-8 icon-v-align" />
                                    {{ introData?.title }}
                                </h2>
                                <span class="badge">改編版本</span>

                                <button v-if="introData?.isOwner" @click="handleDelete" class="delete-btn">
                                    <i-material-symbols-delete-outline-rounded />
                                    刪除此版本
                                </button>
                            </div>

                            <div class="user-info-box">
                                <div class="user-avatar-circle" :style="getAvatarStyle(introData?.userName || '')">
                                    {{ introData?.userName?.charAt(0).toUpperCase() }}
                                </div>
                                <div class="user-text-meta">
                                    <div class="user-name">{{ introData?.userName }}</div>
                                    <div class="user-sub">@{{ introData?.handle }} • {{ introData?.publishTime }}</div>
                                </div>
                            </div>
                        </div>

                        <div class="row main-content-row">
                            <div class="col-7 col-md-12 content-left">
                                <RecipeIntro :info="introData" :hide-actions="true" class="intro-section" />
                                <RecipeSteps :steps="stepsData" class="steps-section" />
                            </div>

                            <div class="col-5 col-md-12 sidebar-right">
                                <div class="sticky-sidebar">
                                    <div class="ingredients-wrapper">
                                        <h3 class="zh-h3 mb-16 sidebar-title">所需食材</h3>
                                        <RecipeIngredients :list="ingredientsData" :readonly="true" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </Transition>
</template>

<style lang="scss" scoped>
@import '@/assets/scss/abstracts/_color.scss';

// 刪除按鈕樣式
.delete-btn {
    display: flex;
    align-items: center;
    gap: 4px;
    background: #FFF0F0;
    color: #FF4D4D;
    border: 1px solid #FFD6D6;
    padding: 6px 12px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;

    &:hover {
        background: #FF4D4D;
        color: white;
    }
}

.adaptation-modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.6);
    backdrop-filter: blur(4px);
    z-index: 2000;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 20px;
}

.modal-window {
    background: white;
    width: 100%;
    max-width: 1100px;
    height: 90vh;
    border-radius: 24px;
    position: relative;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);

    .close-x {
        position: absolute;
        top: 20px;
        right: 20px;
        background: none;
        border: none;
        font-size: 26px;
        color: $neutral-color-700;
        cursor: pointer;
        line-height: 1;
        padding: 5px;
        transition: color 0.2s;
        z-index: 10;

        &:hover {
            color: $neutral-color-black;
        }
    }
}

.modal-scroll-body {
    flex: 1;
    overflow-y: auto;
    padding: 48px;

    &::-webkit-scrollbar {
        width: 6px;
    }

    &::-webkit-scrollbar-track {
        background: transparent;
    }

    &::-webkit-scrollbar-thumb {
        background: $neutral-color-100;
        border-radius: 10px;

        &:hover {
            background: $neutral-color-400;
        }
    }

    scrollbar-width: thin;
    scrollbar-color: $neutral-color-100 transparent;

    @media (max-width: 768px) {
        padding: 24px;
    }
}

.main-content-row {
    @media (max-width: 768px) {
        display: flex;
        flex-direction: column;

        .content-left {
            display: contents;
        }

        .intro-section {
            order: 1;
            margin-bottom: 32px;
        }

        .sidebar-right {
            order: 2;
            margin-bottom: 32px;
        }

        .steps-section {
            order: 3;
        }
    }
}

.modal-title-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 2px solid $neutral-color-100;
    padding-bottom: 20px;
    padding-right: 40px;

    .title-group {
        display: flex;
        align-items: center;
        gap: 16px;
    }

    .zh-h2 {
        margin: 0;
        display: flex;
        align-items: center;
    }

    .badge {
        background: $primary-color-100;
        color: $primary-color-700;
        padding: 4px 14px;
        border-radius: 99px;
        font-weight: 600;
        font-size: 14px;
    }

    .user-info-box {
        display: flex;
        align-items: center;
        gap: 12px;

        .user-text-meta {
            text-align: right;

            .user-name {
                font-weight: 600;
                margin-bottom: 7px;
                color: $neutral-color-800;
                font-size: 15px;
            }

            .user-sub {
                font-size: 12px;
                color: $neutral-color-400;
            }
        }

        .user-avatar-circle {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 15px;
            border: 1px solid rgba(0, 0, 0, 0.05);
            flex-shrink: 0;
            order: 2;
        }

        .user-text-meta {
            order: 1;
        }
    }

    @media (max-width: 768px) {
        flex-direction: column;
        align-items: flex-start;
        gap: 16px;
        padding-right: 30px;

        .user-info-box {
            width: 100%;
            justify-content: flex-start;

            .user-avatar-circle {
                order: 1;
            }

            .user-text-meta {
                order: 2;
                text-align: left;
            }
        }
    }
}

.sticky-sidebar {
    position: sticky;
    top: 0;

    .ingredients-wrapper {
        background: $neutral-color-100;
        padding: 24px;
        border-radius: 20px;
        border: 1px solid rgba($primary-color-400, 0.2);
    }

    .sidebar-title {
        padding-left: 10px;
    }
}

.content-left {
    padding-right: 32px;
}

.mr-8 {
    margin-right: 8px;
}

.mb-16 {
    margin-bottom: 16px;
}

.mb-32 {
    margin-bottom: 32px;
}

.modal-fade-enter-active {
    transition: all 0.4s ease-out;
}

.modal-fade-leave-active {
    transition: all 0.3s ease-in;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
    opacity: 0;
    transform: translateY(20px);
}
</style>