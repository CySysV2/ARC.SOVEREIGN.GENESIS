<template>
  <div class="df-logo">
    <img :src="logoPath" alt="DF Logo" class="logo animated" />
  </div>
</template>

<script setup>
const props = defineProps({
  site: String,
  variant: {
    type: String,
    default: 'symbol' // 'symbol' | 'type' | 'full'
  }
})
const logoPath = `https://media.digital-fabrica.com/svg/${props.site}-${props.variant}.svg`
</script>

<style scoped>
.logo {
  height: 40px;
  transition: transform 0.3s ease, opacity 0.3s ease;
  filter: drop-shadow(0 0 2px #111);
}
.logo.animated:hover {
  transform: scale(1.05);
  opacity: 0.95;
}
</style> 