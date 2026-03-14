<template>
  <div class="min-h-[calc(100vh-3.5rem)] flex items-center justify-center px-4">
    <div class="bg-white dark:bg-gray-900 rounded-2xl shadow-xl w-full max-w-sm p-6 space-y-5">

      <!-- Esperando token -->
      <div v-if="!ready && !expired" class="text-center space-y-2 py-4">
        <div class="w-6 h-6 border-2 border-primary border-t-transparent rounded-full animate-spin mx-auto" />
        <p class="text-sm text-text-meta dark:text-gray-400">Verificando enlace…</p>
      </div>

      <!-- Enlace expirado -->
      <div v-else-if="expired" class="text-center space-y-3 py-4">
        <p class="text-sm text-text-main dark:text-gray-100 font-medium">El enlace expiró o no es válido.</p>
        <p class="text-xs text-text-meta dark:text-gray-400">Solicitá un nuevo enlace de recuperación.</p>
        <RouterLink to="/" class="text-xs text-primary hover:underline">Volver al inicio</RouterLink>
      </div>

      <!-- Formulario nueva contraseña -->
      <template v-else>
        <div>
          <h2 class="font-bold text-text-main dark:text-gray-100 text-base">
            {{ isInvite ? 'Crear contraseña' : 'Nueva contraseña' }}
          </h2>
          <p class="text-xs text-text-meta dark:text-gray-400 mt-0.5">
            {{ isInvite ? 'Establecé tu contraseña para activar tu cuenta.' : 'Ingresá tu nueva contraseña para continuar.' }}
          </p>
        </div>

        <form class="space-y-4" @submit.prevent="submit">
          <div class="space-y-1">
            <label class="text-xs font-medium text-text-meta dark:text-gray-400 uppercase tracking-wide">Nueva contraseña</label>
            <input v-model="password" type="password" required minlength="6" autocomplete="new-password" class="field-input" />
          </div>
          <div class="space-y-1">
            <label class="text-xs font-medium text-text-meta dark:text-gray-400 uppercase tracking-wide">Confirmar contraseña</label>
            <input v-model="confirm" type="password" required minlength="6" autocomplete="new-password" class="field-input" />
          </div>
          <p v-if="error" class="text-xs text-red-500">{{ error }}</p>
          <p v-if="success" class="text-xs text-green-600 dark:text-green-400">{{ success }}</p>
          <button
            type="submit"
            :disabled="loading"
            class="w-full py-2.5 rounded-xl bg-primary text-white text-sm font-semibold hover:bg-primary/90 transition-colors disabled:opacity-50"
          >
            {{ loading ? 'Guardando…' : 'Guardar contraseña' }}
          </button>
        </form>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'
import { useHead } from '../composables/useHead'

const route    = useRoute()
const router   = useRouter()
const isInvite = computed(() => route.query.invite === '1')

useHead({ title: computed(() => isInvite.value ? 'Crear contraseña' : 'Nueva contraseña') })

const password = ref('')
const confirm  = ref('')
const loading  = ref(false)
const error    = ref(null)
const success  = ref(null)
const ready    = ref(false)
const expired  = ref(false)

onMounted(async () => {
  // Invite flow: Supabase ya procesó el hash y tiene sesión activa
  const { data: { session } } = await supabase.auth.getSession()
  if (session) {
    ready.value = true
    return
  }

  // Recovery flow: esperar evento PASSWORD_RECOVERY
  supabase.auth.onAuthStateChange((event) => {
    if (event === 'PASSWORD_RECOVERY') {
      ready.value = true
    }
  })
  setTimeout(() => { if (!ready.value) expired.value = true }, 5000)
})

async function submit() {
  error.value = null
  if (password.value !== confirm.value) {
    error.value = 'Las contraseñas no coinciden.'
    return
  }
  loading.value = true
  const { error: err } = await supabase.auth.updateUser({ password: password.value })
  if (err) {
    error.value = 'No se pudo actualizar la contraseña. El enlace puede haber expirado.'
  } else {
    success.value = '¡Contraseña actualizada! Redirigiendo…'
    await supabase.auth.signOut()
    setTimeout(() => router.push('/'), 1500)
  }
  loading.value = false
}
</script>

<style scoped>
.field-input {
  @apply w-full rounded-xl border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 px-3 py-2 text-sm text-text-main dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary;
}
</style>
