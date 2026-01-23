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

const searchQuery = ref('');
const currentCategory = ref('');
const rawIngredients = ref([]);
const tempSelected = ref([]);

const categoryMap = {
    'fresh-produce': '新鮮蔬果',
    'fruits': '水果',
    'meat-poultry': '肉類禽類',
    'seafood': '海鮮',
    'dairy-eggs-soy': '蛋豆乳製品',
    'grains-pasta-bakery': '五穀雜糧',
    'condiments-sauces-oils': '調味油品',
    'pantry-spices-nuts': '乾貨香料',
    'others': '其他'
};

const fetchIngredients = async () => {
    try {
        // 1. 使用 publicApi.get 代替原生 fetch
        // 2. Axios 會自動解析 JSON，不需要再執行 .json()
        const res = await publicApi.get('data/recipe/ingredients.json');

        // 3. Axios 的回傳資料會放在 res.data 屬性中
        rawIngredients.value = res.data;

        if (rawIngredients.value.length > 0 && !currentCategory.value) {
            currentCategory.value = rawIngredients.value[0].main_category;
        }
    } catch (error) {
        // 如果 API 報錯（例如 404 或 500），會直接進到這裡
        console.error("食材資料讀取失敗:", error);
    }
};

onMounted(() => {
    fetchIngredients();
});

const categories = computed(() => {
    const allCats = rawIngredients.value.map(item => item.main_category);
    return [...new Set(allCats)];
});

const displayIngredients = computed(() => {
    if (searchQuery.value) {
        return rawIngredients.value.filter(item =>
            item.ingredient_name.includes(searchQuery.value)
        );
    }
    return rawIngredients.value.filter(item => item.main_category === currentCategory.value);
});

// --- 邏輯判斷 ---
const isInParent = (name) => {
    return props.selectedList.some(s => s.name === name || s.ingredient_name === name);
};

const isInTemp = (name) => {
    return tempSelected.value.some(s => s.ingredient_name === name);
};

const handleToggleSelect = (item) => {
    if (isInParent(item.ingredient_name)) return;
    const index = tempSelected.value.findIndex(s => s.ingredient_name === item.ingredient_name);
    if (index > -1) {
        tempSelected.value.splice(index, 1);
    } else {
        tempSelected.value.push(item);
    }
};

const handleClose = () => {
    emit('update:modelValue', false);
    searchQuery.value = '';
    tempSelected.value = [];
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
                <button class="close-x" @click="handleClose" aria-label="Close">×</button>

                <div class="modal-header">
                    <div class="modal-title zh-h4-bold">尋找食材</div>
                    <div class="green-divider"></div>
                </div>

                <div class="search-content">
                    <div class="search-bar search-sm">
                        <i class="fa-solid fa-magnifying-glass icon-search"></i>
                        <input v-model="searchQuery" type="text" class="search-input p-p1"
                            placeholder="搜尋食材名稱 (如：蒜頭)...">
                    </div>

                    <div class="category-tabs">
                        <button v-for="cat in categories" :key="cat" class="tab-btn p-p3"
                            :class="{ active: currentCategory === cat && !searchQuery }"
                            @click="currentCategory = cat; searchQuery = ''">
                            {{ categoryMap[cat] || cat }}
                        </button>
                    </div>

                    <div class="list-container">
                        <div v-for="item in displayIngredients" :key="item.ingredient_id" class="list-item">
                            <div class="item-info">
                                <span class="item-name p-p2">{{ item.ingredient_name }}</span>
                                <span class="item-sub p-p3">
                                    {{ item.kcal_per_100g }} kcal/100g
                                </span>
                            </div>

                            <button class="add-btn p-p3" :class="{
                                'in-temp': isInTemp(item.ingredient_name),
                                'in-parent': isInParent(item.ingredient_name)
                            }" :disabled="isInParent(item.ingredient_name)" @click="handleToggleSelect(item)">

                                <span v-if="isInParent(item.ingredient_name)">已在食譜中</span>
                                <span v-else-if="isInTemp(item.ingredient_name)">✓ 已選取</span>
                                <span v-else>選取</span>
                            </button>
                        </div>

                        <div v-if="displayIngredients.length === 0" class="no-data p-p2">
                            查無相關食材
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
            }

            .item-sub {
                color: $neutral-color-400;
                margin-left: 10px;
                font-size: 12px;
            }
        }

        /* 食材列表旁邊的「選取」按鈕樣式優化 */
        .add-btn {
            background: transparent;
            border: 1px solid $neutral-color-400;
            color: $neutral-color-700;
            padding: 4px 16px;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.2s;
            min-width: 90px;

            &:hover {
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
        }
    }
}

.more-box {
    text-align: center;
    margin-top: 20px;

    .cook-btn {
        padding: 8px 40px;
        cursor: pointer;
        // font-weight: bold;
    }
}

.no-data {
    text-align: center;
    padding: 40px;
    color: $neutral-color-400;
}

/* =========================
   RWD - Mobile only
   ========================= */
@media (max-width: 480px) {
    .modal-card {
        width: 100%;
        max-width: calc(100% - 24px);
        padding: 20px 16px;
        border-radius: 12px;
    }

    .modal-header {
        margin-bottom: 16px;

        .modal-title {
            font-size: 18px;
        }
    }

    .search-bar.search-sm {
        padding: 6px 16px;
        margin-bottom: 16px;

        .search-input {
            font-size: 14px;
        }
    }

    .category-tabs {
        gap: 6px;
        margin-bottom: 16px;

        .tab-btn {
            padding: 4px 10px;
            font-size: 12px;
            border-radius: 6px;
        }
    }

    .list-container {
        max-height: 200px;
    }

    .list-container .list-item {
        padding: 10px 12px;

        .item-info {
            flex: 1;
            min-width: 0;

            .item-name {
                display: block;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }

            .item-sub {
                display: none;
            }
        }

        .add-btn {
            min-width: 72px;
            padding: 4px 10px;
            font-size: 12px;
        }
    }

    .more-box {
        margin-top: 16px;

        .cook-btn {
            width: 100%;
            padding: 10px 0;
        }
    }
}
</style>