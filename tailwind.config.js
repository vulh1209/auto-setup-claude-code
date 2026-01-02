/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        claude: {
          50: "#fdf8f6",
          100: "#f9ede7",
          200: "#f4d9ce",
          300: "#ebbfac",
          400: "#df9c82",
          500: "#d4826a",
          600: "#c4684f",
          700: "#a45241",
          800: "#874638",
          900: "#6d3b30",
          950: "#3d2520",
        },
      },
    },
  },
  plugins: [],
};
