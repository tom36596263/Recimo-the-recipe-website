<script setup>
import { ref, computed, onMounted } from 'vue';
import { publicApi } from '@/utils/publicApi';
import RecipeCardSm from '@/components/common/RecipeCardSm.vue';
import BaseBtn from '@/components/common/BaseBtn.vue';
import EditProfileModal from '@/components/common/EditProfileModal.vue';
import { parsePublicFile } from '@/utils/parseFile';

// ==================== 響應式數據 ====================
const activeTab = ref('recipes'); // 當前活動頁籤：recipes / following / likes
const showEditModal = ref(false); // 編輯彈窗顯示狀態

// 個人資訊
const userProfile = ref({
    username: '羅成員',
    role: '大家好',
    avatar: parsePublicFile('img/profile/1.png'),
    coverImage: parsePublicFile('img/profile/2.png'),
    stats: {
        recipes: 10,
        following: 24,
        followers: 86
    }
});

// 食譜資料
const recipes = ref([]);

// 追蹤和粉絲資料
const followingList = ref([
    { id: 1, name: '林雅婷', avatar: parsePublicFile('img/profile/1.png'), recipes: 10, followers: 86, isFollowing: true },
    { id: 2, name: '陳志明', avatar: parsePublicFile('img/profile/1.png'), recipes: 10, followers: 86, isFollowing: true },
    { id: 3, name: '王美玲', avatar: parsePublicFile('img/profile/1.png'), recipes: 10, followers: 86, isFollowing: true },
    { id: 4, name: '張家豪', avatar: parsePublicFile('img/profile/1.png'), recipes: 10, followers: 86, isFollowing: true }
]);

const followersList = ref([
    { id: 1, name: '李思穎', avatar: parsePublicFile('img/profile/1.png'), recipes: 10, followers: 86, isFollowing: false },
    { id: 2, name: '黃建華', avatar: parsePublicFile('img/profile/1.png'), recipes: 10, followers: 86, isFollowing: true },
    { id: 3, name: '劉雅君', avatar: parsePublicFile('img/profile/1.png'), recipes: 10, followers: 86, isFollowing: true },
    { id: 4, name: '吳宗翰', avatar: parsePublicFile('img/profile/1.png'), recipes: 10, followers: 86, isFollowing: true }
]);

// ==================== 工具函數 ====================
/**
 * 獲取食譜的標籤列表
 * @param {Number} recipeId - 食譜 ID
 * @param {Array} recipeTagData - 食譜標籤關聯數據
 * @param {Object} tagMap - 標籤映射表
 * @returns {Array} 標籤名稱數組
 */
const getRecipeTags = (recipeId, recipeTagData, tagMap) => {
    const recipeTags = recipeTagData
        .filter(rt => rt.recipe_id === recipeId)
        .map(rt => tagMap[rt.tag_id])
        .filter(Boolean);
    return recipeTags.length > 0 ? recipeTags : ['未分類'];
};

// ==================== 方法 ====================
const switchTab = (tab) => {
    activeTab.value = tab;
};

const editProfile = () => {
    console.log('點擊編輯按鈕');
    console.log('當前 showEditModal:', showEditModal.value);
    showEditModal.value = true;
    console.log('設定後 showEditModal:', showEditModal.value);
};

const handleSaveProfile = (updatedData) => {
    // 更新個人資料
    if (updatedData.username) userProfile.value.username = updatedData.username;
    if (updatedData.role) userProfile.value.role = updatedData.role;
    if (updatedData.coverImage) userProfile.value.coverImage = updatedData.coverImage;
    if (updatedData.avatar) userProfile.value.avatar = updatedData.avatar;
    
    console.log('儲存個人檔案:', updatedData);
    
    // 關閉彈窗
    showEditModal.value = false;
};

// 切換追蹤狀態
const toggleFollow = (userId) => {
    const user = followersList.value.find(u => u.id === userId);
    if (user) {
        user.isFollowing = !user.isFollowing;
    }
};

// 只顯示前 8 筆食譜
const displayedRecipes = computed(() => {
    return recipes.value.slice(0, 8);
});

// ==================== 生命週期 ====================
/**
 * 組件掛載時載入數據
 */
onMounted(async () => {
    try {
        // 並行載入所有需要的 JSON 檔案
        const [resRecipes, resRecipeTags, resTags] = await Promise.all([
            publicApi.get('data/recipe/recipes.json'),
            publicApi.get('data/recipe/recipe_tag.json'),
            publicApi.get('data/recipe/tags.json')
        ]);

        const recipesData = resRecipes.data;
        const recipeTagData = resRecipeTags.data;
        const tagsData = resTags.data;

        // 建立標籤 ID 對應名稱的映射表
        const tagMap = {};
        tagsData.forEach(tag => {
            tagMap[tag.tag_id] = tag.tag_name;
        });

        // 獲取 base 路徑用於圖片 URL 補全
        const base = import.meta.env.BASE_URL;

        // 載入食譜資料（前 12 筆，但只顯示前 8 筆）
        recipes.value = recipesData.slice(0, 12).map(recipe => ({
            id: recipe.recipe_id,
            recipe_name: recipe.recipe_title,
            image_url: recipe.recipe_image_url.startsWith('http')
                ? recipe.recipe_image_url
                : `${base}${recipe.recipe_image_url}`.replace(/\/+/g, '/'),
            tags: getRecipeTags(recipe.recipe_id, recipeTagData, tagMap),
            author: {
                name: 'Recimo',
                likes: recipe.recipe_like_count || 0
            }
        }));
    } catch (error) {
        console.error('載入資料失敗:', error);
    }
});
</script>

<template>
    <div class="profile-view">
        <div class="container">
            <!-- 個人資訊卡片區域 -->
            <div class="profile-header">
                <!-- 封面圖片 -->
                <div class="cover-image">
                    <img :src="userProfile.coverImage" alt="封面圖片">
                    <!-- 編輯個人檔案按鈕 -->
                    <div class="edit-profile-btn">
                        <BaseBtn @click="editProfile">
                            編輯個人檔案
                        </BaseBtn>
                    </div>
                </div>

                <!-- 個人資訊 -->
                <div class="profile-info">
                    <!-- 頭像 -->
                    <div class="avatar">
                        <img :src="userProfile.avatar" alt="頭像">
                    </div>

                    <!-- 名稱與角色 -->
                    <div class="user-details">
                        <h3 class="username zh-h3">{{ userProfile.username }}</h3>
                        <p class="role zh-body">{{ userProfile.role }}</p>
                    </div>
                </div>

                <!-- 統計數據 -->
                <div class="profile-stats">
                    <div class="stat-item">
                        <span class="stat-label zh-body">食譜：</span>
                        <span class="stat-value zh-body">{{ userProfile.stats.recipes }}</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-label zh-body">追蹤：</span>
                        <span class="stat-value zh-body">{{ userProfile.stats.following }}</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-label zh-body">粉絲：</span>
                        <span class="stat-value zh-body">{{ userProfile.stats.followers }}</span>
                    </div>
                </div>
            </div>

            <!-- 頁籤導航 -->
            <div class="tab-navigation">
                <button 
                    class="tab-btn zh-h5" 
                    :class="{ 'active': activeTab === 'recipes' }"
                    @click="switchTab('recipes')"
                >
                    個人食譜
                </button>
                <button 
                    class="tab-btn zh-h5" 
                    :class="{ 'active': activeTab === 'following' }"
                    @click="switchTab('following')"
                >
                    追蹤
                </button>
                <button 
                    class="tab-btn zh-h5" 
                    :class="{ 'active': activeTab === 'likes' }"
                    @click="switchTab('likes')"
                >
                    粉絲
                </button>
            </div>

            <!-- 食譜列表 -->
            <div v-if="activeTab === 'recipes'" class="row recipe-cards-container">
                <div v-for="recipe in displayedRecipes" 
                    :key="recipe.id" 
                    class="col-3 col-lg-6 col-md-12 recipe-card-col">
                    <RecipeCardSm :recipe="recipe" />
                </div>
            </div>

            <!-- 追蹤列表 -->
            <div v-if="activeTab === 'following'" class="user-list">
                <div v-for="user in followingList" :key="user.id" class="user-item">
                    <img :src="user.avatar" alt="頭像" class="user-avatar">
                    <div class="user-info">
                        <h4 class="user-name zh-h5">{{ user.name }}</h4>
                        <div class="user-stats">
                            <span class="zh-body">{{ user.recipes }} 食譜</span>
                            <span class="zh-body">{{ user.followers }} 粉絲</span>
                        </div>
                    </div>
                    <BaseBtn 
                        @click="toggleFollow(user.id)"
                        :variant="user.isFollowing ? 'outline' : 'solid'" 
                        width="100px"
                        >
                        {{ user.isFollowing ? '追蹤中' : '追蹤' }}
                    </BaseBtn>
                </div>
            </div>

            <!-- 粉絲列表 -->
            <div v-if="activeTab === 'likes'" class="user-list">
                <div v-for="user in followersList" :key="user.id" class="user-item">
                    <img :src="user.avatar" alt="頭像" class="user-avatar">
                    <div class="user-info">
                        <h4 class="user-name zh-h5">{{ user.name }}</h4>
                        <div class="user-stats">
                            <span class="zh-body">{{ user.recipes }} 食譜</span>
                            <span class="zh-body">{{ user.followers }} 粉絲</span>
                        </div>
                    </div>
                    <BaseBtn 
                        @click="toggleFollow(user.id)"
                        :variant="user.isFollowing ? 'outline' : 'solid'" 
                        width="100px"
                        >
                        {{ user.isFollowing ? '追蹤中' : '追蹤' }}
                    </BaseBtn>
                </div>
            </div>
        </div>

        <!-- 編輯個人檔案彈窗 -->
        <Teleport to="body">
            <EditProfileModal 
                :show="showEditModal" 
                :user-profile="userProfile"
                @close="showEditModal = false"
                @save="handleSaveProfile"
            />
        </Teleport>
    </div>
</template>

<style lang="scss" scoped>
.profile-view {
    padding: 32px 0 60px;
    min-height: calc(100vh - 80px);
}

/* ==================== 個人資訊卡片 ==================== */
.profile-header {
    background: $neutral-color-white;
    border-radius: 12px;
    overflow: hidden;
    margin-bottom: 20px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    position: relative;
}

/* 封面圖片 */
.cover-image {
    width: 100%;
    height: 220px;
    position: relative;
    overflow: hidden;

    img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
}

/* 編輯個人檔案按鈕（在封面圖右下角） */
.edit-profile-btn {
    position: absolute;
    bottom: 16px;
    right: 16px;
    z-index: 5;
}

/* 個人資訊區 */
.profile-info {
    display: flex;
    align-items: center;
    padding: 20px 24px;
    background: $neutral-color-white;
    position: relative;
    z-index: 10;
}

.avatar {
    width: 100px;
    height: 100px;
    border-radius: 50%;
    border: 4px solid $neutral-color-white;
    overflow: hidden;
    background: $neutral-color-white;
    flex-shrink: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-top: -60px;

    img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        border-radius: 50%;
    }
}

.user-details {
    margin-left: 20px;
    flex: 1;
}

.username {
    margin: 0 0 4px 0;
    color: $neutral-color-800;
}

.role {
    margin: 0;
    color: $neutral-color-700;
    font-size: 14px;
}

/* 統計數據 */
.profile-stats {
    display: flex;
    gap: 32px;
    padding: 20px 24px;
    border-top: 1px solid $neutral-color-100;
    margin-top: 16px;
}

.stat-item {
    display: flex;
    gap: 4px;
    align-items: baseline;
}

.stat-label {
    color: $neutral-color-700;
    font-size: 14px;
}

.stat-value {
    color: $neutral-color-800;
    font-weight: 600;
    font-size: 14px;
}

/* ==================== 頁籤導航 ==================== */
.tab-navigation {
    display: flex;
    background: $neutral-color-white;
    border-radius: 12px;
    overflow: hidden;
    margin-bottom: 20px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.tab-btn {
    flex: 1;
    padding: 16px;
    background: $neutral-color-white;
    border: none;
    color: $neutral-color-700;
    cursor: pointer;
    transition: all 0.3s ease;
    font-weight: 500;
    position: relative;

    &:hover {
        background: $primary-color-100;
        color: $primary-color-700;
    }

    &.active {
        background: $primary-color-700;
        color: $neutral-color-white;
        font-weight: 600;
    }

    &:not(:last-child)::after {
        content: '';
        position: absolute;
        right: 0;
        top: 50%;
        transform: translateY(-50%);
        width: 1px;
        height: 20px;
        background: $neutral-color-100;
    }
}

/* ==================== 食譜卡片容器 ==================== */
.recipe-cards-container {
    margin-top: 20px;
}

.row:not(.section-header) {
    row-gap: 24px;
}

/* ==================== 用戶列表 ==================== */
.user-list {
    margin-top: 32px;
}

.user-item {
    display: flex;
    align-items: center;
    padding: 16px 20px;
    border-bottom: 1px solid $neutral-color-100;
    gap: 16px;

    &:hover {
        background-color: $neutral-color-100;
    }
}

.user-avatar {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    object-fit: cover;
    flex-shrink: 0;
}

.user-info {
    flex: 1;
}

.user-name {
    margin-bottom: 4px;
    color: $neutral-color-800;
}

.user-stats {
    display: flex;
    gap: 16px;
    color: $neutral-color-700;
    font-size: 14px;
}

// .follow-btn {
//     min-width: 100px;
    
//     &.following {
//         background-color: $neutral-color-100;
//         color: $neutral-color-800;
        
//         &:hover {
//             background-color: $neutral-color-400;
//         }
//     }
// }

/* ==================== 響應式設計 ==================== */
@media screen and (max-width: 810px) {
    .profile-view {
        padding: 24px 0 100px;
    }

    .profile-info {
        align-items: flex-start;
    }

    .user-details {
        margin-left: 0;
        margin-top: 16px;
    }

    .profile-stats {
        flex-direction: column;
        gap: 12px;
    }

    .cover-image {
        height: 160px;
    }

    .avatar {
        width: 80px;
        height: 80px;

        img {
            width: 100%;
            height: 100%;
        }
    }
}
</style>
