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
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import TheHeader from './components/TheHeader.vue'
import TheFooter from './components/TheFooter.vue'
import MaletaDrawer from './components/MaletaDrawer.vue'
import ToastContainer from './components/ToastContainer.vue'
import { useTheme } from './composables/useTheme'

const maletaOpen = ref(false)
const router = useRouter()
useTheme()

onMounted(() => {
  const hash = window.location.hash
  if (hash.includes('type=invite')) {
    router.replace('/reset-password?invite=1')
  } else if (hash.includes('error=')) {
    router.replace('/reset-password?error=1')
  }
})
</script>
