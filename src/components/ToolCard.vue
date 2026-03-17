<template>
  <article class="bg-white dark:bg-gray-800 rounded-2xl shadow-sm hover:shadow-md transition-shadow duration-200 p-5 flex flex-col gap-3 border border-gray-100 dark:border-gray-700">
    <!-- Cabecera: tipo + ámbito -->
    <div class="flex flex-wrap gap-1.5 items-center">
      <span :class="typeBadgeClass">{{ typeLabel }}</span>
      <span
        v-for="s in resource.scope"
        :key="s"
        class="text-xs font-medium px-2 py-0.5 rounded-full bg-gray-100 dark:bg-gray-700 text-text-meta dark:text-gray-400"
      >{{ scopeLabel[s] }}</span>
    </div>

    <h3 class="font-bold text-text-main dark:text-gray-100 text-base leading-snug">{{ resource.title }}</h3>
    <p class="text-xs text-text-meta dark:text-gray-400">{{ resource.category }}</p>

    <!-- Plataformas -->
    <div v-if="resource.type === 'tool' && resource.platforms?.length" class="flex flex-wrap gap-2">
      <component :is="platformIcon(p)" v-for="p in resource.platforms" :key="p" :title="p" class="w-4 h-4 text-text-meta dark:text-gray-500" />
    </div>

    <!-- Badges -->
    <div class="flex flex-wrap gap-1.5 items-center mt-auto pt-2 border-t border-gray-50 dark:border-gray-700">
      <span :class="pricingBadgeClass">{{ pricingLabel }}</span>
      <span v-if="resource.is_opensource" class="text-xs font-medium px-2 py-0.5 rounded-full bg-emerald-50 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-400">Código abierto</span>
      <span v-if="resource.is_reviewed && resource.show_review" class="inline-flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-full bg-primary/10 text-primary">
        <BadgeCheck class="w-3 h-3" /> Revisada
      </span>
      <template v-if="resource.tags?.length">
        <span v-for="tag in resource.tags.slice(0, 3)" :key="tag" class="text-xs px-2 py-0.5 rounded-full bg-gray-100 dark:bg-gray-700 text-text-meta dark:text-gray-400">#{{ tag }}</span>
        <span v-if="resource.tags.length > 3" class="text-xs text-text-meta dark:text-gray-500">+{{ resource.tags.length - 3 }}</span>
      </template>
    </div>

    <!-- Acciones -->
    <div class="flex gap-2 pt-1">
      <button
        class="flex-1 text-sm font-medium py-1.5 px-3 rounded-xl border border-primary text-primary hover:bg-primary hover:text-white transition-colors duration-150"
        @click="$emit('open-detail', resource)"
      >
        Ver más
      </button>
      <button
        :class="[
          'p-1.5 rounded-xl border transition-colors duration-150',
          inMaleta ? 'bg-primary border-primary text-white' : 'border-gray-200 dark:border-gray-600 text-text-meta dark:text-gray-400 hover:border-primary hover:text-primary',
        ]"
        :title="inMaleta ? 'Quitar de Mi Kit' : 'Agregar a Mi Kit'"
        @click="toggleMaleta"
      >
        <BriefcaseBusiness class="w-4 h-4" />
      </button>
      <button
        class="p-1.5 rounded-xl border border-gray-200 dark:border-gray-600 text-text-meta dark:text-gray-400 hover:border-primary hover:text-primary transition-colors duration-150"
        title="Reportar o comentar"
        @click="$emit('open-feedback', resource.id)"
      >
        <MessageSquare class="w-4 h-4" />
      </button>
    </div>
  </article>
</template>

<script setup>
import { BadgeCheck, BriefcaseBusiness, MessageSquare, Globe, Smartphone, Monitor, Terminal, Laptop } from 'lucide-vue-next'
import { computed } from 'vue'
import { useMaletaStore } from '../stores/maleta'
import { useToast } from '../composables/useToast'

const props = defineProps({ resource: { type: Object, required: true } })
defineEmits(['open-detail', 'open-feedback'])

const maleta   = useMaletaStore()
const { add }  = useToast()
const inMaleta = computed(() => maleta.isSelected(props.resource.id))

function toggleMaleta() {
  const adding = !inMaleta.value
  maleta.toggle(props.resource)
  add(adding ? `"${props.resource.title}" agregado al kit` : `"${props.resource.title}" quitado del kit`)
}

const typeLabel    = computed(() => ({ tool: 'Herramienta', guide: 'Guía', resource: 'Recurso' }[props.resource.type]))
const pricingLabel = computed(() => ({ gratis: 'Gratis', pago: 'Pago', freemium: 'Freemium' }[props.resource.pricing]))
const scopeLabel   = { digital: 'Digital', 'física': 'Física', otra: 'Otra', integral: 'Integral' }

const typeBadgeClass = computed(() => {
  const base = 'text-xs font-semibold px-2 py-0.5 rounded-full'
  return { tool: `${base} bg-violet-100 dark:bg-violet-900/40 text-violet-700 dark:text-violet-300`, guide: `${base} bg-sky-100 dark:bg-sky-900/40 text-sky-700 dark:text-sky-300`, resource: `${base} bg-amber-100 dark:bg-amber-900/40 text-amber-700 dark:text-amber-300` }[props.resource.type]
})

const pricingBadgeClass = computed(() => {
  const base = 'text-xs font-medium px-2 py-0.5 rounded-full'
  return { gratis: `${base} bg-green-50 dark:bg-green-900/30 text-green-700 dark:text-green-400`, pago: `${base} bg-red-50 dark:bg-red-900/30 text-red-600 dark:text-red-400`, freemium: `${base} bg-yellow-50 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400` }[props.resource.pricing]
})

function platformIcon(p) {
  return { web: Globe, android: Smartphone, ios: Smartphone, windows: Monitor, linux: Terminal, mac: Laptop }[p] ?? Globe
}
</script>
