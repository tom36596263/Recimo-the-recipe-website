<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import SearchBar from '@/components/common/SearchBar.vue';
import BaseTag from '@/components/common/BaseTag.vue';
import BaseBtn from '@/components/common/BaseBtn.vue';
import CookCard from '@/components/common/CookCard.vue';
import axios from 'axios';
import { publicApi } from '@/utils/publicApi';

const ingredients = ref([]);

onMounted(() => {
    publicApi.get('data/recipe/ingredients.json')
        .then(res => {
            ingredients.value = res.data;
        })
        .catch(err => {
            console.error('讀取 JSON 失敗', err);
        });
});

// --- 標籤設定 ---
const activeTag = ref('蔬菜');
const tags = [
    { text: '蔬菜', value: 'fresh-produce', width: '62px' },
    { text: '水果', value: 'fruits', width: '62px' },
    { text: '肉類', value: 'meat-poultry', width: '62px' },
    { text: '海鮮', value: 'seafood', width: '62px' },
    { text: '乳蛋豆製品', value: 'dairy-eggs-soy', width: '125px' },
    { text: '米麵主食與烘焙 ', value: 'grains-pasta-bakery', width: '150px' },
    { text: '佐料、醬汁與油品', value: 'condiments-sauces-oils', width: '165px' },
    { text: '乾貨、粉類與堅果', value: 'pantry-spices-nuts', width: '165px' }
];
const selectTag = (tagName) => {
    activeTag.value = tagName;
};

//搜尋關鍵字變數
const keyword = ref('');

const filteredIngredients = computed(() => {
    if (!ingredients.value || ingredients.value.length === 0) {
        return [];
    }
    if (keyword.value.trim() !== '') {
        const searchText = keyword.value.trim().toLowerCase();
        return ingredients.value.filter(item => {
            const itemName = item.ingredient_name ? String(item.ingredient_name) : '';
            return itemName.toLowerCase().includes(searchText);
        });
    }
    const currentTagObj = tags.find(tag => tag.text === activeTag.value);
    if (!currentTagObj) return [];

    const targetCategory = currentTagObj.value;

    let results = ingredients.value.filter((item) => {
        return item.main_category === targetCategory;
    });

    if (keyword.value.trim() !== '') {
        const searchText = keyword.value.trim();
        results = results.filter(item => {
            return item.ingredient_name.includes(searchText);
        });
    }
    return results;
});


// 鍋子與拖曳邏輯
const potIngredients = ref([]);
const draggedItem = ref(null);
const isDragOver = ref(false);
const potZoneRef = ref(null); //綁定鍋子 DOM 元素，用於計算座標

// 電腦版滑鼠邏輯 
const handleDragStart = (event, item) => {
    draggedItem.value = item;
    event.dataTransfer.effectAllowed = 'copy';
    event.dataTransfer.setData('text/plain', JSON.stringify(item));
};

const handleDragOver = (event) => {
    event.preventDefault();
    isDragOver.value = true;
};

const handleDragLeave = () => {
    isDragOver.value = false;
};

const handleDrop = (event) => {
    event.preventDefault();
    isDragOver.value = false;
    if (draggedItem.value) {
        addToPot(draggedItem.value);
        draggedItem.value = null;
    }
};

// 平板/手機觸控邏輯
let ghostEl = null; // 用來存儲跟隨手指的暫存 DOM

const handleTouchStart = (event, item) => {
    // 紀錄被拖曳的資料
    draggedItem.value = item;

    // 建立「分身」元素跟隨手指
    const target = event.currentTarget; // 獲取原本的卡片 DOM
    ghostEl = target.cloneNode(true);   // 複製一份

    // 3. 設定分身樣式
    ghostEl.style.position = 'fixed';
    ghostEl.style.zIndex = '9999';
    ghostEl.style.pointerEvents = 'none'; // 讓觸控事件能穿透分身偵測到底下的鍋子
    ghostEl.style.opacity = '0.8';
    ghostEl.style.width = `${target.offsetWidth}px`;
    // ghostEl.style.transform = 'scale()'; // 稍微放大更有感
    ghostEl.style.transition = 'none'; // 移除動畫以免延遲

    // 4. 初始位置
    const touch = event.touches[0];
    updateGhostPosition(touch.clientX, touch.clientY);

    document.body.appendChild(ghostEl);
};

const handleTouchMove = (event) => {
    if (!ghostEl) return;

    // 防止畫面跟著手指捲動 (重要！)
    if (event.cancelable) event.preventDefault();

    const touch = event.touches[0];
    updateGhostPosition(touch.clientX, touch.clientY);

    // 碰撞檢測：檢查手指是否在鍋子範圍內
    checkCollision(touch.clientX, touch.clientY);
};

const handleTouchEnd = (event) => {
    if (!ghostEl) return;

    // 移除分身
    document.body.removeChild(ghostEl);
    ghostEl = null;

    // 如果手指放開時是在鍋子上 (isDragOver 為 true)，則加入食材
    if (isDragOver.value && draggedItem.value) {
        addToPot(draggedItem.value);
    }

    // 重置狀態
    isDragOver.value = false;
    draggedItem.value = null;
};

// 輔助：更新分身位置 (置中於手指)
const updateGhostPosition = (x, y) => {
    if (ghostEl) {
        ghostEl.style.left = `${x - ghostEl.offsetWidth / 2}px`;
        ghostEl.style.top = `${y - ghostEl.offsetHeight / 2}px`;
    }
};

// 輔助：碰撞檢測 (Hit Testing)
const checkCollision = (x, y) => {
    if (!potZoneRef.value) return;

    // 取得鍋子的座標範圍
    const rect = potZoneRef.value.getBoundingClientRect();

    // 判斷手指座標是否在鍋子範圍內
    if (x >= rect.left && x <= rect.right && y >= rect.top && y <= rect.bottom) {
        isDragOver.value = true;
    } else {
        isDragOver.value = false;
    }
};

// 共用邏輯：加入鍋子
const addToPot = (item) => {
    potIngredients.value.push(item);
    console.log('加入鍋子:', item.ingredient_name);
    isDragOver.value = true;
    setTimeout(() => {
        isDragOver.value = false;
    }, 200); // 0.2秒後蓋回去
};


const handleDelete = () => {
    console.log('準備烹飪以下食材:', potIngredients.value);
    alert(`鍋子裡現在有 ${potIngredients.value.length} 個食材！`);
};

// 新增：烹飪狀態
const isCooking = ref(false);
const emit = defineEmits(['cook-finish', 'close']);//送資料
// 新增火焰爆炸狀態變數
const isExploding = ref(false);
//開始烹飪邏輯
const startCooking = () => {
    const count = potIngredients.value.length;

    //沒食材
    if (count === 0) {
        alert('鍋子裡沒有食材喔！');
        return;
    }

    // 啟動烹飪動畫狀態
    isCooking.value = true;

    //判斷食材數量
    if (count > 5) {
        //失敗：食材太多
        isExploding.value = true; // 開啟大火狀態
        console.log('食材太多！火力全開！');

        setTimeout(() => {
            // 3秒後重置
            isCooking.value = false;
            isExploding.value = false; // 關閉大火
            potIngredients.value = []; // 清空鍋子 (回到最一開始狀態)

            alert('歐不！食材太多導致燒焦了，鍋子已清空！');
        }, 2000);

    } else {
        //成功：食材正常 (<=5)
        setTimeout(() => {
            isCooking.value = false;

            // 成功才送出資料
            emit('cook-finish', potIngredients.value);
            emit('close');

            alert(`烹飪完成！使用了 ${count} 個食材，好香啊！`);
            // 成功的鍋子清空由父層決定，或者這裡也可以清空
            potIngredients.value = [];
        }, 2000);
    }
};



</script>

<template>
    <div class="overlay" @click="emit('close')">
        <div class="cook-container" @click.stop>
            <div class="row">
                <div class="col-7">
                    <div class="title">
                        <h3 class="zh-h3 title">靈感廚房</h3>
                    </div>
                    <div class="cook-wrap">
                        <div class="cook-stage" ref="potZoneRef" :class="{ 'active-drop-zone': isDragOver }"
                            @dragover="handleDragOver" @dragleave="handleDragLeave" @drop="handleDrop">

                            <div v-if="potIngredients.length > 0" class="count-badge">
                                {{ potIngredients.length }}
                            </div>
                            <div class="lid" :class="{ 'lid-open': isDragOver, 'lid-boiling': isCooking }">
                                <img src="/src/assets/images/cook/lid.png" alt="">
                            </div>
                            <div class="pot" :class="{ 'shaking': isCooking }">
                                <img src="/src/assets/images/cook/pot.png" alt="">
                            </div>
                            <div class="fire"
                                :class="{ 'cooking-fire': isCooking && !isExploding, 'big-fire': isExploding }">
                                <img src="/src//assets/images/cook/fire.png" alt="">
                            </div>
                        </div>
                        <div class="btn">
                            <BaseBtn :title="isCooking ? '烹飪中' : '開始烹飪'" @click="startCooking" :disabled="isCooking" />
                            <!-- :disabled當這個條件成立時，讓按鈕失效（不能按） -->
                        </div>
                    </div>
                </div>


                <div class="col-5 search-wrap">
                    <div class="close" @click="emit('close')">
                        <i class="fa-solid fa-xmark"></i>
                    </div>
                    <div class="search">
                        <SearchBar v-model="keyword" placeholder="搜尋食譜" style="width: 270px;" />
                    </div>
                    <div class="tag">
                        <BaseTag v-for="item in tags" :key="item.text" :text="item.text" :width="item.width"
                            :show-icon="false" :variant="activeTag === item.text ? 'primary' : 'action'"
                            @click="selectTag(item.text)"></BaseTag>
                    </div>
                    <div class="card-container">
                        <div v-for="item in filteredIngredients" :key="item.ingredient_id"
                            class="draggable-card-wrapper" draggable="true" @dragstart="handleDragStart($event, item)"
                            @touchstart="handleTouchStart($event, item)" @touchmove="handleTouchMove"
                            @touchend="handleTouchEnd">

                            <CookCard :name="item.ingredient_name" :calories="item.kcal_per_100g"
                                :fat="item.fat_per_100g" :image-src="item.ingredient_image_url"
                                @add-ingredient="addToPot(item)" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>



</template>

<style lang="scss" scoped>
.overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background-color: rgba(0, 0, 0, 0.5);
    z-index: 1000;
    display: flex;
    justify-content: center;
    align-items: center;
    // 防止背景捲動 (選用，視專案需求)
    backdrop-filter: blur(4px);
    z-index: 9999 !important;
}

.cook-container {
    width: 790px;
    height: 487px;
    background-color: $neutral-color-white;
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
}

.row {
    height: 100%;
}

.cook-wrap {
    display: flex;
    flex-direction: column;
    align-items: center;
    position: relative;
}

.title {
    margin-left: 20px;
    margin-top: 20px;
    margin-bottom: 39px;
    color: $primary-color-700;
}

.cook-stage {
    position: relative;
    width: 100%;
    height: 260px;
    margin-left: 250px;
    margin-top: 40px;
    transition: transform 0.2s ease, filter 0.2s;

    &.active-drop-zone {
        transform: scale(1.02);
        filter: drop-shadow(0 0 8px $accent-color-400);
        cursor: copy;
    }
}

.count-badge {
    position: absolute;
    top: 50px;
    left: 80px;
    background-color: $secondary-color-danger-700;
    color: $neutral-color-white;
    width: 30px;
    height: 30px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    z-index: 10;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
}


.lid {
    position: absolute;
    top: 23px;
    left: 39px;
    width: 150px;
    height: 30px;
    transform: rotate(18deg);

    transform-origin: center right; // 設定旋轉的支點在右下角
    transition: transform 0.3s cublic-bezizer(0.25, 0.8, 0.5, 1); //讓掀開過程有 0.3秒 的滑順感
    z-index: 5;

    &.lid-open {
        transform: rotate(30deg) translate(5px, -40px); // translate(10px, -40px): 往右上方移動
    }

    &.lid-boiling {
        animation: lid-jump 0.4s infinite linear;
    }
}

@keyframes lid-jump {
    0% {
        // 維持原本的 18度
        transform: rotate(18deg) translate(0, 0);
    }

    25% {
        // 往上頂一下 (Y軸負值是往上)
        transform: rotate(18deg) translate(2px, -4px);
    }

    50% {
        // 稍微歪一點點，像氣體衝出來
        transform: rotate(20deg) translate(0, -2px);
    }

    75% {
        transform: rotate(18deg) translate(-1px, -3px);
    }

    100% {
        transform: rotate(18deg) translate(0, 0);
    }
}

.pot {
    position: absolute;
    top: 70px;
    left: -80px;
    width: 300px;
    height: 150px;

    &.shaking {
        animation: pot-shake 0.5s infinite linear;
    }
}

@keyframes pot-shake {
    0% {
        transform: rotate(0deg);
    }

    25% {
        transform: rotate(1deg);
    }

    75% {
        transform: rotate(-1deg);
    }

    100% {
        transform: rotate(0deg);
    }
}

.fire {
    position: absolute;
    top: 130px;
    left: -20px;
    width: 240px;
    height: 80px;
    transform-origin: bottom center;
    transition: transform 0.3s; // 讓開始和結束時有過渡

    &.cooking-fire {
        animation: flicker 0.8s infinite ease-in-out;
        // 0.8s: 一次動畫的時間 
        // infinite: 無限循環
        // ease-in-out: 速度曲線
    }

    &.big-fire {
        animation: explosion 0.4s infinite linear;
        width: 300px;
        left: 0px;
        z-index: 20;
    }
}

@keyframes flicker {
    0% {
        transform: scale(1) translateY(0);
    }

    50% {
        transform: scale(1.1) translateY(-2px);
        filter: brightness(120%) drop-shadow(0 0 10px rgba(255, 100, 0, 0.6))
    }

    //filter可以在不修改圖片原始檔案的情況下，直接用程式碼改變元素的視覺效果。

    100% {
        transform: scale(1) translateY(0);
        filter: brightness(100%);
    }
}

@keyframes explosion {
    0% {
        transform: scale(1.1) translateY(0);
        filter: brightness(150%) hue-rotate(-10deg);
    }

    25% {
        transform: scale(1.3) translateY(-5px) rotate(2deg);
    }

    50% {
        transform: scale(1.5) translateY(-10px);
        filter: brightness(200%) drop-shadow(0 0 20px rgba(255, 50, 0, 0.9));
    }

    75% {
        transform: scale(1.3) translateY(-5px) rotate(-2deg);
    }

    100% {
        transform: scale(1.1) translateY(0);
        filter: brightness(150%) hue-rotate(-10deg);
    }
}

.search-wrap {
    background-color: $neutral-color-100;
    display: flex;
    flex-direction: column;
    align-items: center;
    overflow: hidden;
    height: 100%;
}

.close {
    margin-right: -280px;
    margin-top: 10px;
    margin-bottom: -10px;
    cursor: pointer;
}

.search {
    margin: 15px 0;
}

.tag {
    display: flex;
    gap: 8px;
    width: 100%;
    overflow-x: auto;
    overflow-y: hidden;
    padding: 0 20px 10px 20px;
    padding-bottom: 10px;
    user-select: none;
    -webkit-user-select: none;
    touch-action: pan-x;
    overscroll-behavior: contain;

    >* {
        flex-shrink: 0;
        pointer-events: auto;
    }
}

.card-container {
    margin-top: 15px;
    width: 100%;
    flex: 1;
    overflow-y: auto;
    padding: 20px;
}
</style>