<template>
  <Teleport to="body">
    <div
      class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4"
      @click.self="$emit('close')"
    >
      <div class="bg-white rounded-2xl shadow-xl w-full max-w-md p-6 space-y-5">
        <!-- Encabezado -->
        <div class="flex items-start justify-between gap-4">
          <div>
            <h2 class="font-bold text-text-main text-base">Reportar o comentar</h2>
            <p class="text-xs text-text-meta mt-0.5">No necesitás cuenta. Todos los campos son opcionales excepto el mensaje.</p>
          </div>
          <button class="text-text-meta hover:text-text-main transition-colors shrink-0" @click="$emit('close')">
            <X class="w-5 h-5" />
          </button>
        </div>

        <!-- Formulario -->
        <form class="space-y-4" @submit.prevent="submit">
          <!-- Tipo -->
          <div class="flex gap-3">
            <label
              v-for="opt in typeOptions"
              :key="opt.value"
              class="flex-1 flex items-center justify-center gap-2 py-2 rounded-xl border text-sm font-medium cursor-pointer transition-colors"
              :class="form.type === opt.value
                ? 'border-primary bg-primary/5 text-primary'
                : 'border-gray-200 text-text-meta hover:border-primary/50'"
            >
              <input type="radio" :value="opt.value" v-model="form.type" class="sr-only" />
              <component :is="opt.icon" class="w-4 h-4" />
              {{ opt.label }}
            </label>
          </div>

          <!-- Mensaje -->
          <div class="space-y-1">
            <label class="text-xs font-medium text-text-meta uppercase tracking-wide">Mensaje *</label>
            <textarea
              v-model="form.message"
              rows="3"
              placeholder="Describí tu comentario o reporte…"
              class="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm text-text-main placeholder:text-text-meta focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-none"
              required
            />
          </div>

          <!-- Alias -->
          <div class="space-y-1">
            <label class="text-xs font-medium text-text-meta uppercase tracking-wide">Alias <span class="normal-case font-normal">(opcional)</span></label>
            <input
              v-model="form.alias"
              type="text"
              placeholder="Cómo querés que te llamemos"
              class="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm text-text-main placeholder:text-text-meta focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>

          <!-- Email -->
          <div class="space-y-1">
            <label class="text-xs font-medium text-text-meta uppercase tracking-wide">Email <span class="normal-case font-normal">(opcional)</span></label>
            <input
              v-model="form.email"
              type="email"
              placeholder="Para seguimiento si lo autorizás"
              class="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm text-text-main placeholder:text-text-meta focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
            />
          </div>

          <!-- Consentimiento -->
          <label class="flex items-start gap-2.5 cursor-pointer">
            <input
              type="checkbox"
              v-model="form.contact_consent"
              class="mt-0.5 w-3.5 h-3.5 rounded accent-primary shrink-0"
            />
            <span class="text-xs text-text-meta leading-relaxed">
              Doy consentimiento para ser contactado para más información y seguimiento
            </span>
          </label>

          <!-- Error / éxito -->
          <p v-if="error" class="text-xs text-red-500">{{ error }}</p>
          <p v-if="sent" class="text-xs text-green-600 font-medium">¡Gracias! Tu mensaje fue enviado.</p>

          <!-- Botón -->
          <button
            type="submit"
            :disabled="loading || sent"
            class="w-full py-2.5 rounded-xl bg-primary text-white text-sm font-semibold hover:bg-primary/90 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
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

const props = defineProps({
  resourceId: { type: String, required: true },
})

const emit = defineEmits(['close'])

const typeOptions = [
  { value: 'comentario', label: 'Comentario', icon: MessageSquare },
  { value: 'reporte',    label: 'Reporte',    icon: Flag },
]

const form = reactive({
  type:            'comentario',
  message:         '',
  alias:           '',
  email:           '',
  contact_consent: false,
})

const loading = ref(false)
const error   = ref(null)
const sent    = ref(false)

async function submit() {
  if (!form.message.trim()) return
  loading.value = true
  error.value   = null

  const { error: err } = await supabase.from('resource_feedback').insert({
    resource_id:     props.resourceId,
    type:            form.type,
    message:         form.message.trim(),
    alias:           form.alias.trim() || null,
    email:           form.email.trim() || null,
    contact_consent: form.contact_consent,
  })

  if (err) {
    error.value = 'Hubo un error al enviar. Intentá de nuevo.'
  } else {
    sent.value = true
    setTimeout(() => emit('close'), 1800)
  }

  loading.value = false
}
</script>
