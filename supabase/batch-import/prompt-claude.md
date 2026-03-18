# Prompt para completar herramientas con Claude

Usá este prompt cuando tengas el CSV con los campos básicos rellenos y quieras que Claude genere `description`, `verdict`, `tags` y `category`.

---

## Prompt

```
Sos un editor del directorio ToolBox de seguridades.org, una plataforma orientada a trainers de seguridad para periodistas, activistas y defensoras de derechos humanos en América Latina.

Para cada herramienta en el CSV adjunto, completá los siguientes campos:

- **description**: Qué hace la herramienta. 2-3 oraciones, técnicamente preciso pero accesible. Sin juicios de valor.
- **verdict**: Evaluación editorial desde la perspectiva de seguridad digital para periodistas y activistas. 2-4 oraciones. Puede incluir advertencias, casos de uso recomendados y comparación con alternativas.
- **tags**: Array de 3-6 palabras clave en español (CamelCase, sin espacios). Ejemplos: CifradoE2E, CódigoAbierto, Android, Periodismo, VPN, Anonimato.
- **category**: Una sola categoría de esta lista exacta:
  - Comunicación Segura
  - Gestión de Contraseñas
  - Anonimato y Navegación
  - Cifrado de Archivos y Dispositivos
  - Autenticación
  - Cobertura en Campo
  - Protocolos de Viaje
  - Autocuidado
  - Redes de Apoyo
  - Legislación y Derechos
  - Formación y Metodología
  - Otros

Devolvé el resultado como SQL INSERT listo para copiar en Supabase, con este formato exacto por cada herramienta:

(
  'TITLE',
  'DESCRIPTION',
  'VERDICT',
  'TYPE',
  array['SCOPE']::resource_scope[],
  'CATEGORY',
  array['TAG1', 'TAG2', 'TAG3'],
  array['PLATFORM1', 'PLATFORM2']::resource_platform[],  -- omitir si no aplica (guides/resources)
  IS_OPENSOURCE,
  'PRICING',
  IS_REVIEWED, SHOW_REVIEW, HAS_AUDIT, SHOW_AUDIT,
  'OFFICIAL_URL',
  'REPO_URL'  -- usar null si no tiene
),

Herramientas a completar:
[PEGAR CSV AQUÍ]
```

---

## Valores válidos por campo

| Campo | Valores posibles |
|-------|-----------------|
| `type` | `tool` · `guide` · `resource` |
| `scope` | `digital` · `física` · `mixta` · `otra` |
| `platforms` | `web` · `android` · `ios` · `windows` · `linux` · `mac` |
| `pricing` | `gratis` · `pago` · `freemium` |
| `is_reviewed / show_review` | `true` · `false` — si no revisaste la herramienta, ambos en `false` |
| `has_audit / show_audit` | `true` · `false` — solo `true` si hay auditoría de seguridad pública |

## Notas editoriales

- `is_reviewed true` + `show_review false` = revisada pero el veredicto no se muestra aún (borrador)
- `is_reviewed false` + `show_review false` = sin revisar (default para imports nuevos)
- Las guías y recursos no necesitan `platforms`; en ese caso usar `null`
- `repo_url` es null si la herramienta no es open source o no tiene repo público
