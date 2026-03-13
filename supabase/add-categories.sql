-- ============================================================
-- Migración: categorías dinámicas
-- Ejecutar en: Supabase > SQL Editor
-- ============================================================

-- 1. Cambiar resources.category de enum a text
ALTER TABLE resources ALTER COLUMN category TYPE text USING category::text;

-- 2. Tabla categories
CREATE TABLE categories (
  id         uuid primary key default gen_random_uuid(),
  name       text not null unique,
  is_default boolean not null default false,
  created_at timestamptz not null default now()
);

-- 3. RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "categories_public_read"
  ON categories FOR SELECT USING (true);

CREATE POLICY "categories_editor_insert"
  ON categories FOR INSERT
  WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') IN ('editor', 'admin'));

CREATE POLICY "categories_admin_update"
  ON categories FOR UPDATE
  USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

CREATE POLICY "categories_admin_delete"
  ON categories FOR DELETE
  USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- 4. Insertar categorías por defecto
INSERT INTO categories (name, is_default) VALUES
  ('Comunicación Segura',              true),
  ('Gestión de Contraseñas',           true),
  ('Anonimato y Navegación',           true),
  ('Cifrado de Archivos y Dispositivos', true),
  ('Autenticación',                    true),
  ('Cobertura en Campo',               true),
  ('Protocolos de Viaje',              true),
  ('Autocuidado',                      true),
  ('Redes de Apoyo',                   true),
  ('Legislación y Derechos',           true),
  ('Formación y Metodología',          true);
