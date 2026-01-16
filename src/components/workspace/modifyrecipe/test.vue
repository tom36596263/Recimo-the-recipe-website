<script setup>
const props = defineProps(['title', 'size', 'type']); // 必須定義才能在模板使用
const emit = defineEmits(['click-handler']);

const clickAction = () => {
    emit('click-handler', 1, 'someValue'); 
    }
    </script>

    <template>
    <button :class="[size, type]" @click="clickAction">
        {{ title }}
    </button>
    
</template>