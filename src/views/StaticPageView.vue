<template>
  <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
    <div v-if="loading" class="space-y-3">
      <div class="h-8 bg-gray-100 rounded-xl animate-pulse w-1/2" />
      <div class="h-4 bg-gray-100 rounded animate-pulse" />
      <div class="h-4 bg-gray-100 rounded animate-pulse w-3/4" />
    </div>

    <div
      v-else-if="html"
      class="prose prose-sm max-w-none prose-headings:font-bold prose-headings:text-text-main prose-p:text-text-main prose-a:text-primary prose-strong:text-text-main"
      v-html="html"
    />

    <div v-else class="text-center py-20 space-y-2">
      <p class="text-text-meta text-sm">Página no encontrada.</p>
      <RouterLink to="/" class="text-xs text-primary hover:underline">Volver al directorio</RouterLink>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { marked } from 'marked'

const route  = useRoute()
const html   = ref('')
const loading = ref(false)

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
    html.value = marked.parse(mod.default)
  }
  loading.value = false
}

watch(() => route.params.slug, (slug) => loadPage(slug), { immediate: true })
</script>
