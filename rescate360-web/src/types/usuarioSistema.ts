import type { Rol } from './auth'

export type RolGestionable = Exclude<Rol, 'super_admin'>
export type EstadoUsuario = 'activo' | 'en_espera' | 'bloqueado'

export interface UsuarioSistema {
  id: string
  codigo: string // por ejemplo USR-001
  nombre: string
  email: string
  rol: RolGestionable
  estado: EstadoUsuario
  ultimoAcceso: string | null // formato ISO, null si nunca ha ingresado
}

export interface DatosUsuarioNuevo {
  nombre: string
  email: string
}

export type CambiosUsuario = Partial<Pick<UsuarioSistema, 'nombre' | 'email' | 'estado'>>