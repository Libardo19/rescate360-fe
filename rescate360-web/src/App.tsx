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
import MapaPage from './pages/admin/MapaPage'
import AlertasPage from './pages/admin/AlertasPage'
import CentrosPage from './pages/admin/CentrosPage'
import ZonasPage from './pages/admin/ZonasPage'
import DonacionesPage from './pages/admin/DonacionesPage'

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
            <Route path="mapa" element={<MapaPage />} />
            <Route path="alertas" element={<AlertasPage />} />
            <Route path="centros" element={<CentrosPage />} />
            <Route path="zonas" element={<ZonasPage />} />
            <Route path="donaciones" element={<DonacionesPage />} />
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