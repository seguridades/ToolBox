<template>
  <div class="space-y-5">
    <h2 class="font-bold text-text-main dark:text-gray-100">Importar JSON</h2>

    <!-- Drop zone -->
    <div
      class="border-2 border-dashed rounded-2xl p-8 text-center transition-colors cursor-pointer"
      :class="dragging
        ? 'border-primary bg-primary/5'
        : 'border-gray-200 dark:border-gray-700 hover:border-primary/40'"
      @dragover.prevent="dragging = true"
      @dragleave.prevent="dragging = false"
      @drop.prevent="onDrop"
      @click="fileInput.click()"
    >
      <Upload class="w-7 h-7 mx-auto mb-2 text-text-meta dark:text-gray-400" />
      <p class="text-sm text-text-meta dark:text-gray-400">
        Arrastrá un archivo <strong>.json</strong> o hacé clic para seleccionarlo
      </p>
      <input ref="fileInput" type="file" accept=".json,application/json" class="sr-only" @change="onFileChange" />
    </div>

    <!-- Separator -->
    <div class="flex items-center gap-3 text-xs text-text-meta dark:text-gray-400">
      <div class="flex-1 border-t border-gray-100 dark:border-gray-800" />
      <span>o pegá el JSON directamente</span>
      <div class="flex-1 border-t border-gray-100 dark:border-gray-800" />
    </div>

    <!-- Textarea -->
    <textarea
      v-model="rawJson"
      rows="7"
      placeholder='[{ "title": "Signal", "type": "tool", "scope": ["digital"], "category": "Mensajería", "pricing": "gratis", "platforms": ["android", "ios"], "is_opensource": true }]'
      class="w-full rounded-xl border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 px-3 py-2 text-sm font-mono text-text-main dark:text-gray-100 placeholder:text-text-meta dark:placeholder:text-gray-500 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary resize-y"
    />

    <!-- Actions -->
    <div class="flex items-center gap-3">
      <button
        :disabled="!rawJson.trim()"
        class="px-4 py-2 rounded-xl bg-primary text-white text-sm font-medium hover:bg-primary/90 transition-colors disabled:opacity-40 disabled:cursor-not-allowed"
        @click="analyze"
      >
        Analizar
      </button>
      <button
        v-if="rows.length || rawJson || parseError"
        class="text-xs text-text-meta dark:text-gray-400 hover:text-text-main dark:hover:text-gray-100 transition-colors"
        @click="reset"
      >
        Limpiar
      </button>
    </div>

    <!-- Parse error -->
    <p v-if="parseError" class="text-sm text-red-500 bg-red-50 dark:bg-red-900/20 rounded-xl px-4 py-3">{{ parseError }}</p>

    <!-- Preview -->
    <template v-if="rows.length">
      <div class="flex items-center gap-4 text-sm">
        <span class="font-medium text-green-600 dark:text-green-400">{{ validCount }} válido{{ validCount !== 1 ? 's' : '' }}</span>
        <span v-if="invalidCount" class="font-medium text-red-500">{{ invalidCount }} con error{{ invalidCount !== 1 ? 'es' : '' }}</span>
      </div>

      <div class="overflow-x-auto rounded-2xl border border-gray-100 dark:border-gray-800">
        <table class="w-full text-sm">
          <thead class="bg-bg-soft dark:bg-gray-800 text-text-meta dark:text-gray-400 text-xs uppercase tracking-wide">
            <tr>
              <th class="text-left px-4 py-3 font-medium w-8">#</th>
              <th class="text-left px-4 py-3 font-medium">Título</th>
              <th class="text-left px-4 py-3 font-medium">Tipo</th>
              <th class="text-left px-4 py-3 font-medium hidden sm:table-cell">Categoría</th>
              <th class="text-left px-4 py-3 font-medium">Estado</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50 dark:divide-gray-800">
            <tr
              v-for="(row, i) in rows"
              :key="i"
              :class="row.errors.length
                ? 'bg-red-50/50 dark:bg-red-900/10'
                : 'hover:bg-gray-50 dark:hover:bg-gray-800'"
              class="transition-colors"
            >
              <td class="px-4 py-3 text-text-meta dark:text-gray-400 text-xs">{{ i + 1 }}</td>
              <td class="px-4 py-3 font-medium text-text-main dark:text-gray-100 max-w-[180px] truncate">
                {{ row.data.title || '—' }}
              </td>
              <td class="px-4 py-3 text-text-meta dark:text-gray-400">
                {{ TYPE_LABELS[row.data.type] ?? row.data.type ?? '—' }}
              </td>
              <td class="px-4 py-3 text-text-meta dark:text-gray-400 hidden sm:table-cell max-w-[140px] truncate">
                {{ row.data.category || '—' }}
              </td>
              <td class="px-4 py-3">
                <span v-if="!row.errors.length" class="text-xs font-medium text-green-600 dark:text-green-400">OK</span>
                <ul v-else class="text-xs text-red-500 space-y-0.5 list-disc list-inside">
                  <li v-for="e in row.errors" :key="e">{{ e }}</li>
                </ul>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="flex justify-end pt-1">
        <button
          :disabled="!validCount || importing"
          class="flex items-center gap-2 px-5 py-2 rounded-xl bg-primary text-white text-sm font-semibold hover:bg-primary/90 transition-colors disabled:opacity-40 disabled:cursor-not-allowed"
          @click="doImport"
        >
          <Loader2 v-if="importing" class="w-4 h-4 animate-spin" />
          <FileDown v-else class="w-4 h-4" />
          {{ importing ? 'Importando…' : `Importar ${validCount} recurso${validCount !== 1 ? 's' : ''}` }}
        </button>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { Upload, FileDown, Loader2 } from 'lucide-vue-next'
import { supabase } from '../lib/supabase'
import { useAuthStore } from '../stores/auth'
import { useCategoriesStore } from '../stores/categories'
import { useToast } from '../composables/useToast'
import { TYPE_LABELS } from '../constants/labels'

const emit = defineEmits(['imported'])

const auth     = useAuthStore()
const catStore = useCategoriesStore()
const toast    = useToast()

const rawJson    = ref('')
const parseError = ref(null)
const rows       = ref([])
const dragging   = ref(false)
const importing  = ref(false)
const fileInput  = ref(null)

const VALID_TYPES     = ['tool', 'guide', 'resource']
const VALID_SCOPES    = ['digital', 'física', 'otra', 'integral']
const VALID_PRICING   = ['gratis', 'freemium', 'pago']
const VALID_PLATFORMS = ['web', 'android', 'ios', 'windows', 'linux', 'mac']

const validCount   = computed(() => rows.value.filter((r) => !r.errors.length).length)
const invalidCount = computed(() => rows.value.filter((r) => r.errors.length).length)

function onFileChange(e) {
  const file = e.target.files[0]
  if (file) readFile(file)
}

function onDrop(e) {
  dragging.value = false
  const file = e.dataTransfer.files[0]
  if (file) readFile(file)
}

function readFile(file) {
  const reader = new FileReader()
  reader.onload = (ev) => { rawJson.value = ev.target.result }
  reader.readAsText(file)
}

function validate(item) {
  const errors = []

  // Fix C1: guard against null/primitive elements in the array
  if (item === null || typeof item !== 'object' || Array.isArray(item))
    return ['el elemento debe ser un objeto JSON, no un primitivo o null']

  if (!item.title?.trim())
    errors.push('title requerido')

  if (!VALID_TYPES.includes(item.type))
    errors.push(`type debe ser: ${VALID_TYPES.join(' | ')} (recibido: "${item.type ?? ''}")`)

  if (!Array.isArray(item.scope) || !item.scope.length || item.scope.some((s) => !VALID_SCOPES.includes(s)))
    errors.push(`scope debe ser un array con valores: ${VALID_SCOPES.join(', ')}`)

  if (!item.category?.trim())
    errors.push('category requerida')

  if (item.pricing && !VALID_PRICING.includes(item.pricing))
    errors.push(`pricing debe ser: ${VALID_PRICING.join(' | ')} (recibido: "${item.pricing}")`)

  // Fix C6: validate tags shape
  if (item.tags !== undefined && !Array.isArray(item.tags))
    errors.push('tags debe ser un array (ej: ["cifrado", "privacidad"])')

  // Fix C7 (platforms): normalize case before comparison
  if (item.platforms) {
    if (!Array.isArray(item.platforms)) {
      errors.push('platforms debe ser un array')
    } else {
      const bad = item.platforms.filter((p) => !VALID_PLATFORMS.includes(String(p).toLowerCase().trim()))
      if (bad.length) errors.push(`plataformas no reconocidas: ${bad.join(', ')}`)
    }
  }

  // Fix C3: cross-field flag consistency
  if (item.show_review && !item.is_reviewed)
    errors.push('show_review no puede ser true si is_reviewed es false')
  if (item.show_audit && !item.has_audit)
    errors.push('show_audit no puede ser true si has_audit es false')

  return errors
}

function analyze() {
  parseError.value = null
  rows.value = []

  let parsed
  try {
    parsed = JSON.parse(rawJson.value.trim())
  } catch (e) {
    parseError.value = `JSON inválido: ${e.message}`
    return
  }

  if (!Array.isArray(parsed)) {
    parseError.value = 'El JSON debe ser un array de recursos: [ { … }, … ]'
    return
  }

  rows.value = parsed.map((item) => ({ data: item, errors: validate(item) }))
}

function reset() {
  rawJson.value    = ''
  parseError.value = null
  rows.value       = []
  if (fileInput.value) fileInput.value.value = ''
}

async function doImport() {
  importing.value = true
  const userEmail = auth.user?.email ?? null

  const payload = rows.value
    .filter((r) => !r.errors.length)
    .map(({ data: d }) => {
      const isReviewed = d.is_reviewed ?? false
      const hasAudit   = d.has_audit   ?? false
      return {
        title:         d.title.trim(),
        type:          d.type,
        scope:         d.scope,
        category:      d.category.trim(),
        description:   d.description?.trim() || null,
        verdict:       d.verdict?.trim()      || null,
        pricing:       d.pricing              || 'gratis',
        // Fix C7: normalize platform casing
        platforms:     d.type === 'tool'
          ? (d.platforms?.map((p) => String(p).toLowerCase().trim()) ?? null)
          : null,
        official_url:  d.official_url || null,
        repo_url:      d.repo_url     || null,
        // Fix C2 & C5: coerce each tag to string before trimming
        tags:          Array.isArray(d.tags)
          ? d.tags.map((t) => String(t).trim()).filter(Boolean)
          : [],
        is_opensource: d.is_opensource ?? false,
        is_reviewed:   isReviewed,
        // Fix C3: enforce flag dependencies
        show_review:   (d.show_review ?? false) && isReviewed,
        has_audit:     hasAudit,
        show_audit:    (d.show_audit ?? false) && hasAudit,
        created_by:    userEmail,
        updated_by:    userEmail,
      }
    })

  // Fix C2: try/finally guarantees importing resets even on unexpected rejection
  try {
    const { error } = await supabase.from('resources').insert(payload)
    if (error) {
      toast.add(`Error al importar: ${error.message}`, 'error')
    } else {
      toast.add(`${payload.length} recurso${payload.length !== 1 ? 's' : ''} importado${payload.length !== 1 ? 's' : ''} correctamente.`, 'success')
      // Fix C8: refresh category store so new category names appear in dropdowns
      catStore.fetchAll()
      emit('imported')
      reset()
    }
  } catch (e) {
    toast.add(`Error inesperado: ${e.message}`, 'error')
  } finally {
    importing.value = false
  }
}
</script>
