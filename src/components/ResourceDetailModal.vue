<template>
  <Teleport to="body">
    <div
      class="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/40 px-0 sm:px-4"
      @click.self="$emit('close')"
    >
      <div class="bg-white dark:bg-gray-900 w-full sm:max-w-2xl sm:rounded-2xl rounded-t-2xl shadow-xl max-h-[90dvh] flex flex-col">

        <!-- Cabecera fija -->
        <div class="flex items-start justify-between gap-4 px-6 pt-6 pb-4 border-b border-gray-100 dark:border-gray-800">
          <div class="flex flex-wrap gap-1.5 items-center">
            <span :class="typeBadgeClass">{{ typeLabel }}</span>
            <span
              v-for="s in resource.scope"
              :key="s"
              class="text-xs font-medium px-2 py-0.5 rounded-full bg-gray-100 dark:bg-gray-700 text-text-meta dark:text-gray-400"
            >{{ scopeLabel[s] }}</span>
          </div>
          <div class="flex items-center gap-1 shrink-0">
            <RouterLink
              :to="`/directorio/${resource.id}`"
              class="p-1 text-text-meta dark:text-gray-400 hover:text-text-main dark:hover:text-gray-100 transition-colors"
              title="Ver página completa"
              @click="$emit('close')"
            >
              <ExternalLink class="w-4 h-4" />
            </RouterLink>
            <button class="p-1 text-text-meta dark:text-gray-400 hover:text-text-main dark:hover:text-gray-100 transition-colors" @click="$emit('close')">
              <X class="w-5 h-5" />
            </button>
          </div>
        </div>

        <!-- Contenido scrolleable -->
        <div class="overflow-y-auto px-6 py-5 space-y-5">

          <!-- Título + categoría -->
          <div>
            <h2 class="font-bold text-text-main dark:text-gray-100 text-xl leading-snug">{{ resource.title }}</h2>
            <p class="text-sm text-text-meta dark:text-gray-400 mt-1">{{ resource.category }}</p>
          </div>

          <!-- Badges -->
          <div class="flex flex-wrap gap-1.5">
            <span :class="pricingBadgeClass">{{ pricingLabel }}</span>
            <span v-if="resource.is_opensource" class="text-xs font-medium px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700">Código abierto</span>
            <span v-if="resource.is_reviewed && resource.show_review" class="inline-flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-full bg-primary/10 text-primary">
              <BadgeCheck class="w-3 h-3" /> Revisada por seguridades.org
            </span>
            <span v-if="resource.has_audit && resource.show_audit" class="inline-flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-full bg-blue-50 text-blue-700">
              <ShieldCheck class="w-3 h-3" /> Auditoría externa
            </span>
          </div>

          <!-- Plataformas -->
          <div v-if="resource.type === 'tool' && resource.platforms?.length" class="flex flex-wrap gap-2 items-center">
            <span class="text-xs text-text-meta">Disponible en:</span>
            <div class="flex flex-wrap gap-2">
              <span
                v-for="p in resource.platforms"
                :key="p"
                class="flex items-center gap-1 text-xs px-2 py-0.5 rounded-full bg-gray-100 dark:bg-gray-700 text-text-main dark:text-gray-100"
              >
                <component :is="platformIcon(p)" class="w-3 h-3" />
                {{ p }}
              </span>
            </div>
          </div>

          <!-- Descripción -->
          <div v-if="resource.description">
            <p class="text-xs font-semibold uppercase tracking-wide text-text-meta dark:text-gray-400 mb-1">Descripción</p>
            <p class="text-sm text-text-main dark:text-gray-100 leading-relaxed">{{ resource.description }}</p>
          </div>

          <!-- Veredicto editorial -->
          <div v-if="resource.verdict" class="bg-primary/5 dark:bg-primary/10 border border-primary/20 rounded-xl p-4">
            <p class="text-xs font-semibold uppercase tracking-wide text-primary mb-1">Recomendación de seguridades.org</p>
            <p class="text-sm text-text-main dark:text-gray-100 leading-relaxed">{{ resource.verdict }}</p>
          </div>

          <!-- Manuales de uso -->
          <div v-if="resource.type === 'tool' && manuals.length">
            <p class="text-xs font-semibold uppercase tracking-wide text-text-meta dark:text-gray-400 mb-2">Manuales de uso</p>
            <ul class="space-y-2">
              <li v-for="m in manuals" :key="m.id">
                <a
                  :href="m.url"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="flex items-center gap-2 text-sm text-primary hover:underline"
                >
                  <BookOpen class="w-3.5 h-3.5 shrink-0" />
                  <span>{{ m.title }}</span>
                  <span v-if="m.source" class="text-text-meta dark:text-gray-400 text-xs">— {{ m.source }}</span>
                </a>
              </li>
            </ul>
          </div>

          <!-- Tags completos -->
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

          <!-- Última actualización -->
          <p class="text-xs text-text-meta dark:text-gray-400">
            Última actualización: {{ formatDate(resource.updated_at) }}
          </p>
        </div>

        <!-- Pie fijo: botones de acción -->
        <div class="px-6 py-4 border-t border-gray-100 dark:border-gray-800 flex flex-wrap gap-2">
          <a
            v-if="resource.official_url"
            :href="resource.official_url"
            target="_blank"
            rel="noopener noreferrer"
            class="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl bg-primary text-white text-sm font-semibold hover:bg-primary/90 transition-colors"
          >
            <ExternalLink class="w-4 h-4" /> Sitio oficial
          </a>
          <a
            v-if="resource.repo_url"
            :href="resource.repo_url"
            target="_blank"
            rel="noopener noreferrer"
            class="flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl border border-gray-200 dark:border-gray-700 text-text-main dark:text-gray-100 text-sm font-medium hover:border-primary hover:text-primary transition-colors"
          >
            <Github class="w-4 h-4" /> Repositorio
          </a>
          <button
            class="flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl border border-gray-200 dark:border-gray-700 text-text-meta dark:text-gray-400 text-sm hover:border-primary hover:text-primary transition-colors"
            @click="$emit('open-feedback', resource.id)"
          >
            <MessageSquare class="w-4 h-4" /> Comentar
          </button>
          <button
            class="flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl border border-gray-200 dark:border-gray-700 text-text-meta dark:text-gray-400 text-sm hover:border-primary hover:text-primary transition-colors"
            @click="copyLink"
          >
            <Link2 class="w-4 h-4" /> {{ copied ? '¡Copiado!' : 'Compartir' }}
          </button>
          <button
            :class="[
              'flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl border text-sm font-medium transition-colors',
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
  </Teleport>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import {
  X, BadgeCheck, ShieldCheck, BookOpen, ExternalLink,
  Github, MessageSquare, BriefcaseBusiness, Link2,
} from 'lucide-vue-next'
import { supabase } from '../lib/supabase'
import { useMaletaStore } from '../stores/maleta'
import { useScrollLock } from '../composables/useScrollLock'
import { useToast } from '../composables/useToast'
import { TYPE_LABELS, SCOPE_LABELS, PRICING_LABELS } from '../constants/labels'
import { getTypeBadgeClass, getPricingBadgeClass, getPlatformIcon, formatDate } from '../utils/resource'

const props = defineProps({
  resource: { type: Object, required: true },
})

defineEmits(['close', 'open-feedback'])

useScrollLock()
const maleta   = useMaletaStore()
const { add }  = useToast()
const manuals  = ref([])
const copied   = ref(false)

function toggleMaleta() {
  const adding = !inMaleta.value
  maleta.toggle(props.resource)
  add(adding ? `"${props.resource.title}" agregado al kit` : `"${props.resource.title}" quitado del kit`)
}

async function copyLink() {
  await navigator.clipboard.writeText(`${window.location.origin}/directorio/${props.resource.id}`)
  copied.value = true
  setTimeout(() => { copied.value = false }, 2000)
}
const inMaleta = computed(() => maleta.isSelected(props.resource.id))

onMounted(async () => {
  if (props.resource.type !== 'tool') return
  const { data } = await supabase
    .from('tool_manuals')
    .select('*')
    .eq('tool_id', props.resource.id)
    .order('created_at')
  manuals.value = data ?? []
})

const typeLabel         = computed(() => TYPE_LABELS[props.resource.type])
const pricingLabel      = computed(() => PRICING_LABELS[props.resource.pricing])
const scopeLabel        = SCOPE_LABELS
const typeBadgeClass    = computed(() => getTypeBadgeClass(props.resource.type))
const pricingBadgeClass = computed(() => getPricingBadgeClass(props.resource.pricing))
const platformIcon      = getPlatformIcon
</script>
