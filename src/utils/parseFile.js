const base = import.meta.env.BASE_URL
export const parsePublicFile = (imgURL) => {
    return `${base}${imgURL}`
}