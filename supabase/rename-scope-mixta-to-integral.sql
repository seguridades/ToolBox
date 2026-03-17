-- Renombrar valor del enum resource_scope: 'mixta' → 'integral'
-- Ejecutar en: Supabase > SQL Editor

ALTER TYPE resource_scope RENAME VALUE 'mixta' TO 'integral';
