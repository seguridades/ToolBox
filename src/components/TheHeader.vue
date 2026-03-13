<template>
  <header class="bg-white border-b border-gray-100 sticky top-0 z-40">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-14 flex items-center justify-between gap-4">
      <!-- Logo -->
      <RouterLink to="/" class="flex items-center gap-2 shrink-0">
        <ShieldCheck class="w-6 h-6 text-primary" />
        <span class="font-bold text-text-main text-sm">
          toolbox<span class="text-primary">.</span>seguridades
        </span>
      </RouterLink>

      <!-- Nav páginas estáticas -->
      <nav class="hidden sm:flex items-center gap-5 text-sm text-text-meta">
        <RouterLink
          v-for="page in pages"
          :key="page.slug"
          :to="{ name: 'static-page', params: { slug: page.slug } }"
          class="hover:text-text-main transition-colors"
        >
          {{ page.label }}
        </RouterLink>
      </nav>

      <!-- Derecha -->
      <div class="flex items-center gap-3">
        <!-- Maleta (siempre visible) -->
        <button
          class="relative flex items-center gap-1.5 text-sm font-medium px-3 py-1.5 rounded-xl border border-gray-200 text-text-meta hover:border-primary hover:text-primary transition-colors"
          @click="$emit('toggle-maleta')"
        >
          <BriefcaseBusiness class="w-4 h-4" />
          <span class="hidden sm:inline">Maleta</span>
          <span
            v-if="maleta.count > 0"
            class="absolute -top-1.5 -right-1.5 bg-primary text-white text-[10px] font-bold rounded-full w-4 h-4 flex items-center justify-center"
          >
            {{ maleta.count }}
          </span>
        </button>

        <!-- Admin link si hay sesión -->
        <template v-if="auth.user">
          <RouterLink
            to="/admin"
            class="text-sm font-medium px-3 py-1.5 rounded-xl bg-primary text-white hover:bg-primary/90 transition-colors"
          >
            Admin
          </RouterLink>
          <button
            class="text-text-meta hover:text-text-main transition-colors"
            title="Cerrar sesión"
            @click="auth.signOut"
          >
            <LogOut class="w-4 h-4" />
          </button>
        </template>

        <button
          v-else
          class="text-text-meta hover:text-text-main transition-colors"
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
import { ShieldCheck, BriefcaseBusiness, LogIn, LogOut } from 'lucide-vue-next'
import { useMaletaStore } from '../stores/maleta'
import { useAuthStore } from '../stores/auth'
import LoginModal from './LoginModal.vue'

defineEmits(['toggle-maleta'])

const maleta    = useMaletaStore()
const auth      = useAuthStore()
const loginOpen = ref(false)

const pages = [
  { slug: 'acerca-de',      label: 'Acerca de' },
  { slug: 'principios',     label: 'Principios' },
  { slug: 'como-colaborar', label: 'Cómo colaborar' },
]
</script>
