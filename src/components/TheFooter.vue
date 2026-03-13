<template>
  <footer class="border-t border-gray-200 mt-auto py-8">
    <div class="max-w-container mx-auto px-4 sm:px-6 lg:px-8 flex flex-col sm:flex-row justify-between gap-4 text-sm text-text-meta">
      <span>© seguridades.org</span>
      <nav class="flex gap-6">
        <RouterLink :to="{ name: 'static-page', params: { slug: 'acerca-de' } }">Acerca de</RouterLink>
        <RouterLink :to="{ name: 'static-page', params: { slug: 'principios' } }">Principios</RouterLink>
        <RouterLink :to="{ name: 'static-page', params: { slug: 'como-colaborar' } }">Cómo colaborar</RouterLink>
      </nav>
    </div>
  </footer>
</template>
