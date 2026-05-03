# ToolBox — seguridades.org

Directorio curado de herramientas, guías y recursos de seguridad digital y física, desarrollado por [seguridades.org](https://seguridades.org).

**→ [toolbox.seguridades.org](https://toolbox.seguridades.org/)**

## Qué es

ToolBox es un directorio público y de acceso libre para explorar, filtrar y compartir recursos de seguridad. Permite armar un kit personalizado y exportarlo en PDF o CSV.

Los recursos están organizados por tipo (herramienta, guía, recurso), ámbito (digital, física, integral), categoría, plataforma y precio.

## Stack

- [Vue 3](https://vuejs.org/) + [Vite](https://vitejs.dev/)
- [Pinia](https://pinia.vuejs.org/) — estado global
- [Supabase](https://supabase.com/) — base de datos y autenticación
- [Tailwind CSS](https://tailwindcss.com/) — estilos

## Desarrollo local

**Requisitos:** Node.js 18+

```bash
# 1. Clonar el repositorio
git clone https://github.com/PhiRequiem/ToolBox.git
cd ToolBox

# 2. Instalar dependencias
npm install

# 3. Configurar variables de entorno
cp .env.example .env.local
# Completar VITE_SUPABASE_URL y VITE_SUPABASE_ANON_KEY
# (Supabase → Project Settings → API)

# 4. Iniciar servidor de desarrollo
npm run dev
```

## Colaborar

Para sugerir un recurso, reportar un problema o consultar cómo sumarte como editor/a, visitá la página [Cómo colaborar](https://toolbox.seguridades.org/pages/como-colaborar) en el sitio.

Los recursos enviados son evaluados editorialmente antes de publicarse.

## Licencia

[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) — seguridades.org
