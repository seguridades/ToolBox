-- ============================================================
-- Asignación de roles — seguridades.org
-- ============================================================
-- Los roles se guardan en app_metadata del usuario en Supabase Auth.
-- Ejecutar como admin en: Supabase > SQL Editor
--
-- ROLES disponibles: 'editor' | 'admin'
-- ============================================================

-- Asignar rol EDITOR a un usuario (reemplazar el UUID)
update auth.users
set raw_app_meta_data = raw_app_meta_data || '{"role": "editor"}'
where id = 'UUID-DEL-USUARIO';

-- Asignar rol ADMIN a un usuario (reemplazar el UUID)
update auth.users
set raw_app_meta_data = raw_app_meta_data || '{"role": "admin"}'
where id = 'UUID-DEL-USUARIO';

-- Ver todos los usuarios con su rol actual
select id, email, raw_app_meta_data->>'role' as role, created_at
from auth.users
order by created_at desc;

-- Revocar rol (volver a usuario sin permisos especiales)
update auth.users
set raw_app_meta_data = raw_app_meta_data - 'role'
where id = 'UUID-DEL-USUARIO';

-- ============================================================
-- IMPORTANTE: después de cambiar el rol, el usuario debe
-- cerrar sesión y volver a iniciarla para que el JWT
-- refleje el nuevo rol. O forzar refresh del token:
--
--   await supabase.auth.refreshSession()
--
-- ============================================================
