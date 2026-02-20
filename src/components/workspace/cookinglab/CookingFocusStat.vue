<script setup>
import { computed } from 'vue';

const props = defineProps({
    totalMinutes: {
        type: Number,
        default: 0
    },
    totalLogs: {
        type: Number,
        default: 0
    },
    topTag: {
        type: String,
        default: '不限'
    }
});

const formattedTime = computed(() => {
    if (props.totalMinutes <= 0) return { hours: 0, mins: 0 };
    const hours = Math.floor(props.totalMinutes / 60);
    const mins = props.totalMinutes % 60;
    return { hours, mins };
});
</script>

<template>
    <div class="focus-stat-card">
        <div class="stat-item">
            <div class="icon-wrapper">
                <i-material-symbols-timer-outline class="icon" />
            </div>
            <div class="content">
                <div class="label">專注時刻</div>
                <div class="value-group">
                    <span class="number">{{ formattedTime.hours }}</span>
                    <span class="unit">小時</span>
                    <span class="number">{{ formattedTime.mins }}</span>
                    <span class="unit">分鐘</span>
                </div>
            </div>
        </div>

        <div class="divider"></div>

        <div class="stat-item">
            <div class="icon-wrapper">
                <i-material-symbols-skillet-outline class="icon" />
            </div>
            <div class="content">
                <div class="label">累計料理</div>
                <div class="value-group">
                    <span class="number">{{ totalLogs }}</span>
                    <span class="unit">道</span>
                </div>
            </div>
        </div>

        <div class="divider"></div>

        <div class="stat-item">
            <div class="icon-wrapper">
                <i-material-symbols-restaurant-menu class="icon" />
            </div>
            <div class="content">
                <div class="label">偏好風格</div>
                <div class="value-group">
                    <span class="text-value">{{ topTag || '探索中' }}</span>
                </div>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.focus-stat-card {
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: linear-gradient(135deg, $primary-color-800 0%, $primary-color-700 100%);
    color: white;
    padding: 24px 40px;
    border-radius: 16px;
    box-shadow: 0 4px 12px rgba($primary-color-800, 0.2);
    width: 100%;
}

.stat-item {
    display: flex;
    align-items: center;
    gap: 16px;
    flex: 1;
    justify-content: center;

    .icon-wrapper {
        background: rgba(255, 255, 255, 0.15);
        width: 56px;
        height: 56px;
        border-radius: 50%;
        display: flex;
        justify-content: center;
        align-items: center;
        flex-shrink: 0;

        .icon {
            font-size: 28px;
            color: white;
        }
    }

    .content {
        .label {
            font-size: 13px;
            opacity: 0.8;
            margin-bottom: 4px;
            font-weight: 500;
            letter-spacing: 1px;
        }

        .value-group {
            display: flex;
            align-items: baseline;
            gap: 4px;

            .number {
                font-size: 32px;
                font-weight: 700;
                line-height: 1;
            }

            .unit {
                font-size: 14px;
                opacity: 0.9;
                margin-right: 4px;
            }

            .text-value {
                font-size: 28px;
                font-weight: 700;
                line-height: 1;
                white-space: nowrap;
            }
        }
    }
}

.divider {
    width: 1px;
    height: 40px;
    background: rgba(255, 255, 255, 0.2);
    margin: 0 20px;
}

@media screen and (max-width: 992px) {
    .focus-stat-card {
        padding: 20px;
    }

    .stat-item {
        gap: 12px;

        .icon-wrapper {
            width: 48px;
            height: 48px;

            .icon {
                font-size: 24px;
            }
        }

        .content .value-group {

            .number,
            .text-value {
                font-size: 24px;
            }
        }
    }
}

@media screen and (max-width: 768px) {
    .focus-stat-card {
        flex-direction: column;
        align-items: flex-start;
        gap: 24px;
    }

    .stat-item {
        width: 100%;
        justify-content: flex-start;
    }

    .divider {
        width: 100%;
        height: 1px;
        margin: 0;
    }
}
</style>