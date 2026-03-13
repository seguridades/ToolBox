# DOCUMENTO DE ESPECIFICACIONES TÉCNICAS

# Toolbox de seguridades.org

> Versión 0.2 — En definición  
> Proyecto interno seguridades.org

---

## 1. RESUMEN DEL PROYECTO

**Toolbox de seguridades.org** es una plataforma de curaduría de recursos de seguridad (Digital, Física, Otra y Mixta). Permite mapear herramientas, manuales y recursos, ofreciendo validación interna y generación de listas personalizadas ("Maleta de Taller") para talleres y acompañamientos.

---

## 2. STACK TECNOLÓGICO

| Capa          | Tecnología                                  |
| ------------- | ------------------------------------------- |
| Frontend      | Vue.js 3 (Composition API) + Vite           |
| Backend       | Supabase (Auth, PostgreSQL, Edge Functions) |
| Estilos       | Tailwind CSS                                |
| Estado Global | Pinia (persistencia de Maleta de Taller)    |
| Iconografía   | Lucide Vue Next                             |
| Hosting       | Vercel                                      |

---

## 3. DISEÑO Y UI

**Referencia visual:** estilo limpio, tarjetas con espacio generoso, ilustraciones, tipografía bold para títulos, fondo blanco.

### Paleta de Colores

| Token        | Valor                 | Uso                     |
| ------------ | --------------------- | ----------------------- |
| Primary      | `#5D3FD3`             | Botones, badges, acento |
| Background   | `#FFFFFF` / `#F9FAFB` | Fondos                  |
| Text primary | `#1F2937`             | Cuerpo de texto         |
| Text meta    | `#6B7280`             | Metadatos, subtítulos   |

### Estándares de UI

- `rounded-2xl` (16px) para tarjetas y botones
- `shadow-sm` base → `shadow-md` en hover
- Contenedor máximo `max-w-7xl` con paddings laterales responsivos

---

## 4. ARQUITECTURA DE DATOS (SUPABASE)

### 4.1. Tabla: `resources`

| Campo           | Tipo         | Notas                                                                               |
| --------------- | ------------ | ----------------------------------------------------------------------------------- |
| `id`            | UUID         | Primary Key                                                                         |
| `title`         | String       | Nombre del recurso                                                                  |
| `description`   | Text         | Resumen ejecutivo                                                                   |
| `verdict`       | Text         | Recomendación editorial de seguridades.org                                          |
| `type`          | Enum         | `tool \| guide \| resource`                                                         |
| `scope`         | Array        | `digital \| física \| otra \| mixta` (múltiple)                                     |
| `category`      | Enum         | Categoría unificada de navegación (ver sección 4.4)                                 |
| `tags`          | Array (text) | Etiquetas libres, múltiples (ej: `#Android`, `#SinInternet`)                        |
| `platforms`     | Array        | `web \| android \| ios \| windows \| linux \| mac` — nullable, solo aplica a `tool` |
| `is_opensource` | Boolean      | ¿Código abierto?                                                                    |
| `pricing`       | Enum         | `gratis \| pago \| freemium`                                                        |
| `is_reviewed`   | Boolean      | Sello "Revisada por seguridades.org"                                                |
| `show_review`   | Boolean      | Toggle: mostrar `is_reviewed` públicamente                                          |
| `has_audit`     | Boolean      | ¿Tiene auditoría externa reciente?                                                  |
| `show_audit`    | Boolean      | Toggle: mostrar `has_audit` públicamente                                            |
| `official_url`  | URL          | Web oficial del recurso (opcional)                                                  |
| `repo_url`      | URL          | Repositorio GitHub/GitLab (opcional)                                                |
| `author_id`     | UUID         | FK a `users` — solo uso interno, no se muestra públicamente                         |
| `created_at`    | Timestamp    | Fecha de carga                                                                      |
| `updated_at`    | Timestamp    | Última actualización                                                                |

> **Nota:** `platforms` se muestra en UI solo cuando `type = tool`. En los otros tipos el campo queda nullable y oculto.

> **Nota:** `is_reviewed` y `has_audit` no se muestran en la tarjeta pública si están en `false`. El toggle `show_*` permite ocultarlos incluso cuando son `true`.

---

### 4.2. Tabla: `tool_manuals`

Manuales de uso asociados a una herramienta específica (ej: guía de EFF para Signal).

| Campo        | Tipo      | Notas                                        |
| ------------ | --------- | -------------------------------------------- |
| `id`         | UUID      | Primary Key                                  |
| `tool_id`    | UUID      | FK a `resources` (type = tool)               |
| `title`      | String    | Nombre del manual                            |
| `url`        | URL       | Enlace al manual                             |
| `source`     | String    | Organización de origen (ej: EFF, Access Now) |
| `created_at` | Timestamp |                                              |

---

### 4.3. Tabla: `resource_feedback`

| Campo             | Tipo      | Notas                                      |
| ----------------- | --------- | ------------------------------------------ |
| `id`              | UUID      | Primary Key                                |
| `resource_id`     | UUID      | FK a `resources`                           |
| `type`            | Enum      | `reporte \| comentario`                    |
| `message`         | Text      | Contenido del feedback                     |
| `alias`           | String    | Opcional, no requiere cuenta               |
| `email`           | String    | Opcional, para seguimiento                 |
| `contact_consent` | Boolean   | ¿Autoriza ser contactado para seguimiento? |
| `status`          | Enum      | `pendiente \| resuelto`                    |
| `created_at`      | Timestamp |                                            |

---

### 4.4. Categorías (Enum unificado)

Lista unificada para los tres tipos de recursos. Una categoría por recurso.

> v0.2 — Lista inicial, sujeta a ampliación según necesidades del equipo.

1. Comunicación Segura
2. Gestión de Contraseñas
3. Anonimato y Navegación
4. Cifrado de Archivos y Dispositivos
5. Autenticación
6. Cobertura en Campo
7. Protocolos de Viaje
8. Autocuidado
9. Redes de Apoyo
10. Legislación y Derechos
11. Formación y Metodología
12. Otros

---

## 5. TIPOS DE RECURSOS

| Tipo       | Descripción                                                 | Ejemplo                                               |
| ---------- | ----------------------------------------------------------- | ----------------------------------------------------- |
| `tool`     | Software o hardware específico                              | Signal, KeePass, candado biométrico                   |
| `guide`    | Documento metodológico independiente de una herramienta     | Manual de cobertura de marchas de Art19               |
| `resource` | Otros recursos: enlaces, directorios, repositorios de leyes | Directorio de ayuda legal, repositorio de legislación |

---

## 6. ROLES Y SEGURIDAD (RLS)

| Rol         | Permisos                                                           |
| ----------- | ------------------------------------------------------------------ |
| **Público** | Ver y buscar recursos, enviar feedback (anónimo o con alias/email) |
| **Editor**  | Cargar y editar recursos, gestionar `tool_manuals`                 |
| **Admin**   | Todo lo anterior + aprobar cuentas de editores, gestionar feedback |

Acceso restringido vía Supabase Auth. Aprobación de cuentas de editores manual por admin.

---

## 7. FUNCIONALIDADES CLAVE

### 7.1. Sistema de Filtros Reactivos

Filtrado combinable por:

- Texto libre (título, descripción)
- Tipo (`tool | guide | resource`)
- Ámbito (`digital | física | otra | mixta`)
- Categoría
- Tags
- Plataforma (solo relevante para `tool`)
- Pricing (`gratis | pago | freemium`)
- `is_opensource`

Implementación mediante `computed properties` en Vue para respuesta instantánea sin recarga.

### 7.2. Maleta de Taller

Selección de recursos para exportar como lista de referencia para talleres.

- Persistencia en Pinia (estado global)
- Campos exportados: `title | official_url | repo_url | pricing | is_opensource | platforms`
- Formatos de exportación: PDF y Excel

### 7.3. Feedback Público

- Formulario flotante (`FeedbackModal.vue`) accesible desde cada tarjeta
- Sin requerir cuenta
- Campos opcionales: alias, email
- Estados: `pendiente | resuelto` (gestionado por admin)

---

## 8. ESTRUCTURA DE COMPONENTES (VUE)

| Componente          | Descripción                                                          |
| ------------------- | -------------------------------------------------------------------- |
| `ToolCard.vue`      | Tarjeta de recurso con badges de ámbito, tipo, pricing y plataformas |
| `FilterSidebar.vue` | Panel lateral con filtros reactivos por checkboxes                   |
| `FeedbackModal.vue` | Modal flotante para reportes y comentarios                           |
| `MaletaTaller.vue`  | Panel de selección y exportación de recursos                         |
| `TheFooter.vue`     | Footer con enlaces a páginas estáticas                               |

### 8.1. Estrategia de Iconografía

- **Lucide Vue Next** para UI funcional: botones, estados, acciones, metadatos.
- **3 ilustraciones flat** (estilo consistente con referencia visual) para identificar los tipos: `tool`, `guide`, `resource`.
- **Badges de color** por categoría para diferenciación visual rápida en tarjetas.

---

## 9. VISTAS DE RECURSO

### 9.1. Tarjeta Pública (Directorio)

| Campo           | Presentación                               |
| --------------- | ------------------------------------------ |
| `title`         | Título principal                           |
| `type`          | Badge (Herramienta / Guía / Recurso)       |
| `scope`         | Badge(s) (Digital / Física / Otra / Mixta) |
| `category`      | Texto                                      |
| `pricing`       | Badge (Gratis / Pago / Freemium)           |
| `is_opensource` | Badge solo si es `true`                    |
| `is_reviewed`   | Sello solo si `show_review = true`         |
| `platforms`     | Iconos pequeños, solo si `type = tool`     |
| `tags`          | Máximo 3 visibles, el resto oculto         |

### 9.2. Vista Detalle

Todo lo de la tarjeta más:

| Campo          | Presentación                                    |
| -------------- | ----------------------------------------------- |
| `description`  | Resumen ejecutivo                               |
| `verdict`      | Recomendación editorial de seguridades.org      |
| `has_audit`    | Solo si `show_audit = true`                     |
| `official_url` | Botón de acción                                 |
| `repo_url`     | Botón de acción, solo si existe                 |
| `tool_manuals` | Lista de manuales de uso, solo si `type = tool` |
| `tags`         | Todos                                           |
| `updated_at`   | "Última actualización"                          |
| Feedback       | Botón para abrir `FeedbackModal`                |

---

## 11. RUTAS (VUE ROUTER)

| Ruta           | Descripción                                               | Acceso         |
| -------------- | --------------------------------------------------------- | -------------- |
| `/`            | Directorio principal                                      | Público        |
| `/admin`       | Panel de control                                          | Admin / Editor |
| `/pages/:slug` | Páginas estáticas (Acerca de, Principios, Cómo colaborar) | Público        |

> Las páginas estáticas (`/pages/:slug`) se gestionan como archivos Markdown en el repositorio, no desde Supabase.

---

## 12. FLUJO DE APROBACIÓN DE EDITORES

Proceso manual, sin formulario ni automatización en v1:

1. El aspirante contacta a seguridades.org por email solicitando acceso como editor.
2. El admin crea la cuenta manualmente en Supabase y asigna el rol `editor`.
3. El admin notifica al nuevo editor por email.

> Migración a flujo automatizado (formulario + panel `/admin`) queda como mejora futura.

---

## 13. POLÍTICA DE MODERACIÓN DE FEEDBACK

### Formulario público

- Campos: `alias` (opcional), `email` (opcional), `mensaje`, `contact_consent` (checkbox)
- Texto del checkbox: _"Doy consentimiento para ser contactado para más información y seguimiento"_
- No requiere cuenta ni login

### Moderación

- Solo el **admin** gestiona el feedback desde `/admin`
- Los reportes resueltos se marcan como `resuelto` y permanecen en historial, no se eliminan
- Si `contact_consent = true` y el usuario dejó email, el admin puede contactarle para seguimiento
- Si `contact_consent = false` o no hay email, el feedback es de una sola vía sin respuesta

---

_Documento generado en proceso de definición con seguridades.org — no distribuir._
