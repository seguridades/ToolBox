import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

// Campos que se exportan según spec sección 7.2
const EXPORT_FIELDS = ['title', 'official_url', 'repo_url', 'pricing', 'is_opensource', 'platforms']

export const useMaletaStore = defineStore(
  'maleta',
  () => {
    const selected = ref([]) // array de recursos completos

    const count = computed(() => selected.value.length)

    const exportData = computed(() =>
      selected.value.map((r) =>
        Object.fromEntries(EXPORT_FIELDS.map((f) => [f, r[f] ?? null]))
      )
    )

    function toggle(resource) {
      const idx = selected.value.findIndex((r) => r.id === resource.id)
      if (idx === -1) selected.value.push(resource)
      else selected.value.splice(idx, 1)
    }

    function isSelected(id) {
      return selected.value.some((r) => r.id === id)
    }

    function clear() {
      selected.value = []
    }

    return { selected, count, exportData, toggle, isSelected, clear }
  },
  {
    persist: true, // Pinia persistance via pinia-plugin-persistedstate (a instalar)
  }
)
