  if (imagePath.startsWith('/src/')) {
    try {
      const imageModules = import.meta.glob('@/assets/image/**/*.{png,jpg,jpeg,gif,svg}', {
        eager: true,
      })
      const fullPath = imagePath.replace('@/', '/src/')
      const matchedModule = imageModules[fullPath]

      if (matchedModule && matchedModule.default) {
        return matchedModule.default
      }
    } catch (error) {
      console.error('本地圖片載入失敗:', error)
    }
  }