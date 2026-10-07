import { api, USE_MOCK } from './api'
import type { UsuarioSistema, DatosUsuarioNuevo, CambiosUsuario } from '../types/usuarioSistema'

// Datos de prueba inventados, SOLO para desarrollo de la interfaz.
// El primero coincide con el usuario de prueba del login (admin@demo.com).
let mock: UsuarioSistema[] = [
  { id: '1', codigo: 'USR-001', nombre: 'Admin Demo', email: 'admin@demo.com', rol: 'administrador', estado: 'activo', ultimoAcceso: '2026-10-07T10:24:00' },
  { id: '2', codigo: 'USR-002', nombre: 'Marta Salcedo', email: 'marta@demo.com', rol: 'voluntario', estado: 'activo', ultimoAcceso: '2026-10-07T09:12:00' },
  { id: '3', codigo: 'USR-003', nombre: 'Carlos Peñaranda', email: 'carlos@demo.com', rol: 'voluntario', estado: 'activo', ultimoAcceso: '2026-10-06T18:56:00' },
  { id: '4', codigo: 'USR-004', nombre: 'Laura Mejía', email: 'laura@demo.com', rol: 'voluntario', estado: 'activo', ultimoAcceso: '2026-10-05T16:30:00' },
  { id: '5', codigo: 'USR-005', nombre: 'Andrés Ceballos', email: 'andres@demo.com', rol: 'voluntario', estado: 'en_espera', ultimoAcceso: null },
  { id: '6', codigo: 'USR-006', nombre: 'Daniela Torres', email: 'daniela@demo.com', rol: 'ciudadano', estado: 'activo', ultimoAcceso: '2026-10-04T15:03:00' },
  { id: '7', codigo: 'USR-007', nombre: 'Jorge Castellanos', email: 'jorge@demo.com', rol: 'voluntario', estado: 'bloqueado', ultimoAcceso: '2026-09-28T11:40:00' },
  { id: '8', codigo: 'USR-008', nombre: 'Paola Rincón', email: 'paola@demo.com', rol: 'ciudadano', estado: 'activo', ultimoAcceso: '2026-10-06T08:15:00' },
  { id: '9', codigo: 'USR-009', nombre: 'Samuel Ortega', email: 'samuel@demo.com', rol: 'voluntario', estado: 'activo', ultimoAcceso: '2026-10-07T07:50:00' },
  { id: '10', codigo: 'USR-010', nombre: 'Valentina Ruiz', email: 'valentina@demo.com', rol: 'ciudadano', estado: 'en_espera', ultimoAcceso: null },
  { id: '11', codigo: 'USR-011', nombre: 'Esteban Lozano', email: 'esteban@demo.com', rol: 'voluntario', estado: 'activo', ultimoAcceso: '2026-10-03T19:22:00' },
  { id: '12', codigo: 'USR-012', nombre: 'Natalia Bermúdez', email: 'natalia@demo.com', rol: 'ciudadano', estado: 'activo', ultimoAcceso: '2026-10-02T12:10:00' },
  { id: '13', codigo: 'USR-013', nombre: 'Ricardo Maestre', email: 'ricardo@demo.com', rol: 'voluntario', estado: 'activo', ultimoAcceso: '2026-10-06T14:45:00' },
  { id: '14', codigo: 'USR-014', nombre: 'Isabela Cano', email: 'isabela@demo.com', rol: 'ciudadano', estado: 'bloqueado', ultimoAcceso: '2026-09-20T09:00:00' },
]

export async function listarUsuarios(): Promise<UsuarioSistema[]> {
  if (USE_MOCK) return mock.map((u) => ({ ...u }))

  // BACKEND: confirmar la ruta real, la paginación (hoy se pagina en el navegador)
  // y qué usuarios puede ver el administrador.
  return api<UsuarioSistema[]>('/admin/usuarios')
}

// El administrador solo crea voluntarios de su organización.
export async function crearUsuario(datos: DatosUsuarioNuevo): Promise<UsuarioSistema> {
  if (USE_MOCK) {
    const numero = mock.length + 1
    const nuevo: UsuarioSistema = {
      ...datos,
      id: String(Date.now()),
      codigo: `USR-${String(numero).padStart(3, '0')}`,
      rol: 'voluntario',
      estado: 'en_espera', // queda en espera hasta que active su cuenta
      ultimoAcceso: null,
    }
    mock = [...mock, nuevo]
    return { ...nuevo }
  }

  // BACKEND: crear el voluntario y enviarle la invitación para activar su cuenta.
  return api<UsuarioSistema>('/admin/usuarios', { method: 'POST', body: JSON.stringify(datos) })
}

export async function actualizarUsuario(id: string, cambios: CambiosUsuario): Promise<UsuarioSistema> {
  if (USE_MOCK) {
    mock = mock.map((u) => (u.id === id ? { ...u, ...cambios } : u))
    const usuario = mock.find((u) => u.id === id)
    if (!usuario) throw new Error('Usuario no encontrado')
    return { ...usuario }
  }

  // BACKEND: editar datos y bloquear o desbloquear (estado).
  return api<UsuarioSistema>(`/admin/usuarios/${id}`, { method: 'PATCH', body: JSON.stringify(cambios) })
}