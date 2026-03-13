<template>
  <Teleport to="body">
    <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4">
      <div class="bg-white rounded-2xl shadow-xl w-full max-w-sm p-6 space-y-4">
        <p class="text-sm text-text-main leading-relaxed">{{ message }}</p>
        <div class="flex gap-3 justify-end">
          <button class="px-4 py-2 rounded-xl border border-gray-200 text-sm text-text-meta hover:border-gray-300" @click="$emit('cancel')">
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
defineProps({ message: { type: String, required: true } })
defineEmits(['confirm', 'cancel'])
</script>
