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
  grupo?: string // título del bloque en el menú lateral
}

export const menuAdmin: ItemMenu[] = [
  { ruta: '/admin', etiqueta: 'Inicio', icono: LayoutDashboard, fin: true, grupo: 'General' },
  { ruta: '/admin/reportes', etiqueta: 'Reportes', icono: FileWarning, grupo: 'Operación' },
  { ruta: '/admin/solicitudes', etiqueta: 'Solicitudes de ayuda', icono: LifeBuoy, grupo: 'Operación' },
  { ruta: '/admin/mapa', etiqueta: 'Mapa operativo', icono: MapaIcono, grupo: 'Operación' },
  { ruta: '/admin/alertas', etiqueta: 'Alertas', icono: Bell, grupo: 'Operación' },
  { ruta: '/admin/centros', etiqueta: 'Centros de ayuda', icono: Building2, grupo: 'Recursos' },
  { ruta: '/admin/zonas', etiqueta: 'Zonas peligrosas', icono: TriangleAlert, grupo: 'Recursos' },
  { ruta: '/admin/donaciones', etiqueta: 'Donaciones', icono: HeartHandshake, grupo: 'Recursos' },
  { ruta: '/admin/desaparecidos', etiqueta: 'Personas desaparecidas', icono: Search, grupo: 'Recursos' },
  { ruta: '/admin/usuarios', etiqueta: 'Usuarios', icono: Users, grupo: 'Administración' },
  { ruta: '/admin/auditoria', etiqueta: 'Auditoría', icono: ClipboardList, grupo: 'Administración' },
]
