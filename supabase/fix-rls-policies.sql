-- Fix: auth.jwt() ->> 'role' devuelve 'authenticated', no el rol custom.
-- El rol custom está en app_metadata. Hay que usar: auth.jwt() -> 'app_metadata' ->> 'role'

-- resources
drop policy if exists "resources_editor_insert" on resources;
drop policy if exists "resources_editor_update" on resources;
drop policy if exists "resources_admin_delete"  on resources;

create policy "resources_editor_insert"
  on resources for insert
  with check ((auth.jwt() -> 'app_metadata' ->> 'role') in ('editor', 'admin'));

create policy "resources_editor_update"
  on resources for update
  using ((auth.jwt() -> 'app_metadata' ->> 'role') in ('editor', 'admin'));

create policy "resources_admin_delete"
  on resources for delete
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- tool_manuals
drop policy if exists "manuals_editor_write"  on tool_manuals;
drop policy if exists "manuals_editor_update" on tool_manuals;
drop policy if exists "manuals_admin_delete"  on tool_manuals;

create policy "manuals_editor_write"
  on tool_manuals for insert
  with check ((auth.jwt() -> 'app_metadata' ->> 'role') in ('editor', 'admin'));

create policy "manuals_editor_update"
  on tool_manuals for update
  using ((auth.jwt() -> 'app_metadata' ->> 'role') in ('editor', 'admin'));

create policy "manuals_admin_delete"
  on tool_manuals for delete
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- resource_feedback
drop policy if exists "feedback_admin_read"   on resource_feedback;
drop policy if exists "feedback_admin_update" on resource_feedback;

create policy "feedback_admin_read"
  on resource_feedback for select
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "feedback_admin_update"
  on resource_feedback for update
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
