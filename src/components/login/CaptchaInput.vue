<script setup>
import { ref, computed, onMounted, watch } from 'vue'

const props = defineProps({
    modelValue: String
})
const emit = defineEmits(['update:modelValue', 'verified'])

const captchaInput = ref('')
const canvasRef = ref(null)
let currentCaptcha = ''

function rand(min, max) { return Math.floor(Math.random() * (max - min) + min) }

// 產生驗證碼
const generateCaptcha = () => {
    const canvas = canvasRef.value
    if (!canvas) return
    const ctx = canvas.getContext('2d')
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789'
    let code = ''

    ctx.clearRect(0, 0, canvas.width, canvas.height)
    ctx.fillStyle = '#f2f2f2'
    ctx.fillRect(0, 0, canvas.width, canvas.height)

    for (let i = 0; i < 4; i++) {
        const char = chars.charAt(Math.floor(Math.random() * chars.length))
        code += char
        ctx.font = 'bold 24px Arial'
        ctx.fillStyle = `rgb(${rand(0, 150)},${rand(0, 150)},${rand(0, 150)})`
        const x = 10 + i * 25
        const y = 28
        const angle = (rand(-20, 20) * Math.PI) / 180
        ctx.save()
        ctx.translate(x, y)
        ctx.rotate(angle)
        ctx.fillText(char, 0, 0)
        ctx.restore()
    }

    for (let i = 0; i < 5; i++) {
        ctx.strokeStyle = `rgba(${rand(0, 255)},${rand(0, 255)},${rand(0, 255)},0.5)`
        ctx.beginPath()
        ctx.moveTo(rand(0, canvas.width), rand(0, canvas.height))
        ctx.lineTo(rand(0, canvas.width), rand(0, canvas.height))
        ctx.stroke()
    }

    currentCaptcha = code.toLowerCase()
}

// 狀態計算
const status = computed(() => {
    if (!captchaInput.value) return ''
    return captchaInput.value.toLowerCase() === currentCaptcha ? 'success' : 'error'
})

// 訊息
const message = computed(() => {
    if (!captchaInput.value) return ''
    return status.value === 'success' ? '驗證正確' : '驗證碼錯誤'
})

// v-model
watch(captchaInput, val => {
    emit('update:modelValue', val)
    emit('verified', status.value === 'success')
})

onMounted(() => generateCaptcha())
</script>

<template>
    <div class="base-input-container" :class="{ 'is-error': status === 'error', 'is-success': status === 'success' }">
        <label class="form-label">驗證碼</label>
        <div style="display: flex; align-items: center; gap: 8px;">
            <input type="text" v-model="captchaInput" @keyup.enter="$emit('enter-press')" class="form-input"
                placeholder="請輸入驗證碼" />
            <canvas ref="canvasRef" width="120" height="40" class="captcha-canvas" @click="generateCaptcha"></canvas>
            <button type="button" class="captcha-refresh-btn" @click="generateCaptcha">🔄</button>
        </div>
        <div class="input-message">{{ message }}</div>
    </div>
</template>

<style lang="scss" scoped>
@import "@/assets/scss/abstracts/_mixins.scss";
@import "@/assets/scss/components-scss/_input.scss";

.base-input-container {
    margin: 10px 0;

    .form-input {
        $border-color: $neutral-color-400; // 一開始黑框 
    }

    &.is-error {
        .form-input {
            @include input-status($secondary-color-danger-700);
        }

        .input-message {
            visibility: visible;
            color: $secondary-color-danger-700;
        }
    }

    &.is-success {
        .form-input {
            @include input-status($secondary-color-success-700);
        }

        .input-message {
            visibility: visible;
            color: $secondary-color-success-700;
        }
    }

    .captcha-canvas {
        border-radius: 4px;
        border: 1px solid $neutral-color-400;
        cursor: pointer;
    }

    .captcha-refresh-btn {
        @include tag-base(28px, 14px, auto, 8px, $primary-color-100, $neutral-color-black, 4px);
        font-size: 16px;
        cursor: pointer;

        &:hover {
            background-color: $primary-color-400;
        }
    }
}
</style>
