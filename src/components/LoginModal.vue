<template>
  <Teleport to="body">
    <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4" @click.self="$emit('close')">
      <div class="bg-white dark:bg-gray-900 rounded-2xl shadow-xl w-full max-w-sm p-6 space-y-5">

        <div class="flex items-start justify-between">
          <div>
            <h2 class="font-bold text-text-main dark:text-gray-100 text-base">
              {{ mode === 'login' ? 'Acceso al panel' : 'Recuperar contraseña' }}
            </h2>
            <p class="text-xs text-text-meta dark:text-gray-400 mt-0.5">
              {{ mode === 'login' ? 'Solo para editores y admins de seguridades.org' : 'Te enviamos un enlace para restablecer tu contraseña.' }}
            </p>
          </div>
          <button class="text-text-meta dark:text-gray-400 hover:text-text-main dark:hover:text-gray-100" @click="$emit('close')">
            <X class="w-5 h-5" />
          </button>
        </div>

        <!-- Login -->
        <form v-if="mode === 'login'" class="space-y-4" @submit.prevent="submit">
          <div class="space-y-1">
            <label class="text-xs font-medium text-text-meta dark:text-gray-400 uppercase tracking-wide">Email</label>
            <input v-model="email" type="email" required autocomplete="email" class="field-input" />
          </div>
          <div class="space-y-1">
            <label class="text-xs font-medium text-text-meta dark:text-gray-400 uppercase tracking-wide">Contraseña</label>
            <input v-model="password" type="password" required autocomplete="current-password" class="field-input" />
          </div>
          <p v-if="error" class="text-xs text-red-500">{{ error }}</p>
          <button type="submit" :disabled="loading" class="w-full py-2.5 rounded-xl bg-primary text-white text-sm font-semibold hover:bg-primary/90 transition-colors disabled:opacity-50">
            {{ loading ? 'Ingresando…' : 'Ingresar' }}
          </button>
          <button type="button" class="w-full text-xs text-text-meta dark:text-gray-400 hover:text-primary transition-colors" @click="mode = 'recovery'">
            Olvidé mi contraseña
          </button>
        </form>

        <!-- Recovery -->
        <form v-else-if="mode === 'recovery'" class="space-y-4" @submit.prevent="sendRecovery">
          <div class="space-y-1">
            <label class="text-xs font-medium text-text-meta dark:text-gray-400 uppercase tracking-wide">Email</label>
            <input v-model="email" type="email" required autocomplete="email" class="field-input" />
          </div>
          <p v-if="error" class="text-xs text-red-500">{{ error }}</p>
          <button type="submit" :disabled="loading" class="w-full py-2.5 rounded-xl bg-primary text-white text-sm font-semibold hover:bg-primary/90 transition-colors disabled:opacity-50">
            {{ loading ? 'Enviando…' : 'Enviar enlace' }}
          </button>
          <button type="button" class="w-full text-xs text-text-meta dark:text-gray-400 hover:text-primary transition-colors" @click="mode = 'login'">
            ← Volver al login
          </button>
        </form>

        <!-- Sent confirmation -->
        <div v-else class="space-y-4 text-center py-2">
          <p class="text-sm text-text-main dark:text-gray-100">
            Revisá tu casilla <span class="font-medium text-primary">{{ email }}</span>
          </p>
          <p class="text-xs text-text-meta dark:text-gray-400">
            Si el email existe en el sistema, recibirás un enlace para restablecer tu contraseña en los próximos minutos.
          </p>
          <button type="button" class="text-xs text-text-meta dark:text-gray-400 hover:text-primary transition-colors" @click="mode = 'login'">
            ← Volver al login
          </button>
        </div>

      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { ref } from 'vue'
import { X } from 'lucide-vue-next'
import { supabase } from '../lib/supabase'
import { useAuthStore } from '../stores/auth'
import { useRouter } from 'vue-router'
import { useScrollLock } from '../composables/useScrollLock'

const emit = defineEmits(['close'])
useScrollLock()

const mode     = ref('login') // 'login' | 'recovery' | 'sent'
const email    = ref('')
const password = ref('')
const loading  = ref(false)
const error    = ref(null)
const auth     = useAuthStore()
const router   = useRouter()

async function submit() {
  loading.value = true
  error.value   = null
  const { data, error: err } = await supabase.auth.signInWithPassword({ email: email.value, password: password.value })
  if (err) {
    error.value = 'Credenciales incorrectas. Verificá tu email y contraseña.'
  } else {
    auth.user = data.user
    emit('close')
    router.push('/admin')
  }
  loading.value = false
}

async function sendRecovery() {
  loading.value = true
  error.value   = null
  await supabase.auth.resetPasswordForEmail(email.value, {
    redirectTo: `${window.location.origin}/reset-password`,
  })
  // Siempre mostramos el mensaje de confirmación (no revelar si el email existe)
  mode.value    = 'sent'
  loading.value = false
}
</script>

<style scoped>
.field-input {
  @apply w-full rounded-xl border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 px-3 py-2 text-sm text-text-main dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary;
}
</style>
