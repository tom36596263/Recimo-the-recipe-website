<script setup>
import { computed, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import { parsePublicFile } from '@/utils/parseFile';

const props = defineProps({
    recipe: {
        type: Object,
        default: () => ({})
    },
    logs: {
        type: Array,
        default: () => []
    }
});

const emit = defineEmits(['close']);
const router = useRouter();

const getDifficultyLabel = (value) => {
    const val = Math.round(parseFloat(value));
    // 判斷：若為 0 或 1 都回傳「簡單」
    if (val <= 1) return '簡單';
    if (val === 2) return '中等';
    if (val === 3) return '困難';
    return '未知';
};

onMounted(() => document.body.style.overflow = 'hidden');
onUnmounted(() => document.body.style.overflow = '');

const goToLogDetail = (logId) => {
    router.push({
        name: 'view-cooking-log',
        params: { logId: logId }
    });
    emit('close');
};

const formatDate = (dateString) => {
    if (!dateString) return '';
    const date = new Date(dateString);
    return `${date.getFullYear()}/${(date.getMonth() + 1).toString().padStart(2, '0')}/${date.getDate().toString().padStart(2, '0')}`;
};

const formatTime = (timeString) => {
    if (!timeString) return '0分';
    const [h, m] = timeString.split(':');
    if (parseInt(h) > 0) return `${parseInt(h)}小時${parseInt(m)}分`;
    return `${parseInt(m)}分鐘`;
};

const recipeImage = computed(() => {
    const rawPath = props.recipe.recipe_image_url || props.recipe.image_url;
    if (!rawPath) return '';
    return rawPath.startsWith('http') ? rawPath : parsePublicFile(rawPath);
});

const getLogImage = (url) => {
    if (!url) return null;
    return url.startsWith('http') ? url : parsePublicFile(url);
};
</script>

<template>
    <Teleport to="body">
        <div class="modal-backdrop" @click.self="emit('close')">
            <div class="modal-container">
                <button class="close-btn" @click="emit('close')">
                    <i-material-symbols-close />
                </button>

                <div class="modal-body">
                    <div class="recipe-sidebar">
                        <div class="recipe-cover">
                            <img :src="recipeImage" :alt="recipe.recipe_name" />
                        </div>
                        <h3 class="recipe-title">{{ recipe.recipe_title }}</h3>

                        <div class="stat-box">
                            <div class="label">累計製作</div>
                            <div class="value">{{ logs.length }} <span class="unit">次</span></div>
                        </div>
                    </div>

                    <div class="logs-content">
                        <h4 class="timeline-title zh-h4-bold">烹飪足跡</h4>

                        <div class="timeline">
                            <div v-for="(log, index) in logs" :key="log.cooking_log_id" class="timeline-item">
                                <div class="date-label">{{ formatDate(log.logged_at) }}</div>

                                <div class="log-card" @click="goToLogDetail(log.cooking_log_id)">
                                    <div class="log-header">
                                        <div class="rating">
                                            <i-material-symbols-star class="star-icon" />
                                            <span>{{ parseFloat(log.satisfaction_rating) }}</span>
                                        </div>
                                        <div class="duration">
                                            <i-material-symbols-timer-outline class="time-icon" />
                                            {{ formatTime(log.actual_time) }}
                                        </div>
                                    </div>

                                    <div class="log-detail">
                                        <div v-if="log.log_image_url" class="log-photo">
                                            <img :src="getLogImage(log.log_image_url)" alt="成品圖" />
                                        </div>
                                        <div class="log-text">
                                            <p class="summary">{{ log.log_summary || '這次沒有寫下心得...' }}</p>

                                            <div class="tags">
                                                <span class="tag difficulty">流程: {{
                                                    getDifficultyLabel(log.complexity_rating) }}</span>
                                                <span class="tag skill">技法: {{ getDifficultyLabel(log.technique_rating)
                                                    }}</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </Teleport>
</template>

<style lang="scss" scoped>
.modal-backdrop {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.6);
    backdrop-filter: blur(4px);
    z-index: 9999;
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 20px;
}

.modal-container {
    background: white;
    width: 100%;
    max-width: 900px;
    height: 85vh;
    border-radius: 16px;
    position: relative;
    overflow: hidden;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
    display: flex;
    flex-direction: column;
    animation: modalSlideIn 0.3s ease-out;
    // padding: 5px;
}

.close-btn {
    position: absolute;
    top: 16px;
    right: 16px;
    // background: rgba(0, 0, 0, 0.05);
    border: none;
    width: 36px;
    height: 36px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    z-index: 10;
    transition: all 0.2s;
    font-size: 20px;
    color: $neutral-color-400;
}

.modal-body {
    display: flex;
    height: 100%;
    overflow: hidden;
}

.recipe-sidebar {
    width: 35%;
    background: $primary-color-100;
    padding: 40px 30px;
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    border-right: 1px solid $neutral-color-100;

    .recipe-cover {
        width: 160px;
        height: 160px;
        border-radius: 50%;
        overflow: hidden;
        margin-bottom: 20px;
        border: 4px solid white;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);

        img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
    }

    .recipe-title {
        font-size: 22px;
        color: $neutral-color-800;
        margin-bottom: 30px;
        line-height: 1.4;
    }

    .stat-box {
        background: $neutral-color-white;
        padding: 20px;
        border-radius: 12px;
        width: 100%;

        .label {
            font-size: 14px;
            color: $neutral-color-400;
            margin-bottom: 8px;
        }

        .value {
            font-size: 32px;
            font-weight: 700;
            color: $primary-color-700;

            .unit {
                font-size: 14px;
                font-weight: 400;
                color: $neutral-color-700;
            }
        }
    }
}

.logs-content {
    width: 65%;
    padding: 40px;
    overflow-y: auto;
    background: #fff;

    &::-webkit-scrollbar {
        width: 10px;
    }

    &::-webkit-scrollbar-thumb {
        background-color: $neutral-color-400;
        border-radius: 3px;

        &:hover {
            background-color: $accent-color-400;
        }
    }

    .timeline-title {
        font-size: 20px;
        margin-bottom: 30px;
        color: $primary-color-800;
    }
}

.timeline {
    position: relative;
    padding-left: 20px;

    &::before {
        content: '';
        position: absolute;
        left: 2.3px;
        top: 10px;
        bottom: 0;
        width: 2px;
        background: $neutral-color-100;
    }
}

.timeline-item {
    position: relative;
    margin-bottom: 30px;

    &::before {
        content: '';
        position: absolute;
        left: -24px;
        top: 0px;
        width: 10px;
        height: 10px;
        background: $primary-color-700;
        border-radius: 50%;
        border: 2px solid white;
        box-shadow: 0 0 0 2px $primary-color-100;
    }

    .date-label {
        font-size: 14px;
        color: $neutral-color-400;
        margin-bottom: 8px;
        font-weight: 500;
    }
}

.log-card {
    background: white;
    border: 1px solid $neutral-color-100;
    border-radius: 12px;
    padding: 16px;
    transition: all 0.2s;
    cursor: pointer;

    &:hover {
        border-color: $accent-color-400;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        transform: translateY(-2px);
        background-color: $accent-color-100;
    }

    .log-header {
        display: flex;
        justify-content: space-between;
        margin-bottom: 12px;
        padding-bottom: 12px;
        border-bottom: 1px dashed $neutral-color-100;

        .rating {
            color: $secondary-color-warning-700;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .duration {
            color: $neutral-color-400;
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 4px;
        }
    }

    .log-detail {
        display: flex;
        gap: 16px;

        .log-photo {
            width: 80px;
            height: 80px;
            flex-shrink: 0;
            border-radius: 8px;
            overflow: hidden;
            border: 1px solid $neutral-color-100;

            img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }
        }

        .log-text {
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: space-between;

            .summary {
                font-size: 14px;
                color: $neutral-color-700;
                line-height: 1.5;
                margin-bottom: 8px;
            }

            .tags {
                display: flex;
                gap: 8px;

                .tag {
                    font-size: 12px;
                    padding: 2px 8px;
                    border-radius: 4px;
                    background: $neutral-color-100;
                    color: $neutral-color-700;
                }
            }
        }
    }
}

@keyframes modalSlideIn {
    from {
        opacity: 0;
        transform: translateY(20px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}

@media screen and (max-width: 768px) {
    .modal-body {
        flex-direction: column;
        overflow-y: auto;
    }

    .recipe-sidebar {
        width: 100%;
        border-right: none;
        border-bottom: 1px solid $neutral-color-100;
        padding: 24px;
        flex-direction: row;
        gap: 20px;
        text-align: left;

        .recipe-cover {
            width: 80px;
            height: 80px;
            margin-bottom: 0;
        }

        .recipe-title {
            margin-bottom: 8px;
            font-size: 18px;
        }

        .stat-box {
            width: auto;
            padding: 10px 16px;

            .value {
                font-size: 20px;
            }
        }
    }

    .logs-content {
        width: 100%;
        overflow: visible;
    }
}
</style>