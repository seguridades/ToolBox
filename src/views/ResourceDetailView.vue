<template>
  <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">

    <!-- Loading -->
    <div v-if="loading" class="space-y-4 animate-pulse">
      <div class="h-4 bg-gray-100 dark:bg-gray-700 rounded w-1/4" />
      <div class="h-8 bg-gray-100 dark:bg-gray-700 rounded-xl w-3/4" />
      <div class="h-4 bg-gray-100 dark:bg-gray-700 rounded w-1/2" />
      <div class="space-y-2 pt-6">
        <div class="h-4 bg-gray-100 dark:bg-gray-700 rounded" />
        <div class="h-4 bg-gray-100 dark:bg-gray-700 rounded w-5/6" />
        <div class="h-4 bg-gray-100 dark:bg-gray-700 rounded w-4/6" />
      </div>
    </div>

    <!-- Not found -->
    <div v-else-if="!resource" class="text-center py-24 space-y-3">
      <p class="text-text-meta dark:text-gray-400 text-sm">Recurso no encontrado.</p>
      <RouterLink to="/directorio" class="text-sm text-primary hover:underline">← Volver al directorio</RouterLink>
    </div>

    <!-- Content -->
    <div v-else class="space-y-6">

      <!-- Back -->
      <RouterLink to="/directorio" class="inline-flex items-center gap-1.5 text-sm text-text-meta dark:text-gray-400 hover:text-primary transition-colors">
        <ArrowLeft class="w-4 h-4" /> Volver al listado
      </RouterLink>

      <!-- Type + scope -->
      <div class="flex flex-wrap gap-1.5 items-center">
        <span :class="typeBadgeClass">{{ typeLabel }}</span>
        <span
          v-for="s in resource.scope"
          :key="s"
          class="text-xs font-medium px-2 py-0.5 rounded-full bg-gray-100 dark:bg-gray-700 text-text-meta dark:text-gray-400"
        >{{ scopeLabel[s] }}</span>
      </div>

      <!-- Title + category -->
      <div>
        <h1 class="font-bold text-text-main dark:text-gray-100 text-2xl sm:text-3xl leading-snug">{{ resource.title }}</h1>
        <p class="text-sm text-text-meta dark:text-gray-400 mt-1">{{ resource.category }}</p>
      </div>

      <!-- Pricing + trust badges -->
      <div class="flex flex-wrap gap-1.5">
        <span :class="pricingBadgeClass">{{ pricingLabel }}</span>
        <span v-if="resource.is_opensource" class="text-xs font-medium px-2 py-0.5 rounded-full bg-emerald-50 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-400">Código abierto</span>
        <span v-if="resource.is_reviewed && resource.show_review" class="inline-flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-full bg-primary/10 text-primary">
          <BadgeCheck class="w-3 h-3" /> Revisada por seguridades.org
        </span>
        <span v-if="resource.has_audit && resource.show_audit" class="inline-flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-full bg-blue-50 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400">
          <ShieldCheck class="w-3 h-3" /> Auditoría externa
        </span>
      </div>

      <!-- Platforms -->
      <div v-if="resource.type === 'tool' && resource.platforms?.length" class="flex flex-wrap gap-2 items-center">
        <span class="text-xs text-text-meta dark:text-gray-400">Disponible en:</span>
        <span
          v-for="p in resource.platforms"
          :key="p"
          class="flex items-center gap-1 text-xs px-2 py-0.5 rounded-full bg-gray-100 dark:bg-gray-700 text-text-main dark:text-gray-100"
        >
          <component :is="platformIcon(p)" class="w-3 h-3" />{{ p }}
        </span>
      </div>

      <!-- Description -->
      <div v-if="resource.description">
        <p class="text-xs font-semibold uppercase tracking-wide text-text-meta dark:text-gray-400 mb-2">Descripción</p>
        <p class="text-sm text-text-main dark:text-gray-100 leading-relaxed">{{ resource.description }}</p>
      </div>

      <!-- Verdict -->
      <div v-if="resource.verdict" class="bg-primary/5 dark:bg-primary/10 border border-primary/20 rounded-xl p-4">
        <p class="text-xs font-semibold uppercase tracking-wide text-primary mb-1">Recomendación de seguridades.org</p>
        <p class="text-sm text-text-main dark:text-gray-100 leading-relaxed">{{ resource.verdict }}</p>
      </div>

      <!-- Manuals -->
      <div v-if="resource.type === 'tool' && manuals.length">
        <p class="text-xs font-semibold uppercase tracking-wide text-text-meta dark:text-gray-400 mb-2">Manuales de uso</p>
        <ul class="space-y-2">
          <li v-for="m in manuals" :key="m.id">
            <a :href="m.url" target="_blank" rel="noopener noreferrer"
              class="flex items-center gap-2 text-sm text-primary hover:underline">
              <BookOpen class="w-3.5 h-3.5 shrink-0" />
              {{ m.title }}
              <span v-if="m.source" class="text-text-meta dark:text-gray-400 text-xs">— {{ m.source }}</span>
            </a>
          </li>
        </ul>
      </div>

      <!-- Tags -->
      <div v-if="resource.tags?.length">
        <p class="text-xs font-semibold uppercase tracking-wide text-text-meta dark:text-gray-400 mb-2">Etiquetas</p>
        <div class="flex flex-wrap gap-1.5">
          <span
            v-for="tag in resource.tags"
            :key="tag"
            class="text-xs px-2 py-0.5 rounded-full bg-gray-100 dark:bg-gray-700 text-text-meta dark:text-gray-400"
          >#{{ tag }}</span>
        </div>
      </div>

      <!-- Last updated -->
      <p class="text-xs text-text-meta dark:text-gray-400">Última actualización: {{ formatDate(resource.updated_at) }}</p>

      <!-- Actions -->
      <div class="flex flex-wrap gap-3 pt-4 border-t border-gray-100 dark:border-gray-800">
        <a
          v-if="resource.official_url"
          :href="resource.official_url"
          target="_blank"
          rel="noopener noreferrer"
          class="flex items-center gap-2 py-2.5 px-5 rounded-xl bg-primary text-white text-sm font-semibold hover:bg-primary/90 transition-colors"
        >
          <ExternalLink class="w-4 h-4" /> Sitio oficial
        </a>
        <a
          v-if="resource.repo_url"
          :href="resource.repo_url"
          target="_blank"
          rel="noopener noreferrer"
          class="flex items-center gap-2 px-4 py-2.5 rounded-xl border border-gray-200 dark:border-gray-700 text-text-main dark:text-gray-100 text-sm font-medium hover:border-primary hover:text-primary transition-colors"
        >
          <Github class="w-4 h-4" /> Repositorio
        </a>
        <button
          class="flex items-center gap-2 px-4 py-2.5 rounded-xl border border-gray-200 dark:border-gray-700 text-text-meta dark:text-gray-400 text-sm hover:border-primary hover:text-primary transition-colors"
          @click="copyLink"
        >
          <Link2 class="w-4 h-4" />
          {{ copied ? '¡Copiado!' : 'Copiar enlace' }}
        </button>
        <button
          :class="[
            'flex items-center gap-2 px-4 py-2.5 rounded-xl border text-sm font-medium transition-colors',
            inMaleta
              ? 'bg-primary border-primary text-white'
              : 'border-gray-200 dark:border-gray-700 text-text-meta dark:text-gray-400 hover:border-primary hover:text-primary',
          ]"
          @click="toggleMaleta"
        >
          <BriefcaseBusiness class="w-4 h-4" />
          {{ inMaleta ? 'En mi kit' : 'Agregar al kit' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import {
  ArrowLeft, BadgeCheck, ShieldCheck, BookOpen,
  ExternalLink, Github, Link2, BriefcaseBusiness,
} from 'lucide-vue-next'
import { supabase } from '../lib/supabase'
import { useMaletaStore } from '../stores/maleta'
import { useToast } from '../composables/useToast'
import { useHead } from '../composables/useHead'
import { TYPE_LABELS, SCOPE_LABELS, PRICING_LABELS } from '../constants/labels'
import { getTypeBadgeClass, getPricingBadgeClass, getPlatformIcon, formatDate } from '../utils/resource'

const route    = useRoute()
const maleta   = useMaletaStore()
const { add }  = useToast()

const resource = ref(null)
const manuals  = ref([])
const loading  = ref(true)
const copied   = ref(false)

const inMaleta = computed(() => resource.value ? maleta.isSelected(resource.value.id) : false)

useHead({
  title:       computed(() => resource.value?.title ?? null),
  description: computed(() => resource.value?.description ?? null),
})

onMounted(async () => {
  const { data } = await supabase
    .from('resources')
    .select('*')
    .eq('id', route.params.id)
    .single()
  resource.value = data
  if (data?.type === 'tool') {
    const { data: m } = await supabase
      .from('tool_manuals')
      .select('*')
      .eq('tool_id', data.id)
      .order('created_at')
    manuals.value = m ?? []
  }
  loading.value = false
})

function toggleMaleta() {
  if (!resource.value) return
  const adding = !inMaleta.value
  maleta.toggle(resource.value)
  add(adding
    ? `"${resource.value.title}" agregado al kit`
    : `"${resource.value.title}" quitado del kit`)
}

async function copyLink() {
  await navigator.clipboard.writeText(window.location.href)
  copied.value = true
  setTimeout(() => { copied.value = false }, 2000)
}

const typeLabel         = computed(() => TYPE_LABELS[resource.value?.type])
const pricingLabel      = computed(() => PRICING_LABELS[resource.value?.pricing])
const scopeLabel        = SCOPE_LABELS
const typeBadgeClass    = computed(() => getTypeBadgeClass(resource.value?.type))
const pricingBadgeClass = computed(() => getPricingBadgeClass(resource.value?.pricing))
const platformIcon      = getPlatformIcon
</script>
