import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

// API and WebSocket calls go through the Vite dev server, so the login cookie stays same-origin.
const target = process.env.VITE_API_PROXY_TARGET ?? 'http://localhost:8000'

export default defineConfig({
  plugins: [react()],
  server: {
    // Localhost only, unless VITE_HOST is set (the Docker container sets 0.0.0.0).
    host: process.env.VITE_HOST ?? 'localhost',
    port: 5173,
    proxy: {
      '/api': { target, changeOrigin: true },
      '/ws': { target: target.replace(/^http/, 'ws'), ws: true },
    },
  },
})
