<script setup>
import { ref, onMounted } from 'vue';
import BenefitTable from '@/components/site/benefits/BenefitTable.vue';
import ContactForm from '@/components/site/benefits/ContactForm.vue';
import FAQCollapse from '@/components/site/benefits/FAQCollapse.vue';
import BenefitBanner from '../../components/site/benefits/BenefitBanner.vue';

// 建立一個簡單的觀察者來觸發動畫
const sections = ref([]);
onMounted(() => {
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('is-visible');
            }
        });
    }, { threshold: 0.1 }); // 只要看到 10% 就觸發

    const elements = document.querySelectorAll('.reveal');
    elements.forEach(el => observer.observe(el));
});
</script>

<template>
    <div class="container fade-in-init">
        <div class="row">
            <div class="col-12">
                <BenefitBanner />
            </div>
        </div>
    </div>

    <div class="benefit-table-bg reveal">
        <div class="container">
            <div class="row">
                <div class="col-12">
                    <BenefitTable />
                </div>
            </div>
        </div>
    </div>

    <div class="container reveal">
        <div class="row">
            <div class="col-12">
                <FAQCollapse />
                <section class="contact-content reveal">
                    <ContactForm />
                </section>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
// --- 基礎樣式 ---
.benefit-table-bg {
    margin-top: 100px;
    margin-bottom: 80px;
    width: 100%;
    background-color: $neutral-color-100;
    padding: 80px 0; // 稍微增加 padding 讓背景更有呼吸感
}

.contact-content {
    margin-top: 100px;
    margin-bottom: 90px;
}

// --- 動畫定義 ---

.fade-in-init {
    animation: fadeInScale 0.8s ease-out forwards;
}

@keyframes fadeInScale {
    from {
        opacity: 0;
        transform: scale(0.98);
    }

    to {
        opacity: 1;
        transform: scale(1);
    }
}

// 捲動揭示動畫
.reveal {
    opacity: 0;
    transform: translateY(30px);
    transition: all 0.8s cubic-bezier(0.21, 0.6, 0.35, 1);

    &.is-visible {
        opacity: 1;
        transform: translateY(0);
    }
}


.contact-content.reveal {
    transition-delay: 0.2s;
}
</style>