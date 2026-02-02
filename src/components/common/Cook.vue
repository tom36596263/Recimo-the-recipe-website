<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import SearchBar from '@/components/common/SearchBar.vue';
import BaseTag from '@/components/common/BaseTag.vue';
import BaseBtn from '@/components/common/BaseBtn.vue';
import CookCard from '@/components/common/CookCard.vue';
import axios from 'axios';
// import { publicApi } from '@/utils/publicApi';
import { phpApi } from '@/utils/publicApi';

const ingredients = ref([]);

onMounted(() => {
    phpApi.get('recipes/user_ingredients.php')
        .then(res => {
            let responseData = res.data;

            // --- 關鍵修正：如果是字串，手動轉成物件 ---
            if (typeof responseData === 'string') {
                try {
                    responseData = JSON.parse(responseData);
                } catch (e) {
                    console.error("JSON 解析失敗，內容可能包含非 JSON 文字", responseData);
                }
            }

            if (responseData && responseData.status === 'success') {
                ingredients.value = responseData.data;
                console.log('成功載入食材陣列:', ingredients.value);
            } else {
                console.error('API 回傳錯誤:', responseData ? responseData.message : '未知錯誤');
            }
        })
        .catch(err => {
            console.error('連線失敗', err);
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
    // 1. 防呆：如果原本就沒資料，回傳空陣列
    if (!ingredients.value || ingredients.value.length === 0) {
        return [];
    }

    let results = [];

    // 2. 第一層篩選：決定是「搜尋模式」還是「分類模式」
    if (keyword.value.trim() !== '') {
        // --- A. 搜尋模式：無視分類，搜尋全部 ---
        const searchText = keyword.value.trim().toLowerCase();
        results = ingredients.value.filter(item => {
            const itemName = item.ingredient_name ? String(item.ingredient_name) : '';
            return itemName.toLowerCase().includes(searchText);
        });
    } else {
        // --- B. 分類模式：依照上方標籤 (activeTag) ---
        const currentTagObj = tags.find(tag => tag.text === activeTag.value);

        // 確保有找到對應的標籤設定
        if (currentTagObj) {
            const targetCategory = currentTagObj.value;
            results = ingredients.value.filter(item => {
                return item.main_category === targetCategory;
            });
        }
    }

    // 3. 第二層篩選：把「已經在鍋子裡」的扣掉
    // 這裡會檢查 potIngredients 陣列，如果 ID 一樣就不顯示
    return results.filter(item => {
        const isInPot = potIngredients.value.some(potItem => {
            // 請特別注意：這裡假設你的 JSON 資料欄位名稱是 ingredient_id
            return potItem.ingredient_id === item.ingredient_id;
        });
        // 回傳 !isInPot (如果「不在」鍋子裡，才要顯示)
        return !isInPot;
    });
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
// 平板/手機拖曳
let ghostEl = null;
let isDragging = false;
let startX = 0;
let startY = 0;

const handleTouchStart = (e, item) => {
    const touch = e.touches[0];
    startX = touch.clientX;
    startY = touch.clientY;
    draggedItem.value = item;
    isDragging = false; // 初始不是拖曳
};

const handleTouchMove = (e) => {
    if (!draggedItem.value) return;
    const touch = e.touches[0];
    const deltaX = Math.abs(touch.clientX - startX);
    const deltaY = Math.abs(touch.clientY - startY);

    // 如果移動距離超過 10px 才認定拖曳
    if (!isDragging && (deltaX > 10 || deltaY > 10)) {
        isDragging = true;

        // 建立分身
        const target = e.currentTarget;
        ghostEl = target.cloneNode(true);
        ghostEl.style.position = 'fixed';
        ghostEl.style.zIndex = '9999';
        ghostEl.style.pointerEvents = 'none';
        ghostEl.style.opacity = '0.8';
        ghostEl.style.width = `${target.offsetWidth}px`;
        ghostEl.style.transition = 'none';
        document.body.appendChild(ghostEl);
    }

    // 只有真的拖曳才阻止滾動
    if (isDragging && e.cancelable) e.preventDefault();

    if (isDragging) {
        updateGhostPosition(touch.clientX, touch.clientY);
        checkCollision(touch.clientX, touch.clientY);
    }
};

const handleTouchEnd = () => {
    if (ghostEl) {
        document.body.removeChild(ghostEl);
        ghostEl = null;
    }
    if (isDragOver.value && draggedItem.value) addToPot(draggedItem.value);
    draggedItem.value = null;
    isDragging = false;
    isDragOver.value = false;
};

// ghostEl位置
const updateGhostPosition = (x, y) => {
    if (ghostEl) {
        ghostEl.style.left = `${x - ghostEl.offsetWidth / 2}px`;
        ghostEl.style.top = `${y - ghostEl.offsetHeight / 2}px`;
    }
};

// 碰撞檢測
const checkCollision = (x, y) => {
    if (!potZoneRef.value) return;
    const rect = potZoneRef.value.getBoundingClientRect();
    isDragOver.value = x >= rect.left && x <= rect.right && y >= rect.top && y <= rect.bottom;
};

// 加入鍋子
const addToPot = item => {
    if (potIngredients.value.length >= 8) {
        alert('鍋子已經滿了！最多只能放 8 個食材喔！');

        // 拖曳結束的狀態重置一下，避免卡住
        draggedItem.value = null;
        isDragOver.value = false;
        return; // 直接結束，不執行下面的 push
    }


    potIngredients.value.push(item);
    draggedItem.value = null;
    setTimeout(() => isDragOver.value = false, 200);
};


const handleDelete = () => {
    console.log('準備烹飪以下食材:', potIngredients.value);
    alert(`鍋子裡現在有 ${potIngredients.value.length} 個食材！`);
};

//烹飪狀態
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

        <div class="orientation-lock" @click.stop>
            <div class="phone-icon">
                <i class="fa-solid fa-mobile-screen-button"></i>
            </div>
            <p>為了最佳體驗<br>請將手機轉為橫向</p>
            <BaseBtn class="close-warning-btn" @click="emit('close')" title="關閉靈感廚房" />

        </div>

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

                            <TransitionGroup name="fade-drop" tag="div" class="floating-ingredients-container">
                                <img v-for="(item, index) in potIngredients" :key="item.ingredient_id"
                                    :src="$parsePublicFile(item.ingredient_image_url)" alt=""
                                    class="floating-ingredient-item" :class="{ 'falling-in': isCooking }"
                                    :style="{ '--i': index }">
                            </TransitionGroup>

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
                        <SearchBar v-model="keyword" placeholder="搜尋食材" style="width: 270px;" />
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
                                :fat="item.fat_per_100g" :image-src="$parsePublicFile(item.ingredient_image_url)"
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
    border-radius: $radius-base;
    overflow: hidden;

    // transform-origin: center center;
    // transition: transform 0.3s ease;

    .cook-wrap {
        display: flex;
        flex-direction: column;
        align-items: center;
        position: relative;
    }

}

@media screen and (max-height: 500px) {
    .cook-container {
        width: 90%;
        height: 100%;

    }

}

@media screen and (max-height: 400px) {
    .cook-container {
        width: 100%;
        height: 100%;

    }

}


/* 1. 平板且直向 (portrait) */
@media screen and (max-width: 810px) and (orientation: portrait) {

    // 隱藏真正的廚房
    .cook-content-wrapper {
        display: none !important;
    }

    // 顯示轉向提示
    .orientation-lock {
        display: flex !important;
    }
}

// /* 2. 手機橫向 (landscape) 且高度較小 (通常手機橫向高度 < 500px) */
// @media screen and (max-height: 500px) and (orientation: landscape) {
//     .orientation-lock {
//         display: none !important;
//     }

//     .cook-content-wrapper {
//         display: block !important;
//         /* 自動縮放：如果手機橫向寬度不夠 790px，將整個廚房縮小 */
//         transform: scale(0.1);
//         box-shadow: 0 0 0 100vmax rgba(0, 0, 0, 0.8); // 加深背景讓視線集中
//     }
// }

// /* 針對特別小的手機橫向 (例如 iPhone SE 橫向) */
// @media screen and (max-width: 810px) and (orientation: landscape) {
//     .cook-content-wrapper {
//         transform: scale(0.65);
//         /* 縮得更小一點 */
//     }
// }

.row {
    height: 100%;
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



@media screen and (max-height: 390px) {
    .cook-stage {
        transform: scale(0.8);
        margin-right: 50px;
        margin-top: -2px;
    }

    .btn {
        margin-top: -20px;
    }
}


@media screen and (max-height: 430px) {
    .cook-stage {
        transform: scale(0.9);
        margin-right: 30px;
    }

    .btn {
        margin-top: -15px;
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
    flex: 1 1 auto;
    overflow-y: auto;
    -webkit-overflow-scrolling: touch; // 平滑滾動
    max-height: calc(100% - 150px);
    padding: 0 20px 20px 20px;
}

// 1. 容器定位
.floating-ingredients-container {
    position: absolute;
    top: 60px; // 大約在鍋口的位置
    left: 50%;
    transform: translateX(-50%);
    width: 180px; // 比鍋身稍微窄一點
    height: 60px;
    z-index: 3; // 重點：介於鍋蓋(5)和鍋身(預設0)之間
    pointer-events: none; // 避免擋住滑鼠操作
}

// 2. 個別食材圖片樣式
.floating-ingredient-item {
    position: absolute;
    width: 45px; // 設定一個合適的大小
    height: 45px;
    border-radius: 50%;
    object-fit: contain;
    // top: 50px;
    // // left: 50%;
    margin-left: -22.5px; // width 的一半，用來居中
    filter: drop-shadow(0 1px 2px rgba(0, 0, 0, 0.1)); // 加一點陰影更有立體感

    // 利用 nth-child 加上 CSS 變數，讓前5個食材位置稍微錯開
    // 這裡設定簡單的左右交錯和旋轉，看起來比較自然
    &:nth-child(1) {
        top: -100px;
        left: -120%;
        transform: rotate(-20deg);
    }

    &:nth-child(2) {
        top: -100px;
        left: -90%;
        transform: rotate(-10deg);
        z-index: 2;
    }

    &:nth-child(3) {
        top: -100px;
        left: -60%;
        transform: rotate(5deg);
        z-index: 3;
    }

    // 疊在最上面
    &:nth-child(4) {
        top: -100px;
        left: -30%;
        transform: rotate(-25deg);
    }

    &:nth-child(5) {
        top: -100px;
        left: 0%;
        transform: rotate(20deg);
        z-index: 1;
    }

    // 超過5個的就隨意一點(雖然你的邏輯也會擋住)
    &:nth-child(n+6) {
        top: -100px;
        left: 30%;
        opacity: 0.8;
    }

    &:nth-child(n+7) {
        top: -100px;
        left: 60%;
        opacity: 0.8;
    }

    &:nth-child(n+8) {
        top: -100px;
        left: 90%;
        opacity: 0.8;
    }
}


// 定義進入前和離開後的狀態 (起始點)
.fade-drop-enter-from,
.fade-drop-leave-to {
    opacity: 0;
    transform: translateY(-30px) scale(0.5) !important;
}

.falling-in {
    left: 50% !important;
    transform: translateX(-50%) translateY(120px) scale(0.2) !important;
    opacity: 0 !important;
    transition: all 0.3s cubic-bezier(0.55, 0.055, 0.675, 0.3);
    transition-delay: calc(var(--i) * 0.1s);
}

.orientation-lock {
    display: none; // 預設隱藏
    flex-direction: column;
    align-items: center;
    justify-content: center;
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background-color: rgba(50, 50, 50, 0.95);
    z-index: 10001;
    color: #fff;
    text-align: center;
    backdrop-filter: blur(10px);

    p {
        margin-top: 20px;
        font-size: 1.2rem;
        line-height: 1.6;
        letter-spacing: 1.5px;
    }

    .phone-icon {
        font-size: 3rem;
        animation: rotate-device 2s infinite ease-in-out;
    }

    .close-warning-btn {
        margin-top: 30px;
        background: transparent;
        border: 1px solid #fff;
        color: #fff;
        padding: 8px 20px;
        border-radius: 50px;
        cursor: pointer;
        transition: 0.3s;

        &:hover {
            background: #fff;
            color: #333;
        }
    }
}

@keyframes rotate-device {
    0% {
        transform: rotate(0deg);
    }

    30% {
        transform: rotate(0deg);
    }

    50% {
        transform: rotate(-90deg);
    }

    80% {
        transform: rotate(-90deg);
    }

    100% {
        transform: rotate(0deg);
    }
}
</style>