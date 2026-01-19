<script setup>
    import { ref, computed } from 'vue'

    const props = defineProps({
        initialLikes: {
            type: Number,
            default: 0
        },
        activeClass: {
            type: String,
            default: 'active'
        }
    });

    const emit = defineEmits(['update:liked']);

    const isLiked = ref(false);
    const toggleLike = () => {
        isLiked.value = !isLiked.value;
        emit('update:liked', isLikedvalue);
    }
    const displayLike = computed(() => {
        return props.initialLikes + (isLiked.value ? 1 : 0);
    })

</script>
<template>
    <button 
    class="like-btn action-btn"
    :class="{ [activeClass]:isLiked }"
    @click="toggleLike"
    >
        <i-material-symbols-thumb-up-outline v-if="!isLiked" class="action-icon" />
        <i-material-symbols-thumb-up v-else class="action-icon" />
        <span class="count">{{ displayLike }}</span>
    </button>
    
</template>
<style lang="scss" scoped>
    .action-btn {
        background: none;
        border: none;
        cursor: pointer;
        display: flex;
        align-items: center;
        color: $neutral-color-800;
        padding: 4px;
        transition: all 0.2s ease;

        .action-icon {
            font-size: 18px;
        }

        .count {
            margin-left: 4px;
            font-size: 14px;
            font-weight: 500;
        }

        &.active {
            color: $primary-color-700
        }
    }
</style>