import { createRouter, createWebHistory } from 'vue-router';
import { ref, markRaw } from 'vue';
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
        // 隨便借用一個現有的 Layout 或直接載入組件
        path: '/loginlightbox',
        name: 'loginlightbox',
        component: () => import('@/components/LoginLightbox.vue')
      },
      {
        path: '/',
        name: 'home',
        component: () => import('@/views/site/HomeView.vue'),
        meta: { layout: 'default', breadcrumb: null }
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
      // {
      //   path: '/mall',
      //   component: () => import('@/views/site/MallView.vue'),
      //   meta: { layout: 'default', title: 'Recimo商城', breadcrumb: 'Recimo商城', showInMenu: true }
      // },
      // {
      //   path: '/mall/:id',
      //   name: 'product-detail',
      //   component: () => import('@/views/site/ProductDetail.vue'),
      //   meta: { layout: 'default', breadcrumb: '載入中...', showInMenu: true }
      // },
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
        meta: { layout: 'default', title: '結帳', breadcrumb: '結帳' }
      }
    ]
  },

  // ==========================================
  // 2. 前台工作區 (使用 WorkspaceLayout)
  // ==========================================
  {
    path: '/workspace',
    redirect: '/workspace/my-recipes',
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

export default router;
