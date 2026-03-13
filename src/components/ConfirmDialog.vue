<template>
  <Teleport to="body">
    <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4">
      <div class="bg-white dark:bg-gray-900 rounded-2xl shadow-xl w-full max-w-sm p-6 space-y-4">
        <p class="text-sm text-text-main dark:text-gray-100 leading-relaxed">{{ message }}</p>
        <div class="flex gap-3 justify-end">
          <button class="px-4 py-2 rounded-xl border border-gray-200 dark:border-gray-700 text-sm text-text-meta dark:text-gray-400 hover:border-gray-300" @click="$emit('cancel')">
            Cancelar
          </button>
          <button class="px-4 py-2 rounded-xl bg-red-500 text-white text-sm font-semibold hover:bg-red-600 transition-colors" @click="$emit('confirm')">
            Eliminar
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { useScrollLock } from '../composables/useScrollLock'
defineProps({ message: { type: String, required: true } })
defineEmits(['confirm', 'cancel'])
useScrollLock()
</script>
