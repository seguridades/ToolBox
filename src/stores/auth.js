import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '../lib/supabase'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const loading = ref(true)

  const role = computed(() => user.value?.app_metadata?.role ?? null)
  const isEditor = computed(() => role.value === 'editor' || role.value === 'admin')
  const isAdmin = computed(() => role.value === 'admin')

  async function init() {
    const { data } = await supabase.auth.getSession()
    user.value = data.session?.user ?? null
    loading.value = false

    supabase.auth.onAuthStateChange((_event, session) => {
      user.value = session?.user ?? null
    })
  }

  async function signOut() {
    await supabase.auth.signOut()
    user.value = null
  }

  return { user, loading, role, isEditor, isAdmin, init, signOut }
})
