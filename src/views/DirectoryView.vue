<template>
  <div class="flex gap-8 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <FilterSidebar class="hidden lg:block w-64 shrink-0" />

    <main class="flex-1 min-w-0">
      <!-- Barra superior: búsqueda + botón filtros (móvil) -->
      <div class="flex gap-2 mb-6">
        <div class="relative flex-1">
          <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-meta" />
          <input
            v-model="store.filters.search"
            type="text"
            placeholder="Buscar herramientas, guías, recursos…"
            class="w-full pl-9 pr-4 py-2.5 rounded-2xl border border-gray-200 text-sm text-text-main placeholder:text-text-meta focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition"
          />
        </div>
        <!-- Botón filtros: solo visible cuando el sidebar está oculto -->
        <button
          class="relative lg:hidden flex items-center gap-2 px-3 py-2 rounded-2xl border text-sm font-medium transition-colors"
          :class="activeFilterCount > 0
            ? 'border-primary bg-primary/5 text-primary'
            : 'border-gray-200 text-text-meta hover:border-primary hover:text-primary'"
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

      <!-- Conteo + filtros activos -->
      <div v-if="!store.loading" class="flex items-center justify-between mb-4">
        <p class="text-xs text-text-meta">
          {{ store.filtered.length }} resultado{{ store.filtered.length !== 1 ? 's' : '' }}
        </p>
        <button
          v-if="activeFilterCount > 0"
          class="text-xs text-primary hover:underline"
          @click="store.resetFilters"
        >
          Limpiar filtros ({{ activeFilterCount }})
        </button>
      </div>

      <!-- Skeleton -->
      <div v-if="store.loading" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <div v-for="n in 6" :key="n" class="h-52 bg-gray-100 rounded-2xl animate-pulse" />
      </div>

      <!-- Error -->
      <p v-else-if="store.error" class="text-red-500 text-sm">
        Error al cargar recursos: {{ store.error }}
      </p>

      <!-- Sin resultados -->
      <div v-else-if="!store.filtered.length" class="text-center py-20 space-y-2">
        <SearchX class="w-8 h-8 text-gray-300 mx-auto" />
        <p class="text-text-meta text-sm">No hay recursos que coincidan con los filtros aplicados.</p>
        <button class="text-xs text-primary hover:underline" @click="store.resetFilters">
          Limpiar filtros
        </button>
      </div>

      <!-- Grid -->
      <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <ToolCard
          v-for="resource in store.filtered"
          :key="resource.id"
          :resource="resource"
          @open-detail="activeResource = resource"
          @open-feedback="feedbackResourceId = $event"
        />
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
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Search, SearchX, SlidersHorizontal } from 'lucide-vue-next'
import ToolCard from '../components/ToolCard.vue'
import FilterSidebar from '../components/FilterSidebar.vue'
import FilterDrawer from '../components/FilterDrawer.vue'
import FeedbackModal from '../components/FeedbackModal.vue'
import ResourceDetailModal from '../components/ResourceDetailModal.vue'
import { useResourcesStore } from '../stores/resources'

const store = useResourcesStore()

const activeResource     = ref(null)
const feedbackResourceId = ref(null)
const filterDrawerOpen   = ref(false)

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

onMounted(() => store.fetchAll())
</script>
