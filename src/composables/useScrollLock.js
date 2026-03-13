import { onMounted, onUnmounted, watch } from 'vue'

// Para modales con v-if (se montan y desmontan)
export function useScrollLock() {
  onMounted(() => { document.body.style.overflow = 'hidden' })
  onUnmounted(() => { document.body.style.overflow = '' })
}

// Para drawers que siempre están montados y usan una prop `open`
export function useScrollLockProp(openRef) {
  watch(openRef, (val) => {
    document.body.style.overflow = val ? 'hidden' : ''
  })
  onUnmounted(() => { document.body.style.overflow = '' })
}
