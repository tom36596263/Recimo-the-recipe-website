<script setup>
import BenefitTable from '@/components/site/benefits/BenefitTable.vue';
import ContactForm from '@/components/site/benefits/ContactForm.vue';
import FAQCollapse from '@/components/site/benefits/FAQCollapse.vue';
import BenefitBanner from '../../components/site/benefits/BenefitBanner.vue';
</script>

<template>
    <div class="container">
        <div class="row">
        <div class="col-12">
            <BenefitBanner />
        </div>
        </div>
    </div>

    <!-- 背景延伸層，放在 container 外 -->
    <div class="benefit-table-bg">
        <div class="container">
        <div class="row">
            <div class="col-12">
            <BenefitTable />
            </div>
        </div>
        </div>
    </div>

    <div class="container">
        <div class="row">
        <div class="col-12">
            <FAQCollapse />
            <section class="contact-content">
                <ContactForm />
            </section>
            
        </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
    .benefit-table-bg {
        margin-top: 100px;
        margin-bottom: 80px;
        width: 100%;
        background-color: $neutral-color-100; 
        padding: 40px 0;           
    }

    .contact-content {
        margin-top: 100px;
        margin-bottom: 90px;
    }

</style>
