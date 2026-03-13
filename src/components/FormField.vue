<template>
  <div class="space-y-1">
    <label class="text-xs font-medium text-text-meta uppercase tracking-wide">
      {{ label }}
      <span v-if="hint" class="normal-case font-normal ml-1">{{ hint }}</span>
    </label>
    <slot />
  </div>
</template>

<script setup>
defineProps({
  label: { type: String, required: true },
  hint:  { type: String, default: null },
})
</script>
