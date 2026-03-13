<template>
  <div class="min-h-screen flex flex-col bg-white">
    <TheHeader @toggle-maleta="maletaOpen = !maletaOpen" />
    <RouterView class="flex-1" />
    <TheFooter />
  </div>

  <MaletaDrawer :open="maletaOpen" @close="maletaOpen = false" />
</template>

<script setup>
import { ref } from 'vue'
import TheHeader from './components/TheHeader.vue'
import TheFooter from './components/TheFooter.vue'
import MaletaDrawer from './components/MaletaDrawer.vue'

const maletaOpen = ref(false)
</script>
