<script setup>
import { ref, computed, onMounted } from 'vue';
import { parsePublicFile } from '@/utils/parseFile.js';

const props = defineProps({
    templates: { type: Array, default: () => [] }
});

const emit = defineEmits(['close', 'select']);

const closePanel = () => { emit("close") };

const selectTemplate = (item) => {
    emit('select', {
        type: 1,
        id: item.cover_template_id,
        url: item.template_url
    });
    closePanel();
};
</script>

<template>
    <Teleport to="body">
        <div class="overlay" @click.self="closePanel">
            <div class="cover-panel">
                <div class="cover-panel__header">
                    <div class="cover-panel__title zh-h4-bold">選擇封面圖片</div>
                    <div class="cover-panel__close-btn" @click="closePanel">
                        <i-material-symbols-close />
                    </div>
                </div>

                <div class="cover-panel__body">
                    <div class="grid-container">
                        <div class="cover-card cover-card--special">
                            <i-material-symbols-add-rounded />
                        </div>

                        <div class="cover-card cover-card--system">
                            <span class="p-p2">系統預設</span>
                        </div>

                        <div v-for="item in templates" :key="item.cover_template_id" class="cover-card"
                            @click="selectTemplate(item)">
                            <img :src="parsePublicFile(item.template_url)" :alt="item.template_name" />
                            <div class="cover-card__name">{{ item.template_name }}</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </Teleport>
</template>

<style lang="scss" scoped>
.overlay {
    z-index: 1000;
    position: fixed;
    bottom: 0;
    right: 0;
    width: 510px;
    height: 100vh;
    background-color: rgba($neutral-color-black, 0.3);
    display: flex;
    justify-content: center;
    align-items: flex-end;
}

.cover-panel {
    bottom: 0;
    width: 450px;
    height: 80vh;
    background-color: $neutral-color-white;
    border-radius: 10px 10px 0 0;
    padding: 20px;

    &__header {
        display: flex;
        justify-content: space-between;
    }

    &__title {
        color: $primary-color-800;
    }

    &__close-btn {
        color: $neutral-color-700;
    }
}

.grid-container {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 15px;
    margin-top: 20px;
    max-height: 60vh;
    overflow-y: auto;
    padding-right: 5px;
}

.cover-card {
    aspect-ratio: 1 /1;
    background-color: $neutral-color-100;
    border-radius: 12px;
    cursor: pointer;
    position: relative;
    overflow: hidden;
    border: 2px solid transparent;
    transition: 0.3s;

    img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    &__name {
        position: absolute;
        bottom: 0;
        width: 100%;
        background: rgba($neutral-color-black, 0.4);
        color: #fff;
        font-size: 12px;
        text-align: center;
        padding: 2px 0;
        opacity: 0;
        transition: 0.3s;
    }

    &:hover {
        border-color: $primary-color-400;

        .cover-card__name {
            opacity: 1;
        }
    }

    &--special,
    &--system {
        display: flex;
        justify-content: center;
        align-items: center;
        color: $neutral-color-400;
        background: $neutral-color-100;
        border: 2px dashed $neutral-color-400;

        svg {
            font-size: 30px;
        }
    }
}
</style>