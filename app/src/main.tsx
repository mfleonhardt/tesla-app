import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter, Routes, Route } from 'react-router-dom'

import { AuthProvider, useAuth } from './contexts/AuthContext.tsx'
import App from './pages/App.tsx'
import { userAuthorizationUrl } from './lib/TeslaAuth.ts'
import './styles/index.css'

const AppRoutes = () => {
  const { isAuthenticated, loading } = useAuth();

  if (loading) {
    return <div>Loading...</div>;
  }

  // Redirect to Tesla auth if not authenticated
  if (!isAuthenticated) {
    window.location.href = userAuthorizationUrl(window.location.href);
    return null;
  }

  return (
    <Routes>
      <Route path="/" element={<App />} />
    </Routes>
  );
};

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <AuthProvider>
      <BrowserRouter>
        <AppRoutes />
      </BrowserRouter>
    </AuthProvider>
  </StrictMode>,
)
