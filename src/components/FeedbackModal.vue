<template>
  <Teleport to="body">
    <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4" @click.self="$emit('close')">
      <div class="bg-white dark:bg-gray-900 rounded-2xl shadow-xl w-full max-w-md p-6 space-y-5">
        <div class="flex items-start justify-between gap-4">
          <div>
            <h2 class="font-bold text-text-main dark:text-gray-100 text-base">Reportar o comentar</h2>
            <p class="text-xs text-text-meta dark:text-gray-400 mt-0.5">No necesitás cuenta. Todos los campos son opcionales excepto el mensaje.</p>
          </div>
          <button class="text-text-meta dark:text-gray-400 hover:text-text-main dark:hover:text-gray-100 transition-colors shrink-0" @click="$emit('close')">
            <X class="w-5 h-5" />
          </button>
        </div>

        <form class="space-y-4" @submit.prevent="submit">
          <div class="flex gap-3">
            <label
              v-for="opt in typeOptions"
              :key="opt.value"
              class="flex-1 flex items-center justify-center gap-2 py-2 rounded-xl border text-sm font-medium cursor-pointer transition-colors"
              :class="form.type === opt.value
                ? 'border-primary bg-primary/5 text-primary'
                : 'border-gray-200 dark:border-gray-700 text-text-meta dark:text-gray-400 hover:border-primary/50'"
            >
              <input type="radio" :value="opt.value" v-model="form.type" class="sr-only" />
              <component :is="opt.icon" class="w-4 h-4" />
              {{ opt.label }}
            </label>
          </div>

          <div class="space-y-1">
            <label class="text-xs font-medium text-text-meta dark:text-gray-400 uppercase tracking-wide">Mensaje *</label>
            <textarea v-model="form.message" rows="3" placeholder="Describí tu comentario o reporte…" class="field-input resize-none" required />
          </div>

          <div class="space-y-1">
            <label class="text-xs font-medium text-text-meta dark:text-gray-400 uppercase tracking-wide">Alias <span class="normal-case font-normal">(opcional)</span></label>
            <input v-model="form.alias" type="text" placeholder="Cómo querés que te llamemos" class="field-input" />
          </div>

          <div class="space-y-1">
            <label class="text-xs font-medium text-text-meta dark:text-gray-400 uppercase tracking-wide">Email <span class="normal-case font-normal">(opcional)</span></label>
            <input v-model="form.email" type="email" placeholder="Para seguimiento si lo autorizás" class="field-input" />
          </div>

          <label class="flex items-start gap-2.5 cursor-pointer">
            <input type="checkbox" v-model="form.contact_consent" class="mt-0.5 w-3.5 h-3.5 rounded accent-primary shrink-0" />
            <span class="text-xs text-text-meta dark:text-gray-400 leading-relaxed">
              Doy consentimiento para ser contactado para más información y seguimiento
            </span>
          </label>

          <p v-if="error" class="text-xs text-red-500">{{ error }}</p>

          <button type="submit" :disabled="loading" class="w-full py-2.5 rounded-xl bg-primary text-white text-sm font-semibold hover:bg-primary/90 transition-colors disabled:opacity-50 disabled:cursor-not-allowed">
            {{ loading ? 'Enviando…' : 'Enviar' }}
          </button>
        </form>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { X, Flag, MessageSquare } from 'lucide-vue-next'
import { supabase } from '../lib/supabase'
import { useScrollLock } from '../composables/useScrollLock'
import { useToast } from '../composables/useToast'

const props = defineProps({ resourceId: { type: String, required: true } })
const emit  = defineEmits(['close'])

useScrollLock()
const { add } = useToast()

const typeOptions = [
  { value: 'comentario', label: 'Comentario', icon: MessageSquare },
  { value: 'reporte',    label: 'Reporte',    icon: Flag },
]

const form = reactive({ type: 'comentario', message: '', alias: '', email: '', contact_consent: false })
const loading = ref(false)
const error   = ref(null)

async function submit() {
  if (!form.message.trim()) return
  loading.value = true
  error.value   = null

  const { error: err } = await supabase.from('resource_feedback').insert({
    resource_id: props.resourceId,
    type:        form.type,
    message:     form.message.trim(),
    alias:       form.alias.trim() || null,
    email:       form.email.trim() || null,
    contact_consent: form.contact_consent,
  })

  if (err) {
    error.value = 'Hubo un error al enviar. Intentá de nuevo.'
  } else {
    add('¡Gracias! Tu mensaje fue enviado.')
    emit('close')
  }
  loading.value = false
}
</script>

<style scoped>
.field-input {
  @apply w-full rounded-xl border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 px-3 py-2 text-sm text-text-main dark:text-gray-100 placeholder:text-text-meta dark:placeholder:text-gray-500 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary;
}
</style>
