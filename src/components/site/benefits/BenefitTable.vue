<script setup>
// 表格資料不變
const benefitData = [
    { name: '查看官方食譜', guest: 'check', member: 'check' },
    { name: '查看社群食譜', guest: '', member: 'check' },
    { name: '食譜加入收藏', guest: '', member: 'check' },
    { name: '改編官方食譜', guest: '', member: 'check' },
    { name: '查看食譜改編集', guest: '', member: 'check' },
    { name: '開始烹飪、食譜筆記、食譜心得', guest: '', member: 'check' },
    { name: '靈感廚房', guest: '無個人化推薦', member: 'check' },
    { name: 'Recimo商城', guest: '僅可查看商品', member: 'check' },
    { name: '我的廚房', guest: '', member: 'check' },
    { name: '我的烹飪實驗室', guest: '', member: 'check' },
    { name: '備餐計畫', guest: '', member: 'check' },
];
</script>

<template>
    <div class="benefit-table-wrapper">
        <img src="@/assets/images/benifit/crown.svg" class="crown-icon" alt="crown" />

        <div class="row table-header">
        <div class="col-4"></div>
        <div class="col-4 text-center p-p1">沒有註冊</div>
        <div class="col-4 text-center p-p1">有註冊</div>
        </div>

        <div v-for="(item, index) in benefitData" :key="index" class="row table-row">
        <div class="col-4 item-name">
            <p class="p-p1">{{ item.name }}</p>
        </div>

        <div class="col-4 text-center">
            <img v-if="item.guest" src="@/assets/images/benifit/formcheck.svg" class="check-icon" />
            <span v-if="item.guest && item.guest !== 'check'" class="p-p1">{{ item.guest }}</span>
        </div>

        <div class="col-4 text-center">
            <img v-if="item.member" src="@/assets/images/benifit/formcheck.svg" class="check-icon" />
            <span v-if="item.member && item.member !== 'check'" class="p-p1">{{ item.member }}</span>
        </div>
        </div>
    </div>

    <!-- 新增 wrapper -->
    <div class="btn-wrapper">
        <CircleBtn title="查看功能介紹" type="green" href="./about" class="more-btn" />
    </div>
</template>

<style lang="scss" scoped>
.btn-wrapper {
    text-align: center;       
    margin-top: 30px;        
}

    .benefit-table-wrapper {
        position: relative;
        border: 1px solid $primary-color-800;
        border-radius: 12px;
        background-color: $primary-color-100;
        margin-top: 50px;
        overflow: visible;

    .row {
        margin-left: 0;
        margin-right: 0;
    }

    [class*="col-"] {
        padding-left: 8px;
        padding-right: 8px;
    }

    .table-header {
    background-color: $primary-color-400;
    color: $primary-color-800;
    border-bottom: 1px solid $primary-color-800;
    border-radius: 11px 11px 0 0;
    font-weight: bold;


    [class^="col-"] {
        padding: 12px 0;
        display: flex;
        align-items: center;
        justify-content: center; 
        text-align: center;
        &:not(:last-child) {
            border-right: 1px solid $primary-color-800;
        }
    }
}


    .table-row {
            display: flex;
            border-bottom: 1px solid $primary-color-800;
            align-items: stretch;

            &:last-child { border-bottom: none; }

            [class^="col-"] {
                display: flex;
                align-items: center;
                justify-content: center;
                padding:  10px;

            &:not(:last-child) { border-right: 1px solid $primary-color-800; }
        }

        .item-name {
            justify-content: center;
            padding-left: 16px;
        }

        .note-text {
            font-size: 14px;
            color: $primary-color-800;
        }

        .check-icon {
            width: 25px;
            height: 25px;
        }
    }

    .crown-icon {
        position: absolute;
        top: -50px;
        right: 40px;
        width: 50px;
        z-index: 10;
    }
}
</style>
