<template>
  <Teleport to="body">
    <div
      class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4"
      @click.self="$emit('close')"
    >
      <div class="bg-white rounded-2xl shadow-xl w-full max-w-sm p-6 space-y-5">
        <div class="flex items-start justify-between">
          <div>
            <h2 class="font-bold text-text-main text-base">Acceso al panel</h2>
            <p class="text-xs text-text-meta mt-0.5">Solo para editores y admins de seguridades.org</p>
          </div>
          <button class="text-text-meta hover:text-text-main" @click="$emit('close')">
            <X class="w-5 h-5" />
          </button>
        </div>

        <form class="space-y-4" @submit.prevent="submit">
          <div class="space-y-1">
            <label class="text-xs font-medium text-text-meta uppercase tracking-wide">Email</label>
            <input
              v-model="email"
              type="email"
              required
              autocomplete="email"
              class="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>
          <div class="space-y-1">
            <label class="text-xs font-medium text-text-meta uppercase tracking-wide">Contraseña</label>
            <input
              v-model="password"
              type="password"
              required
              autocomplete="current-password"
              class="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>

          <p v-if="error" class="text-xs text-red-500">{{ error }}</p>

          <button
            type="submit"
            :disabled="loading"
            class="w-full py-2.5 rounded-xl bg-primary text-white text-sm font-semibold hover:bg-primary/90 transition-colors disabled:opacity-50"
          >
            {{ loading ? 'Ingresando…' : 'Ingresar' }}
          </button>
        </form>
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

const emit = defineEmits(['close'])

const email    = ref('')
const password = ref('')
const loading  = ref(false)
const error    = ref(null)

const auth   = useAuthStore()
const router = useRouter()

async function submit() {
  loading.value = true
  error.value   = null

  const { data, error: err } = await supabase.auth.signInWithPassword({
    email:    email.value,
    password: password.value,
  })

  if (err) {
    error.value = 'Credenciales incorrectas. Verificá tu email y contraseña.'
  } else {
    auth.user = data.user
    emit('close')
    router.push('/admin')
  }

  loading.value = false
}
</script>
