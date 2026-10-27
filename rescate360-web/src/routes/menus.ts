import {
  LayoutDashboard,
  FileWarning,
  LifeBuoy,
  Map as MapaIcono,
  Bell,
  Building2,
  TriangleAlert,
  HeartHandshake,
  Search,
  Users,
  ClipboardList,
  Network,
  type LucideIcon,
} from 'lucide-react'

export interface ItemMenu {
  ruta: string
  etiqueta: string
  icono: LucideIcon
  fin?: boolean
}

export const menuAdmin: ItemMenu[] = [
  { ruta: '/admin', etiqueta: 'Inicio', icono: LayoutDashboard, fin: true },
  { ruta: '/admin/reportes', etiqueta: 'Reportes', icono: FileWarning },
  { ruta: '/admin/solicitudes', etiqueta: 'Solicitudes de ayuda', icono: LifeBuoy },
  { ruta: '/admin/mapa', etiqueta: 'Mapa operativo', icono: MapaIcono },
  { ruta: '/admin/alertas', etiqueta: 'Alertas', icono: Bell },
  { ruta: '/admin/centros', etiqueta: 'Centros de ayuda', icono: Building2 },
  { ruta: '/admin/zonas', etiqueta: 'Zonas peligrosas', icono: TriangleAlert },
  { ruta: '/admin/donaciones', etiqueta: 'Donaciones', icono: HeartHandshake },
  { ruta: '/admin/desaparecidos', etiqueta: 'Personas desaparecidas', icono: Search },
  { ruta: '/admin/usuarios', etiqueta: 'Usuarios', icono: Users },
  { ruta: '/admin/auditoria', etiqueta: 'Auditoría', icono: ClipboardList },
]

// Super admin: el mismo panel, con alcance global. Reutiliza las páginas del administrador
// (el backend le devuelve todo) y suma Organizaciones.
export const menuSuperAdmin: ItemMenu[] = [
  { ruta: '/superadmin', etiqueta: 'Inicio', icono: LayoutDashboard, fin: true },
  { ruta: '/superadmin/organizaciones', etiqueta: 'Organizaciones', icono: Network },
  { ruta: '/superadmin/usuarios', etiqueta: 'Usuarios', icono: Users },
  { ruta: '/superadmin/solicitudes', etiqueta: 'Solicitudes de ayuda', icono: LifeBuoy },
  { ruta: '/superadmin/reportes', etiqueta: 'Reportes', icono: FileWarning },
  { ruta: '/superadmin/mapa', etiqueta: 'Mapa operativo', icono: MapaIcono },
]
