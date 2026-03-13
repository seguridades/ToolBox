-- ============================================================
-- Toolbox de seguridades.org — Schema v0.2
-- Ejecutar en: Supabase > SQL Editor
-- ============================================================

-- -------------------------------------------------------
-- ENUMS
-- -------------------------------------------------------

create type resource_type as enum ('tool', 'guide', 'resource');
create type resource_scope as enum ('digital', 'física', 'otra', 'mixta');
create type resource_pricing as enum ('gratis', 'pago', 'freemium');
create type resource_platform as enum ('web', 'android', 'ios', 'windows', 'linux', 'mac');
create type feedback_type as enum ('reporte', 'comentario');
create type feedback_status as enum ('pendiente', 'resuelto');
create type resource_category as enum (
  'Comunicación Segura',
  'Gestión de Contraseñas',
  'Anonimato y Navegación',
  'Cifrado de Archivos y Dispositivos',
  'Autenticación',
  'Cobertura en Campo',
  'Protocolos de Viaje',
  'Autocuidado',
  'Redes de Apoyo',
  'Legislación y Derechos',
  'Formación y Metodología',
  'Otros'
);

-- -------------------------------------------------------
-- TABLA: resources
-- -------------------------------------------------------

create table resources (
  id             uuid primary key default gen_random_uuid(),
  title          text not null,
  description    text,
  verdict        text,
  type           resource_type not null,
  scope          resource_scope[] not null default '{}',
  category       resource_category not null,
  tags           text[] not null default '{}',
  platforms      resource_platform[],          -- nullable, solo relevante si type = 'tool'
  is_opensource  boolean not null default false,
  pricing        resource_pricing not null default 'gratis',
  is_reviewed    boolean not null default false,
  show_review    boolean not null default false,
  has_audit      boolean not null default false,
  show_audit     boolean not null default false,
  official_url   text,
  repo_url       text,
  author_id      uuid references auth.users(id) on delete set null,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

-- Actualiza updated_at automáticamente
create or replace function update_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger resources_updated_at
  before update on resources
  for each row execute function update_updated_at();

-- -------------------------------------------------------
-- TABLA: tool_manuals
-- -------------------------------------------------------

create table tool_manuals (
  id          uuid primary key default gen_random_uuid(),
  tool_id     uuid not null references resources(id) on delete cascade,
  title       text not null,
  url         text not null,
  source      text,
  created_at  timestamptz not null default now()
);

-- -------------------------------------------------------
-- TABLA: resource_feedback
-- -------------------------------------------------------

create table resource_feedback (
  id              uuid primary key default gen_random_uuid(),
  resource_id     uuid not null references resources(id) on delete cascade,
  type            feedback_type not null,
  message         text not null,
  alias           text,
  email           text,
  contact_consent boolean not null default false,
  status          feedback_status not null default 'pendiente',
  created_at      timestamptz not null default now()
);

-- -------------------------------------------------------
-- ROW LEVEL SECURITY
-- -------------------------------------------------------

alter table resources        enable row level security;
alter table tool_manuals     enable row level security;
alter table resource_feedback enable row level security;

-- resources: lectura pública
create policy "resources_public_read"
  on resources for select
  using (true);

-- resources: escritura solo para editor y admin
create policy "resources_editor_insert"
  on resources for insert
  with check (auth.jwt() ->> 'role' in ('editor', 'admin'));

create policy "resources_editor_update"
  on resources for update
  using (auth.jwt() ->> 'role' in ('editor', 'admin'));

create policy "resources_admin_delete"
  on resources for delete
  using (auth.jwt() ->> 'role' = 'admin');

-- tool_manuals: lectura pública
create policy "manuals_public_read"
  on tool_manuals for select
  using (true);

-- tool_manuals: escritura para editor y admin
create policy "manuals_editor_write"
  on tool_manuals for insert
  with check (auth.jwt() ->> 'role' in ('editor', 'admin'));

create policy "manuals_editor_update"
  on tool_manuals for update
  using (auth.jwt() ->> 'role' in ('editor', 'admin'));

create policy "manuals_admin_delete"
  on tool_manuals for delete
  using (auth.jwt() ->> 'role' = 'admin');

-- resource_feedback: inserción pública (sin login)
create policy "feedback_public_insert"
  on resource_feedback for insert
  with check (true);

-- resource_feedback: solo admin puede leer y gestionar
create policy "feedback_admin_read"
  on resource_feedback for select
  using (auth.jwt() ->> 'role' = 'admin');

create policy "feedback_admin_update"
  on resource_feedback for update
  using (auth.jwt() ->> 'role' = 'admin');

-- -------------------------------------------------------
-- ÍNDICES
-- -------------------------------------------------------

create index resources_type_idx      on resources(type);
create index resources_category_idx  on resources(category);
create index resources_pricing_idx   on resources(pricing);
create index resources_scope_idx     on resources using gin(scope);
create index resources_tags_idx      on resources using gin(tags);
create index resources_platforms_idx on resources using gin(platforms);
create index feedback_resource_idx   on resource_feedback(resource_id);
create index feedback_status_idx     on resource_feedback(status);
