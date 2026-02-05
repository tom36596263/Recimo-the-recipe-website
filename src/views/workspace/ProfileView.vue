<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { phpApi } from '@/utils/publicApi';
import { useAuthStore } from '@/stores/authStore';
import { useRoute, useRouter } from 'vue-router';
import RecipeCardSm from '@/components/common/RecipeCardSm.vue';
import BaseBtn from '@/components/common/BaseBtn.vue';
import EditProfileModal from '@/components/common/EditProfileModal.vue';
import { parsePublicFile } from '@/utils/parseFile';

// ==================== Props ====================
const props = defineProps({
    userId: {
        type: [String, Number],
        default: null
    }
});

// ==================== Store & Router ====================
const authStore = useAuthStore();
const route = useRoute();
const router = useRouter();

// ==================== 計算屬性 ====================
// 目標使用者 ID（優先從 route.params 讀取，其次是 props，最後是登入者 ID）
const targetUserId = computed(() => {
    const routeUserId = route.params.userId;
    const propsUserId = props.userId;

    // 優先使用 route.params，如果沒有就用 props，都沒有就用登入者 ID
    if (routeUserId) {
        return Number(routeUserId);
    } else if (propsUserId) {
        return Number(propsUserId);
    } else {
        return authStore.userId;
    }
});

// 是否為查看自己的主頁
const isOwnProfile = computed(() => {
    return targetUserId.value === authStore.userId;
});

// ==================== 響應式數據 ====================
const activeTab = ref('recipes'); // 當前活動頁籤：recipes / following / likes
const showEditModal = ref(false); // 編輯彈窗顯示狀態
const isLoading = ref(false);
const isLoadingFollows = ref(false);
const error = ref(null);
const notFound = ref(false);

// 個人資訊
const userProfile = ref({
    username: authStore.user?.user_name || '訪客',
    role: authStore.user?.user_bio || '無內容',
    avatar: authStore.user?.user_url ? parsePublicFile(authStore.user.user_url) : parsePublicFile('img/profile/1.png'),
    coverImage: parsePublicFile('img/profile/2.png'),
    isFollowing: false,  // 新增：追蹤狀態
    stats: {
        recipes: 0,
        following: 0,
        followers: 0
    }
});

// 食譜資料
const recipes = ref([]);

// 追蹤和粉絲資料
const followingList = ref([]);
const followersList = ref([]);

// 搜尋使用者資料
const searchQuery = ref('');
const searchResults = ref([]);
const isSearching = ref(false);
const hasSearched = ref(false);

// ==================== 工具函數 ====================
/**
 * 處理圖片 URL（支援絕對路徑和相對路徑）
 */
const getImageUrl = (url) => {
    if (!url) return parsePublicFile('img/default-recipe.jpg');
    if (url.startsWith('http')) return url;
    return parsePublicFile(url);
};

// ==================== 方法 ====================
const switchTab = async (tab) => {
    activeTab.value = tab;

    // 切換到追蹤或粉絲頁籤時載入資料
    if (tab === 'following' && followingList.value.length === 0) {
        await loadFollowingList();
    } else if (tab === 'likes' && followersList.value.length === 0) {
        await loadFollowersList();
    }
};

const editProfile = () => {
    showEditModal.value = true;
};

const handleSaveProfile = async (updatedData) => {
    if (!authStore.userId) return;

    try {
        const formData = new FormData();
        formData.append('user_id', authStore.userId);

        if (updatedData.username) formData.append('user_name', updatedData.username);
        if (updatedData.role) formData.append('user_bio', updatedData.role);

        // 處理頭像上傳
        if (updatedData.avatarFile) {
            formData.append('avatar', updatedData.avatarFile);
        }

        // 處理封面圖上傳
        if (updatedData.coverImageFile) {
            formData.append('cover_image', updatedData.coverImageFile);
        }

        const { data } = await phpApi.post('personal/profile_update.php', formData, {
            headers: { 'Content-Type': 'multipart/form-data' }
        });

        if (data.success) {
            // 重新載入個人資料
            await loadProfile();
            showEditModal.value = false;
        }
    } catch (err) {
        console.error('更新個人資料失敗:', err);
        alert('更新失敗，請稍後再試');
    }
};

/**
 * 切換追蹤狀態
 */
const toggleFollow = async (userId) => {
    if (!authStore.userId) {
        authStore.openLoginAlert();
        return;
    }

    try {
        // 使用 URLSearchParams 來發送 form-data 格式（因為 PHP 使用 $_POST）
        const params = new URLSearchParams();
        params.append('follower_id', authStore.userId);
        params.append('followed_id', userId);
        params.append('action', 'toggle');

        const { data } = await phpApi.post('social/follows.php', params, {
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        });

        if (data.success) {
            const newFollowingStatus = data.is_following;

            // 更新追蹤列表 - 需要處理添加/移除
            if (newFollowingStatus) {
                // 追蹤：如果不在列表中就添加，如果在就更新
                const existingIndex = followingList.value.findIndex(u => u.id === userId);
                if (existingIndex === -1) {
                    // 不在列表中，需要從其他列表找到該使用者資料並添加
                    const userToAdd = followersList.value.find(u => u.id === userId)
                        || searchResults.value.find(u => u.id === userId);
                    if (userToAdd) {
                        followingList.value = [
                            ...followingList.value,
                            { ...userToAdd, isFollowing: true }
                        ];
                    }
                } else {
                    // 已在列表中，更新狀態
                    followingList.value = followingList.value.map(u =>
                        u.id === userId ? { ...u, isFollowing: true } : u
                    );
                }
            } else {
                // 取消追蹤：從列表中移除
                followingList.value = followingList.value.filter(u => u.id !== userId);
            }

            // 更新粉絲列表（只更新追蹤狀態，不修改粉絲數）
            followersList.value = followersList.value.map(u =>
                u.id === userId
                    ? { ...u, isFollowing: newFollowingStatus }
                    : u
            );

            // 更新搜尋結果（只更新追蹤狀態，不修改粉絲數）
            searchResults.value = searchResults.value.map(u =>
                u.id === userId
                    ? { ...u, isFollowing: newFollowingStatus }
                    : u
            );

            // 如果是在他人主頁，更新封面圖上的追蹤按鈕狀態
            if (!isOwnProfile.value && userId === targetUserId.value) {
                userProfile.value = {
                    ...userProfile.value,
                    isFollowing: newFollowingStatus,
                    stats: {
                        ...userProfile.value.stats,
                        followers: newFollowingStatus
                            ? userProfile.value.stats.followers + 1
                            : Math.max(userProfile.value.stats.followers - 1, 0)
                    }
                };
            }

            // 更新當前登入使用者的追蹤數（只在自己的主頁時才更新）
            if (isOwnProfile.value) {
                userProfile.value = {
                    ...userProfile.value,
                    stats: {
                        ...userProfile.value.stats,
                        following: newFollowingStatus
                            ? userProfile.value.stats.following + 1
                            : Math.max(userProfile.value.stats.following - 1, 0)
                    }
                };
            }
        }
    } catch (err) {
        console.error('追蹤操作失敗:', err);
        console.error('錯誤詳情:', err.response?.data || err.message);
        alert('操作失敗，請稍後再試');
    }
};

/**
 * 載入個人資料（含統計數據）
 */
const loadProfile = async () => {
    if (!targetUserId.value) {
        console.warn('使用者 ID 無效');
        return;
    }

    try {
        const { data } = await phpApi.get(`personal/profile_get.php?user_id=${targetUserId.value}&current_user_id=${authStore.userId || 0}`);

        // 檢查 data 是否有效
        if (!data || typeof data !== 'object' || data.not_found) {
            notFound.value = true;
            return;
        }

        notFound.value = false;
        // 更新個人資訊
        userProfile.value = {
            username: data.user_name || '訪客',
            role: data.user_bio || '無內容',
            avatar: getImageUrl(data.user_url),
            coverImage: getImageUrl(data.user_cover_image),
            isFollowing: data.is_following || false,  // 追蹤狀態
            stats: {
                recipes: data.stats?.recipes || 0,
                following: data.stats?.following || 0,
                followers: data.stats?.followers || 0
            }
        };

        // 只有查看自己的主頁時才同步更新 authStore
        if (isOwnProfile.value && authStore.user) {
            authStore.user.user_name = data.user_name;
            authStore.user.user_bio = data.user_bio;
            authStore.user.user_url = data.user_url;
        }

    } catch (err) {
        notFound.value = true;
        console.error('載入個人資料失敗:', err);
        console.error('錯誤詳情:', err.response?.data || err.message);
    }
};

/**
 * 載入個人食譜資料
 */
const loadMyRecipes = async () => {
    if (!targetUserId.value) {
        console.warn('使用者 ID 無效');
        error.value = '無效的使用者';
        return;
    }

    isLoading.value = true;
    error.value = null;

    try {
        const { data } = await phpApi.get(`personal/myrecipe_get.php?user_id=${targetUserId.value}`);

        if (!data) {
            recipes.value = [];
            return;
        }

        if (!Array.isArray(data)) {
            console.error('API 回傳格式錯誤，預期陣列但收到:', typeof data, data);
            recipes.value = [];
            return;
        }

        // 轉換食譜資料格式
        recipes.value = data.map(recipe => ({
            id: recipe.recipe_id,
            recipe_name: recipe.recipe_title,
            image_url: getImageUrl(recipe.recipe_image_url),
            tags: [recipe.recipe_type || '未分類'],
            author: {
                name: recipe.user_name || userProfile.value.username,
                likes: recipe.recipe_like_count || 0
            },
            _raw: recipe
        }));

    } catch (err) {
        console.error('載入食譜失敗:', err);
        console.error('錯誤詳情:', err.response?.data || err.message);
        error.value = '載入食譜失敗，請稍後再試';
        recipes.value = [];
    } finally {
        isLoading.value = false;
    }
};

/**
 * 點擊使用者跳轉到其主頁
 */
const viewUserProfile = (userId) => {
    if (userId === authStore.userId) {
        router.push({ name: 'user-profile' });
    } else {
        router.push({ name: 'other-user-profile', params: { userId } });
    }
};

/**
 * 搜尋使用者
 */
const searchUsers = async () => {
    if (!searchQuery.value.trim()) {
        alert('請輸入搜尋關鍵字');
        return;
    }

    isSearching.value = true;
    hasSearched.value = true;

    try {
        const { data } = await phpApi.get(`social/user_search.php`, {
            params: {
                query: searchQuery.value,
                current_user_id: authStore.userId
            }
        });

        if (Array.isArray(data)) {
            searchResults.value = data.map(user => ({
                id: user.user_id,
                name: user.user_name,
                avatar: getImageUrl(user.user_url),
                bio: user.user_bio || '無內容',
                recipes: user.recipe_count || 0,
                followers: user.follower_count || 0,
                isFollowing: user.is_following || false
            }));
        } else {
            searchResults.value = [];
        }
    } catch (err) {
        console.error('搜尋使用者失敗:', err);
        alert('搜尋失敗，請稍後再試');
        searchResults.value = [];
    } finally {
        isSearching.value = false;
    }
};

/**
 * Enter 鍵搜尋
 */
const handleEnterSearch = (event) => {
    if (event.key === 'Enter') {
        searchUsers();
    }
};

/**
 * 載入追蹤列表
 */
const loadFollowingList = async () => {
    if (!targetUserId.value) return;

    isLoadingFollows.value = true;

    try {
        const { data } = await phpApi.get(`social/follows.php?user_id=${targetUserId.value}&type=following`);

        if (Array.isArray(data)) {
            followingList.value = data.map(user => ({
                id: user.id,
                name: user.name,
                avatar: getImageUrl(user.avatar),
                bio: user.bio,
                recipes: user.recipes,
                followers: user.followers,
                isFollowing: user.isFollowing
            }));
        } else {
            console.warn('追蹤列表回傳格式錯誤，預期陣列但收到:', typeof data, data);
            followingList.value = [];
        }
    } catch (err) {
        console.error('載入追蹤列表失敗:', err);
        console.error('錯誤狀態碼:', err.response?.status);
        console.error('錯誤訊息:', err.response?.data);
        console.error('請求 URL:', err.config?.url);
        console.error('完整錯誤:', err.message);
        followingList.value = [];
    } finally {
        isLoadingFollows.value = false;
    }
};

/**
 * 載入粉絲列表
 */
const loadFollowersList = async () => {
    if (!targetUserId.value) return;

    isLoadingFollows.value = true;

    try {
        const { data } = await phpApi.get(`social/follows.php?user_id=${targetUserId.value}&type=followers`);

        if (Array.isArray(data)) {
            followersList.value = data.map(user => ({
                id: user.id,
                name: user.name,
                avatar: getImageUrl(user.avatar),
                bio: user.bio,
                recipes: user.recipes,
                followers: user.followers,
                isFollowing: user.isFollowing
            }));
        } else {
            console.warn('粉絲列表回傳格式錯誤，預期陣列但收到:', typeof data, data);
            followersList.value = [];
        }
    } catch (err) {
        console.error('載入粉絲列表失敗:', err);
        console.error('錯誤狀態碼:', err.response?.status);
        console.error('錯誤訊息:', err.response?.data);
        console.error('請求 URL:', err.config?.url);
        console.error('完整錯誤:', err.message);
        followersList.value = [];
    } finally {
        isLoadingFollows.value = false;
    }
};

// 只顯示前 8 筆食譜
const displayedRecipes = computed(() => {
    return recipes.value.slice(0, 8);
});

// ==================== 生命週期 ====================
onMounted(async () => {
    await loadProfile();
    await loadMyRecipes();
});

// 監聽登入狀態變化
watch(() => authStore.userId, async (newUserId) => {
    if (newUserId && isOwnProfile.value) {
        await loadProfile();
        await loadMyRecipes();
    }
});

// 監聽 userId 參數變化（切換不同使用者主頁）
watch(() => props.userId, async (newUserId, oldUserId) => {
    // 重置資料
    followingList.value = [];
    followersList.value = [];
    searchResults.value = [];
    hasSearched.value = false;
    searchQuery.value = '';
    activeTab.value = 'recipes';

    await loadProfile();
    await loadMyRecipes();
}, { immediate: false });

// 監聽路由變化（從他人主頁回到自己主頁）
watch(() => route.name, async (newName, oldName) => {
    if (newName === 'user-profile' && oldName === 'other-user-profile') {
        // 重置資料
        followingList.value = [];
        followersList.value = [];
        searchResults.value = [];
        hasSearched.value = false;
        searchQuery.value = '';
        activeTab.value = 'recipes';

        await loadProfile();
        await loadMyRecipes();
    }
});
</script>

<template>
    <div class="profile-view">
        <template v-if="notFound">
            <div class="empty-state" style="width:100%;text-align:center;padding:64px 0;">
                <p class="zh-body">此使用者不存在或已被刪除</p>
            </div>
        </template>
        <template v-else>
            <div class="container">
                <!-- 個人資訊卡片區域 -->
                <div class="profile-header">
                    <!-- 封面圖片 -->
                    <div class="cover-image">
                        <img :src="userProfile.coverImage" alt="封面圖片">
                        <!-- 編輯個人檔案按鈕（只有查看自己主頁時顯示） -->
                        <div v-if="isOwnProfile" class="edit-profile-btn">
                            <BaseBtn @click="editProfile">
                                編輯個人檔案
                            </BaseBtn>
                        </div>
                        <!-- 追蹤按鈕（查看他人主頁時顯示） -->
                        <div v-else class="follow-profile-btn">
                            <BaseBtn :key="`follow-btn-${userProfile.isFollowing}`" @click="toggleFollow(targetUserId)"
                                :variant="userProfile.isFollowing ? 'outline' : 'solid'">
                                {{ userProfile.isFollowing ? '追蹤中' : '追蹤' }}
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
                    <button class="tab-btn zh-h5" :class="{ 'active': activeTab === 'recipes' }"
                        @click="switchTab('recipes')">
                        個人食譜
                    </button>
                    <button class="tab-btn zh-h5" :class="{ 'active': activeTab === 'following' }"
                        @click="switchTab('following')">
                        追蹤
                    </button>
                    <button class="tab-btn zh-h5" :class="{ 'active': activeTab === 'likes' }"
                        @click="switchTab('likes')">
                        粉絲
                    </button>
                    <button class="tab-btn zh-h5" :class="{ 'active': activeTab === 'search' }"
                        @click="switchTab('search')">
                        搜尋使用者
                    </button>
                </div>

                <!-- 食譜列表 -->
                <div v-if="activeTab === 'recipes'" class="row recipe-cards-container">
                    <template v-if="displayedRecipes.length > 0">
                        <div v-for="recipe in displayedRecipes" :key="recipe.id"
                            class="col-3 col-lg-6 col-md-12 recipe-card-col">
                            <RecipeCardSm :recipe="recipe" />
                        </div>
                    </template>
                    <div v-else class="empty-state" style="width:100%;text-align:center;padding:48px 0;">
                        <p class="zh-body">目前沒有個人食譜</p>
                    </div>
                </div>

                <!-- 追蹤列表 -->
                <div v-if="activeTab === 'following'" class="user-list">
                    <!-- 載入中 -->
                    <div v-if="isLoadingFollows" class="loading-state">
                        <p class="zh-body">載入中...</p>
                    </div>

                    <!-- 空狀態 -->
                    <div v-else-if="followingList.length === 0" class="empty-state">
                        <p class="zh-body">還沒有追蹤任何人</p>
                    </div>

                    <!-- 追蹤用戶列表 -->
                    <TransitionGroup v-else name="user-list" tag="div" class="user-list-container">
                        <div v-for="user in followingList" :key="user.id" class="user-item">
                            <img :src="user.avatar" alt="頭像" class="user-avatar" @click="viewUserProfile(user.id)">
                            <div class="user-info" @click="viewUserProfile(user.id)">
                                <h4 class="user-name zh-h5">{{ user.name }}</h4>
                                <p class="user-bio zh-body">{{ user.bio }}</p>
                                <div class="user-stats">
                                    <span class="zh-body">{{ user.recipes }} 食譜</span>
                                    <span class="zh-body">{{ user.followers }} 粉絲</span>
                                </div>
                            </div>
                            <BaseBtn v-if="user.id !== authStore.userId"
                                :key="`following-${user.id}-${user.isFollowing}`" @click="toggleFollow(user.id)"
                                :variant="user.isFollowing ? 'outline' : 'solid'" width="100px">
                                {{ user.isFollowing ? '追蹤中' : '追蹤' }}
                            </BaseBtn>
                            <span v-else class="self-tag zh-body">本人</span>
                        </div>
                    </TransitionGroup>
                </div>

                <!-- 粉絲列表 -->
                <div v-if="activeTab === 'likes'" class="user-list">
                    <!-- 載入中 -->
                    <div v-if="isLoadingFollows" class="loading-state">
                        <p class="zh-body">載入中...</p>
                    </div>

                    <!-- 空狀態 -->
                    <div v-else-if="followersList.length === 0" class="empty-state">
                        <p class="zh-body">還沒有粉絲</p>
                    </div>

                    <!-- 粉絲用戶列表 -->
                    <TransitionGroup v-else name="user-list" tag="div" class="user-list-container">
                        <div v-for="user in followersList" :key="user.id" class="user-item">
                            <img :src="user.avatar" alt="頭像" class="user-avatar" @click="viewUserProfile(user.id)">
                            <div class="user-info" @click="viewUserProfile(user.id)">
                                <h4 class="user-name zh-h5">{{ user.name }}</h4>
                                <p class="user-bio zh-body">{{ user.bio }}</p>
                                <div class="user-stats">
                                    <span class="zh-body">{{ user.recipes }} 食譜</span>
                                    <span class="zh-body">{{ user.followers }} 粉絲</span>
                                </div>
                            </div>
                            <BaseBtn v-if="user.id !== authStore.userId"
                                :key="`follower-${user.id}-${user.isFollowing}`" @click="toggleFollow(user.id)"
                                :variant="user.isFollowing ? 'outline' : 'solid'" width="100px">
                                {{ user.isFollowing ? '追蹤中' : '追蹤' }}
                            </BaseBtn>
                            <span v-else class="self-tag zh-body">本人</span>
                        </div>
                    </TransitionGroup>
                </div>

                <!-- 搜尋使用者 -->
                <div v-if="activeTab === 'search'" class="search-section">
                    <!-- 搜尋列 -->
                    <div class="search-bar">
                        <input v-model="searchQuery" type="text" class="search-input" placeholder="輸入使用者名稱..."
                            @keyup="handleEnterSearch">
                        <BaseBtn @click="searchUsers" :disabled="isSearching">
                            {{ isSearching ? '搜尋中...' : '搜尋' }}
                        </BaseBtn>
                    </div>

                    <!-- 搜尋結果 -->
                    <div class="search-results">
                        <!-- 載入中 -->
                        <div v-if="isSearching" class="loading-state">
                            <p class="zh-body">搜尋中...</p>
                        </div>

                        <!-- 空狀態 -->
                        <div v-else-if="hasSearched && searchResults.length === 0" class="empty-state">
                            <p class="zh-body">找不到符合的使用者</p>
                        </div>

                        <!-- 使用者列表 -->
                        <div v-else-if="searchResults.length > 0" class="user-list">
                            <div v-for="user in searchResults" :key="user.id" class="user-item">
                                <img :src="user.avatar" alt="頭像" class="user-avatar" @click="viewUserProfile(user.id)">
                                <div class="user-info" @click="viewUserProfile(user.id)">
                                    <h4 class="user-name zh-h5">{{ user.name }}</h4>
                                    <p class="user-bio zh-body">{{ user.bio }}</p>
                                    <div class="user-stats">
                                        <span class="zh-body">{{ user.recipes }} 食譜</span>
                                        <span class="zh-body">{{ user.followers }} 粉絲</span>
                                    </div>
                                </div>
                                <BaseBtn v-if="user.id !== authStore.userId"
                                    :key="`search-${user.id}-${user.isFollowing}`" @click="toggleFollow(user.id)"
                                    :variant="user.isFollowing ? 'outline' : 'solid'" width="100px">
                                    {{ user.isFollowing ? '追蹤中' : '追蹤' }}
                                </BaseBtn>
                                <span v-else class="self-tag zh-body">本人</span>
                            </div>
                        </div>

                        <!-- 初始狀態 -->
                        <div v-else class="initial-state">
                            <p class="zh-body">請輸入關鍵字開始搜尋</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 編輯個人檔案彈窗 -->
            <Teleport to="body">
                <EditProfileModal :show="showEditModal" :user-profile="userProfile" @close="showEditModal = false"
                    @save="handleSaveProfile" />
            </Teleport>
        </template>
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
.edit-profile-btn,
.follow-profile-btn {
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
    position: relative;
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

/* ==================== 搜尋使用者區域 ==================== */
.search-section {
    margin-top: 32px;
}

.search-bar {
    display: flex;
    gap: 12px;
    align-items: center;
    margin-bottom: 24px;
}

.search-input {
    flex: 1;
    padding: 12px 16px;
    border: 1px solid $neutral-color-400;
    border-radius: 8px;
    font-size: 16px;
    transition: border-color 0.2s;

    &:focus {
        outline: none;
        border-color: $primary-color-700;
    }

    &::placeholder {
        color: $neutral-color-400;
    }
}

.search-results {
    min-height: 200px;
}

.loading-state,
.empty-state,
.initial-state {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 200px;
    color: $neutral-color-700;
}

.self-tag {
    padding: 8px 16px;
    background: $neutral-color-100;
    color: $neutral-color-700;
    border-radius: 6px;
    font-size: 14px;
}

.user-avatar {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    object-fit: cover;
    flex-shrink: 0;
    cursor: pointer;
    transition: opacity 0.2s;

    &:hover {
        opacity: 0.8;
    }
}

.user-info {
    flex: 1;
    cursor: pointer;

    &:hover .user-name {
        color: $primary-color-700;
    }
}

.user-name {
    margin-bottom: 4px;
    color: $neutral-color-800;
}

.user-bio {
    margin-bottom: 4px;
    color: $neutral-color-700;
    font-size: 13px;
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

/* ==================== 過渡效果 ==================== */
.user-list-container {
    position: relative;
}

.user-list-move,
.user-list-enter-active,
.user-list-leave-active {
    transition: all 0.5s cubic-bezier(0.55, 0, 0.1, 1);
}

.user-list-enter-from {
    opacity: 0;
    transform: translateY(-30px);
}

.user-list-leave-to {
    opacity: 0;
    transform: translateY(30px);
}

.user-list-leave-active {
    position: absolute;
    left: 0;
    right: 0;
}

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

    .search-bar {
        flex-direction: column;

        button {
            width: 100%;
        }
    }

    .user-item {
        flex-wrap: wrap;

        .user-info {
            flex-basis: 100%;
            order: 2;
            margin-top: 12px;
        }

        button,
        .self-tag {
            margin-left: auto;
        }
    }
}
</style>
