import { api, consulta, USE_MOCK, type Pagina } from './api'
import type { CambiosOrganizacion, DatosOrganizacion, Organizacion } from '../types/organizacion'
import type { DatosUsuarioNuevo, Invitacion, UsuarioSistema } from '../types/usuarioSistema'

// Datos de prueba, SOLO para desarrollo de la interfaz (VITE_USE_MOCK=true).
let mock: Organizacion[] = [
  { id: 'org-1', nombre: 'Cruz Roja Valledupar', tipo: 'cruz_roja', telefono_contacto: '+576055700000', activa: true, creado_en: '2026-10-01T00:00:00' },
  { id: 'org-2', nombre: 'Bomberos Aguachica', tipo: 'bomberos', telefono_contacto: null, activa: true, creado_en: '2026-10-02T00:00:00' },
]

// El super admin ve todas; el administrador y el voluntario, solo la suya
export async function listarOrganizaciones(): Promise<Organizacion[]> {
  if (USE_MOCK) return mock.map((o) => ({ ...o }))
  return (await api<Pagina<Organizacion>>(`/organizaciones${consulta({ por_pagina: 100 })}`)).items
}

export async function crearOrganizacion(datos: DatosOrganizacion): Promise<Organizacion> {
  if (USE_MOCK) {
    const nueva: Organizacion = { ...datos, id: `org-${Date.now()}`, telefono_contacto: datos.telefono_contacto ?? null, activa: true, creado_en: new Date().toISOString() }
    mock = [...mock, nueva]
    return nueva
  }
  return api<Organizacion>('/organizaciones', { method: 'POST', body: JSON.stringify(datos) })
}

// activa=false deja sin acceso a toda su gente (el backend responde ORGANIZACION_INACTIVA)
export async function actualizarOrganizacion(id: string, cambios: CambiosOrganizacion): Promise<Organizacion> {
  if (USE_MOCK) {
    mock = mock.map((o) => (o.id === id ? { ...o, ...cambios } : o))
    return { ...mock.find((o) => o.id === id)! }
  }
  return api<Organizacion>(`/organizaciones/${id}`, { method: 'PATCH', body: JSON.stringify(cambios) })
}

export async function listarAdministradores(organizacionId: string): Promise<UsuarioSistema[]> {
  if (USE_MOCK) return []
  return (await api<Pagina<UsuarioSistema>>(`/organizaciones/${organizacionId}/administradores${consulta({ por_pagina: 100 })}`)).items
}

export async function invitarAdministrador(organizacionId: string, datos: DatosUsuarioNuevo): Promise<Invitacion> {
  return api<Invitacion>(`/organizaciones/${organizacionId}/administradores`, { method: 'POST', body: JSON.stringify(datos) })
}

// Revocar = bloquear la cuenta del administrador
export async function revocarAdministrador(organizacionId: string, usuarioId: string): Promise<UsuarioSistema> {
  return api<UsuarioSistema>(`/organizaciones/${organizacionId}/administradores/${usuarioId}`, { method: 'DELETE' })
}
