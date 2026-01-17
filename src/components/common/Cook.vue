<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import SearchBar from '@/components/common/SearchBar.vue';
import CookCard from '@/components/common/CookCard.vue';
// --- 標籤設定 ---
const tags = [
    { text: '蔬菜', width: '62px' },
    { text: '水果', width: '62px' },
    { text: '肉類', width: '62px' },
    { text: '海鮮', width: '62px' },
    { text: '乳蛋豆製品', width: '125px' },
    { text: '米麵主食與烘焙 ', width: '150px' },
    { text: '佐料、醬汁與油品', width: '165px' },
    { text: '乾貨、粉類與堅果', width: '165px' }
];
</script>
<template>
    <div class="container">
        <div class="row">
            <div class="col-6">
                <div class="cook-wrap">
                    <div class="title">
                        <h3 class="zh-h3">靈感廚房</h3>
                    </div>
                    <div class="lid">
                        <img src="/src/assets/images/cook/lid.png" alt="">
                    </div>
                    <div class="pot">
                        <img src="/src/assets/images/cook/pot.png" alt="">
                    </div>
                    <div class="fire">
                        <img src="/src//assets/images/cook/fire.png" alt="">
                    </div>
                    <div class="fire">
                        <img src="" alt="">
                    </div>

                    <div class="btn">
                        <BaseBtn title="開始烹飪" @click="handleDelete" />
                    </div>

                </div>

            </div>
            <div class="col-6">
                <div class="search-wrap">
                    <div class="close">

                    </div>
                    <div class="search">
                        <SearchBar placeholder="搜尋食譜" style="width: 270px;" />
                    </div>
                    <div class="tag">
                        <BaseTag v-for="item in tags" :key="item.text" :text="item.text" :width="item.width"
                            :show-icon="false" :variant="activeTag === item.text ? 'primary' : 'action'"
                            @click="selectTag(item.text)"></BaseTag>
                    </div>
                    <div class="card-container">
                        <CookCard />
                    </div>
                </div>

            </div>
        </div>
    </div>
</template>