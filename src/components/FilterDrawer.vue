<template>
  <Teleport to="body">
    <Transition name="fade">
      <div v-if="open" class="fixed inset-0 z-40 bg-black/30" @click="$emit('close')" />
    </Transition>
    <Transition name="slide">
      <div v-if="open" class="fixed top-0 left-0 z-50 h-full w-72 bg-white dark:bg-gray-900 shadow-xl flex flex-col">
        <div class="flex items-center justify-between px-5 py-4 border-b border-gray-100 dark:border-gray-800 shrink-0">
          <span class="font-semibold text-text-main dark:text-gray-100 text-sm">Filtros</span>
          <button class="text-text-meta dark:text-gray-400 hover:text-text-main dark:hover:text-gray-100 transition-colors" @click="$emit('close')">
            <X class="w-5 h-5" />
          </button>
        </div>
        <div class="flex-1 overflow-y-auto p-4">
          <FilterSidebar />
        </div>
        <div class="px-5 py-4 border-t border-gray-100 dark:border-gray-800 shrink-0">
          <button class="w-full py-2.5 rounded-xl bg-primary text-white text-sm font-semibold" @click="$emit('close')">
            Ver {{ store.filtered.length }} resultado{{ store.filtered.length !== 1 ? 's' : '' }}
          </button>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { toRef } from 'vue'
import { X } from 'lucide-vue-next'
import FilterSidebar from './FilterSidebar.vue'
import { useResourcesStore } from '../stores/resources'
import { useScrollLockProp } from '../composables/useScrollLock'

const props = defineProps({ open: { type: Boolean, required: true } })
defineEmits(['close'])

useScrollLockProp(toRef(props, 'open'))
const store = useResourcesStore()
</script>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s ease; }
.fade-enter-from, .fade-leave-to       { opacity: 0; }
.slide-enter-active, .slide-leave-active { transition: transform 0.25s ease; }
.slide-enter-from, .slide-leave-to       { transform: translateX(-100%); }
</style>
