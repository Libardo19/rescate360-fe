// Roles que devuelve el backend (confirmar nombres exactos con el equipo de backend)
export type Rol = 'ciudadano' | 'voluntario' | 'administrador' | 'super_admin'

export interface Usuario {
  id: string
  nombre: string
  email: string
  rol: Rol
  organizacion_id?: string | null
}

export interface LoginRequest {
  email: string
  password: string
}

export interface LoginResponse {
  token: string
  usuario: Usuario
}