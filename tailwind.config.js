/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      fontFamily: {
        mono: ["IBM Plex Mono", "JetBrains Mono", "monospace"],
      },
      colors: {
        // Claude Orange - primary color hsl(28 85% 55%)
        claude: {
          50: "#fff7ed",
          100: "#ffedd5",
          200: "#fed7aa",
          300: "#fdba74",
          400: "#fb923c",
          500: "#e87c2e", // hsl(28 85% 55%) ~ #e87c2e
          600: "#d86b1c",
          700: "#c2410c",
          800: "#9a3412",
          900: "#7c2d12",
          950: "#431407",
        },
        // Deep charcoal background hsl(20 8% 6%)
        charcoal: {
          950: "#0f0d0c", // hsl(20 8% 6%)
          900: "#171412",
          800: "#201c19",
          700: "#2a2521",
          600: "#3d3632",
        },
        // Glass effect colors
        glass: {
          bg: "rgba(15, 13, 12, 0.8)",
          border: "rgba(255, 255, 255, 0.08)",
          hover: "rgba(255, 255, 255, 0.12)",
        },
      },
      backdropBlur: {
        xs: "2px",
      },
    },
  },
  plugins: [],
};
