<template>
  <Teleport to="body">
    <div
      class="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/40 px-0 sm:px-4"
      @click.self="$emit('close')"
    >
      <div class="bg-white dark:bg-gray-900 w-full sm:max-w-2xl sm:rounded-2xl rounded-t-2xl shadow-xl max-h-[92dvh] flex flex-col">
        <!-- Cabecera -->
        <div class="flex items-center justify-between px-6 pt-5 pb-4 border-b border-gray-100 dark:border-gray-800 shrink-0">
          <h2 class="font-bold text-text-main dark:text-gray-100">{{ isEditing ? 'Editar recurso' : 'Nuevo recurso' }}</h2>
          <button class="text-text-meta dark:text-gray-400 hover:text-text-main dark:hover:text-gray-100" @click="$emit('close')">
            <X class="w-5 h-5" />
          </button>
        </div>

        <!-- Form scrolleable -->
        <form class="overflow-y-auto px-6 py-5 space-y-5 flex-1" @submit.prevent="submit">

          <!-- Título -->
          <Field label="Título *">
            <input v-model="form.title" type="text" required class="field-input" />
          </Field>

          <!-- Tipo -->
          <Field label="Tipo *">
            <div class="flex gap-2">
              <label v-for="t in typeOptions" :key="t.value"
                class="flex-1 text-center text-xs font-medium py-2 rounded-xl border cursor-pointer transition-colors"
                :class="form.type === t.value ? 'border-primary bg-primary/5 text-primary' : 'border-gray-200 dark:border-gray-700 text-text-meta dark:text-gray-400 hover:border-primary/40'"
              >
                <input type="radio" :value="t.value" v-model="form.type" class="sr-only" />
                {{ t.label }}
              </label>
            </div>
          </Field>

          <!-- Ámbito -->
          <Field label="Ámbito *">
            <div class="flex flex-wrap gap-3">
              <label v-for="s in scopeOptions" :key="s.value" class="flex items-center gap-1.5 text-sm cursor-pointer">
                <input type="checkbox" :value="s.value" v-model="form.scope" class="rounded accent-primary w-3.5 h-3.5" />
                {{ s.label }}
              </label>
            </div>
          </Field>

          <!-- Categoría -->
          <Field label="Categoría *">
            <select v-model="form.category" required class="field-input">
              <option value="" disabled>Seleccioná una categoría</option>
              <option value="__new__">+ Agregar nueva categoría</option>
              <option v-for="cat in catStore.names" :key="cat" :value="cat">{{ cat }}</option>
            </select>
            <input
              v-if="form.category === '__new__'"
              v-model="customCategory"
              type="text"
              placeholder="Nombre de la nueva categoría *"
              class="field-input mt-2"
            />
          </Field>

          <!-- Descripción -->
          <Field label="Descripción">
            <textarea v-model="form.description" rows="3" class="field-input resize-none" />
          </Field>

          <!-- Veredicto -->
          <Field label="Recomendación editorial">
            <textarea v-model="form.verdict" rows="3" class="field-input resize-none" placeholder="Recomendación de seguridades.org…" />
          </Field>

          <!-- Pricing -->
          <Field label="Precio *">
            <div class="flex gap-2">
              <label v-for="p in pricingOptions" :key="p.value"
                class="flex-1 text-center text-xs font-medium py-2 rounded-xl border cursor-pointer transition-colors"
                :class="form.pricing === p.value ? 'border-primary bg-primary/5 text-primary' : 'border-gray-200 dark:border-gray-700 text-text-meta dark:text-gray-400 hover:border-primary/40'"
              >
                <input type="radio" :value="p.value" v-model="form.pricing" class="sr-only" />
                {{ p.label }}
              </label>
            </div>
          </Field>

          <!-- Plataformas (solo si tool) -->
          <Field v-if="form.type === 'tool'" label="Plataformas">
            <div class="flex flex-wrap gap-3">
              <label v-for="p in platformOptions" :key="p.value" class="flex items-center gap-1.5 text-sm cursor-pointer">
                <input type="checkbox" :value="p.value" v-model="form.platforms" class="rounded accent-primary w-3.5 h-3.5" />
                {{ p.label }}
              </label>
            </div>
          </Field>

          <!-- URLs -->
          <div class="grid grid-cols-2 gap-4">
            <Field label="Sitio oficial">
              <input v-model="form.official_url" type="url" placeholder="https://…" class="field-input" />
            </Field>
            <Field label="Repositorio">
              <input v-model="form.repo_url" type="url" placeholder="https://github.com/…" class="field-input" />
            </Field>
          </div>

          <!-- Tags -->
          <Field label="Etiquetas" hint="Separadas por coma">
            <input v-model="tagsInput" type="text" placeholder="Android, SinInternet, Cifrado…" class="field-input" />
          </Field>

          <!-- Toggles -->
          <div class="grid grid-cols-2 gap-3">
            <Toggle v-model="form.is_opensource" label="Código abierto" />
            <Toggle v-model="form.is_reviewed"   label="Revisada internamente" />
            <Toggle v-model="form.show_review"   label="Mostrar sello revisada" :disabled="!form.is_reviewed" />
            <Toggle v-model="form.has_audit"     label="Tiene auditoría externa" />
            <Toggle v-model="form.show_audit"    label="Mostrar auditoría" :disabled="!form.has_audit" />
          </div>

          <!-- Manuales de uso (solo si type = tool y estamos editando) -->
          <div v-if="form.type === 'tool' && isEditing" class="space-y-3 pt-2 border-t border-gray-100 dark:border-gray-800">
            <div class="flex items-center justify-between">
              <p class="text-xs font-semibold uppercase tracking-wide text-text-meta dark:text-gray-400">Manuales de uso</p>
              <button type="button" class="text-xs text-primary hover:underline flex items-center gap-1" @click="addingManual = true">
                <Plus class="w-3.5 h-3.5" /> Agregar
              </button>
            </div>

            <!-- Lista de manuales existentes -->
            <ul class="space-y-2">
              <li v-for="m in manuals" :key="m.id" class="flex items-start justify-between gap-2 text-xs bg-bg-soft dark:bg-gray-800 rounded-xl px-3 py-2">
                <div class="min-w-0">
                  <p class="font-medium text-text-main dark:text-gray-100 truncate">{{ m.title }}</p>
                  <p class="text-text-meta dark:text-gray-400 truncate">{{ m.source }} — {{ m.url }}</p>
                </div>
                <button type="button" class="text-text-meta dark:text-gray-400 hover:text-red-500 transition-colors shrink-0" @click="deleteManual(m)">
                  <Trash2 class="w-3.5 h-3.5" />
                </button>
              </li>
              <li v-if="!manuals.length" class="text-xs text-text-meta">Sin manuales todavía.</li>
            </ul>

            <!-- Formulario inline para nuevo manual -->
            <div v-if="addingManual" class="bg-bg-soft dark:bg-gray-800 rounded-xl p-3 space-y-2">
              <input v-model="newManual.title" type="text" placeholder="Título del manual *" class="field-input text-xs" />
              <input v-model="newManual.url"   type="url"  placeholder="URL *" class="field-input text-xs" />
              <input v-model="newManual.source" type="text" placeholder="Fuente (ej: EFF, Access Now)" class="field-input text-xs" />
              <div class="flex gap-2 justify-end">
                <button type="button" class="text-xs text-text-meta dark:text-gray-400 hover:text-text-main dark:hover:text-gray-100" @click="addingManual = false">Cancelar</button>
                <button type="button" class="text-xs font-medium text-primary hover:underline" @click="saveManual">Guardar manual</button>
              </div>
            </div>
          </div>

          <p v-if="error" class="text-xs text-red-500">{{ error }}</p>
        </form>

        <!-- Pie fijo -->
        <div class="px-6 py-4 border-t border-gray-100 dark:border-gray-800 flex justify-end gap-3 shrink-0">
          <button type="button" class="px-4 py-2 rounded-xl border border-gray-200 dark:border-gray-700 text-sm text-text-meta dark:text-gray-400 hover:border-gray-300 dark:hover:border-gray-500" @click="$emit('close')">
            Cancelar
          </button>
          <button
            :disabled="loading"
            class="px-5 py-2 rounded-xl bg-primary text-white text-sm font-semibold hover:bg-primary/90 transition-colors disabled:opacity-50"
            @click="submit"
          >
            {{ loading ? 'Guardando…' : isEditing ? 'Guardar cambios' : 'Crear recurso' }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { reactive, ref, computed, onMounted } from 'vue'
import { X, Plus, Trash2 } from 'lucide-vue-next'
import { supabase } from '../lib/supabase'
import Field from './FormField.vue'
import Toggle from './FormToggle.vue'
import { useScrollLock } from '../composables/useScrollLock'
import { useCategoriesStore } from '../stores/categories'
import { useAuthStore } from '../stores/auth'

const props = defineProps({
  resource: { type: Object, default: null }, // null = crear, objeto = editar
})

const emit = defineEmits(['close', 'saved'])
useScrollLock()

const catStore = useCategoriesStore()
const auth     = useAuthStore()

const isEditing = computed(() => !!props.resource)

const form = reactive({
  title:        props.resource?.title        ?? '',
  type:         props.resource?.type         ?? 'tool',
  scope:        props.resource?.scope        ?? [],
  category:     props.resource?.category     ?? '',
  description:  props.resource?.description  ?? '',
  verdict:      props.resource?.verdict      ?? '',
  pricing:      props.resource?.pricing      ?? 'gratis',
  platforms:    props.resource?.platforms    ?? [],
  official_url: props.resource?.official_url ?? '',
  repo_url:     props.resource?.repo_url     ?? '',
  is_opensource: props.resource?.is_opensource ?? false,
  is_reviewed:   props.resource?.is_reviewed   ?? false,
  show_review:   props.resource?.show_review   ?? false,
  has_audit:     props.resource?.has_audit     ?? false,
  show_audit:    props.resource?.show_audit    ?? false,
})

const tagsInput      = ref(props.resource?.tags?.join(', ') ?? '')
const customCategory = ref('')
const loading        = ref(false)
const error          = ref(null)

// Manuales
const manuals     = ref([])
const addingManual = ref(false)
const newManual   = reactive({ title: '', url: '', source: '' })

onMounted(async () => {
  catStore.fetchAll()
  if (!isEditing.value || props.resource.type !== 'tool') return
  const { data } = await supabase.from('tool_manuals').select('*').eq('tool_id', props.resource.id).order('created_at')
  manuals.value = data ?? []
})

async function saveManual() {
  if (!newManual.title || !newManual.url) return
  const { data, error: err } = await supabase.from('tool_manuals').insert({
    tool_id: props.resource.id,
    title:   newManual.title.trim(),
    url:     newManual.url.trim(),
    source:  newManual.source.trim() || null,
  }).select().single()
  if (!err) {
    manuals.value.push(data)
    Object.assign(newManual, { title: '', url: '', source: '' })
    addingManual.value = false
  }
}

async function deleteManual(manual) {
  await supabase.from('tool_manuals').delete().eq('id', manual.id)
  manuals.value = manuals.value.filter((m) => m.id !== manual.id)
}

async function submit() {
  const categoryValue = form.category === '__new__'
    ? customCategory.value.trim()
    : form.category

  if (!form.title || !form.type || !categoryValue || !form.scope.length) {
    error.value = form.category === '__new__' && !customCategory.value.trim()
      ? 'Ingresá el nombre de la nueva categoría.'
      : 'Completá los campos obligatorios: título, tipo, ámbito y categoría.'
    return
  }
  loading.value = true
  error.value   = null

  // Si es categoría nueva, guardarla en el store (ignorar error de duplicado)
  if (form.category === '__new__' && customCategory.value.trim()) {
    await catStore.add(customCategory.value.trim())
  }

  const userEmail = auth.user?.email ?? null
  const payload = {
    ...form,
    category:   categoryValue,
    tags:       tagsInput.value.split(',').map((t) => t.trim()).filter(Boolean),
    platforms:  form.type === 'tool' ? form.platforms : null,
    official_url: form.official_url || null,
    repo_url:     form.repo_url     || null,
    updated_by: userEmail,
    ...(!isEditing.value && { created_by: userEmail }),
  }

  const { error: err } = isEditing.value
    ? await supabase.from('resources').update(payload).eq('id', props.resource.id)
    : await supabase.from('resources').insert(payload)

  if (err) error.value = err.message
  else emit('saved')

  loading.value = false
}

// Opciones
const typeOptions    = [{ value: 'tool', label: 'Herramienta' }, { value: 'guide', label: 'Guía' }, { value: 'resource', label: 'Recurso' }]
const scopeOptions   = [{ value: 'digital', label: 'Digital' }, { value: 'física', label: 'Física' }, { value: 'otra', label: 'Otra' }, { value: 'mixta', label: 'Mixta' }]
const pricingOptions = [{ value: 'gratis', label: 'Gratis' }, { value: 'freemium', label: 'Freemium' }, { value: 'pago', label: 'Pago' }]
const platformOptions = [
  { value: 'web', label: 'Web' }, { value: 'android', label: 'Android' },
  { value: 'ios', label: 'iOS' }, { value: 'windows', label: 'Windows' },
  { value: 'linux', label: 'Linux' }, { value: 'mac', label: 'Mac' },
]
</script>

<style scoped>
.field-input {
  @apply w-full rounded-xl border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 px-3 py-2 text-sm text-text-main dark:text-gray-100 placeholder:text-text-meta dark:placeholder:text-gray-500 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary;
}
</style>
