<template>
  <div class="space-y-2">
    <p class="text-xs font-semibold uppercase tracking-wide text-text-meta">{{ label }}</p>
    <div class="space-y-1.5">
      <slot />
    </div>
  </div>
</template>

<script setup>
defineProps({ label: { type: String, required: true } })
</script>
