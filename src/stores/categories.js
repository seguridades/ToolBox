import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '../lib/supabase'

export const useCategoriesStore = defineStore('categories', () => {
  const categories = ref([])
  const loading    = ref(false)

  const names = computed(() => categories.value.map((c) => c.name))

  async function fetchAll() {
    if (categories.value.length) return
    loading.value = true
    const { data } = await supabase.from('categories').select('*').order('name')
    categories.value = data ?? []
    loading.value = false
  }

  async function add(name) {
    const { data, error } = await supabase
      .from('categories')
      .insert({ name: name.trim() })
      .select()
      .single()
    if (!error) categories.value.push(data)
    return { data, error }
  }

  async function update(id, name) {
    const { error } = await supabase
      .from('categories')
      .update({ name: name.trim() })
      .eq('id', id)
    if (!error) {
      const cat = categories.value.find((c) => c.id === id)
      if (cat) cat.name = name.trim()
    }
    return { error }
  }

  async function remove(id) {
    const { error } = await supabase.from('categories').delete().eq('id', id)
    if (!error) categories.value = categories.value.filter((c) => c.id !== id)
    return { error }
  }

  function refresh() {
    categories.value = []
    return fetchAll()
  }

  return { categories, loading, names, fetchAll, add, update, remove, refresh }
})
