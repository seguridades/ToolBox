<template>
  <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-6">
    <!-- Tabs -->
    <div class="flex gap-1 border-b border-gray-200">
      <button
        v-for="tab in visibleTabs"
        :key="tab.id"
        class="px-4 py-2 text-sm font-medium transition-colors border-b-2 -mb-px"
        :class="activeTab === tab.id
          ? 'border-primary text-primary'
          : 'border-transparent text-text-meta hover:text-text-main'"
        @click="activeTab = tab.id"
      >
        {{ tab.label }}
      </button>
    </div>

    <!-- Tab: Recursos -->
    <div v-if="activeTab === 'resources'" class="space-y-4">
      <div class="flex items-center justify-between">
        <h2 class="font-bold text-text-main">Recursos</h2>
        <button
          class="flex items-center gap-2 text-sm font-medium px-4 py-2 rounded-xl bg-primary text-white hover:bg-primary/90 transition-colors"
          @click="openForm(null)"
        >
          <Plus class="w-4 h-4" /> Nuevo recurso
        </button>
      </div>

      <!-- Buscador -->
      <div class="relative">
        <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-meta" />
        <input
          v-model="resourceSearch"
          type="text"
          placeholder="Buscar por título…"
          class="w-full pl-9 pr-4 py-2 rounded-xl border border-gray-200 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
        />
      </div>

      <!-- Loading -->
      <div v-if="loadingResources" class="space-y-2">
        <div v-for="n in 5" :key="n" class="h-12 bg-gray-100 rounded-xl animate-pulse" />
      </div>

      <!-- Tabla -->
      <div v-else class="overflow-x-auto rounded-2xl border border-gray-100">
        <table class="w-full text-sm">
          <thead class="bg-bg-soft text-text-meta text-xs uppercase tracking-wide">
            <tr>
              <th class="text-left px-4 py-3 font-medium">Título</th>
              <th class="text-left px-4 py-3 font-medium">Tipo</th>
              <th class="text-left px-4 py-3 font-medium">Categoría</th>
              <th class="text-left px-4 py-3 font-medium">Precio</th>
              <th class="px-4 py-3"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50">
            <tr v-if="!filteredResources.length">
              <td colspan="5" class="px-4 py-8 text-center text-text-meta text-xs">Sin resultados</td>
            </tr>
            <tr
              v-for="r in filteredResources"
              :key="r.id"
              class="hover:bg-gray-50 transition-colors"
            >
              <td class="px-4 py-3 font-medium text-text-main">{{ r.title }}</td>
              <td class="px-4 py-3">
                <span :class="typeBadge(r.type)">{{ typeLabel[r.type] }}</span>
              </td>
              <td class="px-4 py-3 text-text-meta">{{ r.category }}</td>
              <td class="px-4 py-3 text-text-meta capitalize">{{ r.pricing }}</td>
              <td class="px-4 py-3">
                <div class="flex items-center justify-end gap-2">
                  <button class="text-text-meta hover:text-primary transition-colors" @click="openForm(r)">
                    <Pencil class="w-4 h-4" />
                  </button>
                  <button class="text-text-meta hover:text-red-500 transition-colors" @click="confirmDelete(r)">
                    <Trash2 class="w-4 h-4" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Tab: Feedback (solo admin) -->
    <div v-if="activeTab === 'feedback'" class="space-y-4">
      <div class="flex items-center justify-between">
        <h2 class="font-bold text-text-main">Feedback recibido</h2>
        <div class="flex gap-2">
          <button
            v-for="s in feedbackStatusOptions"
            :key="s.value"
            class="text-xs font-medium px-3 py-1.5 rounded-xl border transition-colors"
            :class="feedbackFilter === s.value
              ? 'border-primary bg-primary/5 text-primary'
              : 'border-gray-200 text-text-meta hover:border-primary/40'"
            @click="feedbackFilter = s.value"
          >
            {{ s.label }}
          </button>
        </div>
      </div>

      <div v-if="loadingFeedback" class="space-y-2">
        <div v-for="n in 4" :key="n" class="h-20 bg-gray-100 rounded-xl animate-pulse" />
      </div>

      <div v-else class="space-y-3">
        <div v-if="!filteredFeedback.length" class="text-center py-12 text-text-meta text-sm">
          No hay feedback {{ feedbackFilter === 'pendiente' ? 'pendiente' : 'resuelto' }}.
        </div>
        <div
          v-for="fb in filteredFeedback"
          :key="fb.id"
          class="bg-white border border-gray-100 rounded-2xl p-4 space-y-2"
        >
          <div class="flex items-start justify-between gap-4">
            <div class="flex items-center gap-2 flex-wrap">
              <span class="text-xs font-semibold px-2 py-0.5 rounded-full"
                :class="fb.type === 'reporte' ? 'bg-red-50 text-red-600' : 'bg-sky-50 text-sky-600'">
                {{ fb.type === 'reporte' ? 'Reporte' : 'Comentario' }}
              </span>
              <span class="text-xs text-text-meta">{{ fb.alias ?? 'Anónimo' }}</span>
              <span class="text-xs text-text-meta">· {{ formatDate(fb.created_at) }}</span>
              <span v-if="fb.contact_consent && fb.email" class="text-xs text-primary">· {{ fb.email }}</span>
            </div>
            <button
              v-if="fb.status === 'pendiente'"
              class="text-xs font-medium px-3 py-1 rounded-xl bg-green-50 text-green-700 hover:bg-green-100 transition-colors shrink-0"
              @click="resolveFeedback(fb)"
            >
              Marcar resuelto
            </button>
            <span v-else class="text-xs text-text-meta shrink-0">Resuelto</span>
          </div>
          <p class="text-sm text-text-main leading-relaxed">{{ fb.message }}</p>
          <p class="text-xs text-text-meta">Recurso: {{ resourceTitles[fb.resource_id] ?? fb.resource_id }}</p>
        </div>
      </div>
    </div>
  </div>

  <!-- Modal formulario -->
  <ResourceForm
    v-if="formOpen"
    :resource="editingResource"
    @close="formOpen = false"
    @saved="onSaved"
  />

  <!-- Confirm delete -->
  <ConfirmDialog
    v-if="deleteTarget"
    :message="`¿Eliminar «${deleteTarget.title}»? Esta acción no se puede deshacer.`"
    @confirm="doDelete"
    @cancel="deleteTarget = null"
  />
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Plus, Search, Pencil, Trash2 } from 'lucide-vue-next'
import { supabase } from '../lib/supabase'
import { useAuthStore } from '../stores/auth'
import ResourceForm from '../components/ResourceForm.vue'
import ConfirmDialog from '../components/ConfirmDialog.vue'

const auth = useAuthStore()

// Tabs
const allTabs = [
  { id: 'resources', label: 'Recursos', roles: ['editor', 'admin'] },
  { id: 'feedback',  label: 'Feedback',  roles: ['admin'] },
]
const visibleTabs = computed(() => allTabs.filter((t) => t.roles.includes(auth.role)))
const activeTab   = ref('resources')

// --- Recursos ---
const resources        = ref([])
const loadingResources = ref(false)
const resourceSearch   = ref('')
const formOpen         = ref(false)
const editingResource  = ref(null)
const deleteTarget     = ref(null)

const typeLabel = { tool: 'Herramienta', guide: 'Guía', resource: 'Recurso' }
function typeBadge(type) {
  const base = 'text-xs font-medium px-2 py-0.5 rounded-full'
  return { tool: `${base} bg-violet-100 text-violet-700`, guide: `${base} bg-sky-100 text-sky-700`, resource: `${base} bg-amber-100 text-amber-700` }[type]
}

const filteredResources = computed(() =>
  resources.value.filter((r) =>
    !resourceSearch.value || r.title.toLowerCase().includes(resourceSearch.value.toLowerCase())
  )
)

async function loadResources() {
  loadingResources.value = true
  const { data } = await supabase.from('resources').select('*').order('created_at', { ascending: false })
  resources.value = data ?? []
  loadingResources.value = false
}

function openForm(resource) {
  editingResource.value = resource
  formOpen.value = true
}

function onSaved() {
  formOpen.value = false
  loadResources()
}

function confirmDelete(resource) {
  deleteTarget.value = resource
}

async function doDelete() {
  await supabase.from('resources').delete().eq('id', deleteTarget.value.id)
  deleteTarget.value = null
  loadResources()
}

// --- Feedback ---
const feedback        = ref([])
const loadingFeedback = ref(false)
const feedbackFilter  = ref('pendiente')
const feedbackStatusOptions = [
  { value: 'pendiente', label: 'Pendiente' },
  { value: 'resuelto',  label: 'Resuelto' },
]

const filteredFeedback = computed(() =>
  feedback.value.filter((f) => f.status === feedbackFilter.value)
)

const resourceTitles = computed(() =>
  Object.fromEntries(resources.value.map((r) => [r.id, r.title]))
)

async function loadFeedback() {
  loadingFeedback.value = true
  const { data } = await supabase
    .from('resource_feedback')
    .select('*')
    .order('created_at', { ascending: false })
  feedback.value = data ?? []
  loadingFeedback.value = false
}

async function resolveFeedback(fb) {
  await supabase.from('resource_feedback').update({ status: 'resuelto' }).eq('id', fb.id)
  fb.status = 'resuelto'
}

function formatDate(ts) {
  return new Intl.DateTimeFormat('es', { day: 'numeric', month: 'short', year: 'numeric' }).format(new Date(ts))
}

onMounted(() => {
  loadResources()
  if (auth.isAdmin) loadFeedback()
})
</script>
