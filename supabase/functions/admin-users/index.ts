import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const supabaseAdmin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  )

  // Verificar que el caller sea admin
  const token = req.headers.get('Authorization')?.replace('Bearer ', '')
  const { data: { user }, error: authErr } = await supabaseAdmin.auth.getUser(token)
  if (authErr || user?.app_metadata?.role !== 'admin') {
    return new Response(JSON.stringify({ error: 'No autorizado' }), {
      status: 403,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  const { action, userId, role } = await req.json()

  if (action === 'list') {
    const { data, error } = await supabaseAdmin.auth.admin.listUsers()
    if (error) return new Response(JSON.stringify({ error: error.message }), { status: 500, headers: corsHeaders })
    const users = data.users.map((u) => ({
      id:               u.id,
      email:            u.email,
      role:             u.app_metadata?.role ?? null,
      created_at:       u.created_at,
      last_sign_in_at:  u.last_sign_in_at,
    }))
    return new Response(JSON.stringify(users), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  if (action === 'setRole') {
    const { error } = await supabaseAdmin.auth.admin.updateUserById(userId, {
      app_metadata: { role: role || null },
    })
    if (error) return new Response(JSON.stringify({ error: error.message }), { status: 500, headers: corsHeaders })
    return new Response(JSON.stringify({ ok: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  return new Response(JSON.stringify({ error: 'Acción desconocida' }), {
    status: 400,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
})
