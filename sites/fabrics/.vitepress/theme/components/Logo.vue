<template>
  <div class="logo-wrapper">
    <transition name="fade" mode="out-in">
      <img
        :src="variant === 'symbol' ? `/svg/${site}-symbol.svg` : variant === 'type' ? `/svg/${site}-type.svg` : `/svg/${site}-full.svg`"
        class="logo"
        :alt="`${site} logo (${variant})`"
      />
    </transition>
  </div>
</template>

<script setup>
const props = defineProps({
  site: String,
  variant: {
    type: String,
    default: 'full' // 'symbol', 'type', or 'full'
  }
})
</script>

<style scoped>
.logo-wrapper {
  display: flex;
  align-items: center;
}
.logo {
  height: 36px;
  transition: all 0.3s ease;
}
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.3s ease;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}
</style> 