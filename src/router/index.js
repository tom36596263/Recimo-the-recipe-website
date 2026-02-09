import { ref, markRaw } from 'vue';
// 引用 Pinia Store (權限狀態管理)
import { createRouter, createWebHistory } from 'vue-router';
import { useAuthStore } from '@/stores/authStore';
// 引用icon
import IconForkSpoon from 'virtual:icons/material-symbols/Fork-Spoon'
import IconSkillet from 'virtual:icons/material-symbols/Skillet-outline'
import IconHandMeal from 'virtual:icons/material-symbols/Hand-Meal-outline'
import IconInboxTextPerson from 'virtual:icons/material-symbols/Inbox-Text-Person-outline'
import IconShoppingCart from 'virtual:icons/material-symbols/Shopping-Cart-outline'
import IconAssignment from 'virtual:icons/material-symbols/Assignment-outline'
import IconAccount from 'virtual:icons/material-symbols/Account-circle'

const pageicon = ref([
  markRaw(IconForkSpoon),
  markRaw(IconSkillet),
  markRaw(IconHandMeal),
  markRaw(IconInboxTextPerson),
  markRaw(IconShoppingCart),
  markRaw(IconAssignment)
]);

const routes = [
  // ==========================================
  // 1. 前台官網 (使用 DefaultLayout)
  // ==========================================
  {
    path: '/',
    component: () => import('@/layouts/DefaultLayout.vue'),
    children: [
      {
        path: '/',
        name: 'home',
        component: () => import('@/views/site/HomeView.vue'),
        meta: { title: '首頁', layout: 'default', breadcrumb: null }
      },
      {
        path: '/search',
        name: 'site-search',
        component: () => import('@/views/site/SearchView.vue'),
        meta: { layout: 'default', title: '搜尋好料理', breadcrumb: '搜尋好料理' }
      },
      {
        path: '/about',
        name: 'about',
        component: () => import('@/views/site/AboutView.vue'),
        meta: { layout: 'default', title: '關於Recimo', breadcrumb: '關於Recimo', showInMenu: true, }
      },
      {
        path: '/recipes',
        name: 'recipes-overview',
        component: () => import('@/views/site/RecipeOverview.vue'),
        meta: { layout: 'default', title: '食譜總覽', breadcrumb: '食譜總覽', showInMenu: true, }
      },
      {
        path: '/mall',
        component: () => import('@/views/site/MallView.vue'),
        meta: { layout: 'default', title: 'Recimo商城', breadcrumb: 'Recimo商城', showInMenu: true },
        children: [
          {
            path: ':id',
            name: 'product-detail',
            component: () => import('@/views/site/ProductDetail.vue'),
            meta: { isDynamic: true, breadcrumb: '動態的名字' },
            props: true,
          }
        ]
      },
      {
        path: '/benefits',
        name: 'benefits',
        component: () => import('@/views/site/BenefitsView.vue'),
        meta: { layout: 'default', title: '會員權益', breadcrumb: '會員權益', showInMenu: true }
      },
      {
        path: '/cart',
        name: 'cart',
        component: () => import('@/views/site/CartView.vue'),
        meta: { layout: 'default', title: '我的購物車', breadcrumb: '我的購物車' }
      },
      {
        path: '/checkout',
        name: 'checkout',
        component: () => import('@/views/site/CheckoutView.vue'),
        meta: { layout: 'default', title: '結帳', breadcrumb: '結帳', requiresAuth: true }
      }
    ]
  },
  // ==========================================
  // 2. 前台工作區 (使用 WorkspaceLayout)
  // ==========================================
  {
    path: '/workspace',
    redirect: '/workspace/my-recipes',
    meta: { requiresAuth: true }, // 標記此路徑及其子路徑需要登入
    component: () => import('@/layouts/WorkspaceLayout.vue'),
    children: [
      {
        path: 'my-recipes',
        name: 'my-recipes',
        component: () => import('@/views/workspace/MyRecipes.vue'),
        meta: {
          title: '我的食譜',
          icon: markRaw(IconForkSpoon),
          layout: 'workspace',
          requiresAuth: true
        }
      },
      {
        path: 'recent-recipes',
        name: 'recent-recipes',
        component: () => import('@/views/workspace/RecentRecipes.vue'),
        meta: {
          title: '最近觀看食譜',
          layout: 'workspace',
          requiresAuth: true
        }
      },
      {
        path: 'my-favorites',
        name: 'my-favorites',
        component: () => import('@/views/workspace/MyFavorites.vue'),
        meta: {
          title: '我的收藏',
          layout: 'workspace',
          requiresAuth: true
        }
      },
      {
        path: 'personal-recipes',
        name: 'personal-recipes',
        component: () => import('@/views/workspace/PersonalRecipes.vue'),
        meta: {
          title: '個人食譜',
          layout: 'workspace',
          requiresAuth: true
        }
      },
      {
        path: 'lab',
        name: 'cooking-lab',
        component: () => import('@/views/workspace/CookingLab.vue'),
        meta: {
          title: '烹飪實驗室',
          icon: markRaw(IconSkillet),
          layout: 'workspace',
          requiresAuth: true
        }
      },
      {
        path: 'cooking-log/:id',
        name: 'cooking-log',
        component: () => import('@/views/workspace/CookingLog.vue'),
        meta: {
          title: '烹飪日誌',
          layout: 'workspace',
          requiresAuth: true
        }
      },
      {
        path: 'plan',
        name: 'meal-plan',
        component: () => import('@/views/workspace/MealPlan.vue'),
        meta: {
          title: '備餐計畫',
          icon: markRaw(IconHandMeal),
          layout: 'workspace',
          requiresAuth: true
        }
      },
      {
        path: 'edit-plan/:id',
        name: 'edit-meal-plan',
        component: () => import('@/views/workspace/EditMealPlan.vue'),
        meta: { title: '編輯計畫', layout: 'workspace', requiresAuth: true },
        props: true
      },
      {
        path: 'recipes',
        name: 'workspace-recipes',
        component: () => import('@/views/workspace/RecipeOverview.vue'),
        meta: {
          title: '食譜總覽',
          icon: markRaw(IconInboxTextPerson),
          layout: 'workspace',
          requiresAuth: true
        }
      },
      {
        path: 'recipe-detail/:id',
        name: 'workspace-recipe-detail',
        component: () => import('@/views/workspace/RecipeDetail.vue'),
        meta: { title: '食譜詳情', layout: 'workspace', requiresAuth: true }
      },
      {
        path: 'edit-recipe',
        name: 'edit-recipe',
        component: () => import('@/views/workspace/EditRecipe.vue'),
        meta: { title: '食譜編輯', layout: 'workspace', requiresAuth: true }
      },
      {
        path: 'guide/:id',
        name: 'recipe-guide',
        component: () => import('@/views/workspace/RecipeGuide.vue'),
        meta: {
          title: '步驟播放',
          layout: 'workspace',
          requiresAuth: true
        }
      },
      {
        path: 'orders',
        name: 'order-inquiry',
        component: () => import('@/views/workspace/OrderInquiry.vue'),
        meta: {
          title: '訂單查詢',
          icon: markRaw(IconAssignment),
          layout: 'workspace',
          requiresAuth: true
        }
      },
      {
        path: 'profile',
        name: 'user-profile',
        component: () => import('@/views/workspace/ProfileView.vue'),
        meta: {
          title: '個人主頁',
          icon: markRaw(IconAccount),
          layout: 'workspace',
          requiresAuth: true,
        }
      },
      {
        path: 'user/:userId',
        name: 'other-user-profile',
        component: () => import('@/views/workspace/ProfileView.vue'),
        meta: {
          title: '其他使用者主頁',
          layout: 'workspace',
          requiresAuth: true
        },
        props: true
      },
      {
        path: 'settings',
        name: 'user-settings',
        component: () => import('@/views/workspace/SettingsView.vue'),
        meta: { title: '會員中心', layout: 'workspace', requiresAuth: true }
      },
      {
        path: 'modify-recipe/:id?', // :id 代表食譜的編號
        name: 'modify-recipe',
        component: () => import('@/views/workspace/ModifyRecipe.vue'),
        meta: {
          title: '食譜改編',
          layout: 'workspace',
          requiresAuth: true
        }
      }
    ]
  },
  // 404 處理：若輸入不存在的網址導回首頁
  // {
  //   path: '/:pathMatch(.*)*',
  //   redirect: '/'
  // }
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
  scrollBehavior(to, from, savedPosition) {
    return { top: 0 };
  }
});

// ==========================================
// 全域導航守衛
// ==========================================
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore();

  // 修改網頁頁籤名稱
  const siteName = 'Recimo'; // 你的網站名稱
  // 優先找子路由的 title，如果沒有就用預設名稱
  document.title = to.meta.title ? `${to.meta.title} | ${siteName}` : siteName;

  if (to.matched.some(record => record.meta.requiresAuth)) {
    if (!authStore.isLoggedIn) {
      // 1. 開啟燈箱
      // authStore.openLoginLightbox();
      // --- 核心修改：存入一個跳轉動作 ---
      authStore.pendingAction = () => {
        router.push(to.fullPath);
      };

      authStore.openLoginLightbox();
      // 2. 停止目前的導航（保持在原頁面）
      // 或者你想讓使用者回首頁同時開燈箱，就用 next({ path: '/' })
      next(false);
    } else {
      next();
    }
  } else {
    next();
  }
});

export default router;