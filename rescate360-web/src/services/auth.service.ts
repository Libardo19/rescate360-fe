import { api, USE_MOCK } from './api'
import type { LoginRequest, LoginResponse, Usuario } from '../types/auth'

// Usuarios de prueba, SOLO para desarrollo de la interfaz.
const MOCK: Record<string, Usuario> = {
  'admin@demo.com': { id: '1', nombre: 'Admin Demo', email: 'admin@demo.com', rol: 'administrador', organizacion_id: 'org-1' },
  'super@demo.com': { id: '2', nombre: 'Super Admin Demo', email: 'super@demo.com', rol: 'super_admin' },
  'ciudadano@demo.com': { id: '3', nombre: 'Ciudadano Demo', email: 'ciudadano@demo.com', rol: 'ciudadano' },
}

export async function login(datos: LoginRequest): Promise<LoginResponse> {
  if (USE_MOCK) {
    const usuario = MOCK[datos.email]
    if (!usuario || datos.password !== '12345678') {
      throw new Error('Credenciales incorrectas')
    }
    return { token: 'token-de-prueba', usuario }
  }

  // BACKEND: confirmar la ruta y los campos reales del login.
  return api<LoginResponse>('/auth/login', {
    method: 'POST',
    body: JSON.stringify(datos),
  })
}

export async function logout(): Promise<void> {
  if (USE_MOCK) return
  // BACKEND: si existe endpoint de cierre de sesión, llamarlo aquí.
}