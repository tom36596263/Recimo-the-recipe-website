import { createRouter, createWebHistory } from 'vue-router';

const routes = [
  // ==========================================
  // 1. 前台官網 (使用 DefaultLayout)
  // ==========================================
  {
    path: '/test-auth',
    name: 'test-auth',
    // 隨便借用一個現有的 Layout 或直接載入組件
    component: () => import('@/components/LoginLightbox.vue')
  },
  {
    path: '/',
    name: 'home', // 首頁
    component: () => import('@/views/site/HomeView.vue'),
    meta: { layout: 'default' }
  },
  {
    path: '/search',
    name: 'site-search', //站內搜尋頁
    component: () => import('@/views/site/SearchView.vue'),
    meta: { layout: 'default' }
  },
  {
    path: '/about',
    name: 'about', // 關於Recimo
    component: () => import('@/views/site/AboutView.vue'),
    meta: { layout: 'default' }
  },
  {
    path: '/recipes',
    name: 'recipes-overview', // 食譜總覽
    component: () => import('@/views/site/RecipeOverview.vue'),
    meta: { layout: 'default' }
  },
  {
    path: '/mall',
    name: 'mall', // Recimo商城
    component: () => import('@/views/site/MallView.vue'),
    meta: { layout: 'default' }
  },
  {
    path: '/mall/:id',
    name: 'product-detail', //商品詳情頁
    component: () => import('@/views/site/ProductDetail.vue'),
    meta: { layout: 'default' }
  },
  {
    path: '/benefits',
    name: 'benefits', // 會員權益
    component: () => import('@/views/site/BenefitsView.vue'),
    meta: { layout: 'default' }
  },
  {
    path: '/cart',
    name: 'cart', // 購物車
    component: () => import('@/views/site/CartView.vue'),
    meta: { layout: 'default' }
  },
  {
    path: '/checkout',
    name: 'checkout', //結帳
    component: () => import('@/views/site/CheckoutView.vue'),
    meta: { layout: 'default' }
  },

  // ==========================================
  // 2. 前台工作區 (使用 WorkspaceLayout)
  // ==========================================
  {
    path: '/workspace',
    redirect: '/workspace/my-recipes', // 進入工作區自動導向我的食譜
    children: [
      {
        path: 'my-recipes',
        name: 'my-recipes', // 我的食譜
        component: () => import('@/views/workspace/MyRecipes.vue'),
        meta: {
          layout: 'workspace',
          requiresAuth: true
        }
      },
      {
        path: 'lab',
        name: 'cooking-lab', //烹飪實驗室
        component: () => import('@/views/workspace/CookingLab.vue'),
        meta: {
          layout: 'workspace',
          requiresAuth: true
        }
      },
      {
        path: 'plan',
        name: 'meal-plan', // 備餐計畫
        component: () => import('@/views/workspace/MealPlan.vue'),
        meta: {
          layout: 'workspace',
          requiresAuth: true
        }
      },
      {
        path: 'recipes',
        name: 'workspace-recipes', // 食譜總覽(工作區)
        component: () => import('@/views/workspace/RecipeOverview.vue'),
        meta: {
          layout: 'workspace',
          requiresAuth: true
        }
      },
      {
        path: 'recipe-detail/:id',
        name: 'workspace-recipe-detail', // 食譜詳情頁
        component: () => import('@/views/workspace/RecipeDetail.vue'),
        meta: { layout: 'workspace', requiresAuth: true, hideTopBar: false }
      },
      {
        path: 'edit-recipe',
        name: 'edit-recipe', // 食譜編輯
        component: () => import('@/views/workspace/EditRecipe.vue'),
        meta: {
          layout: 'workspace',
          requiresAuth: true,
          hideTopBar: true // 在 WorkspaceLayout.vue 裡有寫 v-if 判斷是否隱藏topbar
        }
      },
      {
        path: 'orders',
        name: 'order-inquiry', // 訂單查詢
        component: () => import('@/views/workspace/OrderInquiry.vue'),
        meta: {
          layout: 'workspace',
          requiresAuth: true
        }
      },
      {
        path: 'profile',
        name: 'user-profile', //個人主頁
        component: () => import('@/views/workspace/ProfileView.vue'),
        meta: { layout: 'workspace', requiresAuth: true, hideTopBar: false }
      },
      {
        path: 'settings',
        name: 'user-settings', //會員中心(設定)
        component: () => import('@/views/workspace/SettingsView.vue'),
        meta: { layout: 'workspace', requiresAuth: true, hideTopBar: false }
      }
    ]
  },
  // ==========================================
  // 3. 後台
  // ==========================================
  {
    path: '/admin',
    component: () => import('@/layouts/AdminLayout.vue'),
    redirect: '/admin/members', // 進入後台預設導向會員管理
    children: [
      {
        path: 'members',
        name: 'AdminMembers',
        component: () => import('@/views/admin/MemberAdmin.vue'),
        meta: { title: '會員管理' }
      },
      {
        path: 'ingredients',
        name: 'AdminIngredients',
        component: () => import('@/views/admin/IngredientAdmin.vue'),
        meta: { title: '食材管理' }
      },
      {
        path: 'recipes',
        name: 'AdminRecipes',
        component: () => import('@/views/admin/RecipeAdmin.vue'),
        meta: { title: '食譜管理' }
      },
      {
        path: 'reports',
        name: 'AdminReports',
        component: () => import('@/views/admin/ReportAdmin.vue'),
        meta: { title: '檢舉管理' }
      },
      {
        path: 'support',
        name: 'AdminSupport',
        component: () => import('@/views/admin/SupportAdmin.vue'),
        meta: { title: '客服表單' }
      },
      {
        path: 'products',
        name: 'AdminProducts',
        component: () => import('@/views/admin/ProductAdmin.vue'),
        meta: { title: '商品管理' }
      },
      {
        path: 'orders',
        name: 'AdminOrders',
        component: () => import('@/views/admin/OrderAdmin.vue'),
        meta: { title: '訂單管理' }
      },
      {
        path: 'notifications',
        name: 'AdminNotifications',
        component: () => import('@/views/admin/NotificationAdmin.vue'),
        meta: { title: '通知管理' }
      },
      {
        path: 'faqs',
        name: 'AdminFaqs',
        component: () => import('@/views/admin/FaqAdmin.vue'),
        meta: { title: '常見問題管理' }
      },
      {
        path: 'staff',
        name: 'AdminStaff',
        component: () => import('@/views/admin/StaffAdmin.vue'),
        meta: { title: '後台人員管理' }
      }
    ]
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;
