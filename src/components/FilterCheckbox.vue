<template>
  <label class="flex items-center gap-2 cursor-pointer group">
    <input
      type="checkbox"
      :checked="modelValue.includes(value)"
      class="w-3.5 h-3.5 rounded accent-primary shrink-0"
      @change="toggle"
    />
    <span class="text-text-main group-hover:text-primary transition-colors leading-none">
      {{ label }}
    </span>
  </label>
</template>

<script setup>
const props = defineProps({
  modelValue: { type: Array, required: true },
  value:      { type: String, required: true },
  label:      { type: String, required: true },
})

const emit = defineEmits(['update:modelValue'])

function toggle() {
  const next = props.modelValue.includes(props.value)
    ? props.modelValue.filter((v) => v !== props.value)
    : [...props.modelValue, props.value]
  emit('update:modelValue', next)
}
</script>
