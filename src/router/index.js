import { createRouter, createWebHistory } from 'vue-router';

const routes = [
  // ==========================================
  // 1. 前台官網 (使用 DefaultLayout)
  // ==========================================
  {
    path: '/',
    name: 'home',
    component: () => import('@/views/site/HomeView.vue'),
    meta: { title: '首頁', showInMenu: true, layout: 'default' }
  },
  {
    path: '/search',
    name: 'site-search',
    component: () => import('@/views/site/SearchView.vue'),
    meta: {layout: 'default' }
  },
  {
    path: '/about',
    name: 'about',
    component: () => import('@/views/site/AboutView.vue'),
    meta: { title: '關於Recimo', showInMenu: true, layout: 'default' }
  },
  {
    path: '/recipes',
    name: 'recipes-overview',
    component: () => import('@/views/site/RecipeOverview.vue'),
    meta: { title: '食譜總覽', showInMenu: true, layout: 'default' }
  },
  {
    path: '/mall',
    name: 'mall',
    component: () => import('@/views/site/MallView.vue'),
    meta: { title: 'Recimo商城', showInMenu: true, layout: 'default' }
  },
  {
    path: '/mall/:id',
    name: 'product-detail',
    component: () => import('@/views/site/ProductDetail.vue'),
    meta: { layout: 'default' }
  },
  {
    path: '/benefits',
    name: 'benefits',
    component: () => import('@/views/site/BenefitsView.vue'),
    meta: { title: '會員權益', showInMenu: true, layout: 'default' }
  },
  {
    path: '/cart',
    name: 'cart',
    component: () => import('@/views/site/CartView.vue'),
    meta: { layout: 'default' }
  },
  {
    path: '/checkout',
    name: 'checkout',
    component: () => import('@/views/site/CheckoutView.vue'),
    meta: { layout: 'default' }
  },

  // ==========================================
  // 2. 前台工作區 (使用 WorkspaceLayout)
  // ==========================================
  {
    path: '/workspace',
    redirect: '/workspace/my-recipes',
    children: [
      {
        path: 'my-recipes',
        name: 'my-recipes',
        component: () => import('@/views/workspace/MyRecipes.vue'),
        meta: { layout: 'workspace', requiresAuth: true }
      },
      {
        path: 'lab',
        name: 'cooking-lab',
        component: () => import('@/views/workspace/CookingLab.vue'),
        meta: { layout: 'workspace', requiresAuth: true }
      },
      {
        path: 'plan',
        name: 'meal-plan',
        component: () => import('@/views/workspace/MealPlan.vue'),
        meta: { layout: 'workspace', requiresAuth: true }
      },
      {
        path: 'edit-plan',
        name: 'edit-meal-plan',
        component: () => import('@/views/workspace/EditMealPlan.vue'),
        meta: { layout: 'workspace', requiresAuth: true }
      },
      {
        path: 'recipes',
        name: 'workspace-recipes',
        component: () => import('@/views/workspace/RecipeOverview.vue'),
        meta: { layout: 'workspace', requiresAuth: true }
      },
      {
        path: 'recipe-detail/:id',
        name: 'workspace-recipe-detail',
        component: () => import('@/views/workspace/RecipeDetail.vue'),
        meta: { layout: 'workspace', requiresAuth: true }
      },
      {
        path: 'edit-recipe',
        name: 'edit-recipe',
        component: () => import('@/views/workspace/EditRecipe.vue'),
        meta: { layout: 'workspace', requiresAuth: true, hideTopBar: true }
      },
      {
        path: 'orders',
        name: 'order-inquiry',
        component: () => import('@/views/workspace/OrderInquiry.vue'),
        meta: { layout: 'workspace', requiresAuth: true }
      },
      {
        path: 'profile',
        name: 'user-profile',
        component: () => import('@/views/workspace/ProfileView.vue'),
        meta: { layout: 'workspace', requiresAuth: true }
      },
      {
        path: 'settings',
        name: 'user-settings',
        component: () => import('@/views/workspace/SettingsView.vue'),
        meta: { layout: 'workspace', requiresAuth: true }
      }
    ]
  },
  // 404 處理：若輸入不存在的網址（包含舊的 /admin），導回首頁
  {
    path: '/:pathMatch(.*)*',
    redirect: '/'
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;
