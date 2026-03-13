<template>
  <div>
  <div class="flex gap-8 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <FilterSidebar class="hidden lg:block w-64 shrink-0" />

    <main class="flex-1 min-w-0">
      <!-- Barra superior: búsqueda + botón filtros (móvil) -->
      <div class="flex gap-2 mb-6">
        <div class="relative flex-1">
          <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-meta" />
          <input
            v-model="searchInput"
            type="text"
            placeholder="Buscar herramientas, guías, recursos…"
            class="w-full pl-9 pr-4 py-2.5 rounded-2xl border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 text-sm text-text-main dark:text-gray-100 placeholder:text-text-meta dark:placeholder:text-gray-500 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition"
          />
        </div>
        <!-- Botón filtros: solo visible cuando el sidebar está oculto -->
        <button
          class="relative lg:hidden flex items-center gap-2 px-3 py-2 rounded-2xl border text-sm font-medium transition-colors"
          :class="activeFilterCount > 0
            ? 'border-primary bg-primary/5 text-primary'
            : 'border-gray-200 dark:border-gray-700 text-text-meta dark:text-gray-400 hover:border-primary hover:text-primary'"
          @click="filterDrawerOpen = true"
        >
          <SlidersHorizontal class="w-4 h-4" />
          <span class="hidden sm:inline">Filtros</span>
          <span
            v-if="activeFilterCount > 0"
            class="absolute -top-1.5 -right-1.5 bg-primary text-white text-[10px] font-bold rounded-full w-4 h-4 flex items-center justify-center"
          >{{ activeFilterCount }}</span>
        </button>
      </div>

      <!-- Chips de filtros activos -->
      <div v-if="activeChips.length" class="flex flex-wrap gap-2 mb-3">
        <span
          v-for="(chip, i) in activeChips"
          :key="i"
          class="inline-flex items-center gap-1 text-xs font-medium px-2.5 py-1 rounded-full bg-primary/10 text-primary"
        >
          {{ chip.label }}
          <button class="hover:opacity-60 transition-opacity" @click="chip.remove()">
            <X class="w-3 h-3" />
          </button>
        </span>
      </div>

      <!-- Conteo + limpiar -->
      <div v-if="!store.loading" class="flex items-center justify-between mb-4">
        <p class="text-xs text-text-meta dark:text-gray-400">
          <template v-if="totalPages > 1">
            {{ rangeStart }}–{{ rangeEnd }} de {{ store.filtered.length }} resultado{{ store.filtered.length !== 1 ? 's' : '' }}
          </template>
          <template v-else>
            {{ store.filtered.length }} resultado{{ store.filtered.length !== 1 ? 's' : '' }}
          </template>
        </p>
        <button
          v-if="activeFilterCount > 0"
          class="text-xs text-primary hover:underline"
          @click="store.resetFilters"
        >
          Limpiar todo
        </button>
      </div>

      <!-- Skeleton -->
      <div v-if="store.loading" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <div v-for="n in 6" :key="n" class="h-52 bg-gray-100 dark:bg-gray-700 rounded-2xl animate-pulse" />
      </div>

      <!-- Error -->
      <p v-else-if="store.error" class="text-red-500 text-sm">
        Error al cargar recursos: {{ store.error }}
      </p>

      <!-- Sin resultados -->
      <div v-else-if="!store.filtered.length" class="text-center py-20 space-y-2">
        <SearchX class="w-8 h-8 text-gray-300 mx-auto" />
        <p class="text-text-meta dark:text-gray-400 text-sm">No hay recursos que coincidan con los filtros aplicados.</p>
        <button class="text-xs text-primary hover:underline" @click="store.resetFilters">
          Limpiar filtros
        </button>
      </div>

      <!-- Grid -->
      <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <ToolCard
          v-for="resource in paginated"
          :key="resource.id"
          :resource="resource"
          @open-detail="activeResource = resource"
          @open-feedback="feedbackResourceId = $event"
        />
      </div>

      <!-- Paginación -->
      <div v-if="totalPages > 1" class="flex items-center justify-center gap-3 mt-8 pt-6 border-t border-gray-100 dark:border-gray-800">
        <button
          :disabled="page === 1"
          class="px-4 py-2 rounded-xl border text-sm font-medium transition-colors disabled:opacity-40 disabled:cursor-not-allowed"
          :class="page === 1
            ? 'border-gray-200 dark:border-gray-700 text-text-meta dark:text-gray-400'
            : 'border-gray-200 dark:border-gray-700 text-text-main dark:text-gray-100 hover:border-primary hover:text-primary'"
          @click="page--"
        >
          ← Anterior
        </button>
        <span class="text-sm text-text-meta dark:text-gray-400">{{ page }} / {{ totalPages }}</span>
        <button
          :disabled="page === totalPages"
          class="px-4 py-2 rounded-xl border text-sm font-medium transition-colors disabled:opacity-40 disabled:cursor-not-allowed"
          :class="page === totalPages
            ? 'border-gray-200 dark:border-gray-700 text-text-meta dark:text-gray-400'
            : 'border-gray-200 dark:border-gray-700 text-text-main dark:text-gray-100 hover:border-primary hover:text-primary'"
          @click="page++"
        >
          Siguiente →
        </button>
      </div>
    </main>
  </div>

  <FilterDrawer :open="filterDrawerOpen" @close="filterDrawerOpen = false" />

  <ResourceDetailModal
    v-if="activeResource"
    :resource="activeResource"
    @close="activeResource = null"
    @open-feedback="feedbackResourceId = $event; activeResource = null"
  />

  <FeedbackModal
    v-if="feedbackResourceId"
    :resource-id="feedbackResourceId"
    @close="feedbackResourceId = null"
  />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Search, SearchX, SlidersHorizontal, X } from 'lucide-vue-next'
import ToolCard from '../components/ToolCard.vue'
import FilterSidebar from '../components/FilterSidebar.vue'
import FilterDrawer from '../components/FilterDrawer.vue'
import FeedbackModal from '../components/FeedbackModal.vue'
import ResourceDetailModal from '../components/ResourceDetailModal.vue'
import { useResourcesStore } from '../stores/resources'
import { useHead } from '../composables/useHead'

useHead({ title: 'Listado', description: 'Explorá y filtrá herramientas, guías y recursos de seguridad digital y física.' })

const store  = useResourcesStore()
const route  = useRoute()
const router = useRouter()

const activeResource     = ref(null)
const feedbackResourceId = ref(null)
const filterDrawerOpen   = ref(false)

// --- Búsqueda con debounce ---
const searchInput = ref(store.filters.search)
let debounceTimer = null
watch(searchInput, (val) => {
  clearTimeout(debounceTimer)
  debounceTimer = setTimeout(() => { store.filters.search = val }, 250)
})
watch(() => store.filters.search, (val) => { searchInput.value = val })

// --- Paginación ---
const PAGE_SIZE  = 12
const page       = ref(1)
const totalPages = computed(() => Math.ceil(store.filtered.length / PAGE_SIZE) || 1)
const rangeStart = computed(() => (page.value - 1) * PAGE_SIZE + 1)
const rangeEnd   = computed(() => Math.min(page.value * PAGE_SIZE, store.filtered.length))
const paginated  = computed(() => store.filtered.slice((page.value - 1) * PAGE_SIZE, page.value * PAGE_SIZE))

// Reset page when filters or total changes
watch(() => store.filtered.length, () => { page.value = 1 })

// --- Filtros activos ---
const activeFilterCount = computed(() => {
  const f = store.filters
  return (
    f.types.length +
    f.scopes.length +
    f.categories.length +
    f.pricing.length +
    f.platforms.length +
    (f.isOpensource !== null ? 1 : 0)
  )
})

const TYPE_LABELS     = { tool: 'Herramienta', guide: 'Guía', resource: 'Recurso' }
const SCOPE_LABELS    = { digital: 'Digital', física: 'Física', otra: 'Otra', mixta: 'Mixta' }
const PRICING_LABELS  = { gratis: 'Gratis', freemium: 'Freemium', pago: 'Pago' }
const PLATFORM_LABELS = { web: 'Web', android: 'Android', ios: 'iOS', windows: 'Windows', linux: 'Linux', mac: 'Mac' }

const activeChips = computed(() => {
  const f = store.filters
  const chips = []
  f.types.forEach((v)     => chips.push({ label: TYPE_LABELS[v]     ?? v, remove: () => { store.filters.types     = f.types.filter((x) => x !== v) } }))
  f.scopes.forEach((v)    => chips.push({ label: SCOPE_LABELS[v]    ?? v, remove: () => { store.filters.scopes    = f.scopes.filter((x) => x !== v) } }))
  f.categories.forEach((v)=> chips.push({ label: v,                       remove: () => { store.filters.categories = f.categories.filter((x) => x !== v) } }))
  f.pricing.forEach((v)   => chips.push({ label: PRICING_LABELS[v]  ?? v, remove: () => { store.filters.pricing   = f.pricing.filter((x) => x !== v) } }))
  f.platforms.forEach((v) => chips.push({ label: PLATFORM_LABELS[v] ?? v, remove: () => { store.filters.platforms = f.platforms.filter((x) => x !== v) } }))
  if (f.isOpensource !== null) chips.push({ label: f.isOpensource ? 'Código abierto' : 'Código cerrado', remove: () => { store.filters.isOpensource = null } })
  return chips
})

// --- Query params ---
function parseArr(val) {
  if (!val) return []
  return (Array.isArray(val) ? val : [val]).flatMap((v) => v.split(',')).filter(Boolean)
}

function filtersToQuery(f) {
  const q = {}
  if (f.search)           q.q           = f.search
  if (f.types.length)     q.tipos       = f.types.join(',')
  if (f.scopes.length)    q.ambitos     = f.scopes.join(',')
  if (f.categories.length) q.cats       = f.categories.join(',')
  if (f.pricing.length)   q.precios     = f.pricing.join(',')
  if (f.platforms.length) q.plataformas = f.platforms.join(',')
  if (f.isOpensource !== null) q.opensource = f.isOpensource ? '1' : '0'
  return q
}

function applyQueryToFilters() {
  const q = route.query
  if (!Object.keys(q).length) return
  store.filters.search      = q.q     || ''
  store.filters.types       = parseArr(q.tipos)
  store.filters.scopes      = parseArr(q.ambitos)
  store.filters.categories  = parseArr(q.cats)
  store.filters.pricing     = parseArr(q.precios)
  store.filters.platforms   = parseArr(q.plataformas)
  store.filters.isOpensource = q.opensource === '1' ? true : q.opensource === '0' ? false : null
}

// Sync store filters → URL
watch(() => ({ ...store.filters }), (f) => {
  router.replace({ query: filtersToQuery(f) })
}, { deep: true })

onMounted(() => {
  applyQueryToFilters()
  // Sync current store state to URL (handles navigation from HomeView with pre-set filters)
  router.replace({ query: filtersToQuery(store.filters) })
  store.fetchAll()
})
</script>
