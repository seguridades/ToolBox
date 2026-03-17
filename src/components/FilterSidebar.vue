<template>
  <aside class="bg-bg-soft dark:bg-gray-800 rounded-2xl p-4 space-y-5 text-sm">
    <!-- Encabezado + reset -->
    <div class="flex items-center justify-between">
      <span class="font-semibold text-text-main dark:text-gray-100">Filtros</span>
      <button
        v-if="hasActiveFilters"
        class="text-xs text-primary hover:underline"
        @click="store.resetFilters"
      >
        Limpiar
      </button>
    </div>

    <!-- Tipo -->
    <FilterGroup label="Tipo">
      <FilterCheckbox
        v-for="opt in typeOptions"
        :key="opt.value"
        v-model="store.filters.types"
        :value="opt.value"
        :label="opt.label"
      />
    </FilterGroup>

    <!-- Ámbito -->
    <FilterGroup label="Ámbito">
      <FilterCheckbox
        v-for="opt in scopeOptions"
        :key="opt.value"
        v-model="store.filters.scopes"
        :value="opt.value"
        :label="opt.label"
      />
    </FilterGroup>

    <!-- Categoría -->
    <FilterGroup label="Categoría">
      <FilterCheckbox
        v-for="cat in catStore.names"
        :key="cat"
        v-model="store.filters.categories"
        :value="cat"
        :label="cat"
      />
    </FilterGroup>

    <!-- Pricing -->
    <FilterGroup label="Precio">
      <FilterCheckbox
        v-for="opt in pricingOptions"
        :key="opt.value"
        v-model="store.filters.pricing"
        :value="opt.value"
        :label="opt.label"
      />
    </FilterGroup>

    <!-- Plataforma -->
    <FilterGroup label="Plataforma">
      <FilterCheckbox
        v-for="opt in platformOptions"
        :key="opt.value"
        v-model="store.filters.platforms"
        :value="opt.value"
        :label="opt.label"
      />
    </FilterGroup>

    <!-- Código abierto -->
    <FilterGroup label="Código abierto">
      <label class="flex items-center gap-2 cursor-pointer">
        <input
          type="checkbox"
          :checked="store.filters.isOpensource === true"
          class="w-3.5 h-3.5 rounded accent-primary"
          @change="(e) => store.filters.isOpensource = e.target.checked ? true : null"
        />
        <span class="text-text-main dark:text-gray-100">Solo código abierto</span>
      </label>
    </FilterGroup>
  </aside>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useResourcesStore } from '../stores/resources'
import { useCategoriesStore } from '../stores/categories'
import FilterGroup from './FilterGroup.vue'
import FilterCheckbox from './FilterCheckbox.vue'

const store    = useResourcesStore()
const catStore = useCategoriesStore()
onMounted(() => catStore.fetchAll())

const hasActiveFilters = computed(() => {
  const f = store.filters
  return (
    f.search ||
    f.types.length ||
    f.scopes.length ||
    f.categories.length ||
    f.pricing.length ||
    f.platforms.length ||
    f.isOpensource !== null
  )
})

const typeOptions = [
  { value: 'tool',     label: 'Herramienta' },
  { value: 'guide',    label: 'Guía' },
  { value: 'resource', label: 'Recurso' },
]

const scopeOptions = [
  { value: 'digital', label: 'Digital' },
  { value: 'física',  label: 'Física' },
  { value: 'otra',    label: 'Otra' },
  { value: 'integral', label: 'Integral' },
]

const pricingOptions = [
  { value: 'gratis',   label: 'Gratis' },
  { value: 'freemium', label: 'Freemium' },
  { value: 'pago',     label: 'Pago' },
]

const platformOptions = [
  { value: 'web',     label: 'Web' },
  { value: 'android', label: 'Android' },
  { value: 'ios',     label: 'iOS' },
  { value: 'windows', label: 'Windows' },
  { value: 'linux',   label: 'Linux' },
  { value: 'mac',     label: 'Mac' },
]

</script>
