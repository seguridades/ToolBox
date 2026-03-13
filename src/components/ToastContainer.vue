<template>
  <Teleport to="body">
    <div class="fixed bottom-5 right-5 z-[100] flex flex-col gap-2 items-end">
      <TransitionGroup name="toast">
        <div
          v-for="t in toasts"
          :key="t.id"
          class="flex items-center gap-3 px-4 py-3 rounded-2xl shadow-lg text-sm font-medium max-w-xs"
          :class="{
            'bg-gray-900 text-white dark:bg-white dark:text-gray-900':          t.type === 'success',
            'bg-red-500 text-white':                                             t.type === 'error',
            'bg-amber-400 text-amber-900':                                       t.type === 'warning',
          }"
        >
          <CheckCircle v-if="t.type === 'success'" class="w-4 h-4 shrink-0" />
          <XCircle     v-else-if="t.type === 'error'"   class="w-4 h-4 shrink-0" />
          <span>{{ t.message }}</span>
          <button class="ml-1 opacity-60 hover:opacity-100" @click="remove(t.id)">
            <X class="w-3.5 h-3.5" />
          </button>
        </div>
      </TransitionGroup>
    </div>
  </Teleport>
</template>

<script setup>
import { CheckCircle, XCircle, X } from 'lucide-vue-next'
import { useToast } from '../composables/useToast'

const { toasts, remove } = useToast()
</script>

<style scoped>
.toast-enter-active { transition: all 0.25s ease; }
.toast-leave-active { transition: all 0.2s ease; }
.toast-enter-from   { opacity: 0; transform: translateX(1rem); }
.toast-leave-to     { opacity: 0; transform: translateX(1rem); }
</style>
