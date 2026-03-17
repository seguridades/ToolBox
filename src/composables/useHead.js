import { watchEffect, isRef, onUnmounted } from 'vue'

const SITE_NAME   = 'ToolBox — seguridades.org'
const DEFAULT_DESC = 'Directorio de recursos de seguridad digital, física e integral curado por seguridades.org.'

function setMeta(name, content) {
  let el = document.querySelector(`meta[name="${name}"]`)
  if (!el) { el = document.createElement('meta'); el.name = name; document.head.appendChild(el) }
  el.content = content
}

function setOg(prop, content) {
  let el = document.querySelector(`meta[property="${prop}"]`)
  if (!el) { el = document.createElement('meta'); el.setAttribute('property', prop); document.head.appendChild(el) }
  el.setAttribute('content', content)
}

export function useHead({ title, description } = {}) {
  watchEffect(() => {
    const t = isRef(title) ? title.value : title
    const d = isRef(description) ? description.value : description
    const fullTitle = t ? `${t} | ${SITE_NAME}` : SITE_NAME
    const desc      = d || DEFAULT_DESC

    document.title = fullTitle
    setMeta('description', desc)
    setOg('og:title', fullTitle)
    setOg('og:description', desc)
  })

  onUnmounted(() => {
    document.title = SITE_NAME
    setMeta('description', DEFAULT_DESC)
    setOg('og:title', SITE_NAME)
    setOg('og:description', DEFAULT_DESC)
  })
}
