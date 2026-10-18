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
  type LucideIcon,
} from 'lucide-react'

export interface ItemMenu {
  ruta: string
  etiqueta: string
  icono: LucideIcon
  fin?: boolean
}

export const menuAdmin: ItemMenu[] = [
  { ruta: '/admin', etiqueta: 'Dashboard', icono: LayoutDashboard, fin: true },
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