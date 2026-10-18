import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { AuthProvider } from './context/AuthContext'
import ProtectedRoute from './routes/ProtectedRoute'
import { menuAdmin } from './routes/menus'
import PanelLayout from './layouts/PanelLayout'
import LandingPage from './pages/landing/LandingPage'
import LoginPage from './pages/login/LoginPage'
import AdminDashboard from './pages/admin/AdminDashboard'
import SuperAdminDashboard from './pages/superadmin/SuperAdminDashboard'
import PaginaEnConstruccion from './pages/shared/PaginaEnConstruccion'
import ReportesPage from './pages/admin/ReportesPage'
import SolicitudesPage from './pages/admin/SolicitudesPage'

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<LandingPage />} />
          <Route path="/login" element={<LoginPage />} />

          <Route
            path="/admin"
            element={
              <ProtectedRoute roles={['administrador']}>
                <PanelLayout menu={menuAdmin} titulo="Administrador" />
              </ProtectedRoute>
            }
          >
            <Route index element={<AdminDashboard />} />
            <Route path="reportes" element={<ReportesPage />} />
            <Route path="solicitudes" element={<SolicitudesPage />} />
            <Route path="mapa" element={<PaginaEnConstruccion titulo="Mapa operativo" />} />
            <Route path="alertas" element={<PaginaEnConstruccion titulo="Alertas" />} />
            <Route path="centros" element={<PaginaEnConstruccion titulo="Centros de ayuda" />} />
            <Route path="zonas" element={<PaginaEnConstruccion titulo="Zonas peligrosas" />} />
            <Route path="donaciones" element={<PaginaEnConstruccion titulo="Donaciones" />} />
            <Route path="desaparecidos" element={<PaginaEnConstruccion titulo="Personas desaparecidas" />} />
            <Route path="usuarios" element={<PaginaEnConstruccion titulo="Usuarios" />} />
            <Route path="auditoria" element={<PaginaEnConstruccion titulo="Auditoría" />} />
          </Route>

          <Route
            path="/superadmin"
            element={
              <ProtectedRoute roles={['super_admin']}>
                <SuperAdminDashboard />
              </ProtectedRoute>
            }
          />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  )
}