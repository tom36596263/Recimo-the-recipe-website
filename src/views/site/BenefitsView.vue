<script setup>
import { ref, onMounted, watch } from 'vue';
import BenefitTable from '@/components/site/benefits/BenefitTable.vue';
import ContactForm from '@/components/site/benefits/ContactForm.vue';
import FAQCollapse from '@/components/site/benefits/FAQCollapse.vue';
import BenefitBanner from '../../components/site/benefits/BenefitBanner.vue';
import LoginLightbox from '@/components/LoginLightbox.vue';

const isLoginVisible = ref(false);

// 燈箱開啟時鎖定 body 捲動
watch(isLoginVisible, (val) => {
    if (val) {
        document.body.style.overflow = 'hidden';
    } else {
        document.body.style.overflow = '';
    }
});

onMounted(() => {
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('is-visible');
            }
        });
    }, { threshold: 0.1 });
    const elements = document.querySelectorAll('.reveal');
    elements.forEach(el => observer.observe(el));
});
</script>

<template>
    <div class="container fade-in-init">
        <div class="row">
            <div class="col-12">
                <BenefitBanner @open-login="isLoginVisible = true" />
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

    <LoginLightbox v-if="isLoginVisible" @close="isLoginVisible = false" />
</template>

<style lang="scss" scoped>
/* 樣式保持不變 */
.benefit-table-bg {
    margin-top: 40px;
    margin-bottom: 40px;
    width: 100%;
    background-color: $neutral-color-100;
    padding: 40px 0;
}

.contact-content {
    margin-top: 100px;
    margin-bottom: 90px;
}

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