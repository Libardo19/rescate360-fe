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
  grupo?: string // título del bloque en el menú "Más" y en la paleta de comandos
  descripcion?: string // texto corto que se muestra en el menú "Más" y en la paleta
  principal?: boolean // aparece directamente en la barra superior (y en el dock móvil)
  corta?: string // etiqueta corta para la barra superior
}

export const menuAdmin: ItemMenu[] = [
  { ruta: '/admin', etiqueta: 'Inicio', icono: LayoutDashboard, fin: true, grupo: 'General', principal: true, descripcion: 'Resumen operativo de tu organización' },
  { ruta: '/admin/reportes', etiqueta: 'Reportes', icono: FileWarning, grupo: 'Operación', principal: true, descripcion: 'Verifica, rechaza o marca duplicados' },
  { ruta: '/admin/solicitudes', etiqueta: 'Solicitudes de ayuda', corta: 'Solicitudes', icono: LifeBuoy, grupo: 'Operación', principal: true, descripcion: 'Prioriza y atiende pedidos de ayuda' },
  { ruta: '/admin/mapa', etiqueta: 'Mapa operativo', corta: 'Mapa', icono: MapaIcono, grupo: 'Operación', principal: true, descripcion: 'Todo lo que pasa, en un mapa' },
  { ruta: '/admin/alertas', etiqueta: 'Alertas', icono: Bell, grupo: 'Operación', principal: true, descripcion: 'Avisos oficiales para la comunidad' },
  { ruta: '/admin/centros', etiqueta: 'Centros de ayuda', icono: Building2, grupo: 'Recursos', descripcion: 'Albergues, comedores y puestos médicos' },
  { ruta: '/admin/zonas', etiqueta: 'Zonas peligrosas', icono: TriangleAlert, grupo: 'Recursos', descripcion: 'Áreas de riesgo dibujadas en el mapa' },
  { ruta: '/admin/donaciones', etiqueta: 'Donaciones', icono: HeartHandshake, grupo: 'Recursos', descripcion: 'Inventario de cada centro' },
  { ruta: '/admin/desaparecidos', etiqueta: 'Personas desaparecidas', icono: Search, grupo: 'Recursos', descripcion: 'Casos en búsqueda y encontrados' },
  { ruta: '/admin/usuarios', etiqueta: 'Usuarios', icono: Users, grupo: 'Administración', descripcion: 'Voluntarios y administradores' },
  { ruta: '/admin/auditoria', etiqueta: 'Auditoría', icono: ClipboardList, grupo: 'Administración', descripcion: 'Historial de cada cambio' },
]

// Super admin: el mismo panel, con alcance global. Reutiliza las páginas del administrador
// (el backend le devuelve todo) y suma Organizaciones.
export const menuSuperAdmin: ItemMenu[] = [
  { ruta: '/superadmin', etiqueta: 'Inicio', icono: LayoutDashboard, fin: true, grupo: 'General', principal: true, descripcion: 'Resumen global del sistema' },
  { ruta: '/superadmin/organizaciones', etiqueta: 'Organizaciones', icono: Network, grupo: 'Administración', principal: true, descripcion: 'Entidades y sus administradores' },
  { ruta: '/superadmin/usuarios', etiqueta: 'Usuarios', icono: Users, grupo: 'Administración', principal: true, descripcion: 'Todos los usuarios del sistema' },
  { ruta: '/superadmin/solicitudes', etiqueta: 'Solicitudes de ayuda', corta: 'Solicitudes', icono: LifeBuoy, grupo: 'Operación', principal: true, descripcion: 'Solicitudes de todas las organizaciones' },
  { ruta: '/superadmin/reportes', etiqueta: 'Reportes', icono: FileWarning, grupo: 'Operación', descripcion: 'Reportes de todas las organizaciones' },
  { ruta: '/superadmin/mapa', etiqueta: 'Mapa operativo', icono: MapaIcono, grupo: 'Operación', descripcion: 'Todo lo que pasa, en un mapa' },
]
