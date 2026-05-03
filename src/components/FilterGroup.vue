<template>
  <div class="space-y-2">
    <div class="flex items-baseline gap-1.5">
      <p class="text-xs font-semibold uppercase tracking-wide text-text-meta dark:text-gray-500">{{ label }}</p>
      <span v-if="hint" class="text-[10px] text-text-meta dark:text-gray-600 normal-case font-normal">{{ hint }}</span>
    </div>
    <div class="space-y-1.5">
      <slot />
    </div>
  </div>
</template>

<script setup>
defineProps({
  label: { type: String, required: true },
  hint:  { type: String, default: null },
})
</script>
