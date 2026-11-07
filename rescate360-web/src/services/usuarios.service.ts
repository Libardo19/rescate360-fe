import { api, USE_MOCK } from './api'
import type {
  DatosPerfilVoluntario,
  MiembroOrganizacion,
  UsuarioEncontrado,
} from '../types/usuarioAdmin'

// Datos de prueba, SOLO para desarrollo de la interfaz.
let miembros: MiembroOrganizacion[] = [
  { id: '1', nombre: 'Admin Demo', correo: 'admin@demo.com', telefono: '+57 300 000 0001', rol: 'administrador', creadoEn: '2026-09-01T08:00:00', perfil: null, asignacionesActivas: 0 },
  { id: '10', nombre: 'Camilo Arrieta', correo: 'camilo.arrieta@correo.com', telefono: '+57 301 234 5678', rol: 'voluntario', creadoEn: '2026-09-12T10:00:00', perfil: { disponibilidad: 'Fines de semana', certificaciones: 'Primeros auxilios (Cruz Roja)', activo: true }, asignacionesActivas: 2 },
  { id: '11', nombre: 'Valentina Gutiérrez', correo: 'vale.gutierrez@correo.com', telefono: '+57 302 345 6789', rol: 'voluntario', creadoEn: '2026-09-20T15:30:00', perfil: { disponibilidad: 'Noches', certificaciones: 'Rescate acuático', activo: true }, asignacionesActivas: 1 },
  { id: '12', nombre: 'Jorge Baquero', correo: 'jorge.baquero@correo.com', telefono: null, rol: 'voluntario', creadoEn: '2026-10-01T09:15:00', perfil: null, asignacionesActivas: 0 },
  { id: '13', nombre: 'Natalia Fuentes', correo: 'natalia.fuentes@correo.com', telefono: '+57 304 567 8901', rol: 'voluntario', creadoEn: '2026-09-05T11:45:00', perfil: { disponibilidad: 'Tiempo completo', certificaciones: null, activo: false }, asignacionesActivas: 0 },
  { id: '14', nombre: 'Ricardo Lozano', correo: 'ricardo.lozano@bomberos.gov.co', telefono: '+57 305 678 9012', rol: 'administrador', creadoEn: '2026-09-02T08:30:00', perfil: null, asignacionesActivas: 0 },
]

// Otros usuarios del sistema, para probar la búsqueda por correo.
const otrosUsuarios: UsuarioEncontrado[] = [
  { id: '3', nombre: 'Ciudadano Demo', correo: 'ciudadano@demo.com', rol: 'ciudadano' },
  { id: '20', nombre: 'Paola Rincón', correo: 'paola.rincon@correo.com', rol: 'ciudadano' },
  { id: '21', nombre: 'Hernán Cuello', correo: 'hernan.cuello@correo.com', rol: 'voluntario' }, // de otra organización
]

export async function listarMiembros(organizacionId: string): Promise<MiembroOrganizacion[]> {
  if (USE_MOCK) return miembros.map((m) => ({ ...m, perfil: m.perfil && { ...m.perfil } }))

  // BACKEND: confirmar la ruta real. Solo usuarios con organizacion_id = organizacionId.
  return api<MiembroOrganizacion[]>(`/organizaciones/${organizacionId}/usuarios`)
}

// Devuelve null si no existe ningún usuario con ese correo.
export async function buscarUsuarioPorCorreo(correo: string): Promise<UsuarioEncontrado | null> {
  const buscado = correo.trim().toLowerCase()
  if (USE_MOCK) {
    const miembro = miembros.find((m) => m.correo === buscado)
    if (miembro) return { id: miembro.id, nombre: miembro.nombre, correo: miembro.correo, rol: miembro.rol }
    return otrosUsuarios.find((u) => u.correo === buscado) ?? null
  }

  // BACKEND: endpoint de búsqueda por correo exacto (no exponer listados completos de ciudadanos).
  try {
    return await api<UsuarioEncontrado>(`/usuarios/buscar?correo=${encodeURIComponent(buscado)}`)
  } catch (e) {
    if (e instanceof Error && e.message.includes('404')) return null
    throw e
  }
}

// Flujo ciudadano → voluntario (sección 4 del modelo de BD). El backend valida que el usuario
// siga siendo 'ciudadano' y hace el UPDATE + el perfil en una transacción.
export async function asignarVoluntario(
  organizacionId: string,
  usuario: UsuarioEncontrado,
  perfil: DatosPerfilVoluntario | null,
): Promise<MiembroOrganizacion> {
  if (USE_MOCK) {
    if (usuario.rol !== 'ciudadano') throw new Error('El usuario ya no es ciudadano')
    const nuevo: MiembroOrganizacion = {
      id: usuario.id,
      nombre: usuario.nombre,
      correo: usuario.correo,
      telefono: null,
      rol: 'voluntario',
      creadoEn: new Date().toISOString(),
      perfil: perfil && { ...perfil, activo: true },
      asignacionesActivas: 0,
    }
    miembros = [nuevo, ...miembros]
    const otro = otrosUsuarios.find((u) => u.id === usuario.id)
    if (otro) otro.rol = 'voluntario'
    return { ...nuevo }
  }

  return api<MiembroOrganizacion>(`/organizaciones/${organizacionId}/voluntarios/${usuario.id}`, {
    method: 'POST',
    body: JSON.stringify({ perfil }),
  })
}

export async function cambiarActivoVoluntario(usuarioId: string, activo: boolean): Promise<MiembroOrganizacion> {
  if (USE_MOCK) {
    miembros = miembros.map((m) =>
      m.id === usuarioId
        ? { ...m, perfil: { disponibilidad: null, certificaciones: null, ...m.perfil, activo } }
        : m,
    )
    const miembro = miembros.find((m) => m.id === usuarioId)
    if (!miembro) throw new Error('Usuario no encontrado')
    return { ...miembro }
  }

  // BACKEND: actualiza perfiles_voluntario.activo (y crea el perfil si no existía).
  return api<MiembroOrganizacion>(`/voluntarios/${usuarioId}/perfil`, {
    method: 'PATCH',
    body: JSON.stringify({ activo }),
  })
}
