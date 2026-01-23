<script setup>
import { ref, watch, onMounted, onUnmounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import card from '@/components/mall/CheckCard.vue';
// import axios from 'axios';
// import { publicApi } from '@/utils/publicApi';
import { useCartStore } from '@/stores/cartStore';
import Modal from '@/components/BaseModal.vue';

// 控制彈窗顯示的變數
const showSuccessModal = ref(false);
const cartStore = useCartStore(); // 2. 初始化 Store
const router = useRouter();
const orderItems = computed(() => cartStore.items);
// onMounted(() => {
//   publicApi.get('data/mall/order_product.json')
//     .then(res => {
//       orderItems.value = res.data;
//     })
//     .catch(err => {
//       console.error('讀取 JSON 失敗', err);
//     });
// })


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
  if (field === 'name' && !form.value.name) errors.value.name = '*請輸入姓名';
  if (field === 'phone') {
    if (!form.value.phone) errors.value.phone = '*請輸入手機號碼';
    else if (!/^09\d{8}$/.test(form.value.phone))
      errors.value.phone = '*手機格式錯誤';
  }
  if (field === 'email') {
    if (!form.value.email) errors.value.email = '*請輸入電子信箱';
    else if (!form.value.email.includes('@'))
      errors.value.email = '*電子信箱格式錯誤';
  }
  if (field === 'adress' && !form.value.adress)
    errors.value.adress = '*請輸入地址';

  // 2. 宅配收件人必填檢查 (跳過 addhome)
  // 只要有選配送方式(不管是同訂購人還是新增)，這些欄位都必須有值
  if (form.value.shippingType) {
    if (field === 'addname' && !form.value.addname)
      errors.value.addname = '*請輸入收件人';
    if (field === 'addadress' && !form.value.addadress)
      errors.value.addadress = '*請輸入地址';
    if (field === 'addphone') {
      if (!form.value.addphone) errors.value.addphone = '*請輸入手機';
      else if (!/^09\d{8}$/.test(form.value.addphone))
        errors.value.addphone = '*格式錯誤';
    }
  }

  // 3. 信用卡必填檢查
  if (form.value.paymentMethod === 'card') {
    if (field.includes('cardnum') && !form.value[field])
      errors.value[field] = '*必填';
    if (field === 'num' && !form.value.num) errors.value.num = '*必填';
    if (field === 'savenum' && !form.value.savenum)
      errors.value.savenum = '*必填';
  }
};
const formatExpiryDate = (e) => {
  //取得當前輸入值，並只保留數字 (移除所有非數字字元)
  let val = e.target.value.replace(/\D/g, '');

  //限制最多只有 4 個數字 (MMYY)
  if (val.length > 4) val = val.slice(0, 4);

  //自動補斜線邏輯
  //數字超過 2 碼 (例如輸入了 123 -> 變成 12/3)
  if (val.length > 2) {
    val = val.slice(0, 2) + '/' + val.slice(2);
  }
  //剛好輸入第 2 碼，且「不是」在按刪除鍵 (例如輸入 12 -> 變成 12/)
  else if (val.length === 2 && e.inputType !== 'deleteContentBackward') {
    val = val + '/';
  }

  //將處理好的值寫回 form
  form.value.num = val;
};

// 新增一個產生 8 位數亂碼的函式
const generateOrderId = () => {
  // 產生 10000000 ~ 99999999 之間的亂數
  return String(Math.floor(10000000 + Math.random() * 90000000));
};

// 接收 template 傳進來的 navigate 函式
const handleSubmit = (navigate) => {

  // --- 1. 執行原本的驗證邏輯 (保持不變) ---
  validateField('name');
  validateField('phone');
  validateField('email');
  validateField('adress');

  if (form.value.shippingType) {
    validateField('addname');
    validateField('addphone');
    validateField('addadress');
  }

  if (form.value.paymentMethod === 'card') {
    validateField('cardnum1');
    validateField('cardnum2');
    validateField('cardnum3');
    validateField('cardnum4');
    validateField('num');
    validateField('savenum');
  }

  const hasError = Object.values(errors.value).some((msg) => msg !== '');

  // --- 2. 判斷邏輯 ---

  if (hasError) {
    alert('資料填寫有誤，請檢查紅色欄位');
    // 這裡不呼叫 navigate()，所以雖然外面有 router-link，但不會跳轉！
  } else if (!form.value.shippingType) {
    alert('請選擇宅配地址方式');
  } else if (!form.value.paymentMethod) {
    alert('請選擇付款方式');
  } else {
    // 1. 決定收件人資訊 (如果是同訂購人，就用訂購人的資料，否則用新增的)
    const receiverName = form.value.shippingType === 'same' ? form.value.name : form.value.addname;
    const receiverPhone = form.value.shippingType === 'same' ? form.value.phone : form.value.addphone;

    // 2. 轉換商品格式 (對應 OrderCard 的 items: [{ name, qty, price }] )
    const formattedItems = orderItems.value.map(item => ({
      name: item.product_name || item.name, // 確保抓得到名稱
      qty: Number(item.count || item.quantity || 1),
      price: Number(item.product_price || item.price || 0)
    }));

    // 3. 建立訂單物件
    const newOrder = {
      // 需求：8位數訂單編號
      id: generateOrderId(),

      date: new Date().toISOString().split('T')[0], // YYYY-MM-DD
      status: 0, // 0: 新訂單/訂購成功

      // OrderCard 顯示需要的欄位
      trackingNo: '處理中', // 新訂單還沒有物流編號
      receiver: receiverName,
      phone: receiverPhone,
      method: '宅配到府', // 固定或根據 shippingType 顯示
      payment: form.value.paymentMethod === 'card' ? '已付款' : '未付款',

      // 商品列表
      items: formattedItems,

      // 保留原始金額資訊 (給後端或除錯用)
      total_amount: totalAmount.value,
      shipping_fee: shippingFee.value
    };

    // B. 從 LocalStorage 取出舊訂單 (如果有)
    const existingOrders = JSON.parse(localStorage.getItem('mall_orders') || '[]');

    // C. 加入新訂單 (放在最前面)
    existingOrders.unshift(newOrder);

    // D. 存回 LocalStorage
    localStorage.setItem('mall_orders', JSON.stringify(existingOrders));

    // E. 清空購物車 Store
    cartStore.items = [];

    console.log('訂單已儲存：', newOrder);

    // F. 顯示成功彈窗
    showSuccessModal.value = true;
    setTimeout(() => {
      handleModalCloseAndRedirect();
    }, 3000);
  }
};

// --- 處理彈窗關閉並跳轉 ---
const handleModalCloseAndRedirect = () => {
  // 關閉彈窗
  showSuccessModal.value = false;

  // 執行跳轉
  router.push('../workspace/orders');
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

  return orderItems.value.reduce((total, item) => {
    // 價格:優先找 product_price，沒有再找 price，都沒有就當 0
    const price = Number(item.product_price) || Number(item.price) || 0;

    // 數量:優先找 count，沒有再找 quantity，都沒有就當 0
    const qty = Number(item.count) || Number(item.quantity) || 0;

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

//按下 Enter 切換到下一個 Input
const handleNextInput = (e) => {
  // 只針對 input 標籤作用，且排除 checkbox (checkbox 通常用空白鍵或點擊)
  if (e.target.tagName === 'INPUT' && e.target.type !== 'checkbox') {
    e.preventDefault(); // 阻止 Enter 送出表單

    // 取得所有 input 元素
    const inputs = Array.from(document.querySelectorAll('input'));

    // 過濾出「可見」且「未被 disable」的輸入框
    // offsetParent !== null 是判斷元素是否可見的常用技巧 (能過濾掉 v-show="false" 的元素)
    const visibleInputs = inputs.filter(input =>
      input.offsetParent !== null &&
      !input.disabled &&
      input.type !== 'hidden'
    );

    // 找到目前焦點所在的 index
    const index = visibleInputs.indexOf(e.target);

    // 如果不是最後一個，就 focus 下一個
    if (index > -1 && index < visibleInputs.length - 1) {
      visibleInputs[index + 1].focus();
    } else {
      // 如果是最後一個 input，可以選擇移除焦點或是直接執行送出
      e.target.blur();
    }
  }
};

// 定義 DOM 參照 (Ref)
const cardInput2 = ref(null);
const cardInput3 = ref(null);
const cardInput4 = ref(null);

// 處理信用卡輸入與跳轉
const handleCardInput = (e, fieldName, nextInputRef) => {
  // 1. 清除該欄位的錯誤訊息
  errors.value[fieldName] = '';

  // 2. 過濾非數字 (防呆)
  // 注意：因為有 v-model，我們直接修改 form 的值即可觸發畫面更新
  const val = e.target.value.replace(/\D/g, '');
  form.value[fieldName] = val;

  // 3. 判斷是否跳轉
  // 如果輸入滿 4 碼，且有傳入下一個欄位的 ref，就將焦點移過去
  if (val.length === 4 && nextInputRef) {
    nextInputRef.focus();
  }
};
</script>

<template>
  <div class="container" @keydown.enter="handleNextInput">
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
                <input type="text" v-model="form.name" class="form-input" placeholder="請輸入姓名"
                  :class="{ 'is-error': errors.name }" @blur="validateField('name')" @input="errors.name = ''" />
                <span class="error-msg p-p2 p-p2" v-if="errors.name">{{ errors.name }}</span>
              </div>

              <div class="field">
                <label class="p-p1">手機</label>
                <input type="tel" v-model="form.phone" maxlength="10" class="form-input" placeholder="請輸入手機"
                  :class="{ 'is-error': errors.phone }" @blur="validateField('phone')" @input="errors.phone = ''" />
                <span class="error-msg p-p2 p-p2" v-if="errors.phone">{{ errors.phone }}</span>
              </div>
            </div>
            <div class="field-flex">
              <div class="field">
                <label class="p-p1">電子信箱</label>
                <input type="email" v-model="form.email" class="form-input" placeholder="請輸入電子信箱"
                  :class="{ 'is-error': errors.email }" @blur="validateField('email')" @input="errors.email = ''" />
                <span class="error-msg p-p2 p-p2" v-if="errors.email">{{ errors.email }}</span>
              </div>

              <div class="field">
                <label class="p-p1">家用電話</label>
                <input type="tel" v-model="form.home" placeholder="請輸入電話 (選填)" class="form-input" />
              </div>
            </div>

            <div class="field lg">
              <label class="p-p1">地址</label>
              <input type="text" v-model="form.adress" class="form-input" placeholder="請輸入地址"
                :class="{ 'is-error': errors.adress }" @blur="validateField('adress')" @input="errors.adress = ''" />
              <span class="error-msg p-p2 p-p2" v-if="errors.adress">{{ errors.adress }}</span>
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
                      <input type="text" v-model="form.addname" class="form-input" placeholder="請輸入姓名"
                        :class="{ 'is-error': errors.addname }" @blur="validateField('addname')"
                        @input="errors.addname = ''" />
                      <span class="error-msg p-p2 p-p2" v-if="errors.addname">{{ errors.addname }}</span>
                    </div>
                    <div class="field add-field">
                      <label class="p-p1">手機號碼</label>
                      <input type="text" maxlength="10" v-model="form.addphone" class="form-input" placeholder="請輸入手機"
                        :class="{ 'is-error': errors.addphone }" @blur="validateField('addphone')"
                        @input="errors.addphone = ''" />
                      <span class="error-msg p-p2" v-if="errors.addphone">{{ errors.addphone }}</span>
                    </div>
                  </div>
                  <div class="field-flex">
                    <div class="field add-field">
                      <label class="p-p1">家用電話</label>
                      <input type="text" v-model="form.addhome" placeholder="請輸入電話號碼 (選填)" class="form-input" />
                    </div>

                    <div class="field add-field">
                      <label class="p-p1">寄件地址</label>
                      <input type="text" v-model="form.addadress" class="form-input" placeholder="請輸入地址"
                        :class="{ 'is-error': errors.addadress }" @blur="validateField('addadress')"
                        @input="errors.addadress = ''" />
                      <span class="error-msg p-p2 p-p2" v-if="errors.addadress">{{ errors.addadress }}</span>
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
                  <input type="text" maxlength="4" v-model="form.cardnum1" class="form-input" placeholder="0000"
                    :class="{ 'is-error': errors.cardnum1 }" @blur="validateField('cardnum1')"
                    @input="handleCardInput($event, 'cardnum1', cardInput2)" />

                  <span class="separator">-</span>

                  <input type="text" maxlength="4" v-model="form.cardnum2" class="form-input" placeholder="0000"
                    ref="cardInput2" :class="{ 'is-error': errors.cardnum2 }" @blur="validateField('cardnum2')"
                    @input="handleCardInput($event, 'cardnum2', cardInput3)" />

                  <span class="separator">-</span>

                  <input type="text" maxlength="4" v-model="form.cardnum3" class="form-input" placeholder="0000"
                    ref="cardInput3" :class="{ 'is-error': errors.cardnum3 }" @blur="validateField('cardnum3')"
                    @input="handleCardInput($event, 'cardnum3', cardInput4)" />

                  <span class="separator">-</span>

                  <input type="text" maxlength="4" v-model="form.cardnum4" class="form-input" placeholder="0000"
                    ref="cardInput4" :class="{ 'is-error': errors.cardnum4 }" @blur="validateField('cardnum4')"
                    @input="handleCardInput($event, 'cardnum4', null)" />
                </div>
                <span class="error-msg p-p2"
                  v-if="errors.cardnum1 || errors.cardnum2 || errors.cardnum3 || errors.cardnum4">
                  *請檢查卡號是否填寫完整
                </span>
              </div>
              <div class="field-flex">
                <div class="field">
                  <label class="p-p1">有效期限</label>
                  <input type="text" v-model="form.num" class="form-input" placeholder="MM/YY" maxlength="5"
                    :class="{ 'is-error': errors.num }" @blur="validateField('num')" @input="formatExpiryDate">
                  <span class="error-msg p-p2" v-if="errors.num">{{ errors.num }}</span>
                </div>

                <div class="field">
                  <label class="p-p1">安全碼</label>
                  <input type="text" maxlength="3" v-model="form.savenum" class="form-input" placeholder="CVC"
                    :class="{ 'is-error': errors.savenum }" @blur="validateField('savenum')"
                    @input="errors.savenum = ''" />
                  <span class="error-msg p-p2" v-if="errors.savenum">{{ errors.savenum }}</span>
                </div>
              </div>
            </div>
          </div>
          <div class="submit">
            <BaseBtn title="確定結帳" @click="handleSubmit" />
          </div>
          <Modal :is-open="showSuccessModal" type="success" title="訂單已送出" description="感謝您的購買，您可以在訂單查詢頁面查看詳情。"
            icon-class="fa-solid fa-circle-check" @close="handleModalCloseAndRedirect">
          </Modal>

        </div>
      </div>
      <div class="col-6 col-lg-12">
        <div class="card-container">
          <div class="order-list">
            <div class="order-list">
              <CheckCard v-for="item in orderItems" :key="item.id || item.product_id"
                :product-name="item.product_name || item.name" :quantity="item.count || item.quantity"
                :price="item.product_price || item.price" :image="item.product_image?.[0]?.image_url
                  ? item.product_image[0].image_url.replace('public', '')
                  : '/default.png'" />
            </div>
          </div>
        </div>
        <hr>
        <div class="total-sum">
          <router-link to="cart">
            <div class="submit">
              <BaseBtn title="返回購物車" @click="backcart" />
            </div>
          </router-link>
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

.error-msg {
  color: $secondary-color-danger-700;
  margin-top: -10px;
  margin-left: 5px;

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
