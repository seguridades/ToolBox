# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
npm run dev       # Start Vite dev server
npm run build     # Production build
npm run preview   # Preview built output locally
```

No test framework is configured.

**Environment**: Copy `.env.example` to `.env.local` and set `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` from the Supabase project settings.

## Architecture

Vue 3 + Vite SPA backed by Supabase (PostgreSQL + Auth). Deployed on Vercel with SPA history rewrites (`vercel.json`).

**Routing** (`src/router/`): Five main routes — `/directorio` (catalog), `/directorio/:id` (detail), `/admin` (requires auth + editor/admin role), `/reset-password`, and `/pages/:slug` (markdown static pages from `src/pages/`). Auth guard redirects unauthorized users to `/directorio`.

**State** (`src/stores/`): Four Pinia stores:
- `auth.js` — Supabase session, role check (`admin`/`editor`/null), persisted auth state
- `resources.js` — Full resource catalog + all reactive filters (search, type, scope, category, tags, platform, pricing, opensource). Filtering is a single computed property over the full dataset.
- `maleta.js` — User's curated "kit" (like a cart); persisted to localStorage via `pinia-plugin-persistedstate`
- `categories.js` — Category CRUD

**Data model**: Supabase tables `resources` and `categories`. Resources have: `title`, `type` (tool/guide/resource), `scope` (digital/física/otra/integral), `category`, `pricing` (gratis/freemium/pago), `platforms` (array), `is_opensource`, `is_reviewed`.

**Composables** (`src/composables/`): `useTheme` (class-based dark/light, localStorage), `useToast`, `useExport` (PDF via jsPDF, CSV — both lazy-imported), `useScrollLock`, `useMeta`.

**UI conventions**:
- All copy is in Spanish.
- Tailwind CSS with a custom primary color (`#5D3FD3`). Badge colors are semantic: violet/sky/amber for resource types; green/yellow/red for pricing tiers.
- Modals, the maleta drawer, and filter drawers use Vue `<Teleport to="body">`.
- Desktop: sidebar filter panel. Mobile: drawer filter UI (same filters, different layout).
- Constants for labels and enums live in `src/constants/` — update these when adding new types/scopes/platforms.
