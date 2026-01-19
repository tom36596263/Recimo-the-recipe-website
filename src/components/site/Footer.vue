<script setup>
    import { useRouter } from 'vue-router';
    import { computed } from 'vue';

    import SearchBar from '@/components/common/SearchBar.vue'
    import LogoBlack from '/img/site/Recimo-logo-black.svg'

    const router = useRouter();

    // 篩選出 Default 佈局下的子路由
    const navItems = computed(() => {
    // 直接拿取所有路由，篩選出 layout 為 default 且 meta.showInMenu 為 true 的項目
        return router.getRoutes()
        .filter(route => route.meta?.layout === 'default' && route.meta?.showInMenu)
        .map(route => ({
            path: route.path,
            title: route.meta.title
        }));
    });
</script>
<template>
    <div class=" footer container">
        <div class="row">
            <div class="col-12">
                <div class="logo">
                    <router-link to="/"><img :src="$parsePublicFile('img/site/Recimo-logo-black.svg')" alt="logo" ></router-link>
                </div>
            </div>
            <div class="col-9 col-lg-12 link-group">
                <router-link to="/workspace" class="login-btn p-p1">
                    <i-material-symbols-fork-spoon />
                    我的廚房
                </router-link>
                <router-link 
                v-for="item in navItems" 
                :key="item.path" 
                :to="item.path"
                class="p-p1">
                {{ item.title }}
                </router-link>
            </div>
            <div class="col-3 col-lg-12">
                <SearchBar />
            </div>
            <div class="col-9 col-lg-12 info-group">
                <div class="info">
                    <p class="p-p2">官方信箱 | hello@recimo.com</p>
                    <p class="p-p2">合作洽談 | collab@recimo.com</p>
                    <p class="p-p2">客服時段 | 週一至週五 10:00 - 18:00</p>
                </div>
                <div class="info">
                    <p class="p-p2">總部 | recimo 實驗廚房 (recimo Lab) </p>
                    <p class="p-p2">地址 | 106 台北市大安區風味路123號4樓 </p>
                    <p class="p-p2">電話 | (02) 2345-6789 </p>
                </div>
                
            </div>
            <div class="col-3 col-lg-12 follow-us">
                <span class="en-h1">Follow Us</span>
                <div class="icon">
                    <span><i class="fa-brands fa-facebook"></i></span>
                    <span><i class="fa-brands fa-instagram"></i></span>
                </div>
            </div>
        </div>
    </div>
</template>
<style lang="scss" scoped>
    .footer{
        .logo{
            margin-bottom: 30px;
            display: flex;
            align-items: start;
        }
        .link-group{
            display:flex;
            gap: 12px;
            align-items: center;
            margin-bottom: 30px;
            
            a{
                text-decoration: none;
                color: inherit;
                display: inline-block;
                display: flex;
                align-items: center;
                height: 50px;
                padding: 0 10px;
                &:hover{
                    color: $accent-color-700;
                }
            }
            .login-btn{
                background-color: $primary-color-700;
                background: linear-gradient(
                    120deg, 
                    $accent-color-700 0%, 
                    $accent-color-700 40%, 
                    $primary-color-700 60%,
                    $primary-color-700 100%);
                background-size: 250% 100%;
                background-position: 100% 0%;
                transition: background-position .5s cubic-bezier(0.4, 0, 0.2, 1);

                color: $neutral-color-white;
                height: 40px;
                align-items: center;
                display: inline-flex;
                padding: 0 30px;
                border-radius: 50px;
                
                &:hover{
                    background-position: left bottom;
                    color: $neutral-color-white;
                }
            }
        }
        
        .info-group{
            display: flex;
            text-align: start;
            gap: 30px;
        }
        .follow-us{
            display: flex;
            align-items: start;
            flex-direction: column;
            .icon{
                font-size: 24px;
                color: $primary-color-700;
                
                span{
                    margin-right: 8px;
                    transition: .3 ease;
                    &:hover{
                        color: $accent-color-700;
                        cursor: pointer;
                    }
                }
            }
        }
    }
    @media screen and (max-width: 1024px){
        .footer{
            .logo{
                justify-content: center;
            }
            .link-group{
                justify-content: center;
            }
            .search-bar, .info-group{
                margin-bottom: 30px;
                justify-content: center;
            }
            .follow-us{
                span{
                    margin-bottom: 6px;
                }
                align-items: center;
                justify-content: center;
            }
        }
    }
    @media screen and (max-width: 810px){
        .footer{
            .link-group{
                flex-direction: column;
                gap: 0;
                .login-btn{
                    width: 100%;
                    text-align: center;
                    justify-content: center;
                }
                a{
                    width:100%;
                    justify-content: center;
                    border-bottom: 1px solid $neutral-color-700;
                }
                .login-btn{
                    border-bottom: none;
                }
            }
            .info-group{
                flex-direction: column;
                gap: 0;
                p{
                    margin-bottom:4px;
                }
            }
            
        }
    }
</style>