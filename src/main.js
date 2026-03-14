import { createApp } from 'vue'
import { createPinia } from 'pinia'
import piniaPluginPersistedstate from 'pinia-plugin-persistedstate'
import router from './router'
import './style.css'
import App from './App.vue'
import { useAuthStore } from './stores/auth'

// Capturar el hash ANTES de auth.init() — Supabase lo borra durante la inicialización
const initialHash = window.location.hash

const app   = createApp(App)
const pinia = createPinia()
pinia.use(piniaPluginPersistedstate)

app.use(pinia)
app.use(router)

const auth = useAuthStore()
auth.init().then(() => {
  app.mount('#app')
  if (initialHash.includes('type=invite')) {
    router.replace('/reset-password?invite=1')
  } else if (initialHash.includes('error=')) {
    router.replace('/reset-password?error=1')
  }
})
