import type { Rol } from './auth'

// Tabla `perfiles_voluntario` (opcional, 1:1 con usuarios).
export interface PerfilVoluntario {
  disponibilidad: string | null
  certificaciones: string | null
  activo: boolean
}

// Usuario de la organización del administrador (rol voluntario o administrador).
export interface MiembroOrganizacion {
  id: string
  nombre: string
  correo: string
  telefono: string | null
  rol: Extract<Rol, 'voluntario' | 'administrador'>
  creadoEn: string // formato ISO
  perfil: PerfilVoluntario | null // solo voluntarios, y solo si se creó el perfil
  asignacionesActivas: number // filas de `asignaciones` con estado 'activa'
}

// Resultado de buscar a un usuario por correo para reclutarlo como voluntario.
export interface UsuarioEncontrado {
  id: string
  nombre: string
  correo: string
  rol: Rol
}

export type DatosPerfilVoluntario = Pick<PerfilVoluntario, 'disponibilidad' | 'certificaciones'>
