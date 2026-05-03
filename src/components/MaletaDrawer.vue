<template>
  <Teleport to="body">
    <Transition name="fade">
      <div v-if="open" class="fixed inset-0 z-40 bg-black/30" @click="$emit('close')" />
    </Transition>
    <Transition name="slide">
      <div v-if="open" class="fixed top-0 right-0 z-50 h-full w-80 bg-white dark:bg-gray-900 shadow-xl flex flex-col">
        <div class="flex items-center justify-between px-5 py-4 border-b border-gray-100 dark:border-gray-800 shrink-0">
          <div class="flex items-center gap-2">
            <BriefcaseBusiness class="w-4 h-4 text-primary" />
            <span class="font-semibold text-text-main dark:text-gray-100 text-sm">Mi Kit</span>
          </div>
          <button class="text-text-meta dark:text-gray-400 hover:text-text-main dark:hover:text-gray-100 transition-colors" @click="$emit('close')">
            <X class="w-5 h-5" />
          </button>
        </div>

        <div class="flex-1 overflow-y-auto px-5 py-4">
          <p v-if="maleta.count === 0" class="text-sm text-text-meta dark:text-gray-400 leading-relaxed">
            Agregá recursos con el ícono de maletín en cada tarjeta para armar tu kit.
          </p>
          <ul v-else class="space-y-3">
            <li v-for="r in maleta.selected" :key="r.id" class="flex items-start justify-between gap-3">
              <div class="space-y-0.5 min-w-0">
                <p class="text-sm text-text-main dark:text-gray-100 leading-snug">{{ r.title }}</p>
                <p class="text-xs text-text-meta dark:text-gray-400 capitalize">{{ r.pricing }}</p>
              </div>
              <button class="text-text-meta dark:text-gray-400 hover:text-red-500 transition-colors shrink-0 mt-0.5" @click="maleta.toggle(r)">
                <X class="w-4 h-4" />
              </button>
            </li>
          </ul>
        </div>

        <div v-if="maleta.count > 0" class="px-5 py-4 border-t border-gray-100 dark:border-gray-800 space-y-2 shrink-0">
          <button class="w-full flex items-center justify-center gap-2 py-2.5 rounded-xl bg-primary text-white text-sm font-semibold hover:bg-primary/90 transition-colors" @click="doExportPDF">
            <FileDown class="w-4 h-4" /> Exportar PDF
          </button>
          <button class="w-full flex items-center justify-center gap-2 py-2.5 rounded-xl border border-primary text-primary text-sm font-medium hover:bg-primary/5 transition-colors" @click="doExportCSV">
            <Sheet class="w-4 h-4" /> Exportar CSV
          </button>
          <button class="w-full text-xs text-text-meta dark:text-gray-400 hover:text-red-500 transition-colors pt-1" @click="clearConfirmOpen = true">
            Vaciar kit
          </button>
        </div>
      </div>
    </Transition>
  </Teleport>

  <ConfirmDialog
    v-if="clearConfirmOpen"
    message="¿Vaciar el kit? Esta acción no se puede deshacer."
    @confirm="doClear"
    @cancel="clearConfirmOpen = false"
  />
</template>

<script setup>
import { BriefcaseBusiness, X, FileDown, Sheet } from 'lucide-vue-next'
import { ref, toRef } from 'vue'
import { useMaletaStore } from '../stores/maleta'
import { exportPDF, exportCSV } from '../composables/useExport'
import { useScrollLockProp } from '../composables/useScrollLock'
import ConfirmDialog from './ConfirmDialog.vue'

const props = defineProps({ open: { type: Boolean, required: true } })
defineEmits(['close'])

useScrollLockProp(toRef(props, 'open'))
const maleta           = useMaletaStore()
const clearConfirmOpen = ref(false)

function doExportPDF() { exportPDF(maleta.exportData) }
function doExportCSV() { exportCSV(maleta.exportData) }
function doClear()     { maleta.clear(); clearConfirmOpen.value = false }
</script>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s ease; }
.fade-enter-from, .fade-leave-to       { opacity: 0; }
.slide-enter-active, .slide-leave-active { transition: transform 0.25s ease; }
.slide-enter-from, .slide-leave-to       { transform: translateX(100%); }
</style>
