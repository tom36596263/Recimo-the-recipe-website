<script setup>
import { ref, computed, onMounted } from 'vue';
import { publicApi } from '@/utils/publicApi';

const props = defineProps({
    modelValue: Boolean,
    selectedList: {
        type: Array,
        default: () => []
    }
});

const emit = defineEmits(['update:modelValue', 'add-multiple']);

// --- 數量限制設定 ---
const MAX_TAGS = 3;

const searchQuery = ref('');
const currentCategory = ref('全部');
const rawTags = ref([]);
const tempSelected = ref([]);

// 抓取資料 (省略重複部分...)
const fetchTags = async () => {
    try {
        const res = await publicApi.get('data/recipe/tags.json');
        rawTags.value = res.data || [];
    } catch (error) {
        console.error("標籤資料讀取失敗:", error);
    }
};

onMounted(() => { fetchTags(); });

// 自動提取分類 (省略重複部分...)
const categories = computed(() => {
    const types = rawTags.value.map(item => item.tag_type);
    return ['全部', ...new Set(types)];
});

// 搜尋與過濾 (省略重複部分...)
const displayTags = computed(() => {
    let list = rawTags.value;
    if (searchQuery.value) {
        return list.filter(item => item.tag_name.toLowerCase().includes(searchQuery.value.toLowerCase()));
    }
    if (currentCategory.value !== '全部') {
        list = list.filter(item => item.tag_type === currentCategory.value);
    }
    return list;
});

// --- 核心邏輯：數量判斷 ---
// 計算「已在頁面上的」+「在燈箱剛選的」總數
const totalCount = computed(() => props.selectedList.length + tempSelected.value.length);

const isInParent = (id) => props.selectedList.some(s => Number(s.tag_id) === Number(id));
const isInTemp = (id) => tempSelected.value.some(s => Number(s.tag_id) === Number(id));

const handleToggleSelect = (item) => {
    if (isInParent(item.tag_id)) return;

    const index = tempSelected.value.findIndex(s => Number(s.tag_id) === Number(item.tag_id));

    if (index > -1) {
        // 如果已經在暫選清單，就移除 (取消選取不受限)
        tempSelected.value.splice(index, 1);
    } else {
        // ✨ 新增標籤前，先檢查是否滿額
        if (totalCount.value >= MAX_TAGS) {
            alert(`標籤數量已達上限 ${MAX_TAGS} 個囉！`);
            return;
        }
        tempSelected.value.push(item);
    }
};

const handleClose = () => {
    emit('update:modelValue', false);
    searchQuery.value = '';
    tempSelected.value = [];
    currentCategory.value = '全部';
};

const handleConfirm = () => {
    if (tempSelected.value.length === 0) {
        handleClose();
        return;
    }
    emit('add-multiple', [...tempSelected.value]);
    handleClose();
};
</script>

<template>
    <Teleport to="body">
        <div v-if="modelValue" class="black-mask" @click.self="handleClose">
            <div class="modal-card">
                <button class="close-x" @click="handleClose">×</button>

                <div class="modal-header">
                    <div class="modal-title zh-h4-bold">
                        選擇食譜標籤 <span class="count-hint p-p3">({{ totalCount }}/{{ MAX_TAGS }})</span>
                    </div>
                    <div class="green-divider"></div>
                </div>

                <div class="search-content">
                    <div class="search-bar search-sm">
                        <i class="fa-solid fa-magnifying-glass icon-search"></i>
                        <input v-model="searchQuery" type="text" class="search-input p-p1" placeholder="搜尋標籤名稱...">
                    </div>

                    <div class="category-tabs">
                        <button v-for="cat in categories" :key="cat" class="tab-btn p-p3"
                            :class="{ active: currentCategory === cat && !searchQuery }"
                            @click="currentCategory = cat; searchQuery = ''">
                            {{ cat }}
                        </button>
                    </div>

                    <div class="list-container">
                        <div v-for="item in displayTags" :key="item.tag_id" class="list-item">
                            <div class="item-info">
                                <span class="item-name p-p2"># {{ item.tag_name }}</span>
                                <span class="item-sub p-p3">{{ item.tag_type }}</span>
                            </div>

                            <button class="add-btn p-p3" :class="{
                                'in-temp': isInTemp(item.tag_id),
                                'in-parent': isInParent(item.tag_id),
                                'is-full': totalCount >= MAX_TAGS && !isInTemp(item.tag_id) && !isInParent(item.tag_id)
                            }" :disabled="isInParent(item.tag_id)" @click="handleToggleSelect(item)">
                                <span v-if="isInParent(item.tag_id)">已在食譜中</span>
                                <span v-else-if="isInTemp(item.tag_id)">✓ 已選取</span>
                                <span v-else>選取</span>
                            </button>
                        </div>
                    </div>

                    <div class="info-right more-box">
                        <BaseBtn :title="`確認新增 (${tempSelected.length})`" :width="200" @click="handleConfirm"
                            class="cook-btn" />
                    </div>
                </div>
            </div>
        </div>
    </Teleport>
</template>

<style scoped lang="scss">
@import '@/assets/scss/abstracts/_color.scss';

.black-mask {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 2000;
}

.modal-card {
    background: $neutral-color-white;
    width: 540px;
    height: auto;
    max-width: calc(100% - 40px);
    border-radius: 16px;
    padding: 30px;
    position: relative;
    box-shadow: 0 8px 30px rgba(0, 0, 0, 0.15);
    display: flex;
    flex-direction: column;

    .close-x {
        position: absolute;
        top: 15px;
        right: 20px;
        background: none;
        border: none;
        font-size: 24px;
        color: $neutral-color-700;
        cursor: pointer;

        &:hover {
            color: $neutral-color-black;
        }
    }
}

.modal-header {
    margin-bottom: 20px;

    .modal-title {
        color: $primary-color-700;
        margin-bottom: 12px;
        display: flex;
        align-items: baseline;
        gap: 8px;

        // 數量提示小字
        .count-hint {
            color: $neutral-color-400;
            font-weight: normal;
        }
    }

    .green-divider {
        height: 1px;
        background: $primary-color-400;
    }
}

.search-bar.search-sm {
    display: flex;
    align-items: center;
    background: $neutral-color-white;
    border: 1.5px solid $primary-color-700;
    border-radius: 30px;
    padding: 8px 20px;
    margin-bottom: 20px;
    width: 100%;
    box-sizing: border-box;

    .icon-search {
        color: $neutral-color-700;
        margin-right: 12px;
        font-size: 16px;
    }

    .search-input {
        flex: 1;
        border: none;
        outline: none;
        background: transparent;
        color: $neutral-color-black;

        &::placeholder {
            color: $neutral-color-400;
        }
    }
}

.category-tabs {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-bottom: 20px;

    .tab-btn {
        background: $primary-color-100;
        border: none;
        border-radius: 8px;
        padding: 6px 16px;
        color: $neutral-color-800;
        cursor: pointer;
        transition: 0.2s;

        &:hover {
            background: $primary-color-400;
            color: $neutral-color-white;
        }

        &.active {
            background: $primary-color-700;
            color: $neutral-color-white;
        }
    }
}

.list-container {
    border: 1px solid $neutral-color-100;
    border-radius: 8px;
    max-height: 300px;
    overflow-y: auto;

    .list-item {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 12px 20px;
        border-bottom: 1px solid $neutral-color-100;

        &:last-child {
            border-bottom: none;
        }

        .item-info {
            display: flex;
            align-items: baseline;

            .item-name {
                color: $neutral-color-black;
                font-weight: 500;
            }

            .item-sub {
                color: $neutral-color-400;
                margin-left: 10px;
                font-size: 12px;
            }
        }

        .add-btn {
            background: transparent;
            border: 1px solid $neutral-color-400;
            color: $neutral-color-700;
            padding: 4px 16px;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.2s;
            min-width: 90px;

            &:hover:not(:disabled) {
                border-color: $primary-color-700;
                color: $primary-color-700;
            }

            &.in-temp {
                background: $primary-color-700;
                color: $neutral-color-white;
                border: none;
            }

            &.in-parent {
                background: $neutral-color-100;
                color: $neutral-color-400;
                border: 1px solid $neutral-color-100;
                cursor: not-allowed;
            }

            // 當數量滿額時，未選取的按鈕樣式
            &.is-full {
                opacity: 0.5;
                cursor: not-allowed;

                &:hover {
                    color: $neutral-color-700;
                    border-color: $neutral-color-400;
                }
            }
        }
    }
}

.more-box {
    text-align: center;
    margin-top: 20px;
}

.no-data {
    text-align: center;
    padding: 40px;
    color: $neutral-color-400;
}

/* RWD 同步食材燈箱邏輯 */
@media (max-width: 480px) {
    .modal-card {
        padding: 20px 16px;
    }

    .category-tabs {
        gap: 6px;

        .tab-btn {
            padding: 4px 10px;
            font-size: 12px;
        }
    }

    .list-container {
        max-height: 200px;

        .list-item {
            padding: 10px 12px;

            .item-info .item-sub {
                display: none;
            }

            .add-btn {
                min-width: 72px;
                font-size: 12px;
            }
        }
    }
}
</style>