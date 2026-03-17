<template>
  <footer class="border-t border-gray-200 dark:border-gray-800 mt-auto py-8">
    <div class="max-w-container mx-auto px-4 sm:px-6 lg:px-8 flex flex-col sm:flex-row justify-between gap-4 text-sm text-text-meta dark:text-gray-400">
      <a href="https://creativecommons.org/licenses/by-sa/4.0/" target="_blank" rel="noopener" class="hover:text-text-main dark:hover:text-gray-100 transition-colors">
        seguridades.org | CC BY-SA 4.0
      </a>
      <nav class="flex gap-6">
        <RouterLink :to="{ name: 'static-page', params: { slug: 'acerca-de' } }" class="hover:text-text-main dark:hover:text-gray-100 transition-colors">Acerca de</RouterLink>
        <RouterLink :to="{ name: 'static-page', params: { slug: 'principios' } }" class="hover:text-text-main dark:hover:text-gray-100 transition-colors">Principios</RouterLink>
        <RouterLink :to="{ name: 'static-page', params: { slug: 'como-colaborar' } }" class="hover:text-text-main dark:hover:text-gray-100 transition-colors">Cómo colaborar</RouterLink>
      </nav>
    </div>
  </footer>
</template>
