/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        brand: {
          DEFAULT: '{{brand_color}}',
          dark:    '{{brand_dark}}',
        },
      },
    },
  },
  plugins: [],
}
