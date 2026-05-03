import { Globe, Smartphone, Monitor, Terminal, Laptop } from 'lucide-vue-next'

const TYPE_BADGE_BASE    = 'text-xs font-semibold px-2 py-0.5 rounded-full'
const PRICING_BADGE_BASE = 'text-xs font-medium px-2 py-0.5 rounded-full'

export function getTypeBadgeClass(type) {
  return {
    tool:     `${TYPE_BADGE_BASE} bg-violet-100 dark:bg-violet-900/40 text-violet-700 dark:text-violet-300`,
    guide:    `${TYPE_BADGE_BASE} bg-sky-100 dark:bg-sky-900/40 text-sky-700 dark:text-sky-300`,
    resource: `${TYPE_BADGE_BASE} bg-amber-100 dark:bg-amber-900/40 text-amber-700 dark:text-amber-300`,
  }[type] ?? TYPE_BADGE_BASE
}

export function getPricingBadgeClass(pricing) {
  return {
    gratis:   `${PRICING_BADGE_BASE} bg-green-50 dark:bg-green-900/30 text-green-700 dark:text-green-400`,
    pago:     `${PRICING_BADGE_BASE} bg-red-50 dark:bg-red-900/30 text-red-600 dark:text-red-400`,
    freemium: `${PRICING_BADGE_BASE} bg-yellow-50 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400`,
  }[pricing] ?? PRICING_BADGE_BASE
}

export function getPlatformIcon(platform) {
  return { web: Globe, android: Smartphone, ios: Smartphone, windows: Monitor, linux: Terminal, mac: Laptop }[platform] ?? Globe
}

export function formatDate(ts, monthFormat = 'long') {
  if (!ts) return '—'
  return new Intl.DateTimeFormat('es', { day: 'numeric', month: monthFormat, year: 'numeric' }).format(new Date(ts))
}
