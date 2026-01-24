<script setup>
    import { ref, onMounted } from 'vue'
    import { testApi, testApi2 } from '@/utils/publicApi'
    import { UploadTest } from '@/components/UploadTest.vue'
    const newData = ref(null)
    const userId = 16
    // https://tibamef2e.com/cjd101/g1/api/news/get_news.php
    // https://notes.webmix.cc/ajax/teach/api/list.php?user_id=16

    // onMounted(() => {
        
    //     // testApi.get('/news/get_news.php').then((res) => {
    //     testApi2.get(`/list.php?user_id=${ userId }`).then((res) => {
    //         console.log(res)
    //         // debugger
    //         if(res){
    //             newData.value = res.data ? res.data : null;
    //         }
    //     })
    // })
    onMounted (async() => {
        try{
            console.log(1)
            const res = await testApi2.get(`/list.php?user_id=${ userId }`)
            if(res && res.data){
                console.log(2)
                newData.value = res.data
            }console.log(3)
        }catch(error){
            debugger
        }
    })
</script>

<template>
    <h1>會員中心(設定)</h1>
    {{newData}}
    <UploadTest />
</template>

<style lang="scss" scoped>

//  lang="scss": 告訴 Vue 這裡要用 Scss 編譯
//  scoped: 確保這裡寫的 CSS 只會影響目前這個頁面，不會「跑去污染」到其他頁面的樣式。

</style>
