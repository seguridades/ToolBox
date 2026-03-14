<template>
  <div class="min-h-screen flex flex-col bg-white dark:bg-gray-900">
    <TheHeader @toggle-maleta="maletaOpen = !maletaOpen" />
    <RouterView v-slot="{ Component }">
      <Transition name="page-fade" mode="out-in">
        <component :is="Component" class="flex-1" />
      </Transition>
    </RouterView>
    <TheFooter />
  </div>

  <MaletaDrawer :open="maletaOpen" @close="maletaOpen = false" />
  <ToastContainer />
</template>

<script setup>
import { ref } from 'vue'
import TheHeader from './components/TheHeader.vue'
import TheFooter from './components/TheFooter.vue'
import MaletaDrawer from './components/MaletaDrawer.vue'
import ToastContainer from './components/ToastContainer.vue'
import { useTheme } from './composables/useTheme'

const maletaOpen = ref(false)
useTheme()
</script>
