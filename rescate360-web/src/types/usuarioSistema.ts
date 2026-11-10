import type { EstadoUsuario, Usuario } from './auth'

export type { EstadoUsuario } from './auth'

// El mismo UsuarioOut del backend: el panel lista y gestiona usuarios con esa forma
export type UsuarioSistema = Usuario

export interface DatosUsuarioNuevo {
  nombre: string
  email: string
  telefono?: string
  // Solo el super admin la envía: el administrador siempre invita a su propia organización
  organizacion_id?: string
}

// InvitacionOut: el código se muestra UNA sola vez (en la BD solo queda su hash)
export interface Invitacion {
  usuario: UsuarioSistema
  codigo_activacion: string
  vence_en: string
}

export type CambiosUsuario = Partial<{ nombre: string; email: string; telefono: string; estado: EstadoUsuario }>
