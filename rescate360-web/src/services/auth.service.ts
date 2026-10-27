import { api, ApiError, USE_MOCK } from './api'
import type { CanalRecuperacion, LoginRequest, LoginResponse, Usuario } from '../types/auth'

const base = { telefono: null, estado: 'activo', ultimo_acceso: null, creado_en: '2026-10-01T00:00:00' } as const

// Usuarios de prueba, SOLO para desarrollo de la interfaz (VITE_USE_MOCK=true).
const MOCK: Record<string, Usuario> = {
  'admin@demo.com': { ...base, id: '1', codigo: 'USR-001', nombre: 'Admin Demo', email: 'admin@demo.com', rol: 'administrador', organizacion_id: 'org-1' },
  'super@demo.com': { ...base, id: '2', codigo: 'USR-002', nombre: 'Super Admin Demo', email: 'super@demo.com', rol: 'super_admin', organizacion_id: null },
  'ciudadano@demo.com': { ...base, id: '3', codigo: 'USR-003', nombre: 'Ciudadano Demo', email: 'ciudadano@demo.com', rol: 'ciudadano', organizacion_id: null },
}

export async function login(datos: LoginRequest): Promise<LoginResponse> {
  if (USE_MOCK) {
    const usuario = MOCK[datos.email]
    if (!usuario || datos.password !== '12345678') {
      throw new ApiError(401, 'Correo o contraseña incorrectos', 'CREDENCIALES_INVALIDAS')
    }
    return { access_token: 'token-de-prueba', refresh_token: 'refresh-de-prueba', token_type: 'bearer', usuario }
  }
  return api<LoginResponse>('/auth/login', { method: 'POST', body: JSON.stringify(datos) })
}

// El backend no guarda sesiones (JWT): cerrar sesión es borrar los tokens del navegador.

export async function pedirCodigoRecuperacion(email: string, canal: CanalRecuperacion): Promise<string> {
  if (USE_MOCK) return 'Si la cuenta existe, te enviamos un código.'
  const r = await api<{ detalle: string }>('/auth/recuperar', { method: 'POST', body: JSON.stringify({ email, canal }) })
  return r.detalle
}

export async function restablecerContrasena(email: string, codigo: string, password: string): Promise<LoginResponse> {
  if (USE_MOCK) throw new ApiError(422, 'No disponible con datos de prueba', 'MOCK')
  return api<LoginResponse>('/auth/restablecer', { method: 'POST', body: JSON.stringify({ email, codigo, password }) })
}
