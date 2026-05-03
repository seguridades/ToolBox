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
    <p v-if="resource.description" class="text-xs text-text-meta dark:text-gray-400 line-clamp-2 leading-relaxed -mt-1">{{ resource.description }}</p>

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
import { BadgeCheck, BriefcaseBusiness, MessageSquare } from 'lucide-vue-next'
import { computed } from 'vue'
import { useMaletaStore } from '../stores/maleta'
import { useToast } from '../composables/useToast'
import { TYPE_LABELS, SCOPE_LABELS, PRICING_LABELS } from '../constants/labels'
import { getTypeBadgeClass, getPricingBadgeClass, getPlatformIcon } from '../utils/resource'

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

const typeLabel         = computed(() => TYPE_LABELS[props.resource.type])
const pricingLabel      = computed(() => PRICING_LABELS[props.resource.pricing])
const scopeLabel        = SCOPE_LABELS
const typeBadgeClass    = computed(() => getTypeBadgeClass(props.resource.type))
const pricingBadgeClass = computed(() => getPricingBadgeClass(props.resource.pricing))
const platformIcon      = getPlatformIcon
</script>
