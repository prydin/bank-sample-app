/** @type {import('tailwindcss').Config} */
export default {
    content: ['./index.html', './src/**/*.{ts,tsx}'],
    theme: {
        extend: {
            colors: {
                brand: {
                    50:  '#eef2f8',
                    100: '#d6dfee',
                    200: '#aebfde',
                    300: '#7e98c8',
                    400: '#4f72b0',
                    500: '#2f5594',
                    600: '#1f4179',
                    700: '#173360',
                    800: '#0f2447',
                    900: '#0a1a35',
                },
            },
            fontFamily: {
                sans: ['Inter', 'ui-sans-serif', 'system-ui', 'sans-serif'],
            },
            boxShadow: {
                card: '0 1px 2px rgba(15, 36, 71, 0.04), 0 4px 12px rgba(15, 36, 71, 0.06)',
            },
        },
    },
    plugins: [],
};
