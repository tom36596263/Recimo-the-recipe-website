<script setup>
import { ref, watch, onMounted, onUnmounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { Swiper, SwiperSlide } from 'swiper/vue';
import { Navigation, FreeMode } from 'swiper/modules';
import 'swiper/css';
import 'swiper/css/navigation';
import 'swiper/css/free-mode';
import OrderCard from '../../components/mall/CheckCard.vue';
import CheckCard from '../../components/mall/CheckCard.vue';

// Swiper 模組
const swiperModules = [Navigation, FreeMode];

// 控制方向與滑動模式
const direction = ref('horizontal');
const freeMode = ref(true);
const slidesPerView = ref('auto'); // 平板改 1

const updateSwiperMode = () => {
  const width = window.innerWidth;
  if (width >= 1024) {
    direction.value = 'vertical';
    freeMode.value = false; // 桌機卷軸
    slidesPerView.value = 'auto';
  } else {
    // 手機 & 平板都水平滑動
    direction.value = 'horizontal';
    freeMode.value = true;
    slidesPerView.value = 'auto';
  }
};

onMounted(() => {
  updateSwiperMode();
  window.addEventListener('resize', updateSwiperMode);
});

onUnmounted(() => {
  window.removeEventListener('resize', updateSwiperMode);
});

const orderItems = ref([
  {
    id: 101, // 訂單項目的唯一 ID (隨便寫)
    productId: 1, // ⚠️ 重要：這裡必須對應你 products.json 裡面有的 ID
    quantity: 3, // 數量
    price: 480
  },
  {
    id: 102,
    productId: 2, // ⚠️ 這裡也要確認 json 裡有 ID 為 2 的商品
    quantity: 1,
    price: 220
  },
  {
    id: 103,
    productId: 3, // ⚠️ 這裡也要確認 json 裡有 ID 為 2 的商品
    quantity: 1,
    price: 180
  }
]);

const router = useRouter();

// 資料打包
const form = ref({
  // 訂購人
  name: '',
  phone: '',
  email: '',
  home: '', // 非必填
  adress: '',

  // 宅配收件人
  addname: '',
  addphone: '',
  addhome: '', // 非必填
  addadress: '',

  // 信用卡
  cardnum1: '',
  cardnum2: '',
  cardnum3: '',
  cardnum4: '',
  expire: '', // 對應有效期限
  cvc: '',

  // 雖然模板是用 num 和 savenum，建議這邊統一對應
  num: '', // 有效期限 (MM/YY)
  savenum: '', // 安全碼 (CVC)

  // 狀態控制
  shippingType: '', // 'new' 或 'same'
  paymentMethod: '' // 'card' 或 'cod'
});

const errors = ref({});

// --- 監聽邏輯 (保持不變) ---
watch(
  () => form.value.shippingType,
  (val) => {
    if (val === 'same') {
      form.value.addname = form.value.name;
      form.value.addphone = form.value.phone;
      form.value.addhome = form.value.home;
      form.value.addadress = form.value.adress;
    } else if (val === 'new') {
      form.value.addname = '';
      form.value.addphone = '';
      form.value.addhome = '';
      form.value.addadress = '';
    }
  }
);

watch(
  () => form.value.paymentMethod,
  (val) => {
    if (val === 'cod') {
      errors.value.cardnum1 = '';
      errors.value.cardnum2 = '';
      errors.value.cardnum3 = '';
      errors.value.cardnum4 = '';
      errors.value.num = '';
      errors.value.savenum = '';
    }
  }
);

// --- 驗證邏輯 (已排除家用電話) ---
const validateField = (field) => {
  // 先清除該欄位舊錯誤
  errors.value[field] = '';

  // 1. 訂購人必填檢查 (跳過 home)
  if (field === 'name' && !form.value.name) errors.value.name = '請輸入姓名';
  if (field === 'phone') {
    if (!form.value.phone) errors.value.phone = '請輸入手機號碼';
    else if (!/^09\d{8}$/.test(form.value.phone))
      errors.value.phone = '手機格式錯誤';
  }
  if (field === 'email') {
    if (!form.value.email) errors.value.email = '請輸入 Email';
    else if (!form.value.email.includes('@'))
      errors.value.email = 'Email 格式錯誤';
  }
  if (field === 'adress' && !form.value.adress)
    errors.value.adress = '請輸入地址';

  // 2. 宅配收件人必填檢查 (跳過 addhome)
  // 只要有選配送方式(不管是同訂購人還是新增)，這些欄位都必須有值
  if (form.value.shippingType) {
    if (field === 'addname' && !form.value.addname)
      errors.value.addname = '請輸入收件人';
    if (field === 'addadress' && !form.value.addadress)
      errors.value.addadress = '請輸入地址';
    if (field === 'addphone') {
      if (!form.value.addphone) errors.value.addphone = '請輸入手機';
      else if (!/^09\d{8}$/.test(form.value.addphone))
        errors.value.addphone = '格式錯誤';
    }
  }

  // 3. 信用卡必填檢查
  if (form.value.paymentMethod === 'card') {
    if (field.includes('cardnum') && !form.value[field])
      errors.value[field] = '必填';
    if (field === 'num' && !form.value.num) errors.value.num = '必填';
    if (field === 'savenum' && !form.value.savenum)
      errors.value.savenum = '必填';
  }
};

// --- 送出按鈕 (檢查所有必填) ---
const handleDelete = () => {
  // 1. 觸發 [訂購人] 必填驗證 (不包含 home)
  validateField('name');
  validateField('phone');
  validateField('email');
  validateField('adress');

  // 2. 觸發 [宅配] 必填驗證 (如果有選配送方式)
  if (form.value.shippingType) {
    validateField('addname');
    validateField('addphone');
    // validateField('addhome'); // 這行故意註解掉，不檢查家用電話
    validateField('addadress');
  }

  // 3. 觸發 [信用卡] 必填驗證 (如果有選信用卡)
  if (form.value.paymentMethod === 'card') {
    validateField('cardnum1');
    validateField('cardnum2');
    validateField('cardnum3');
    validateField('cardnum4');
    validateField('num');
    validateField('savenum');
  }

  // 4. 總檢查
  const hasError = Object.values(errors.value).some((msg) => msg !== '');

  if (hasError) {
    alert('資料填寫有誤，請檢查紅色欄位');
  } else if (!form.value.shippingType) {
    alert('請選擇宅配地址方式');
  } else if (!form.value.paymentMethod) {
    alert('請選擇付款方式');
  } else {
    console.log('送出資料：', form.value);
    alert('訂單送出成功');
    router.push('../workspace/OrderInquiry.vue');
  }
};

// 計算商品總金額 (小計)
const subtotal = computed(() => {
  return orderItems.value.reduce((total, item) => {
    // 直接用 item 裡面的 price * quantity
    return total + item.price * item.quantity;
  }, 0);
});

// 計算運費 (小計 >= 1000 免運，否則 60)
const shippingFee = computed(() => {
  return subtotal.value >= 1000 ? 0 : 60;
});

// 計算總結帳金額 (小計 + 運費)
const totalAmount = computed(() => {
  return subtotal.value + shippingFee.value;
});
</script>

<template>
  <div class="bread">
    <a class="p-p1" href="HomeView.vue">首頁 </a>
    <a class="p-p1" href="MallView.vue"> / Recimo商城 </a>
    <a class="p-p1" href="CartView.vue"> / 購物車 </a>
    <span> / 結帳</span>
  </div>

  <div class="title">
    <h2 class="zh-h2">結帳 Checkout</h2>
  </div>

  <div class="container">
    <div class="checkout-container">
      <div class="purchaser">
        <div class="purchaser-title">
          <h5 class="zh-h5">訂購人資料</h5>
        </div>

        <div class="field">
          <label class="p-p1">姓名</label>
          <input
            type="text"
            v-model="form.name"
            placeholder="請輸入姓名"
            class="form-input"
            :class="{ 'is-error': errors.name }"
            @blur="validateField('name')"
            @input="errors.name = ''"
          />
        </div>

        <div class="field">
          <label class="p-p1">手機</label>
          <input
            type="tel"
            v-model="form.phone"
            placeholder="請輸入手機"
            maxlength="10"
            class="form-input"
            :class="{ 'is-error': errors.phone }"
            @blur="validateField('phone')"
            @input="errors.phone = ''"
          />
        </div>

        <div class="field">
          <label class="p-p1">E-mail</label>
          <input
            type="email"
            v-model="form.email"
            placeholder="請輸入Email"
            class="form-input"
            :class="{ 'is-error': errors.email }"
            @blur="validateField('email')"
            @input="errors.email = ''"
          />
        </div>

        <div class="field">
          <label class="p-p1">家用電話</label>
          <input
            type="tel"
            v-model="form.home"
            placeholder="請輸入電話 (選填)"
            class="form-input"
          />
        </div>

        <div class="field">
          <label class="p-p1">地址</label>
          <input
            type="text"
            v-model="form.adress"
            placeholder="請輸入地址"
            class="form-input"
            :class="{ 'is-error': errors.adress }"
            @blur="validateField('adress')"
            @input="errors.adress = ''"
          />
        </div>
      </div>

      <div class="delivery">
        <div class="deliver-title">
          <h5 class="zh-h5">宅配地址</h5>
        </div>
        <div class="deliver-text">
          <div class="deliver-other-text">
            <div class="other-address-text">
              <div class="add">
                <input
                  type="checkbox"
                  :checked="form.shippingType === 'new'"
                  @click="form.shippingType = 'new'"
                />
                <p class="p-p1">新增宅配地址</p>
              </div>
              <div class="same">
                <input
                  type="checkbox"
                  :checked="form.shippingType === 'same'"
                  @click="form.shippingType = 'same'"
                />
                <p class="p-p1">同訂購人</p>
              </div>
            </div>

            <div
              class="add-address"
              v-show="
                form.shippingType === 'new' || form.shippingType === 'same'
              "
            >
              <div class="field add-field">
                <label class="p-p1">收貨人</label>
                <input
                  type="text"
                  v-model="form.addname"
                  placeholder="請輸入姓名"
                  class="form-input"
                  :class="{ 'is-error': errors.addname }"
                  @blur="validateField('addname')"
                  @input="errors.addname = ''"
                />
              </div>
              <div class="field add-field">
                <label class="p-p1">手機號碼</label>
                <input
                  type="text"
                  maxlength="10"
                  v-model="form.addphone"
                  placeholder="請輸入電話號碼"
                  class="form-input"
                  :class="{ 'is-error': errors.addphone }"
                  @blur="validateField('addphone')"
                  @input="errors.addphone = ''"
                />
              </div>

              <div class="field add-field">
                <label class="p-p1">家用電話</label>
                <input
                  type="text"
                  v-model="form.addhome"
                  placeholder="請輸入電話號碼 (選填)"
                  class="form-input"
                />
              </div>

              <div class="field add-field">
                <label class="p-p1">寄件地址</label>
                <input
                  type="text"
                  v-model="form.addadress"
                  placeholder="請輸入地址"
                  class="form-input"
                  :class="{ 'is-error': errors.addadress }"
                  @blur="validateField('addadress')"
                  @input="errors.addadress = ''"
                />
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="pay">
        <div class="pay-title">
          <h5 class="zh-h5">付款方式</h5>
        </div>

        <div class="same">
          <input
            type="checkbox"
            :checked="form.paymentMethod === 'card'"
            @click="form.paymentMethod = 'card'"
          />
          <p class="p-p1">信用卡付款</p>
        </div>

        <div v-show="form.paymentMethod === 'card'">
          <div class="pay-field">
            <label class="p-p1">卡號</label>
            <div class="card-row"></div>
            <input
              type="text"
              maxlength="4"
              v-model="form.cardnum1"
              placeholder="0000"
              class="form-input"
              :class="{ 'is-error': errors.cardnum1 }"
              @blur="validateField('cardnum1')"
              @input="errors.cardnum1 = ''"
            />
            <span class="separator">-</span>
            <input
              type="text"
              maxlength="4"
              v-model="form.cardnum2"
              placeholder="0000"
              class="form-input"
              :class="{ 'is-error': errors.cardnum2 }"
              @blur="validateField('cardnum2')"
              @input="errors.cardnum2 = ''"
            />
            <span class="separator">-</span>
            <input
              type="text"
              maxlength="4"
              v-model="form.cardnum3"
              placeholder="0000"
              class="form-input"
              :class="{ 'is-error': errors.cardnum3 }"
              @blur="validateField('cardnum3')"
              @input="errors.cardnum3 = ''"
            />
            <span class="separator">-</span>
            <input
              type="text"
              maxlength="4"
              v-model="form.cardnum4"
              placeholder="0000"
              class="form-input"
              :class="{ 'is-error': errors.cardnum4 }"
              @blur="validateField('cardnum4')"
              @input="errors.cardnum4 = ''"
            />
          </div>
          <div class="field">
            <label class="p-p1">有效期限</label>
            <input
              type="text"
              v-model="form.num"
              placeholder="MM/YY"
              class="form-input"
              :class="{ 'is-error': errors.num }"
              @blur="validateField('num')"
              @input="errors.num = ''"
            />
          </div>
          <div class="field">
            <label class="p-p1">安全碼</label>
            <input
              type="text"
              maxlength="3"
              v-model="form.savenum"
              placeholder="CVC"
              class="form-input"
              :class="{ 'is-error': errors.savenum }"
              @blur="validateField('savenum')"
              @input="errors.savenum = ''"
            />
          </div>
        </div>

        <div class="same">
          <input
            type="checkbox"
            :checked="form.paymentMethod === 'cod'"
            @click="form.paymentMethod = 'cod'"
          />
          <p class="p-p1">貨到付款</p>
        </div>
      </div>

      <div class="submit">
        <BaseBtn title="確定結帳" @click="handleDelete" />
      </div>
    </div>

    <div class="card-container">
      <div class="row reverse-layout">
        <div class="col-12 col-md-10">
          <div class="product-container">
            <div class="order-list swiper-wrap">
              <Swiper
                class="order-swiper"
                :modules="swiperModules"
                :space-between="12"
                :slides-per-view="slidesPerView"
                :direction="direction"
                :free-mode="freeMode"
                navigation
              >
                <SwiperSlide
                  v-for="item in orderItems"
                  :key="item.id"
                  class="order-slide"
                >
                  <CheckCard
                    :product-id="item.productId"
                    :quantity="item.quantity"
                  />
                </SwiperSlide>
              </Swiper>
            </div>
          </div>
        </div>
      </div>
      <div class="total-sum">
        <div class="row-text">
          <p class="p-p1">運費</p>
          <p class="p-p1">
            {{ shippingFee === 0 ? '免運' : `$${shippingFee}` }}
          </p>
        </div>

        <div class="row-text">
          <p class="p-p1">總計</p>
          <p class="p-p1">${{ totalAmount }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
input[type='checkbox'] {
  accent-color: $primary-color-700; // 控制勾選時的顏色
  width: 18px;
  height: 18px;
  cursor: pointer;
  margin-top: 13px;
  margin-right: 8px;
  vertical-align: middle; // 建議加上這行，讓它跟旁邊的文字垂直置中對齊
}

// 麵包屑
.bread {
  margin-top: 17px;
  margin-left: 40px;
}
.bread > a {
  text-decoration: none;
  color: $neutral-color-800;
}
.bread > span {
  color: $primary-color-400;
}
@media (max-width: 768px) {
  .bread {
    display: none;
  }
}

.title {
  margin-left: 40px;
  margin-top: 16px;
  position: relative;
}

// .title::after {
//   content: '';
//   width: 97%;
//   max-width: 550px;
//   height: 0.5px;
//   background-color: $neutral-color-800;
//   display: block;
//   bottom: -3px;
//   position: absolute;
// }
@media (max-width: 768px) {
  .title {
    margin-left: 23px;
    margin-top: 20px;
  }
}

.container {
  display: flex;
  justify-content: space-around;
  gap: 10px;
}

//訂購人資料
.checkout-container {
  display: flex;
  flex-direction: column;
  gap: 40px;
}

.purchaser-title {
  margin-top: 43px;
  margin-bottom: 20px;
}
.field {
  display: flex;
  align-items: center;
  margin-bottom: 13px;
  gap: 13px;
}
.field > label {
  flex: 1;
}
.field > input {
  width: 313px;
  background-color: $neutral-color-100;
}
.field > input:focus {
  border: 1px solid $neutral-color-800;
}
@media (max-width: 1024px) {
  .container {
    flex-wrap: wrap;
    flex-direction: column-reverse;
  }

  .field {
    gap: 0px;
    flex-direction: column;
    align-items: flex-start;
  }
}

//宅配地址
// .deliver-title::before {
//   content: '';
//   width: 130%;
//   max-width: 600px;
//   height: 0.5px;
//   background-color: $neutral-color-800;
//   display: block;
//   position: absolute;
//   bottom: 50px;
//   left: -60px;
// }

.deliver-title {
  margin-bottom: 15px;
  position: relative;
}
.deliver-text {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 3px;
  margin-top: -20px;
}

.check-address {
  display: flex;
  align-items: flex-end;
  gap: 15px;
}

.wrap {
  display: flex;
}

.check-address-text {
  display: flex;
  flex-direction: column;
  margin-top: 5px;
}

.adderess-text-flex {
  display: flex;
  gap: 20px;
}

.choose {
  display: flex;
  align-items: center;
  margin-left: 40px;
}

.choose > i {
  cursor: pointer;
  flex: 1;
}

.other-address-text {
  display: flex;
  margin-top: 20px;
}

.add,
.same {
  display: flex;
  margin-bottom: 10px;
  align-items: flex-end;
}

.add {
  margin-right: 30px;
}

.add-field > input {
  background-color: $neutral-color-100;
}
@media (max-width: 768px) {
  .choose {
    margin-left: -1px;
  }
}

//信用卡
.pay-field {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 13px;
}

.pay-field > input {
  width: 67px;
}
@media (max-width: 768px) {
  .pay-field {
    justify-content: flex-start;
  }
  .pay-field > label {
    width: 100%;
  }
  .pay-field > input {
    width: 70px;
  }
}

.submit {
  text-align: center;
  margin-bottom: 42px;
}

// .pay-title::before {
//   content: '';
//   width: 130%;
//   max-width: 600px;
//   height: 0.5px;
//   background-color: $neutral-color-800;
//   display: block;
//   position: absolute;
//   bottom: 40px;
//   left: -60px;
// }

.pay-title {
  margin-bottom: 15px;
  position: relative;
}

//商品卡片
.product-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
}
.card-wrap {
  display: flex;
  gap: 20px;
  border: 1px solid $primary-color-700;
  border-radius: $radius-base;
  padding: 20px;
  justify-content: center;
  align-items: center;
}

@media (max-width: 768px) {
  .product-container {
    flex-direction: column;
    margin-top: 20px;
  }
  .card-wrap {
    flex-direction: column;
    gap: 5px;
    align-items: flex-start;
  }
  .card-wrap > img {
    width: 100%;
  }
}

//總計
.row-text {
  display: flex;
  gap: 20px;
}

/* Swiper 容器 */
.swiper-wrap {
  width: 100%;
  max-width: 100%;
}

/* 桌機垂直卷軸 */
@media (min-width: 1025px) {
  .order-list {
    max-height: 500px;
    overflow-y: auto;
  }
}

/* 平板 & 手機水平滑動 */
@media (max-width: 1024px) {
  .order-list {
    max-height: none; // 移除高度限制
    overflow: hidden; // Swiper 自己控制滑動，不要scroll
  }

  .order-swiper {
    flex-wrap: nowrap;
  }

  .order-slide {
    width: auto !important; // 自動寬度
    flex: 0 0 auto; // 卡片不縮放
    display: flex;
  }

  .order-slide > * {
    max-width: 420px;
    width: 100%;
  }

  /* 確保 Swiper 滑動可以手指拖動 */
  .swiper-wrapper {
    display: flex;
  }
}
</style>
