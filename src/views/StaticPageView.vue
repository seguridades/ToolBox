<template>
  <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
    <div v-if="loading" class="space-y-3">
      <div class="h-8 bg-gray-100 dark:bg-gray-700 rounded-xl animate-pulse w-1/2" />
      <div class="h-4 bg-gray-100 dark:bg-gray-700 rounded animate-pulse" />
      <div class="h-4 bg-gray-100 dark:bg-gray-700 rounded animate-pulse w-3/4" />
    </div>

    <div
      v-else-if="html"
      class="prose prose-sm dark:prose-invert max-w-none prose-headings:font-bold prose-headings:text-text-main dark:prose-headings:text-gray-100 prose-p:text-text-main dark:prose-p:text-gray-100 prose-a:text-primary prose-strong:text-text-main dark:prose-strong:text-gray-100"
      v-html="html"
    />

    <div v-else class="text-center py-20 space-y-2">
      <p class="text-text-meta text-sm">Página no encontrada.</p>
      <RouterLink to="/directorio" class="text-xs text-primary hover:underline">Volver al listado</RouterLink>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue'
import { useRoute } from 'vue-router'
import { marked } from 'marked'
import DOMPurify from 'dompurify'
import { useHead } from '../composables/useHead'

const route  = useRoute()
const html   = ref('')
const loading = ref(false)

const pageTitles = { 'acerca-de': 'Acerca de', 'principios': 'Principios', 'como-colaborar': 'Cómo colaborar' }
useHead({ title: computed(() => pageTitles[route.params.slug] ?? null) })

const pages = {
  'acerca-de':     () => import('../pages/acerca-de.md?raw'),
  'principios':    () => import('../pages/principios.md?raw'),
  'como-colaborar': () => import('../pages/como-colaborar.md?raw'),
}

async function loadPage(slug) {
  loading.value = true
  html.value    = ''
  const loader  = pages[slug]
  if (loader) {
    const mod = await loader()
    html.value = DOMPurify.sanitize(marked.parse(mod.default))
  }
  loading.value = false
}

watch(() => route.params.slug, (slug) => loadPage(slug), { immediate: true })
</script>
