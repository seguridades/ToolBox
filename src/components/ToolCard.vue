<template>
  <article
    class="bg-white rounded-2xl shadow-sm hover:shadow-md transition-shadow duration-200 p-5 flex flex-col gap-3 border border-gray-100"
  >
    <!-- Cabecera: tipo + ámbito -->
    <div class="flex flex-wrap gap-1.5 items-center">
      <span :class="typeBadgeClass">{{ typeLabel }}</span>
      <span
        v-for="s in resource.scope"
        :key="s"
        class="text-xs font-medium px-2 py-0.5 rounded-full bg-gray-100 text-text-meta"
      >
        {{ scopeLabel[s] }}
      </span>
    </div>

    <!-- Título -->
    <h3 class="font-bold text-text-main text-base leading-snug">{{ resource.title }}</h3>

    <!-- Categoría -->
    <p class="text-xs text-text-meta">{{ resource.category }}</p>

    <!-- Plataformas (solo si type = tool) -->
    <div v-if="resource.type === 'tool' && resource.platforms?.length" class="flex flex-wrap gap-2">
      <component
        :is="platformIcon(p)"
        v-for="p in resource.platforms"
        :key="p"
        :title="p"
        class="w-4 h-4 text-text-meta"
      />
    </div>

    <!-- Badges inferiores -->
    <div class="flex flex-wrap gap-1.5 items-center mt-auto pt-2 border-t border-gray-50">
      <!-- Pricing -->
      <span :class="pricingBadgeClass">{{ pricingLabel }}</span>

      <!-- Opensource -->
      <span
        v-if="resource.is_opensource"
        class="text-xs font-medium px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700"
      >
        Código abierto
      </span>

      <!-- Sello revisada -->
      <span
        v-if="resource.is_reviewed && resource.show_review"
        class="inline-flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-full bg-primary/10 text-primary"
      >
        <BadgeCheck class="w-3 h-3" />
        Revisada
      </span>

      <!-- Tags (máx 3) -->
      <template v-if="resource.tags?.length">
        <span
          v-for="tag in resource.tags.slice(0, 3)"
          :key="tag"
          class="text-xs px-2 py-0.5 rounded-full bg-gray-100 text-text-meta"
        >
          #{{ tag }}
        </span>
        <span
          v-if="resource.tags.length > 3"
          class="text-xs text-text-meta"
        >
          +{{ resource.tags.length - 3 }}
        </span>
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
          inMaleta
            ? 'bg-primary border-primary text-white'
            : 'border-gray-200 text-text-meta hover:border-primary hover:text-primary',
        ]"
        :title="inMaleta ? 'Quitar de Maleta de Taller' : 'Agregar a Maleta de Taller'"
        @click="maleta.toggle(resource)"
      >
        <BriefcaseBusiness class="w-4 h-4" />
      </button>
      <button
        class="p-1.5 rounded-xl border border-gray-200 text-text-meta hover:border-primary hover:text-primary transition-colors duration-150"
        title="Reportar o comentar"
        @click="$emit('open-feedback', resource.id)"
      >
        <MessageSquare class="w-4 h-4" />
      </button>
    </div>
  </article>
</template>

<script setup>
import {
  BadgeCheck,
  BriefcaseBusiness,
  MessageSquare,
  Globe,
  Smartphone,
  Monitor,
  Terminal,
  Laptop,
} from 'lucide-vue-next'
import { computed } from 'vue'
import { useMaletaStore } from '../stores/maleta'

const props = defineProps({
  resource: { type: Object, required: true },
})

defineEmits(['open-detail', 'open-feedback'])

const maleta = useMaletaStore()
const inMaleta = computed(() => maleta.isSelected(props.resource.id))

// --- Labels ---
const typeLabel = computed(() => ({
  tool: 'Herramienta',
  guide: 'Guía',
  resource: 'Recurso',
}[props.resource.type]))

const scopeLabel = {
  digital: 'Digital',
  'física': 'Física',
  otra: 'Otra',
  mixta: 'Mixta',
}

const pricingLabel = computed(() => ({
  gratis: 'Gratis',
  pago: 'Pago',
  freemium: 'Freemium',
}[props.resource.pricing]))

// --- Badge styles ---
const typeBadgeClass = computed(() => {
  const base = 'text-xs font-semibold px-2 py-0.5 rounded-full'
  return {
    tool:     `${base} bg-violet-100 text-violet-700`,
    guide:    `${base} bg-sky-100 text-sky-700`,
    resource: `${base} bg-amber-100 text-amber-700`,
  }[props.resource.type]
})

const pricingBadgeClass = computed(() => {
  const base = 'text-xs font-medium px-2 py-0.5 rounded-full'
  return {
    gratis:   `${base} bg-green-50 text-green-700`,
    pago:     `${base} bg-red-50 text-red-600`,
    freemium: `${base} bg-yellow-50 text-yellow-700`,
  }[props.resource.pricing]
})

// --- Iconos de plataforma ---
function platformIcon(platform) {
  return {
    web:     Globe,
    android: Smartphone,
    ios:     Smartphone,
    windows: Monitor,
    linux:   Terminal,
    mac:     Laptop,
  }[platform] ?? Globe
}
</script>
