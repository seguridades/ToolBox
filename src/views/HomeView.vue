<template>
  <div class="flex flex-col min-h-[calc(100vh-3.5rem)]">

    <!-- Hero -->
    <div class="flex-1 flex items-center">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 w-full">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">

          <!-- Texto + búsqueda -->
          <div class="space-y-8">
            <div class="space-y-4">
              <span class="inline-block text-xs font-semibold uppercase tracking-widest text-primary bg-primary/8 px-3 py-1.5 rounded-full">
                Listado de recursos
              </span>
              <h1 class="text-4xl sm:text-5xl font-bold text-text-main leading-tight">
                Herramientas de seguridad
              </h1>
              <p class="text-base text-text-meta leading-relaxed max-w-md">
                Recursos de seguridad usados por seguridades.org para talleres, acompañamientos y trabajo en campo.
              </p>
            </div>

            <!-- Buscador -->
            <div class="space-y-3">
              <div class="relative">
                <Search class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-text-meta" />
                <input
                  v-model="query"
                  type="text"
                  placeholder="Buscar herramientas, guías, recursos…"
                  class="w-full pl-12 pr-4 py-4 rounded-2xl border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 text-base text-text-main dark:text-gray-100 placeholder:text-text-meta dark:placeholder:text-gray-500 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition shadow-sm"
                  @keyup.enter="search"
                />
              </div>
              <div class="flex items-center gap-3">
                <button
                  class="flex-1 sm:flex-none sm:px-8 py-3 rounded-2xl bg-primary text-white font-semibold text-sm hover:bg-primary/90 transition-colors"
                  @click="search"
                >
                  Buscar
                </button>
                <RouterLink
                  to="/directorio"
                  class="flex-1 sm:flex-none sm:px-8 py-3 rounded-2xl border border-gray-200 dark:border-gray-700 text-text-main dark:text-gray-100 font-medium text-sm hover:border-primary hover:text-primary transition-colors text-center"
                >
                  Ver listado →
                </RouterLink>
              </div>
            </div>

            <!-- Stats rápidas -->
            <div class="flex gap-6 pt-2">
              <div v-for="stat in stats" :key="stat.label" class="text-center">
                <p class="text-2xl font-bold text-primary">{{ stat.value }}</p>
                <p class="text-xs text-text-meta mt-0.5">{{ stat.label }}</p>
              </div>
            </div>
          </div>

          <!-- Ilustración -->
          <div class="hidden lg:flex items-center justify-center">
            <img
              :src="heroIllustration"
              alt=""
              aria-hidden="true"
              class="w-full max-w-md select-none"
            />
          </div>

        </div>
      </div>
    </div>

    <!-- Categorías destacadas -->
    <div class="border-t border-gray-100 dark:border-gray-800 bg-bg-soft dark:bg-gray-800">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
        <p class="text-xs font-semibold uppercase tracking-widest text-text-meta dark:text-gray-400 mb-5">Explorar por categoría</p>
        <div class="flex flex-wrap gap-2">
          <button
            v-for="cat in featuredCategories"
            :key="cat"
            class="text-sm px-4 py-2 rounded-xl border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 text-text-main dark:text-gray-100 hover:border-primary hover:text-primary transition-colors"
            @click="searchByCategory(cat)"
          >
            {{ cat }}
          </button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Search } from 'lucide-vue-next'
import { useResourcesStore } from '../stores/resources'
import { supabase } from '../lib/supabase'
import heroIllustration from '../assets/hero-illustration.svg'
import { useHead } from '../composables/useHead'

useHead()

const router = useRouter()
const store  = useResourcesStore()
const query  = ref('')

// Stats
const stats = ref([
  { value: '—', label: 'herramientas' },
  { value: '—', label: 'guías' },
  { value: '—', label: 'recursos' },
])

onMounted(async () => {
  const { data } = await supabase
    .from('resources')
    .select('type')
  if (!data) return
  stats.value = [
    { value: data.filter((r) => r.type === 'tool').length,     label: 'herramientas' },
    { value: data.filter((r) => r.type === 'guide').length,    label: 'guías' },
    { value: data.filter((r) => r.type === 'resource').length, label: 'recursos' },
  ]
})

function search() {
  store.resetFilters()
  store.filters.search = query.value.trim()
  router.push('/directorio')
}

function searchByCategory(cat) {
  store.resetFilters()
  store.filters.categories = [cat]
  router.push('/directorio')
}

const featuredCategories = [
  'Comunicación Segura',
  'Gestión de Contraseñas',
  'Anonimato y Navegación',
  'Cifrado de Archivos y Dispositivos',
  'Cobertura en Campo',
  'Autenticación',
  'Legislación y Derechos',
  'Formación y Metodología',
]
</script>
