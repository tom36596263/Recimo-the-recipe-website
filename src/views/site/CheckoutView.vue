<script setup>
import { ref, watch, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { phpApi } from '@/utils/publicApi';
import card from '@/components/mall/CheckCard.vue';
import { useCartStore } from '@/stores/cartStore';
import Modal from '@/components/BaseModal.vue';

//初始化變數
const showSuccessModal = ref(false);
const cartStore = useCartStore();
const router = useRouter();
const orderItems = computed(() => {
  const source = cartItemsFromDB.value.length > 0 ? cartItemsFromDB.value : cartStore.items;
  return source.map(item => ({
    ...item,
    // 確保這裡欄位名稱一致，PHP 回傳是 product_image
    product_image: formatImageUrl(item.product_image || item.image)
  }));
});
// 圖片處理函式 (修正後的版本)
const formatImageUrl = (rawImage) => {
  if (!rawImage) return '';

  // 1. 定義正確的圖片網域
  const isLocal = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';

  // 線上環境使用 recimo_api
  const imgBaseUrl = isLocal
    ? 'http://localhost:8888/recimo_api'
    : 'https://tibamef2e.com/cjd102/g2/api';

  // 處理已經是 http 開頭的網址
  if (typeof rawImage === 'string' && rawImage.startsWith('http')) {

    // 🚑 強力修正：只要是線上的網址，且包含 /recimo/，就強制換成 /api/
    if (rawImage.includes('tibamef2e.com') && rawImage.includes('/recimo/')) {
      const fixedImage = rawImage.replace('/recimo/', '/api/');
      // 在 Console 印出修正紀錄，方便您檢查
      console.log(`修正圖片路徑: ${rawImage} -> ${fixedImage}`);
      return fixedImage;
    }

    return rawImage;
  }

  let relativePath = rawImage;

  // 3. 處理 JSON 格式
  if (typeof rawImage === 'string' && (rawImage.startsWith('[') || rawImage.startsWith('{'))) {
    try {
      const parsed = JSON.parse(rawImage);
      if (Array.isArray(parsed) && parsed.length > 0) {
        const cover = parsed.find(img => img.is_cover) || parsed[0];
        relativePath = cover.image_url;
      }
    } catch (e) { console.warn('JSON parse error', e); }
  }

  // 4. 拼接相對路徑
  if (relativePath && !relativePath.startsWith('http')) {
    const cleanPath = relativePath.replace(/^public\//, '').replace(/^\/+/, '');
    // 結果會是: .../api/ + img/mall/PROD-007_01.jpg
    return `${imgBaseUrl}/${cleanPath}`;
  }

  return relativePath;
};

const cartItemsFromDB = ref([]); // 新增：存儲從 PHP 抓回來的購物車資料
const isLoading = ref(true);
//DOM Refs(用於信用卡輸入跳轉)
const cardInput2 = ref(null);
const cardInput3 = ref(null);
const cardInput4 = ref(null);


// CheckoutView.vue 裡的 fetchCartData
// CheckoutView.vue
const fetchCartData = async () => {
  try {
    isLoading.value = true;
    //確保 URL 是正確的 get_cart.php
    const response = await phpApi.get('/mall/get_cart.php');

    //自動相容兩種格式：如果是物件就拿 .data，如果是陣列就直接用
    const result = response.data;
    const rawData = result.status === 'success' ? result.data : result;

    if (Array.isArray(rawData)) {
      //刪除這裡所有的圖片處理邏輯，直接用 map 簡單處理
      cartItemsFromDB.value = rawData.map(item => {
        //取得原始圖片欄位
        const rawImage = item.product_image || item.image || '';

        return {
          ...item,
          //直接呼叫上方的 formatImageUrl 函式 (它會自動判斷環境)
          product_image: formatImageUrl(rawImage),

          //處理數值格式
          quantity: Number(item.quantity || item.count || 1),
          product_price: Number(item.product_price || item.price)
        };
      });

      console.log('購物車資料加載成功:', cartItemsFromDB.value);
    }
  } catch (error) {
    console.error('抓取購物車失敗:', error);
  } finally {
    isLoading.value = false;
  }
};

onMounted(() => {
  fetchCartData();
});


// 表單資料 (前端使用 snake_case，送出時會轉成 DB 格式)
const form = ref({
  // 訂購人資料
  user_name: '',
  user_phone: '',
  user_email: '',
  user_tel: '',
  user_address: '',

  // 收件人資料
  recipient_name: '',    // 對應 RECIPIENT_NAME
  recipient_phone: '',   // 對應 RECIPIENT_PHONE
  recipient_tel: '',     // 對應 RECIPIENT_PHONE 或備註
  shipping_address: '',  // 對應 SHIPPING_ADDRESS

  // 訂單設定
  logistics_id: 1,       // 對應 LOGISTICS_ID
  payment_method: '',    // 對應 PATMENT_METHOD (依照你的 DB 拼字)
  shipping_type: '',     // 前端控制用 ('new' or 'same')

  // 信用卡 (不存 DB)
  card_num_1: '',
  card_num_2: '',
  card_num_3: '',
  card_num_4: '',
  card_expiry: '',
  card_cvc: '',
});

const errors = ref({});

//監聽邏輯
watch(
  () => form.value.shipping_type,
  (val) => {
    if (val === 'same') {
      form.value.recipient_name = form.value.user_name;
      form.value.recipient_phone = form.value.user_phone;
      form.value.recipient_tel = form.value.user_tel;
      form.value.shipping_address = form.value.user_address;
    } else if (val === 'new') {
      form.value.recipient_name = '';
      form.value.recipient_phone = '';
      form.value.recipient_tel = '';
      form.value.shipping_address = '';
    }
  }
);

watch(
  () => form.value.payment_method,
  (val) => {
    if (val === 'cod') {
      errors.value.card_num_1 = '';
      errors.value.card_num_2 = '';
      errors.value.card_num_3 = '';
      errors.value.card_num_4 = '';
      errors.value.card_expiry = '';
      errors.value.card_cvc = '';
    }
  }
);

// 驗證邏輯
const validateField = (field) => {
  errors.value[field] = '';

  //訂購人
  if (field === 'user_name' && !form.value.user_name) errors.value.user_name = '*請輸入姓名';
  if (field === 'user_phone') {
    if (!form.value.user_phone) errors.value.user_phone = '*請輸入手機號碼';
    else if (!/^09\d{8}$/.test(form.value.user_phone)) errors.value.user_phone = '*手機格式錯誤';
  }
  if (field === 'user_email') {
    if (!form.value.user_email) errors.value.user_email = '*請輸入電子信箱';
    else if (!form.value.user_email.includes('@')) errors.value.user_email = '*電子信箱格式錯誤';
  }
  if (field === 'user_address' && !form.value.user_address) errors.value.user_address = '*請輸入地址';

  // 收件人
  if (form.value.shipping_type) {
    if (field === 'recipient_name' && !form.value.recipient_name) errors.value.recipient_name = '*請輸入收件人';
    if (field === 'shipping_address' && !form.value.shipping_address) errors.value.shipping_address = '*請輸入地址';
    if (field === 'recipient_phone') {
      if (!form.value.recipient_phone) errors.value.recipient_phone = '*請輸入手機';
      else if (!/^09\d{8}$/.test(form.value.recipient_phone)) errors.value.recipient_phone = '*格式錯誤';
    }
  }

  // 信用卡
  if (form.value.payment_method === 'card') {
    if (field.includes('card_num') && !form.value[field]) errors.value[field] = '*必填';
    if (field === 'card_expiry' && !form.value.card_expiry) errors.value.card_expiry = '*必填';
    if (field === 'card_cvc' && !form.value.card_cvc) errors.value.card_cvc = '*必填';
  }
};

//輔助函式
const formatExpiryDate = (e) => {
  let val = e.target.value.replace(/\D/g, '');
  if (val.length > 4) val = val.slice(0, 4);
  if (val.length > 2) {
    val = val.slice(0, 2) + '/' + val.slice(2);
  } else if (val.length === 2 && e.inputType !== 'deleteContentBackward') {
    val = val + '/';
  }
  form.value.card_expiry = val;
};

const handleCardInput = (e, fieldName, nextInputRef) => {
  errors.value[fieldName] = '';
  const val = e.target.value.replace(/\D/g, '');
  form.value[fieldName] = val;
  if (val.length === 4 && nextInputRef) {
    nextInputRef.focus();
  }
};

const handleNextInput = (e) => {
  if (e.target.tagName === 'INPUT' && e.target.type !== 'checkbox') {
    e.preventDefault();
    const inputs = Array.from(document.querySelectorAll('input'));
    const visibleInputs = inputs.filter(input =>
      input.offsetParent !== null && !input.disabled && input.type !== 'hidden'
    );
    const index = visibleInputs.indexOf(e.target);
    if (index > -1 && index < visibleInputs.length - 1) {
      visibleInputs[index + 1].focus();
    } else {
      e.target.blur();
    }
  }
};

//金額計算
const subtotal = computed(() => {
  if (!orderItems.value || orderItems.value.length === 0) return 0;
  return orderItems.value.reduce((total, item) => {
    const price = Number(item.product_price) || Number(item.price) || 0;
    const qty = Number(item.count) || Number(item.quantity) || 0;
    return total + (price * qty);
  }, 0);
});

const shippingFee = computed(() => {
  return subtotal.value >= 1000 ? 0 : 60;
});

const totalAmount = computed(() => {
  return subtotal.value + shippingFee.value;
});
//先建立一個清空資料庫的輔助函式
const clearDatabaseCart = async () => {
  try {
    const response = await phpApi.get('/mall/clear_cart.php'); // 確保路徑對應你的檔案
    console.log('後端購物車清空結果:', response.data);
    return response.data.status === 'success';
  } catch (error) {
    console.error('清空後端購物車失敗:', error);
    return false;
  }
};

const handleSubmit = async () => {
  //驗證登入
  const userInfo = JSON.parse(localStorage.getItem('user'));
  const currentUserId = userInfo?.id || userInfo?.user_id;

  if (!currentUserId) {
    alert('偵測不到登入資訊，請重新登入後再結帳');
    return;
  }

  //  驗證欄位 
  validateField('user_name');
  validateField('user_phone');
  validateField('user_email');
  validateField('user_address');

  if (form.value.shipping_type) {
    validateField('recipient_name');
    validateField('recipient_phone');
    validateField('shipping_address');
  }

  // if (form.value.payment_method === 'card') {
  //   validateField('card_num_1');
  //   validateField('card_num_2');
  //   validateField('card_num_3');
  //   validateField('card_num_4');
  //   validateField('card_expiry');
  //   validateField('card_cvc');
  // }

  const hasError = Object.values(errors.value).some((msg) => msg !== '');
  if (hasError) {
    alert('資料填寫有誤，請檢查紅色欄位');
    return;
  }
  if (!form.value.shipping_type) {
    alert('請選擇宅配地址方式');
    return;
  }
  if (!form.value.payment_method) {
    alert('請選擇付款方式');
    return;
  }

  // 準備 Payload 
  const orderPayload = {
    user_id: currentUserId,
    logistics_id: form.value.logistics_id,
    subtotal: subtotal.value,
    discount_amount: 0,
    shipping_fee: shippingFee.value,
    total_amount: totalAmount.value,
    recipient_name: form.value.shipping_type === 'same' ? form.value.user_name : form.value.recipient_name,
    recipient_phone: form.value.shipping_type === 'same' ? form.value.user_phone : form.value.recipient_phone,
    shipping_address: form.value.shipping_type === 'same' ? form.value.user_address : form.value.shipping_address,
    payment_method: form.value.payment_method,
    items: orderItems.value.map(item => ({
      product_id: item.product_id,
      product_name: item.product_name,
      price: Number(item.product_price),
      quantity: Number(item.quantity)
    }))
  };

  try {
    //呼叫後端 API 
    const response = await phpApi.post('mall/add_order.php', orderPayload);

    if (response.data.success) {
      const realOrderId = response.data.order_id;

      //清空購物車
      await clearDatabaseCart();
      cartStore.items = [];
      cartItemsFromDB.value = [];

      //信用卡轉址 vs 貨到付款顯示成功 ---
      if (form.value.payment_method === 'card') {
        const baseUrl = phpApi.defaults.baseURL;
        const checkoutUrl = `${baseUrl}/mall/ecpay_checkout.php?order_id=${realOrderId}`;
        window.location.href = checkoutUrl;
      } else {
        // [貨到付款] -> 顯示成功燈箱
        // 不需要再存 LocalStorage，因為資料庫已經有這筆訂單了
        // 你的訂單列表頁面 (Order.vue) 會直接去撈資料庫
        showSuccessModal.value = true;
        setTimeout(() => {
          handleModalCloseAndRedirect();
        }, 3000);
      }
    } else {
      alert('訂單建立失敗：' + (response.data.message || '未知錯誤'));
    }
  } catch (error) {
    console.error('API 連線失敗:', error);
    alert('系統錯誤，請檢查網路連線或聯繫管理員');
  }
};
const handleModalCloseAndRedirect = () => {
  showSuccessModal.value = false;
  router.push('../workspace/orders');
};

const backcart = () => {
  // 假設你在 router/index.js 設定的購物車路徑是 /cart
  router.push('/cart');
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
                <input type="text" v-model="form.user_name" class="form-input" placeholder="請輸入姓名" :class="{
                  'is-error': errors.user_name,
                  'is-valid': !errors.user_name && form.user_name
                }" @blur="validateField('user_name')" @input="errors.user_name = ''" />
                <span class="error-msg p-p2" v-if="errors.user_name">{{ errors.user_name }}</span>
              </div>

              <div class="field">
                <label class="p-p1">手機</label>
                <input type="tel" v-model="form.user_phone" maxlength="10" class="form-input" placeholder="請輸入手機"
                  :class="{ 'is-error': errors.user_phone, 'is-valid': !errors.user_phone && form.user_phone }"
                  @blur="validateField('user_phone')" @input="errors.user_phone = ''" />
                <span class="error-msg p-p2" v-if="errors.user_phone">{{ errors.user_phone }}</span>
              </div>
            </div>
            <div class="field-flex">
              <div class="field">
                <label class="p-p1">電子信箱</label>
                <input type="email" v-model="form.user_email" class="form-input" placeholder="請輸入電子信箱"
                  :class="{ 'is-error': errors.user_email, 'is-valid': !errors.user_email && form.user_email }"
                  @blur="validateField('user_email')" @input="errors.user_email = ''" />
                <span class="error-msg p-p2" v-if="errors.user_email">{{ errors.user_email }}</span>
              </div>

              <div class="field">
                <label class="p-p1">家用電話</label>
                <input type="tel" v-model="form.user_tel" placeholder="請輸入電話 (選填)" class="form-input" />
              </div>
            </div>

            <div class="field lg">
              <label class="p-p1">地址</label>
              <input type="text" v-model="form.user_address" class="form-input" placeholder="請輸入地址"
                :class="{ 'is-error': errors.user_address, 'is-valid': !errors.user_address && form.user_address }"
                @blur="validateField('user_address')" @input="errors.user_address = ''" />
              <span class="error-msg p-p2" v-if="errors.user_address">{{ errors.user_address }}</span>
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
                    <input type="checkbox" :checked="form.shipping_type === 'new'"
                      @click="form.shipping_type = 'new'" />
                    <p class="p-p1">新增宅配地址</p>
                  </div>
                  <div class="same">
                    <input type="checkbox" :checked="form.shipping_type === 'same'"
                      @click="form.shipping_type = 'same'" />
                    <p class="p-p1">同訂購人</p>
                  </div>
                </div>

                <div class="add-address" v-show="form.shipping_type === 'new' || form.shipping_type === 'same'">
                  <div class="field-flex">
                    <div class="field add-field">
                      <label class="p-p1">收貨人</label>
                      <input type="text" v-model="form.recipient_name" class="form-input" placeholder="請輸入姓名"
                        :class="{ 'is-error': errors.recipient_name, 'is-valid': !errors.recipient_name && form.recipient_name }"
                        @blur="validateField('recipient_name')" @input="errors.recipient_name = ''" />
                      <span class="error-msg p-p2" v-if="errors.recipient_name">{{ errors.recipient_name }}</span>
                    </div>
                    <div class="field add-field">
                      <label class="p-p1">手機號碼</label>
                      <input type="text" maxlength="10" v-model="form.recipient_phone" class="form-input"
                        placeholder="請輸入手機"
                        :class="{ 'is-error': errors.recipient_phone, 'is-valid': !errors.recipient_phone && form.recipient_phone }"
                        @blur="validateField('recipient_phone')" @input="errors.recipient_phone = ''" />
                      <span class="error-msg p-p2" v-if="errors.recipient_phone">{{ errors.recipient_phone }}</span>
                    </div>
                  </div>
                  <div class="field-flex">
                    <div class="field add-field">
                      <label class="p-p1">家用電話</label>
                      <input type="text" v-model="form.recipient_tel" placeholder="請輸入電話號碼 (選填)" class="form-input" />
                    </div>

                    <div class="field add-field">
                      <label class="p-p1">寄件地址</label>
                      <input type="text" v-model="form.shipping_address" class="form-input" placeholder="請輸入地址"
                        :class="{ 'is-error': errors.shipping_address, 'is-valid': !errors.shipping_address && form.shipping_address }"
                        @blur="validateField('shipping_address')" @input="errors.shipping_address = ''" />
                      <span class="error-msg p-p2" v-if="errors.shipping_address">{{ errors.shipping_address }}</span>
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
                <input type="checkbox" :checked="form.payment_method === 'card'"
                  @click="form.payment_method = 'card'" />
                <p class="p-p1">信用卡付款</p>
              </div>

              <div class="same">
                <input type="checkbox" :checked="form.payment_method === 'cod'" @click="form.payment_method = 'cod'" />
                <p class="p-p1">貨到付款</p>
              </div>
            </div>

            <!-- <div v-show="form.payment_method === 'card'">
              <div class="pay-field">
                <label class="p-p1">卡號</label>
                <div class="card-row">
                  <input type="text" maxlength="4" v-model="form.card_num_1" class="form-input" placeholder="0000"
                    :class="{ 'is-error': errors.card_num_1, 'is-valid': !errors.card_num_1 && form.card_num_1 }"
                    @blur="validateField('card_num_1')" @input="handleCardInput($event, 'card_num_1', cardInput2)" />

                  <span class="separator">-</span>

                  <input type="text" maxlength="4" v-model="form.card_num_2" class="form-input" placeholder="0000"
                    ref="cardInput2"
                    :class="{ 'is-error': errors.card_num_2, 'is-valid': !errors.card_num_2 && form.card_num_2 }"
                    @blur="validateField('card_num_2')" @input="handleCardInput($event, 'card_num_2', cardInput3)" />

                  <span class="separator">-</span>

                  <input type="text" maxlength="4" v-model="form.card_num_3" class="form-input" placeholder="0000"
                    ref="cardInput3"
                    :class="{ 'is-error': errors.card_num_3, 'is-valid': !errors.card_num_3 && form.card_num_3 }"
                    @blur="validateField('card_num_3')" @input="handleCardInput($event, 'card_num_3', cardInput4)" />

                  <span class="separator">-</span>

                  <input type="text" maxlength="4" v-model="form.card_num_4" class="form-input" placeholder="0000"
                    ref="cardInput4"
                    :class="{ 'is-error': errors.card_num_4, 'is-valid': !errors.card_num_4 && form.card_num_4 }"
                    @blur="validateField('card_num_4')" @input="handleCardInput($event, 'card_num_4', null)" />
                </div>
                <span class="error-msg p-p2"
                  v-if="errors.card_num_1 || errors.card_num_2 || errors.card_num_3 || errors.card_num_4">
                  *請檢查卡號是否填寫完整
                </span>
              </div>
              <div class="field-flex">
                <div class="field">
                  <label class="p-p1">有效期限</label>
                  <input type="text" v-model="form.card_expiry" class="form-input" placeholder="MM/YY" maxlength="5"
                    :class="{ 'is-error': errors.card_expiry, 'is-valid': !errors.card_expiry && form.card_expiry }"
                    @blur="validateField('card_expiry')" @input="formatExpiryDate">
                  <span class="error-msg p-p2" v-if="errors.card_expiry">{{ errors.card_expiry }}</span>
                </div>

                <div class="field">
                  <label class="p-p1">安全碼</label>
                  <input type="text" maxlength="3" v-model="form.card_cvc" class="form-input" placeholder="CVC"
                    :class="{ 'is-error': errors.card_cvc, 'is-valid': !errors.card_cvc && form.card_cvc }"
                    @blur="validateField('card_cvc')" @input="errors.card_cvc = ''" />
                  <span class="error-msg p-p2" v-if="errors.card_cvc">{{ errors.card_cvc }}</span>
                </div>
              </div>
            </div> -->
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
          <div class="order-list" v-if="!isLoading">
            <CheckCard v-for="(item, index) in orderItems" :key="item.product_id" :product-name="item.product_name"
              :quantity="Number(item.quantity)" :price="Number(item.product_price)" :image="item.product_image" />
          </div>
          <div v-else style="text-align: center; padding: 20px;">資料加載中...</div>
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
  accent-color: $primary-color-700;
  width: 18px;
  height: 18px;
  cursor: pointer;
  margin-top: 13px;
  margin-right: 8px;
  vertical-align: middle;
}

.title {
  margin-top: 20px;
  margin-bottom: 10px;
}

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

.form-input.is-valid {
  border: 1px solid $primary-color-400;
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
  .deliver-text {
    align-items: stretch;
  }
}

// 信用卡
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

/* 訂單列表 */
.order-list {
  max-height: 500px;
  overflow-y: auto;
}

@media (max-width: 1024px) {
  .order-list {
    display: flex;
    gap: 15px;
    overflow-x: auto;
    overflow-y: hidden;
    -webkit-overflow-scrolling: touch;
    scrollbar-width: none;
  }

  .order-list ::-webkit-scrollbar {
    display: none;
  }
}

// 總計
.total-sum {
  display: flex;
  justify-content: space-around;
}

.row-text {
  display: flex;
  gap: 20px;
}
</style>