<template>
  <header class="bg-white dark:bg-gray-900 border-b border-gray-100 dark:border-gray-800 sticky top-0 z-40">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-14 flex items-center justify-between gap-4">
      <!-- Logo -->
      <RouterLink to="/" class="flex items-center gap-2 shrink-0">
        <Wrench class="w-5 h-5 text-primary" />
        <span class="font-bold text-text-main dark:text-gray-100 text-sm">
          Tool<span class="text-primary">Box</span><span class="text-text-meta dark:text-gray-400 font-normal"> — seguridades.org</span>
        </span>
      </RouterLink>

      <!-- Nav -->
      <nav class="hidden sm:flex items-center gap-5 text-sm text-text-meta dark:text-gray-400">
        <RouterLink to="/directorio" class="hover:text-text-main dark:hover:text-gray-100 transition-colors" active-class="text-text-main dark:text-gray-100 font-medium">
          Listado
        </RouterLink>
        <RouterLink
          v-for="page in pages"
          :key="page.slug"
          :to="{ name: 'static-page', params: { slug: page.slug } }"
          class="hover:text-text-main dark:hover:text-gray-100 transition-colors"
        >
          {{ page.label }}
        </RouterLink>
      </nav>

      <!-- Derecha -->
      <div class="flex items-center gap-2">
        <!-- Toggle dark/light -->
        <button
          class="p-1.5 rounded-xl text-text-meta dark:text-gray-400 hover:text-text-main dark:hover:text-gray-100 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
          :title="isDark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro'"
          @click="toggleTheme"
        >
          <Sun v-if="isDark" class="w-4 h-4" />
          <Moon v-else class="w-4 h-4" />
        </button>

        <!-- Maleta -->
        <button
          class="relative flex items-center gap-1.5 text-sm font-medium px-3 py-1.5 rounded-xl border border-gray-200 dark:border-gray-700 text-text-meta dark:text-gray-400 hover:border-primary hover:text-primary transition-colors"
          @click="$emit('toggle-maleta')"
        >
          <BriefcaseBusiness class="w-4 h-4" />
          <span class="hidden sm:inline">Mi Kit</span>
          <span
            v-if="maleta.count > 0"
            class="absolute -top-1.5 -right-1.5 bg-primary text-white text-[10px] font-bold rounded-full w-4 h-4 flex items-center justify-center"
          >{{ maleta.count }}</span>
        </button>

        <!-- Admin / Login -->
        <template v-if="auth.user">
          <RouterLink
            to="/admin"
            class="text-sm font-medium px-3 py-1.5 rounded-xl bg-primary text-white hover:bg-primary/90 transition-colors"
          >
            Admin
          </RouterLink>
          <button class="text-text-meta dark:text-gray-400 hover:text-text-main dark:hover:text-gray-100 transition-colors" title="Cerrar sesión" @click="handleSignOut">
            <LogOut class="w-4 h-4" />
          </button>
        </template>
        <button
          v-else
          class="text-text-meta dark:text-gray-400 hover:text-text-main dark:hover:text-gray-100 transition-colors"
          title="Ingresar"
          @click="loginOpen = true"
        >
          <LogIn class="w-4 h-4" />
        </button>
      </div>
    </div>
  </header>

  <LoginModal v-if="loginOpen" @close="loginOpen = false" />
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { Wrench, BriefcaseBusiness, LogIn, LogOut, Sun, Moon } from 'lucide-vue-next'
import { useMaletaStore } from '../stores/maleta'
import { useAuthStore } from '../stores/auth'
import { useTheme } from '../composables/useTheme'
import LoginModal from './LoginModal.vue'

defineEmits(['toggle-maleta'])

const maleta    = useMaletaStore()
const auth      = useAuthStore()
const router    = useRouter()
const loginOpen = ref(false)
const { isDark, toggle: toggleTheme } = useTheme()

async function handleSignOut() {
  await auth.signOut()
  router.push('/')
}

const pages = [
  { slug: 'acerca-de',      label: 'Acerca de' },
  { slug: 'principios',     label: 'Principios' },
  { slug: 'como-colaborar', label: 'Cómo colaborar' },
]
</script>
