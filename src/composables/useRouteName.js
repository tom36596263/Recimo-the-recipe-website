import { ref, computed } from 'vue';

const _detailName = ref('')

const setDetailName = (name) => {
    _detailName.value = name
}

const detailName = computed(() => {
    return _detailName.value
})

export const useRouteName = () => {

    return {
        detailName,
        setDetailName,
    }
}