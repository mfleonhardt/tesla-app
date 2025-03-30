import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react-swc'
import tailwindcss from '@tailwindcss/vite'
import path from 'path'
import dotenv from 'dotenv'

dotenv.config({ path: '.env.local' });

const defaultCertPath = path.resolve(__dirname, '../certs');
const host = process.env.VITE_DEV_HOST || 'localhost';
const keyPath = process.env.VITE_KEY_PATH || path.resolve(defaultCertPath, 'app-key.pem')
const certPath = process.env.VITE_CERT_PATH || path.resolve(defaultCertPath, 'app-cert.pem')


// https://vite.dev/config/
export default defineConfig({
  plugins: [
    react(),
    tailwindcss(),
  ],
  server: {
    host,
    port: 3000,
    https: {
      key: keyPath,
      cert: certPath,
  },
  },
});

