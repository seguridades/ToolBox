import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '../lib/supabase'

export const useResourcesStore = defineStore('resources', () => {
  // --- Estado base ---
  const items = ref([])
  const loading = ref(false)
  const error = ref(null)

  // --- Filtros activos ---
  const filters = ref({
    search: '',
    types: [],        // 'tool' | 'guide' | 'resource'
    scopes: [],       // 'digital' | 'física' | 'otra' | 'mixta'
    categories: [],   // enum de categorías
    tags: [],
    platforms: [],    // solo relevante si type = tool
    pricing: [],      // 'gratis' | 'pago' | 'freemium'
    isOpensource: null,
  })

  // --- Lista filtrada reactiva ---
  const filtered = computed(() => {
    return items.value.filter((r) => {
      const { search, types, scopes, categories, tags, platforms, pricing, isOpensource } = filters.value

      if (search) {
        const q = search.toLowerCase()
        if (!r.title.toLowerCase().includes(q) && !r.description?.toLowerCase().includes(q)) return false
      }
      if (types.length && !types.includes(r.type)) return false
      if (scopes.length && !r.scope?.some((s) => scopes.includes(s))) return false
      if (categories.length && !categories.includes(r.category)) return false
      if (tags.length && !r.tags?.some((t) => tags.includes(t))) return false
      if (platforms.length && r.type === 'tool' && !r.platforms?.some((p) => platforms.includes(p))) return false
      if (pricing.length && !pricing.includes(r.pricing)) return false
      if (isOpensource !== null && r.is_opensource !== isOpensource) return false

      return true
    })
  })

  // --- Acciones ---
  async function fetchAll() {
    loading.value = true
    error.value = null
    const { data, error: err } = await supabase
      .from('resources')
      .select('*')
      .order('created_at', { ascending: false })

    if (err) error.value = err.message
    else items.value = data ?? []
    loading.value = false
  }

  function resetFilters() {
    filters.value = {
      search: '',
      types: [],
      scopes: [],
      categories: [],
      tags: [],
      platforms: [],
      pricing: [],
      isOpensource: null,
    }
  }

  return { items, loading, error, filters, filtered, fetchAll, resetFilters }
})
