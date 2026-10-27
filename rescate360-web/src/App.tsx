import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { AuthProvider } from './context/AuthContext'
import ProtectedRoute from './routes/ProtectedRoute'
import { menuAdmin, menuSuperAdmin } from './routes/menus'
import PanelLayout from './layouts/PanelLayout'
import LandingPage from './pages/landing/LandingPage'
import LoginPage from './pages/login/LoginPage'
import AdminDashboard from './pages/admin/AdminDashboard'
import SuperAdminDashboard from './pages/superadmin/SuperAdminDashboard'
import OrganizacionesPage from './pages/superadmin/OrganizacionesPage'
import ReportesPage from './pages/admin/ReportesPage'
import SolicitudesPage from './pages/admin/SolicitudesPage'
import MapaPage from './pages/admin/MapaPage'
import AlertasPage from './pages/admin/AlertasPage'
import CentrosPage from './pages/admin/CentrosPage'
import ZonasPage from './pages/admin/ZonasPage'
import DonacionesPage from './pages/admin/DonacionesPage'
import DesaparecidosPage from './pages/admin/DesaparecidosPage'
import UsuariosPage from './pages/admin/UsuariosPage'
import AuditoriaPage from './pages/admin/AuditoriaPage'

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
            <Route path="desaparecidos" element={<DesaparecidosPage />} />
            <Route path="usuarios" element={<UsuariosPage />} />
            <Route path="auditoria" element={<AuditoriaPage />} />
          </Route>

          <Route
            path="/superadmin"
            element={
              <ProtectedRoute roles={['super_admin']}>
                <PanelLayout menu={menuSuperAdmin} titulo="Super admin" />
              </ProtectedRoute>
            }
          >
            <Route index element={<SuperAdminDashboard />} />
            <Route path="organizaciones" element={<OrganizacionesPage />} />
            <Route path="usuarios" element={<UsuariosPage />} />
            <Route path="solicitudes" element={<SolicitudesPage />} />
            <Route path="reportes" element={<ReportesPage />} />
            <Route path="mapa" element={<MapaPage />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  )
}