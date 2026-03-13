<template>
  <label
    class="flex items-center gap-2 cursor-pointer select-none"
    :class="disabled ? 'opacity-40 cursor-not-allowed' : ''"
  >
    <input
      type="checkbox"
      :checked="modelValue"
      :disabled="disabled"
      class="w-3.5 h-3.5 rounded accent-primary"
      @change="(e) => emit('update:modelValue', e.target.checked)"
    />
    <span class="text-sm text-text-main">{{ label }}</span>
  </label>
</template>

<script setup>
defineProps({
  modelValue: { type: Boolean, required: true },
  label:      { type: String,  required: true },
  disabled:   { type: Boolean, default: false },
})
const emit = defineEmits(['update:modelValue'])
</script>
