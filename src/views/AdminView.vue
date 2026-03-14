<template>
  <div>
  <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-6">
    <!-- Tabs -->
    <div class="flex gap-1 border-b border-gray-200 dark:border-gray-700">
      <button
        v-for="tab in visibleTabs"
        :key="tab.id"
        class="px-4 py-2 text-sm font-medium transition-colors border-b-2 -mb-px"
        :class="activeTab === tab.id
          ? 'border-primary text-primary'
          : 'border-transparent text-text-meta dark:text-gray-400 hover:text-text-main dark:hover:text-gray-100'"
        @click="activeTab = tab.id"
      >
        {{ tab.label }}
      </button>
    </div>

    <!-- Tab: Recursos -->
    <div v-if="activeTab === 'resources'" class="space-y-4">
      <div class="flex items-center justify-between">
        <h2 class="font-bold text-text-main dark:text-gray-100">Recursos</h2>
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
          class="w-full pl-9 pr-4 py-2 rounded-xl border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 text-sm text-text-main dark:text-gray-100 placeholder:text-text-meta dark:placeholder:text-gray-500 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
        />
      </div>

      <!-- Loading -->
      <div v-if="loadingResources" class="space-y-2">
        <div v-for="n in 5" :key="n" class="h-12 bg-gray-100 dark:bg-gray-700 rounded-xl animate-pulse" />
      </div>

      <!-- Tabla -->
      <div v-else class="overflow-x-auto rounded-2xl border border-gray-100 dark:border-gray-800">
        <table class="w-full text-sm">
          <thead class="bg-bg-soft dark:bg-gray-800 text-text-meta dark:text-gray-400 text-xs uppercase tracking-wide">
            <tr>
              <th class="text-left px-4 py-3 font-medium">
                <button class="flex items-center gap-1 hover:text-text-main dark:hover:text-gray-100 transition-colors" @click="toggleSort('title')">
                  Título
                  <ChevronUp v-if="sortKey === 'title' && sortDir === 'asc'" class="w-3 h-3" />
                  <ChevronDown v-else-if="sortKey === 'title' && sortDir === 'desc'" class="w-3 h-3" />
                  <ChevronsUpDown v-else class="w-3 h-3 opacity-40" />
                </button>
              </th>
              <th class="text-left px-4 py-3 font-medium">
                <button class="flex items-center gap-1 hover:text-text-main dark:hover:text-gray-100 transition-colors" @click="toggleSort('type')">
                  Tipo
                  <ChevronUp v-if="sortKey === 'type' && sortDir === 'asc'" class="w-3 h-3" />
                  <ChevronDown v-else-if="sortKey === 'type' && sortDir === 'desc'" class="w-3 h-3" />
                  <ChevronsUpDown v-else class="w-3 h-3 opacity-40" />
                </button>
              </th>
              <th class="text-left px-4 py-3 font-medium hidden xl:table-cell">
                <button class="flex items-center gap-1 hover:text-text-main dark:hover:text-gray-100 transition-colors" @click="toggleSort('category')">
                  Categoría
                  <ChevronUp v-if="sortKey === 'category' && sortDir === 'asc'" class="w-3 h-3" />
                  <ChevronDown v-else-if="sortKey === 'category' && sortDir === 'desc'" class="w-3 h-3" />
                  <ChevronsUpDown v-else class="w-3 h-3 opacity-40" />
                </button>
              </th>
              <th class="px-4 py-3"></th>
              <th class="px-4 py-3"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50 dark:divide-gray-800">
            <tr v-if="!filteredResources.length">
              <td colspan="6" class="px-4 py-8 text-center text-text-meta dark:text-gray-400 text-xs">Sin resultados</td>
            </tr>
            <tr
              v-for="r in filteredResources"
              :key="r.id"
              class="hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
            >
              <td class="px-4 py-3 font-medium text-text-main dark:text-gray-100">{{ r.title }}</td>
              <td class="px-4 py-3">
                <span :class="typeBadge(r.type)">{{ typeLabel[r.type] }}</span>
              </td>
              <td class="px-4 py-3 text-text-meta dark:text-gray-400 hidden xl:table-cell">{{ r.category }}</td>
              <td class="px-4 py-3">
                <div class="audit-info group relative inline-flex">
                  <Info class="w-3.5 h-3.5 text-text-meta dark:text-gray-500 hover:text-primary dark:hover:text-primary transition-colors cursor-default" />
                  <div class="audit-tooltip pointer-events-none absolute bottom-full right-0 mb-2 w-52 rounded-xl bg-gray-900 dark:bg-gray-700 text-white text-xs p-3 space-y-1.5 opacity-0 group-hover:opacity-100 transition-opacity z-50 shadow-lg">
                    <div>
                      <p class="text-gray-400 uppercase tracking-wide text-[10px] font-semibold">Creado por</p>
                      <p>{{ r.created_by ?? '—' }}</p>
                    </div>
                    <div>
                      <p class="text-gray-400 uppercase tracking-wide text-[10px] font-semibold">Modificado</p>
                      <p>{{ r.updated_at ? formatDate(r.updated_at) : '—' }}</p>
                      <p v-if="r.updated_by" class="text-gray-400">{{ r.updated_by }}</p>
                    </div>
                  </div>
                </div>
              </td>
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
        <h2 class="font-bold text-text-main dark:text-gray-100">Feedback recibido</h2>
        <div class="flex gap-2">
          <button
            v-for="s in feedbackStatusOptions"
            :key="s.value"
            class="text-xs font-medium px-3 py-1.5 rounded-xl border transition-colors"
            :class="feedbackFilter === s.value
              ? 'border-primary bg-primary/5 text-primary'
              : 'border-gray-200 dark:border-gray-700 text-text-meta dark:text-gray-400 hover:border-primary/40'"
            @click="feedbackFilter = s.value"
          >
            {{ s.label }}
          </button>
        </div>
      </div>

      <div v-if="loadingFeedback" class="space-y-2">
        <div v-for="n in 4" :key="n" class="h-20 bg-gray-100 dark:bg-gray-700 rounded-xl animate-pulse" />
      </div>

      <div v-else class="space-y-3">
        <div v-if="!filteredFeedback.length" class="text-center py-12 text-text-meta text-sm">
          No hay feedback {{ feedbackFilter === 'pendiente' ? 'pendiente' : 'resuelto' }}.
        </div>
        <div
          v-for="fb in filteredFeedback"
          :key="fb.id"
          class="bg-white dark:bg-gray-800 border border-gray-100 dark:border-gray-700 rounded-2xl p-4 space-y-2"
        >
          <div class="flex items-start justify-between gap-4">
            <div class="flex items-center gap-2 flex-wrap">
              <span class="text-xs font-semibold px-2 py-0.5 rounded-full"
                :class="fb.type === 'reporte' ? 'bg-red-50 text-red-600' : 'bg-sky-50 text-sky-600'">
                {{ fb.type === 'reporte' ? 'Reporte' : 'Comentario' }}
              </span>
              <span class="text-xs text-text-meta dark:text-gray-400">{{ fb.alias ?? 'Anónimo' }}</span>
              <span class="text-xs text-text-meta dark:text-gray-400">· {{ formatDate(fb.created_at) }}</span>
              <span v-if="fb.contact_consent && fb.email" class="text-xs text-primary">· {{ fb.email }}</span>
            </div>
            <button
              v-if="fb.status === 'pendiente'"
              class="text-xs font-medium px-3 py-1 rounded-xl bg-green-50 text-green-700 hover:bg-green-100 transition-colors shrink-0"
              @click="resolveFeedback(fb)"
            >
              Marcar resuelto
            </button>
            <span v-else class="text-xs text-text-meta dark:text-gray-400 shrink-0">Resuelto</span>
          </div>
          <p class="text-sm text-text-main dark:text-gray-100 leading-relaxed">{{ fb.message }}</p>
          <p class="text-xs text-text-meta dark:text-gray-400">Recurso: {{ resourceTitles[fb.resource_id] ?? fb.resource_id }}</p>
        </div>
      </div>
    </div>

    <!-- Tab: Categorías (solo admin) -->
    <div v-if="activeTab === 'categories'" class="space-y-4">
      <div class="flex items-center justify-between">
        <h2 class="font-bold text-text-main dark:text-gray-100">Categorías</h2>
      </div>

      <!-- Agregar nueva -->
      <div class="flex gap-2">
        <input
          v-model="newCategoryName"
          type="text"
          placeholder="Nueva categoría…"
          class="flex-1 rounded-xl border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 px-3 py-2 text-sm text-text-main dark:text-gray-100 placeholder:text-text-meta dark:placeholder:text-gray-500 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary"
          @keyup.enter="addCategory"
        />
        <button
          :disabled="!newCategoryName.trim()"
          class="flex items-center gap-1.5 px-4 py-2 rounded-xl bg-primary text-white text-sm font-semibold hover:bg-primary/90 transition-colors disabled:opacity-40 disabled:cursor-not-allowed"
          @click="addCategory"
        >
          <Plus class="w-4 h-4" /> Agregar
        </button>
      </div>

      <p v-if="catError" class="text-xs text-red-500">{{ catError }}</p>

      <!-- Lista -->
      <div class="overflow-x-auto rounded-2xl border border-gray-100 dark:border-gray-800">
        <table class="w-full text-sm">
          <thead class="bg-bg-soft dark:bg-gray-800 text-text-meta dark:text-gray-400 text-xs uppercase tracking-wide">
            <tr>
              <th class="text-left px-4 py-3 font-medium">Nombre</th>
              <th class="text-left px-4 py-3 font-medium">Tipo</th>
              <th class="px-4 py-3"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50 dark:divide-gray-800">
            <tr v-if="!catStore.categories.length">
              <td colspan="3" class="px-4 py-8 text-center text-text-meta dark:text-gray-400 text-xs">Sin categorías</td>
            </tr>
            <tr
              v-for="cat in catStore.categories"
              :key="cat.id"
              class="hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
            >
              <td class="px-4 py-3">
                <template v-if="editingCatId === cat.id">
                  <input
                    v-model="editingCatName"
                    class="rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 px-2 py-1 text-sm text-text-main dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary w-full max-w-xs"
                    @keyup.enter="saveCategory(cat)"
                    @keyup.escape="editingCatId = null"
                  />
                </template>
                <span v-else class="font-medium text-text-main dark:text-gray-100">{{ cat.name }}</span>
              </td>
              <td class="px-4 py-3">
                <span
                  class="text-xs font-medium px-2 py-0.5 rounded-full"
                  :class="cat.is_default
                    ? 'bg-gray-100 dark:bg-gray-700 text-text-meta dark:text-gray-400'
                    : 'bg-primary/10 text-primary'"
                >{{ cat.is_default ? 'Por defecto' : 'Personalizada' }}</span>
              </td>
              <td class="px-4 py-3">
                <div class="flex items-center justify-end gap-2">
                  <template v-if="editingCatId === cat.id">
                    <button class="text-xs font-medium text-primary hover:underline" @click="saveCategory(cat)">Guardar</button>
                    <button class="text-xs text-text-meta dark:text-gray-400 hover:text-text-main dark:hover:text-gray-100" @click="editingCatId = null">Cancelar</button>
                  </template>
                  <template v-else>
                    <button class="text-text-meta dark:text-gray-400 hover:text-primary transition-colors" @click="startEditCat(cat)">
                      <Pencil class="w-4 h-4" />
                    </button>
                    <button class="text-text-meta dark:text-gray-400 hover:text-red-500 transition-colors" @click="confirmDeleteCat(cat)">
                      <Trash2 class="w-4 h-4" />
                    </button>
                  </template>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <!-- Tab: Usuarios (solo admin) -->
    <div v-if="activeTab === 'users'" class="space-y-4">
      <div class="flex items-center justify-between">
        <h2 class="font-bold text-text-main dark:text-gray-100">Usuarios</h2>
        <button
          class="flex items-center gap-1.5 text-xs text-primary hover:underline"
          @click="loadUsers"
        >
          <RotateCw class="w-3.5 h-3.5" /> Actualizar
        </button>
      </div>

      <div v-if="loadingUsers" class="space-y-2">
        <div v-for="n in 3" :key="n" class="h-14 bg-gray-100 dark:bg-gray-700 rounded-xl animate-pulse" />
      </div>

      <div v-else class="overflow-x-auto rounded-2xl border border-gray-100 dark:border-gray-800">
        <table class="w-full text-sm">
          <thead class="bg-bg-soft dark:bg-gray-800 text-text-meta dark:text-gray-400 text-xs uppercase tracking-wide">
            <tr>
              <th class="text-left px-4 py-3 font-medium">Email</th>
              <th class="text-left px-4 py-3 font-medium">Último acceso</th>
              <th class="text-left px-4 py-3 font-medium">Rol</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50 dark:divide-gray-800">
            <tr v-if="!users.length">
              <td colspan="3" class="px-4 py-8 text-center text-text-meta dark:text-gray-400 text-xs">Sin usuarios</td>
            </tr>
            <tr
              v-for="u in users"
              :key="u.id"
              class="hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
            >
              <td class="px-4 py-3 text-text-main dark:text-gray-100">{{ u.email }}</td>
              <td class="px-4 py-3 text-text-meta dark:text-gray-400 text-xs">
                {{ u.last_sign_in_at ? formatDate(u.last_sign_in_at) : 'Nunca' }}
              </td>
              <td class="px-4 py-3">
                <select
                  :value="u.role"
                  class="rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 px-2 py-1 text-xs text-text-main dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-primary/30"
                  @change="setUserRole(u, $event.target.value || null)"
                >
                  <option v-for="opt in roleOptions" :key="String(opt.value)" :value="opt.value ?? ''">
                    {{ opt.label }}
                  </option>
                </select>
              </td>
            </tr>
          </tbody>
        </table>
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

  <!-- Confirm delete recurso -->
  <ConfirmDialog
    v-if="deleteTarget"
    :message="`¿Eliminar «${deleteTarget.title}»? Esta acción no se puede deshacer.`"
    @confirm="doDelete"
    @cancel="deleteTarget = null"
  />

  <!-- Confirm delete categoría -->
  <ConfirmDialog
    v-if="deleteCatTarget"
    :message="`¿Eliminar la categoría «${deleteCatTarget.name}»? Los recursos que la usen quedarán sin categoría asignada.`"
    @confirm="doDeleteCat"
    @cancel="deleteCatTarget = null"
  />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { Plus, Search, Pencil, Trash2, Info, ChevronUp, ChevronDown, ChevronsUpDown, RotateCw } from 'lucide-vue-next'
import { supabase } from '../lib/supabase'
import { useAuthStore } from '../stores/auth'
import ResourceForm from '../components/ResourceForm.vue'
import ConfirmDialog from '../components/ConfirmDialog.vue'
import { useHead } from '../composables/useHead'
import { useCategoriesStore } from '../stores/categories'

useHead({ title: 'Panel de administración' })

const auth     = useAuthStore()
const catStore = useCategoriesStore()

// Tabs
const allTabs = [
  { id: 'resources',  label: 'Recursos',    roles: ['editor', 'admin'] },
  { id: 'categories', label: 'Categorías',  roles: ['admin'] },
  { id: 'feedback',   label: 'Feedback',    roles: ['admin'] },
  { id: 'users',      label: 'Usuarios',    roles: ['admin'] },
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

const sortKey = ref('created_at')
const sortDir = ref('desc')

function toggleSort(key) {
  if (sortKey.value === key) {
    sortDir.value = sortDir.value === 'asc' ? 'desc' : 'asc'
  } else {
    sortKey.value = key
    sortDir.value = 'asc'
  }
}

const filteredResources = computed(() => {
  const list = resources.value.filter((r) =>
    !resourceSearch.value || r.title.toLowerCase().includes(resourceSearch.value.toLowerCase())
  )
  return [...list].sort((a, b) => {
    const va = (a[sortKey.value] ?? '').toString().toLowerCase()
    const vb = (b[sortKey.value] ?? '').toString().toLowerCase()
    const cmp = va < vb ? -1 : va > vb ? 1 : 0
    return sortDir.value === 'asc' ? cmp : -cmp
  })
})

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

// --- Categorías ---
const newCategoryName = ref('')
const editingCatId    = ref(null)
const editingCatName  = ref('')
const deleteCatTarget = ref(null)
const catError        = ref(null)

function startEditCat(cat) {
  editingCatId.value   = cat.id
  editingCatName.value = cat.name
}

async function addCategory() {
  const name = newCategoryName.value.trim()
  if (!name) return
  catError.value = null
  const { error } = await catStore.add(name)
  if (error) {
    catError.value = error.message.includes('unique')
      ? 'Esa categoría ya existe.'
      : 'Error al agregar la categoría.'
  } else {
    newCategoryName.value = ''
  }
}

async function saveCategory(cat) {
  const name = editingCatName.value.trim()
  if (!name || name === cat.name) { editingCatId.value = null; return }
  const { error } = await catStore.update(cat.id, name)
  if (!error) editingCatId.value = null
}

function confirmDeleteCat(cat) { deleteCatTarget.value = cat }

async function doDeleteCat() {
  await catStore.remove(deleteCatTarget.value.id)
  deleteCatTarget.value = null
}

// --- Usuarios ---
const users        = ref([])
const loadingUsers = ref(false)
const roleOptions  = [
  { value: null,    label: 'Sin rol' },
  { value: 'editor', label: 'Editor' },
  { value: 'admin',  label: 'Admin' },
]

async function invokeAdminUsers(body) {
  const { data: { session } } = await supabase.auth.getSession()
  return supabase.functions.invoke('admin-users', {
    body,
    headers: session ? { Authorization: `Bearer ${session.access_token}` } : {},
  })
}

async function loadUsers() {
  loadingUsers.value = true
  const { data, error } = await invokeAdminUsers({ action: 'list' })
  if (!error) users.value = data
  loadingUsers.value = false
}

async function setUserRole(user, role) {
  const prev = user.role
  user.role = role
  const { error } = await invokeAdminUsers({ action: 'setRole', userId: user.id, role })
  if (error) user.role = prev
}

watch(activeTab, (tab) => { if (tab === 'users') loadUsers() })

async function resolveFeedback(fb) {
  await supabase.from('resource_feedback').update({ status: 'resuelto' }).eq('id', fb.id)
  fb.status = 'resuelto'
}

function formatDate(ts) {
  return new Intl.DateTimeFormat('es', { day: 'numeric', month: 'short', year: 'numeric' }).format(new Date(ts))
}

onMounted(() => { loadResources(); catStore.fetchAll() })

// loadFeedback con watch: maneja tanto el caso inicial como el reload de página
// donde auth.isAdmin puede volverse true después del mount
watch(() => auth.isAdmin, (isAdmin) => {
  if (isAdmin) loadFeedback()
}, { immediate: true })
</script>
