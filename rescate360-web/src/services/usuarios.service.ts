import { api, consulta, USE_MOCK, type Pagina } from './api'
import type { UsuarioSistema, DatosUsuarioNuevo, CambiosUsuario, Invitacion } from '../types/usuarioSistema'

// Datos de prueba inventados, SOLO para desarrollo de la interfaz (VITE_USE_MOCK=true).
const usuarioMock = (n: number, nombre: string, rol: UsuarioSistema['rol'], estado: UsuarioSistema['estado'], acceso: string | null): UsuarioSistema => ({
  id: String(n),
  codigo: `USR-${String(n).padStart(3, '0')}`,
  nombre,
  email: `${nombre.split(' ')[0].toLowerCase()}@demo.com`,
  telefono: null,
  rol,
  estado,
  organizacion_id: rol === 'ciudadano' ? null : 'org-1',
  ultimo_acceso: acceso,
  creado_en: '2026-10-01T00:00:00',
})

let mock: UsuarioSistema[] = [
  { ...usuarioMock(1, 'Admin Demo', 'administrador', 'activo', '2026-10-07T10:24:00'), email: 'admin@demo.com' },
  usuarioMock(2, 'Marta Salcedo', 'voluntario', 'activo', '2026-10-07T09:12:00'),
  usuarioMock(3, 'Carlos Peñaranda', 'voluntario', 'activo', '2026-10-06T18:56:00'),
  usuarioMock(4, 'Laura Mejía', 'voluntario', 'activo', '2026-10-05T16:30:00'),
  usuarioMock(5, 'Andrés Ceballos', 'voluntario', 'en_espera', null),
  usuarioMock(6, 'Jorge Castellanos', 'voluntario', 'bloqueado', '2026-09-28T11:40:00'),
  usuarioMock(7, 'Samuel Ortega', 'voluntario', 'activo', '2026-10-07T07:50:00'),
]

const invitacionMock = (usuario: UsuarioSistema): Invitacion => ({
  usuario,
  codigo_activacion: 'DEMO-2345',
  vence_en: new Date(Date.now() + 72 * 3600 * 1000).toISOString(),
})

// El backend pagina; el panel filtra y pagina en el navegador, así que trae la página más grande.
// Cuando haya más de 100 usuarios, conviene pasar la búsqueda y la paginación al backend (?q=, ?pagina=).
export async function listarUsuarios(): Promise<UsuarioSistema[]> {
  if (USE_MOCK) return mock.map((u) => ({ ...u }))
  const pagina = await api<Pagina<UsuarioSistema>>(`/usuarios${consulta({ por_pagina: 100 })}`)
  return pagina.items
}

// El administrador invita voluntarios de su organización; el super admin elige la organización.
export async function crearUsuario(datos: DatosUsuarioNuevo): Promise<Invitacion> {
  if (USE_MOCK) {
    const nuevo = { ...usuarioMock(mock.length + 1, datos.nombre, 'voluntario', 'en_espera', null), email: datos.email }
    mock = [...mock, nuevo]
    return invitacionMock(nuevo)
  }
  return api<Invitacion>('/usuarios', { method: 'POST', body: JSON.stringify(datos) })
}

export async function actualizarUsuario(id: string, cambios: CambiosUsuario): Promise<UsuarioSistema> {
  if (USE_MOCK) {
    mock = mock.map((u) => (u.id === id ? { ...u, ...cambios } : u))
    const usuario = mock.find((u) => u.id === id)
    if (!usuario) throw new Error('Usuario no encontrado')
    return { ...usuario }
  }
  return api<UsuarioSistema>(`/usuarios/${id}`, { method: 'PATCH', body: JSON.stringify(cambios) })
}

// Para quien no alcanzó a activar su cuenta: el código anterior deja de servir
export async function regenerarCodigo(id: string): Promise<Invitacion> {
  if (USE_MOCK) {
    const usuario = mock.find((u) => u.id === id)
    if (!usuario) throw new Error('Usuario no encontrado')
    return invitacionMock(usuario)
  }
  return api<Invitacion>(`/usuarios/${id}/codigo-activacion`, { method: 'POST' })
}
