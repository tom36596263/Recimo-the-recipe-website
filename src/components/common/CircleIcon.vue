<script setup>
import { computed } from 'vue';

const props = defineProps({
    size: {
        type: String,
        default: 'lg',
        validator: (value) => ['sm', 'lg'].includes(value)
    }
});
const sizeCircle = computed(() => {
    return props.size === 'sm' ? 'icon-circle--sm' : 'icon-circle--lg';
})
</script>
<template>
    <div class="icon-circle" :class="sizeCircle">
        <slot />
    </div>
</template>
<style lang="scss" scoped>
.icon-circle {
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    background-color: $neutral-color-white;
    border-radius: $radius-pill;
    font-size: 32px;
    color: $primary-color-700;
    transition: transform 0.3s ease;

    &:hover {
        transform: scale(1.1);
    }

    &--lg {
        width: 70px;
        height: 70px;
        font-size: 32px;
    }

    &--sm {
        width: 50px;
        height: 50px;
        font-size: 24px;
    }
}
</style>