// Roles que devuelve el backend
export type Rol = 'ciudadano' | 'voluntario' | 'administrador' | 'super_admin'

export type EstadoUsuario = 'activo' | 'en_espera' | 'bloqueado'

// UsuarioOut del backend (snake_case, igual que la API)
export interface Usuario {
  id: string
  codigo: string
  nombre: string
  email: string
  telefono: string | null
  rol: Rol
  estado: EstadoUsuario
  organizacion_id: string | null
  ultimo_acceso: string | null
  creado_en: string
}

export interface LoginRequest {
  email: string
  password: string
}

// SesionOut del backend
export interface LoginResponse {
  access_token: string
  refresh_token: string
  token_type: string
  usuario: Usuario
}

export type CanalRecuperacion = 'sms' | 'correo'
