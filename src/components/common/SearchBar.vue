<script setup>
    import { computed } from 'vue'
    const model = defineModel({ type: String, default: '' });

    const props = defineProps({
        placeholder: {
            type: String,
            default: '尋找靈感食譜...'
        },
        size: {
            type: String,
            default: 'sm',
            validator: (value) => ['sm', 'lg'].includes(value)
        },
        maxWidth: {
            type: [String, Number],
            default: ''
        }
    });

    const emit = defineEmits(['search']);

    const searchClasses = computed(() => [
        'search-bar', `search-${props.size}`
    ]);

    const searchStyle = computed(() => {
        if(!props.maxWidth) return{};
        const w = typeof props.maxWidth === 'number' ? `${props.maxWidth}px`:props.maxWidth;
        return { maxWidth: w };
    });
    const handleEnter = () => {
        emit('search', model.value);
    }

</script>

<template>
    <div :class="searchClasses" :style="searchStyle">
        <i class="fa-solid fa-magnifying-glass icon-search"></i>
        <input 
        v-model="model"
        type="text"
        class="search-input p-p1"
        :placeholder="placeholder"
        @keyup.enter="handleEnter"
        />
    </div>
</template>

<style lang="scss" scoped>
.search-bar {
    display: flex;
    align-items: center;
    position: relative;
    width: 100%;
  // 2. 搜尋 Icon
    .icon-search {
        color: $neutral-color-800;
        position: absolute;
        left: 0;
        z-index: 2;
        pointer-events: none;
    }

  //Input
    .search-input {
        width: 100%;
        height: 100%;
        border: 1px solid $primary-color-700;
        outline: none;  //預設框拿掉
        background: $neutral-color-white;
        color: $neutral-color-800;
        border-radius: $radius-pill;
        transition: .3 ease;

        &:hover{
            border-color: $primary-color-800;
            background-color: rgba($primary-color-100, 0.1)
        }
        &::placeholder {
        color: $primary-color-700;
        opacity: 1;
        }
        &:focus{
            box-shadow: 0 0 0 4px rgba($primary-color-700, 0.1);
        }
    }
  // 大尺寸 (Large)
    &.search-lg {
        height: $height-search-lg;
        .icon-search {
            font-size: 20px;
            margin-left: 24px;
        }
        .search-input {
            font-size: 18px;
            padding-left: 56px;
            padding-right: 24px;
        }
    }

    // 小尺寸 (Small)
    &.search-sm {
        height: $height-search-sm; // 40px
        // max-width: 320px;

        .icon-search {
            font-size: 16px;
            margin-left: 16px;
        }
        .search-input {
            font-size: 14px;
            padding-left: 44px;
            padding-right: 16px;
        }
    }
}
</style>