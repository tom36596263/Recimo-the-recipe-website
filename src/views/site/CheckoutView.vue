<script setup>
import { ref, watch, onMounted, onUnmounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import card from '@/components/mall/CheckCard.vue';
import axios from 'axios';

const router = useRouter();
const orderItems = ref([]);
// import orderItems from '/public/data/mall/order_product.json';
onMounted(async () => {
  try {
    // 3. 使用 fetch 請求位於 public 資料夾內的檔案
    // 注意：在瀏覽器中，public 資料夾通常對應到根目錄 '/'
    const response = await fetch('/data/mall/order_product.json');

    // 4. 確保回應成功
    if (!response.ok) {
      throw new Error('Network response was not ok');
    }

    // 5. 將 JSON 資料解析並存入變數
    orderItems.value = await response.json();

    // console.log('資料載入成功:', orderItems.value);

  } catch (error) {
    // console.error('資料載入失敗:', error);
  }
});


// 資料打包送進後端
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

const backcart = () => {
  router.push('./CartView.vue');
}

// 計算商品總金額 (小計)
const subtotal = computed(() => {
  // 檢查 orderItems.value 是否有值
  if (!orderItems.value || orderItems.value.length === 0) {
    return 0;
  }

  // 記得要加 .value 才能拿到陣列
  return orderItems.value.reduce((total, item) => {
    // 確保 price 和 quantity 是數字，避免 undefined 計算變成 NaN
    const price = item.price || 0;
    const qty = item.quantity || 0;
    return total + (price * qty);
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
  <div class="container">
    <div class="title">
      <h2 class="zh-h2">結帳 Checkout</h2>
    </div>
    <hr>
    <div class="row">
      <div class="col-6 col-lg-12">
        <div class="checkout-container">
          <div class="purchaser">
            <div class="purchaser-title">
              <h5 class="zh-h5">訂購人資料</h5>
            </div>
            <div class="field-flex">
              <div class="field">
                <label class="p-p1">姓名</label>
                <input type="text" v-model="form.name" placeholder="請輸入姓名" class="form-input"
                  :class="{ 'is-error': errors.name }" @blur="validateField('name')" @input="errors.name = ''" />
              </div>

              <div class="field">
                <label class="p-p1">手機</label>
                <input type="tel" v-model="form.phone" placeholder="請輸入手機" maxlength="10" class="form-input"
                  :class="{ 'is-error': errors.phone }" @blur="validateField('phone')" @input="errors.phone = ''" />
              </div>
            </div>
            <div class="field-flex">
              <div class="field">
                <label class="p-p1">E-mail</label>
                <input type="email" v-model="form.email" placeholder="請輸入Email" class="form-input"
                  :class="{ 'is-error': errors.email }" @blur="validateField('email')" @input="errors.email = ''" />
              </div>

              <div class="field">
                <label class="p-p1">家用電話</label>
                <input type="tel" v-model="form.home" placeholder="請輸入電話 (選填)" class="form-input" />
              </div>
            </div>

            <div class="field lg">
              <label class="p-p1">地址</label>
              <input type="text" v-model="form.adress" placeholder="請輸入地址" class="form-input"
                :class="{ 'is-error': errors.adress }" @blur="validateField('adress')" @input="errors.adress = ''" />
            </div>
          </div>

          <div class="delivery">
            <hr>
            <div class="deliver-title">
              <h5 class="zh-h5">宅配地址</h5>
            </div>
            <div class="deliver-text">
              <div class="deliver-other-text">
                <div class="other-address-text">
                  <div class="add">
                    <input type="checkbox" :checked="form.shippingType === 'new'" @click="form.shippingType = 'new'" />
                    <p class="p-p1">新增宅配地址</p>
                  </div>
                  <div class="same">
                    <input type="checkbox" :checked="form.shippingType === 'same'"
                      @click="form.shippingType = 'same'" />
                    <p class="p-p1">同訂購人</p>
                  </div>
                </div>

                <div class="add-address" v-show="form.shippingType === 'new' || form.shippingType === 'same'
                  ">
                  <div class="field-flex">
                    <div class="field add-field">
                      <label class="p-p1">收貨人</label>
                      <input type="text" v-model="form.addname" placeholder="請輸入姓名" class="form-input"
                        :class="{ 'is-error': errors.addname }" @blur="validateField('addname')"
                        @input="errors.addname = ''" />
                    </div>
                    <div class="field add-field">
                      <label class="p-p1">手機號碼</label>
                      <input type="text" maxlength="10" v-model="form.addphone" placeholder="請輸入電話號碼" class="form-input"
                        :class="{ 'is-error': errors.addphone }" @blur="validateField('addphone')"
                        @input="errors.addphone = ''" />
                    </div>
                  </div>
                  <div class="field-flex">
                    <div class="field add-field">
                      <label class="p-p1">家用電話</label>
                      <input type="text" v-model="form.addhome" placeholder="請輸入電話號碼 (選填)" class="form-input" />
                    </div>

                    <div class="field add-field">
                      <label class="p-p1">寄件地址</label>
                      <input type="text" v-model="form.addadress" placeholder="請輸入地址" class="form-input"
                        :class="{ 'is-error': errors.addadress }" @blur="validateField('addadress')"
                        @input="errors.addadress = ''" />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="pay">
            <hr>
            <div class="pay-title">
              <h5 class="zh-h5">付款方式</h5>
            </div>
            <div class="pay-flex">
              <div class="same">
                <input type="checkbox" :checked="form.paymentMethod === 'card'" @click="form.paymentMethod = 'card'" />
                <p class="p-p1">信用卡付款</p>
              </div>

              <div class="same">
                <input type="checkbox" :checked="form.paymentMethod === 'cod'" @click="form.paymentMethod = 'cod'" />
                <p class="p-p1">貨到付款</p>
              </div>
            </div>
            <div v-show="form.paymentMethod === 'card'">
              <div class="pay-field">
                <label class="p-p1">卡號</label>
                <div class="card-row">
                  <input type="text" maxlength="4" v-model="form.cardnum1" placeholder="0000" class="form-input"
                    :class="{ 'is-error': errors.cardnum1 }" @blur="validateField('cardnum1')"
                    @input="errors.cardnum1 = ''" />
                  <span class="separator">-</span>
                  <input type="text" maxlength="4" v-model="form.cardnum2" placeholder="0000" class="form-input"
                    :class="{ 'is-error': errors.cardnum2 }" @blur="validateField('cardnum2')"
                    @input="errors.cardnum2 = ''" />
                  <span class="separator">-</span>
                  <input type="text" maxlength="4" v-model="form.cardnum3" placeholder="0000" class="form-input"
                    :class="{ 'is-error': errors.cardnum3 }" @blur="validateField('cardnum3')"
                    @input="errors.cardnum3 = ''" />
                  <span class="separator">-</span>
                  <input type="text" maxlength="4" v-model="form.cardnum4" placeholder="0000" class="form-input"
                    :class="{ 'is-error': errors.cardnum4 }" @blur="validateField('cardnum4')"
                    @input="errors.cardnum4 = ''" />
                </div>
              </div>
              <div class="field-flex">
                <div class="field">
                  <label class="p-p1">有效期限</label>
                  <input type="text" v-model="form.num" placeholder="MM/YY" class="form-input"
                    :class="{ 'is-error': errors.num }" @blur="validateField('num')" @input="errors.num = ''" />
                </div>
                <div class="field">
                  <label class="p-p1">安全碼</label>
                  <input type="text" maxlength="3" v-model="form.savenum" placeholder="CVC" class="form-input"
                    :class="{ 'is-error': errors.savenum }" @blur="validateField('savenum')"
                    @input="errors.savenum = ''" />
                </div>
              </div>
            </div>
          </div>

          <div class="submit">
            <BaseBtn title="確定結帳" @click="handleDelete" />
          </div>
        </div>
      </div>
      <div class="col-6 col-lg-12">
        <div class="card-container">
          <div class="order-list">
            <div class="order-list">
              <CheckCard v-for="item in orderItems" :key="item.id" :product-name="item.product_name"
                :quantity="item.quantity" :price="item.price" :image="item.images?.[0] || '/default.png'" />
            </div>
          </div>
        </div>
        <hr>
        <div class="total-sum">
          <div class="submit">
            <BaseBtn title="返回購物車" @click="backcart" />
          </div>
          <div class="sum-flex">
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

.title {
  margin-top: 20px;
  margin-bottom: 10px;
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
//

//訂購人資料
.checkout-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
  margin-left: 50px;
}

.purchaser-title {
  margin-top: 20px;
  margin-bottom: 20px;
}

.field {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  margin-bottom: 13px;
  gap: 10px;
}

.field>input {
  width: 313px;
  margin-bottom: 10px;
  background-color: $neutral-color-100;
}

.field>input:focus {
  border: 1px solid $neutral-color-800;
}

@media (max-width: 1024px) {
  .checkout-container {
    margin: 0;
  }

  .row {
    display: flex;
    flex-wrap: wrap;
    flex-direction: column-reverse;
  }

  .field-flex {
    width: 100%;
    display: flex;
    justify-content: space-between;
    gap: 20px;
  }

  .field>input {
    width: 400px;
  }

  .lg>input {
    width: 100%;
  }
}

@media (max-width: 820px) {
  .field-flex {
    flex-direction: column;
    align-content: center;
    gap: 0;
  }

  .field>input {
    width: 100%;
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

.choose>i {
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

.add-field>input {
  background-color: $neutral-color-100;
}

@media (max-width: 1024px) {
  .choose {
    margin-left: -1px;
  }

  .deliver-text {
    align-items: stretch;
  }
}

//信用卡
.pay-flex {
  display: flex;
  gap: 50px;
}

.pay-field {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  align-items: center;
  margin-bottom: 13px;

  .card-row {
    display: flex;
    align-items: center;
    gap: 8px;

    input {
      text-align: center;
    }
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

/* 桌機直向卷軸 */
.order-list {
  max-height: 500px;
  overflow-y: auto;
}

/* 平板 & 手機 */
@media (max-width: 1024px) {
  .order-list {
    display: flex;
    gap: 15px;
    overflow-x: auto;
    /* 可以滑 */
    overflow-y: hidden;
    /* 只關掉垂直 */
    -webkit-overflow-scrolling: touch;
    /* iOS 慣性 */
    scrollbar-width: none;
    /* Firefox */
  }

  .order-list ::-webkit-scrollbar {
    display: none;
  }
}

//總計
.total-sum {
  display: flex;
  justify-content: space-around;
}

.row-text {
  display: flex;
  gap: 20px;
}
</style>
