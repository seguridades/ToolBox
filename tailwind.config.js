/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './index.html',
    './src/**/*.{vue,js,ts}',
  ],
  theme: {
    extend: {
      colors: {
        primary: '#5D3FD3',
        'bg-soft': '#F9FAFB',
        'text-main': '#1F2937',
        'text-meta': '#6B7280',
      },
      maxWidth: {
        container: '80rem', // max-w-7xl equivalente
      },
      borderRadius: {
        card: '1rem', // rounded-2xl (16px)
      },
      boxShadow: {
        card: '0 1px 3px 0 rgb(0 0 0 / 0.1)',       // base
        'card-hover': '0 4px 6px -1px rgb(0 0 0 / 0.1)', // hover
      },
    },
  },
  plugins: [require('@tailwindcss/typography')],
}
